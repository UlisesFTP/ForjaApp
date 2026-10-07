import 'dart:async';
import 'dart:math';

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
import 'package:forja_app/domain/services/plan_generator.dart';
import 'package:forja_app/domain/services/progression_engine.dart';
import 'package:forja_app/ui/coach/view_models/coach_inputs_builder.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// Tuesday 6 Oct 2026 (a training day of the example plan), noon.
final _tuesday = DateTime(2026, 10, 6, 12);

Future<AppDependencies> _deps(DateTime now, {UserProfile? profile}) async {
  final d = await AppDependencies.create(
    store: MemoryForjaStore(),
    launcher: _Launcher(),
    clock: () => now,
  );
  if (profile != null) await d.repository.saveProfile(profile);
  return d;
}

/// A generated plan: the example routines with every exercise at [rir].
PlanVersion _generated({int rir = 3}) => PlanVersion(
  id: 'gen',
  status: PlanStatus.draft,
  source: PlanSource.generated,
  name: 'Generado',
  createdAt: DateTime.utc(2026, 10, 1),
  days: [
    for (final day in legacyTemplatePlan.days)
      PlanDay(
        day.weekday,
        Routine(
          id: 'g-${day.routine.id}',
          name: day.routine.name,
          focus: day.routine.focus,
          warmup: day.routine.warmup,
          exercises: [
            for (final e in day.routine.exercises) e.copyWith(rir: rir),
          ],
        ),
      ),
  ],
);

Future<void> _sets(
  AppDependencies d,
  DateTime day,
  String id, {
  required int sets,
  required int reps,
  required int rir,
}) async {
  for (var i = 0; i < sets; i++) {
    await d.repository.addSet(
      day,
      id,
      SetEntry(weightKg: 40, reps: reps, rir: rir),
    );
  }
  await d.repository.setTechnique(day, id, TechniqueRating.solid);
  await d.repository.toggleExercise(day, id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('D41a · prog-v2 compares the example plan as Hoy shows it', () {
    test(
      'a beginner who did the 2 sets with 3 in reserve gets the increase',
      () async {
        final d = await _deps(
          _tuesday,
          profile: const UserProfile(experience: Experience.beginner),
        );
        addTearDown(() => unawaited(d.dispose()));
        for (final day in [DateTime(2026, 9, 29), DateTime(2026, 10, 6)]) {
          await _sets(d, day, 'squat', sets: 2, reps: 8, rir: 3);
        }
        final s = d.progression.suggestion('squat');
        expect(s.kind, ProgressionKind.increase, reason: s.explanation);
        expect(progressionRulesVersion, 'prog-v2');
      },
    );

    test('a muscle goal on the example plan needs 12 reps, as shown', () async {
      final d = await _deps(
        _tuesday,
        profile: const UserProfile(goal: TrainingGoal.muscle),
      );
      addTearDown(() => unawaited(d.dispose()));
      for (final day in [DateTime(2026, 9, 29), DateTime(2026, 10, 6)]) {
        await _sets(d, day, 'squat', sets: 4, reps: 8, rir: 2);
      }
      expect(d.progression.suggestion('squat').kind, ProgressionKind.hold);
      final d2 = await _deps(
        _tuesday,
        profile: const UserProfile(goal: TrainingGoal.muscle),
      );
      addTearDown(() => unawaited(d2.dispose()));
      for (final day in [DateTime(2026, 9, 29), DateTime(2026, 10, 6)]) {
        await _sets(d2, day, 'squat', sets: 4, reps: 12, rir: 2);
      }
      expect(d2.progression.suggestion('squat').kind, ProgressionKind.increase);
    });

    test('a decision taken under prog-v1 still stands, and no second one is '
        'recorded', () async {
      final d = await _deps(_tuesday);
      addTearDown(() => unawaited(d.dispose()));
      for (final day in [DateTime(2026, 9, 29), DateTime(2026, 10, 6)]) {
        await _sets(d, day, 'squat', sets: 4, reps: 8, rir: 2);
      }
      await d.repository.decideProgression(
        exerciseId: 'squat',
        kind: ProgressionKind.increase,
        basedOn: '2026-10-06',
        ruleVersion: 'prog-v1',
        status: DecisionStatus.rejected,
      );
      final s = d.progression.suggestion('squat');
      expect(d.progression.decisionFor(s)?.ruleVersion, 'prog-v1');
      expect(await d.progression.accept(s), isTrue);
      expect(d.repository.progressionDecisions, hasLength(1));
      expect(d.repository.workingWeight('squat'), isNull);
    });
  });

  group('D41b · no double adjustment for a low energy', () {
    Future<AppDependencies> generated({
      required Energy energy,
      int rir = 3,
    }) async {
      final d = await _deps(_tuesday, profile: UserProfile(energy: energy));
      await d.repository.saveDraft(_generated(rir: rir));
      await d.repository.acceptDraft(_tuesday);
      return d;
    }

    test('a generated plan already at RIR 3 is not lightened again for the '
        'habitual energy', () async {
      final d = await generated(energy: Energy.low);
      addTearDown(() => unawaited(d.dispose()));
      expect(d.today.routine, isNotNull);
      expect(d.today.adjustmentProposed, isFalse);
      expect(d.today.recommendation, isNull);
      // Tiredness today still proposes it.
      await d.repository.saveCheckIn(
        _tuesday,
        const CheckIn(feeling: Feeling.tired),
      );
      expect(d.today.adjustmentProposed, isTrue);
      expect(d.today.recommendation, contains('Intensidad ajustada'));
    });

    test('a generated plan that is not lighter, or the example plan, still '
        'proposes it', () async {
      final notLight = await generated(energy: Energy.low, rir: 2);
      addTearDown(() => unawaited(notLight.dispose()));
      expect(notLight.today.adjustmentProposed, isTrue);
      final example = await _deps(
        _tuesday,
        profile: const UserProfile(energy: Energy.low),
      );
      addTearDown(() => unawaited(example.dispose()));
      expect(example.today.adjustmentProposed, isTrue);
    });
  });

  group('D41c · a recent injury holds an increase back on Progreso', () {
    testWidgets('the card says why and offers no Accept', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 2400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await _deps(_tuesday);
      addTearDown(() => unawaited(d.dispose()));
      for (final day in [DateTime(2026, 9, 29), DateTime(2026, 10, 6)]) {
        await _sets(d, day, 'squat', sets: 4, reps: 8, rir: 2);
      }
      await d.repository.saveCheckIn(
        DateTime(2026, 10, 3),
        const CheckIn(feeling: Feeling.injured),
        phase: CheckInPhase.after,
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 2400)),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.progress);
      await tester.pumpAndSettle();
      final s = d.progression.suggestion('squat');
      expect(s.kind, ProgressionKind.increase);
      expect(find.byKey(const ValueKey('accept-squat')), findsNothing);
      expect(find.byKey(const ValueKey('veto-squat')), findsOneWidget);
      expect(
        find.textContaining('Sin aumento: registraste una lesión'),
        findsOneWidget,
      );
      expect(await d.progression.accept(s), isFalse);
      expect(d.repository.progressionDecisions, isEmpty);
    });
  });

  group('D41d and D41e · Hoy', () {
    testWidgets('the routine shows its estimated length', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await _deps(_tuesday);
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 1600)),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      final minutes = PlanGenerator.routineMinutes(
        legacyTemplatePlan.routineOnWeekday(DateTime.tuesday)!,
        exerciseFor,
      );
      expect(d.today.routineMinutes, minutes);
      expect(find.textContaining('≈ $minutes min'), findsOneWidget);
      expect(find.textContaining('45–60 min'), findsNothing);
    });

    test('back after a break: what to do, until the session starts', () async {
      final d = await _deps(_tuesday);
      addTearDown(() => unawaited(d.dispose()));
      await _sets(d, DateTime(2026, 9, 26), 'row', sets: 3, reps: 10, rir: 2);
      // 10 days later, on a training day.
      expect(d.today.recommendation, startsWith('Llevas 10 días sin entrenar'));
      expect(d.today.recommendation, contains('mismas cargas'));
      await d.repository.addSet(
        _tuesday,
        'squat',
        const SetEntry(weightKg: 40, reps: 5, rir: 3),
      );
      expect(d.today.recommendation, isNull, reason: 'already back today');
      // A rest day says nothing about it.
      d.today.selectDate(DateTime(2026, 10, 7));
      expect(d.today.recommendation, isNull);
    });
  });

  test('Hoy and the minicoach say the same about today', () async {
    // Drawn before anything runs.
    final random = Random(41);
    final cases = [
      for (var i = 0; i < 60; i++)
        (
          Energy.values[random.nextInt(3)],
          [null, ...Feeling.values][random.nextInt(6)],
          random.nextInt(3),
          random.nextInt(30),
          [null, true, false][random.nextInt(3)],
          Experience.values[random.nextInt(3)],
        ),
    ];
    for (final (energy, feeling, plan, gap, adjustment, experience) in cases) {
      final d = await _deps(
        _tuesday,
        profile: UserProfile(energy: energy, experience: experience),
      );
      if (plan > 0) {
        await d.repository.saveDraft(_generated(rir: plan == 1 ? 3 : 2));
        await d.repository.acceptDraft(_tuesday);
      }
      final before = nextDay(_tuesday, -gap - 1);
      final routine = d.repository.routineOn(before);
      if (routine != null) {
        await d.repository.toggleExercise(
          before,
          routine.exercises.first.exerciseId,
        );
      }
      if (feeling != null) {
        await d.repository.saveCheckIn(_tuesday, CheckIn(feeling: feeling));
      }
      if (adjustment != null) {
        await d.repository.setAdjustment(_tuesday, adjustment);
      }
      final expert = ExpertCoach.evaluate(
        buildCoachInputs(
          today: _tuesday,
          workouts: d.repository,
          profiles: d.repository,
          plans: d.repository,
          progression: d.repository,
          catalog: d.repository,
        ),
      );
      expect(
        expert.todayLine,
        d.today.recommendation,
        reason: '$energy $feeling plan=$plan gap=$gap $adjustment',
      );
      expect(
        expert.recommendations.any(
          (r) => r.ruleId == 'readiness.lighter-session',
        ),
        d.today.adjustmentProposed,
      );
      unawaited(d.dispose());
    }
    expect(dateKey(_tuesday), '2026-10-06');
  });
}
