import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/coach/view_models/coach_advice_view_model.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// Monday 5 Oct 2026, noon: a rest day of the example plan.
var _now = DateTime(2026, 10, 5, 12);

Future<AppDependencies> _start(
  WidgetTester tester, {
  Size size = const Size(390, 2400),
  double scale = 1,
  UserProfile? profile,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final d = await AppDependencies.create(
    store: MemoryForjaStore(),
    launcher: _Launcher(),
    clock: () => _now,
  );
  addTearDown(() => unawaited(d.dispose()));
  if (profile != null) await d.repository.saveProfile(profile);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
      child: ForjaApp(dependencies: d, offerOnboarding: false),
    ),
  );
  await tester.pumpAndSettle();
  return d;
}

/// A full squat session at the top of its range.
Future<void> _squat(AppDependencies d, DateTime day) async {
  final planned = PlanExercise.fromExercise(exerciseFor('squat'));
  for (var i = 0; i < planned.sets; i++) {
    await d.repository.addSet(
      day,
      'squat',
      SetEntry(weightKg: 60, reps: planned.repsMax, rir: planned.rir),
    );
  }
  await d.repository.setTechnique(day, 'squat', TechniqueRating.solid);
  await d.repository.toggleExercise(day, 'squat');
}

Future<void> _openCoach(WidgetTester tester) async {
  await tester.tap(find.text('Minicoach'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => _now = DateTime(2026, 10, 5, 12));

  group('Coach page (F16)', () {
    testWidgets('opens from Hoy and from Más with the same label, and shows '
        'its sections', (tester) async {
      final d = await _start(tester);
      expect(find.text('Minicoach'), findsOneWidget);
      await _openCoach(tester);
      expect(find.text('MINICOACH'), findsOneWidget);
      for (final title in [
        'Hoy',
        'Sugerencias',
        'Perfil y revisión',
        'Cómo funciona',
      ]) {
        expect(find.text(title), findsWidgets, reason: title);
      }
      expect(find.textContaining('No es un diagnóstico'), findsOneWidget);
      // The example plan explains itself; there is nothing to do yet.
      expect(find.text('Usas el plan de ejemplo'), findsOneWidget);
      expect(find.textContaining('Sin sugerencias por ahora'), findsOneWidget);
      Navigator.of(tester.element(find.text('MINICOACH'))).pop();
      await tester.pumpAndSettle();
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minicoach'));
      await tester.pumpAndSettle();
      expect(find.text('MINICOACH'), findsOneWidget);
    });

    testWidgets('an increase can be accepted like on Progreso, once', (
      tester,
    ) async {
      final d = await _start(tester);
      await _squat(d, DateTime(2026, 9, 22));
      await _squat(d, DateTime(2026, 9, 29));
      await _openCoach(tester);
      expect(find.text('Sentadilla con barra: subir la carga'), findsOneWidget);
      final accept = find.byKey(
        const ValueKey('coach-accept-progression.prog|squat|2026-09-29'),
      );
      await tester.ensureVisible(accept);
      await tester.pumpAndSettle();
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(d.repository.workingWeight('squat'), 62.5);
      expect(
        d.repository.progressionDecisions.single.status,
        DecisionStatus.accepted,
      );
      expect(
        d.repository.coachDecisions.single.status,
        CoachDecisionStatus.accepted,
      );
      // Decided: it does not come back.
      expect(find.text('Sentadilla con barra: subir la carga'), findsNothing);
    });

    testWidgets('"Por qué" shows the facts, rule, version and evidence', (
      tester,
    ) async {
      final d = await _start(tester);
      await _squat(d, DateTime(2026, 9, 22));
      await _squat(d, DateTime(2026, 9, 29));
      await _openCoach(tester);
      final why = find.byKey(
        const ValueKey('coach-why-progression.prog|squat|2026-09-29'),
      );
      await tester.ensureVisible(why);
      await tester.pumpAndSettle();
      await tester.tap(why);
      await tester.pumpAndSettle();
      expect(find.text('En qué se basa'), findsOneWidget);
      expect(find.textContaining('22 sep · Sesión usada'), findsOneWidget);
      expect(find.text('progression.prog · expert-v1'), findsOneWidget);
      expect(find.textContaining('Heurística:'), findsOneWidget);
      expect(
        find.textContaining('progression.prog → recommendation'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Cerrar Por qué'));
      await tester.pumpAndSettle();
      expect(find.text('En qué se basa'), findsNothing);
      expect(
        d.repository.coachDecisions,
        isEmpty,
        reason: 'looking saves nothing',
      );
    });

    testWidgets('"Ahora no" hides it for its cooldown, then it comes back', (
      tester,
    ) async {
      final d = await _start(tester);
      await _squat(d, DateTime(2026, 9, 22));
      await _squat(d, DateTime(2026, 9, 29));
      final vm = d.createCoachAdvice();
      addTearDown(vm.dispose);
      final r = vm.suggestions.firstWhere(
        (x) => x.ruleId == 'progression.prog',
      );
      expect(await vm.dismiss(r), isTrue);
      bool offered() =>
          vm.suggestions.any((x) => x.ruleId == 'progression.prog');
      expect(offered(), isFalse);
      expect(d.repository.workingWeight('squat'), isNull);
      _now = DateTime(2026, 10, 18, 12);
      expect(offered(), isFalse, reason: '13 of 14 days');
      _now = DateTime(2026, 10, 19, 12);
      // A new day: evaluated again; the old pair is now 20 days old.
      expect(offered(), isTrue);
    });

    testWidgets('a family can be silenced, but not safety', (tester) async {
      final d = await _start(tester, profile: const UserProfile(weightKg: 80));
      await d.repository.addFood(
        const FoodEntry(
          id: 'f',
          dateKey: '2026-10-04',
          name: 'Pan',
          calories: 200,
        ),
      );
      await _openCoach(tester);
      expect(find.text('Referencia general de proteína'), findsOneWidget);
      final toggle = find.byKey(const ValueKey('coach-family-nutrition'));
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(d.repository.coachPreferences.map((p) => p.family), ['nutrition']);
      expect(find.text('Referencia general de proteína'), findsNothing);
      expect(d.repository.coachPreferences.single.muted, isTrue);
      expect(find.byKey(const ValueKey('coach-family-safety')), findsNothing);
    });

    testWidgets('an injury: today first, and an increase held back without '
        'Accept', (tester) async {
      final d = await _start(tester);
      await _squat(d, DateTime(2026, 9, 22));
      await _squat(d, DateTime(2026, 9, 29));
      await d.repository.saveCheckIn(
        DateTime(2026, 10, 3),
        const CheckIn(feeling: Feeling.injured),
        phase: CheckInPhase.after,
      );
      await _openCoach(tester);
      expect(find.text('Lesión reciente'), findsOneWidget);
      expect(
        find.textContaining('Sin aumento: registraste una lesión'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('coach-accept-progression.prog|squat|2026-09-29'),
        ),
        findsNothing,
      );
    });

    testWidgets('an action opens the existing screen: a day to mark', (
      tester,
    ) async {
      final d = await _start(tester);
      // Started on 22 Sep; Tuesday 29 and later have nothing recorded.
      await _squat(d, DateTime(2026, 9, 22));
      await _openCoach(tester);
      final open = find.byKey(
        const ValueKey(
          'coach-accept-adherence.unrecorded|2026-10-03|2026-10-03',
        ),
      );
      await tester.ensureVisible(open);
      await tester.pumpAndSettle();
      await tester.tap(open);
      await tester.pumpAndSettle();
      expect(find.text('MINICOACH'), findsNothing);
      expect(d.shell.page, AppPage.today);
      expect(dateKey(d.today.selectedDate), '2026-10-03');
    });

    testWidgets('Plan opens the plan review', (tester) async {
      final d = await _start(
        tester,
        profile: const UserProfile(onboarded: true, sessionMinutes: 20),
      );
      d.shell.open(AppPage.plan);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('plan-review')));
      await tester.pumpAndSettle();
      expect(find.text('REVISIÓN DEL PLAN'), findsOneWidget);
      expect(find.textContaining('sesión larga'), findsWidgets);
      expect(find.text('Lesión reciente'), findsNothing);
    });

    testWidgets('it is computed only while open', (tester) async {
      final d = await _start(tester);
      final vm = d.createCoachAdvice();
      addTearDown(vm.dispose);
      expect(vm.evaluations, 0, reason: 'nothing until something asks');
      vm.suggestions;
      vm.notes;
      expect(vm.evaluations, 1, reason: 'one evaluation, reused');
      await d.repository.saveCheckIn(
        DateTime(2026, 10, 5),
        const CheckIn(feeling: Feeling.tired),
      );
      vm.notes;
      expect(vm.evaluations, 2, reason: 'new data, new evaluation');
    });

    for (final (name, size, scale) in [
      ('390×844', const Size(390, 844), 1.0),
      ('320 px at 200 %', const Size(320, 900), 2.0),
      ('landscape with the rail', const Size(844, 390), 1.0),
      ('tablet', const Size(1024, 1366), 1.0),
    ]) {
      testWidgets('fits $name without overflow', (tester) async {
        final d = await _start(tester, size: size, scale: scale);
        await _squat(d, DateTime(2026, 9, 22));
        await _squat(d, DateTime(2026, 9, 29));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Minicoach'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Minicoach'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('MINICOACH'), findsOneWidget);
        final handle = tester.ensureSemantics();
        await tester.pump();
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });

  testWidgets('regression (F15): the top bar fits a streak count at 320 px '
      'and 200 % text', (tester) async {
    final d = await _start(tester, size: const Size(320, 900), scale: 2);
    // Tuesday, Thursday and Saturday of the example plan, all trained.
    for (final (day, id) in [
      (DateTime(2026, 9, 29), 'squat'),
      (DateTime(2026, 10, 1), 'bench'),
      (DateTime(2026, 10, 3), 'row'),
    ]) {
      await d.repository.toggleExercise(day, id);
    }
    await tester.pumpAndSettle();
    expect(d.streak.current, 3);
    expect(tester.takeException(), isNull);
    expect(find.text('FORJA'), findsOneWidget);
  });

  test('the ViewModel lists suggestions, notes and today apart', () async {
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      clock: () => _now,
    );
    addTearDown(() => unawaited(d.dispose()));
    await d.repository.saveCheckIn(
      DateTime(2026, 10, 5),
      const CheckIn(feeling: Feeling.injured),
    );
    final vm = CoachAdviceViewModel(
      workouts: d.repository,
      profiles: d.repository,
      plans: d.repository,
      progression: d.repository,
      catalog: d.repository,
      coach: d.repository,
      clock: () => _now,
    );
    addTearDown(vm.dispose);
    expect(vm.forToday.map((r) => r.ruleId), contains('safety.injury-today'));
    expect(
      vm.notes.map((r) => r.family),
      everyElement(isNot(RuleFamily.safety)),
    );
    expect(vm.muted(RuleFamily.safety), isFalse);
  });
}
