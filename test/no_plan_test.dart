import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/backup/backup_codec.dart';
import 'package:forja_app/data/database/forja_database.dart'
    show currentSchemaVersion;
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

final _now = DateTime(2026, 10, 7, 12); // a Wednesday

PlanExercise _p(String id, int sets, int min, int max) => PlanExercise(
  exerciseId: id,
  sets: sets,
  repsMin: min,
  repsMax: max,
  rir: 3,
  restSeconds: 90,
);

/// A four-day plan like the one the person asked for (D45).
PlanVersion fourDays(String id) => PlanVersion(
  id: id,
  status: PlanStatus.draft,
  source: PlanSource.manual,
  name: 'Rutina 4 días',
  createdAt: DateTime.utc(2026, 10, 7),
  days: [
    PlanDay(
      DateTime.monday,
      Routine(
        id: '$id-a',
        name: 'Torso A',
        focus: '',
        warmup: '5–10 min',
        exercises: [_p('chestpress', 3, 8, 12), _p('pulldown', 3, 8, 12)],
      ),
    ),
    PlanDay(
      DateTime.wednesday,
      Routine(
        id: '$id-b',
        name: 'Pierna A',
        focus: '',
        warmup: '5–10 min',
        exercises: [_p('press', 3, 8, 12), _p('legcurl', 3, 10, 15)],
      ),
    ),
    PlanDay(
      DateTime.thursday,
      Routine(
        id: '$id-c',
        name: 'Torso B',
        focus: '',
        warmup: '5–10 min',
        exercises: [_p('inclinedb', 3, 8, 12), _p('chestrow', 3, 8, 12)],
      ),
    ),
    PlanDay(
      DateTime.saturday,
      Routine(
        id: '$id-d',
        name: 'Pierna B',
        focus: '',
        warmup: '5–10 min',
        exercises: [_p('press', 3, 8, 12), _p('calf', 3, 10, 15)],
      ),
    ),
  ],
);

void main() {
  // These tests check the real start: no plan (the rest of the suite keeps
  // the old template, see flutter_test_config.dart).
  late PlanVersion? previous;
  setUp(() {
    previous = LocalForjaRepository.debugStartingPlan;
    LocalForjaRepository.debugStartingPlan = null;
  });
  tearDown(() => LocalForjaRepository.debugStartingPlan = previous);

  Future<AppDependencies> deps([AppSnapshot? snapshot]) async {
    final d = await AppDependencies.create(
      store: MemoryForjaStore(snapshot),
      launcher: _Launcher(),
      clock: () => _now,
    );
    addTearDown(() => unawaited(d.dispose()));
    return d;
  }

  group('a new install starts without a plan (D45)', () {
    test('no day is a training day and nothing is scheduled', () async {
      final d = await deps();
      for (var i = -30; i < 60; i++) {
        final day = _now.add(Duration(days: i));
        expect(d.repository.planFor(day).source, PlanSource.none);
        expect(d.repository.routineOn(day), isNull);
      }
      expect(d.repository.plans, isEmpty);
      expect(d.plan.noPlanToday, isTrue);
      expect(d.today.withoutPlan, isTrue);
      expect(d.today.nextRoutine, isNull);
    });

    test('an install that trained with the old template keeps it up to its '
        'last session, so its history does not change', () async {
      final legs = legacyTemplatePlan.routines.first;
      final d = await deps(
        AppSnapshot(
          sessions: {
            '2026-09-29': WorkoutSession(
              dateKey: '2026-09-29',
              routineId: legs.id,
              exercises: [
                for (final e in legs.exercises)
                  ExerciseLog(exerciseId: e.exerciseId, weightKg: 20),
              ],
            ),
          },
        ),
      );
      expect(
        d.repository.planFor(DateTime(2026, 9, 29)).id,
        legacyTemplatePlan.id,
      );
      expect(d.repository.routineOn(DateTime(2026, 9, 29))?.id, legs.id);
      // Earlier days keep it too; after the last one, no template.
      expect(
        d.repository.planFor(DateTime(2026, 9, 24)).id,
        legacyTemplatePlan.id,
      );
      expect(
        d.repository.planFor(DateTime(2026, 9, 30)).source,
        PlanSource.none,
      );
      expect(d.repository.routineOn(DateTime(2026, 10, 8)), isNull);
      expect(d.today.withoutPlan, isTrue);
    });

    test('a plan of four days is accepted from a future Monday; until then '
        'nothing is planned', () async {
      final d = await deps();
      await d.repository.saveDraft(fourDays('mine'));
      await d.repository.acceptDraft(DateTime(2026, 10, 12));
      expect(d.repository.routineOn(DateTime(2026, 10, 8)), isNull);
      expect(d.repository.routineOn(DateTime(2026, 10, 12))?.name, 'Torso A');
      expect(d.repository.routineOn(DateTime(2026, 10, 14))?.name, 'Pierna A');
      expect(d.repository.routineOn(DateTime(2026, 10, 15))?.name, 'Torso B');
      expect(d.repository.routineOn(DateTime(2026, 10, 17))?.name, 'Pierna B');
      expect(d.repository.routineOn(DateTime(2026, 10, 13)), isNull);
      // Hoy points at it; Plan says when it starts.
      expect(d.today.withoutPlan, isFalse);
      expect(d.today.nextRoutine, contains('Torso A'));
      expect(d.plan.noPlanToday, isTrue);
      expect(d.plan.upcoming?.name, 'Rutina 4 días');
    });

    test('a four-day plan survives a backup; the empty plan is never '
        'written or read', () async {
      final d = await deps();
      await d.repository.saveDraft(fourDays('mine'));
      await d.repository.acceptDraft(DateTime(2026, 10, 12));
      final codec = BackupCodec(
        isKnownExercise: {for (final e in exerciseCatalog) e.id}.contains,
      );
      final text = BackupCodec.encode(
        d.repository.snapshot,
        createdAt: DateTime.utc(2026, 10, 7),
        schema: currentSchemaVersion,
      );
      expect(text, isNot(contains('plan-none')));
      final back = codec.decode(Uint8List.fromList(utf8.encode(text)));
      final plan = back.snapshot.plans.single;
      expect(plan.days.length, 4);
      expect(plan.effectiveFrom, '2026-10-12');
      // A file that claims the empty plan is refused.
      final tampered = jsonDecode(text) as Map<String, dynamic>;
      final data = tampered['data'] as Map<String, dynamic>;
      ((data['plans'] as List).single as Map<String, dynamic>)['source'] =
          'none';
      expect(
        () =>
            codec.decode(Uint8List.fromList(utf8.encode(jsonEncode(tampered)))),
        throwsA(isA<Object>()),
      );
    });
  });

  group('the screens without a plan', () {
    Future<AppDependencies> open(
      WidgetTester tester, {
      Size size = const Size(390, 1600),
      double scale = 1,
      AppSnapshot? snapshot,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await deps(snapshot);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('Hoy invites to create a plan and opens Plan; no example '
        'plan anywhere', (tester) async {
      final d = await open(tester);
      expect(find.text('Aún no tienes un plan'), findsWidgets);
      expect(find.text('Día de descanso'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('today-create-plan')));
      await tester.pumpAndSettle();
      expect(d.shell.page, AppPage.plan);
      expect(find.text('Crear mi plan'), findsOneWidget);
      for (final page in AppPage.values) {
        d.shell.open(page);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$page');
        expect(find.textContaining('Plan de ejemplo'), findsNothing);
        expect(find.textContaining('plan de ejemplo'), findsNothing);
      }
    });

    testWidgets('a plan is built from nothing: add days, then exercises', (
      tester,
    ) async {
      final d = await open(tester, size: const Size(390, 2400));
      d.shell.open(AppPage.plan);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('plan-edit')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Tu plan aún no tiene días'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        final add = find.byKey(const ValueKey('add-day'));
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
      }
      // The stored draft is still empty: the days live in the editor until
      // the person saves.
      expect(d.repository.draft!.days, isEmpty);
      final remove = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('remove-day-'),
      );
      expect(remove, findsNWidgets(4));
      await tester.ensureVisible(remove.last);
      await tester.pumpAndSettle();
      await tester.tap(remove.last);
      await tester.pumpAndSettle();
      expect(remove, findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a plan that starts on Monday is announced in Plan', (
      tester,
    ) async {
      final d = await open(tester);
      await d.repository.saveDraft(fourDays('mine'));
      await d.repository.acceptDraft(DateTime(2026, 10, 12));
      d.shell.open(AppPage.plan);
      await tester.pumpAndSettle();
      expect(find.text('Rutina 4 días'), findsWidgets);
      expect(find.textContaining('Empieza el'), findsOneWidget);
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      expect(find.text('Aún no tienes un plan'), findsNothing);
      expect(find.textContaining('Torso A'), findsOneWidget);
    });

    testWidgets('Hoy and Plan without a plan meet the guidelines at '
        '390 px, and fit 320 px at 200 %', (tester) async {
      final handle = tester.ensureSemantics();
      final d = await open(tester);
      for (final page in [AppPage.today, AppPage.plan]) {
        d.shell.open(page);
        await tester.pumpAndSettle();
        // The navbar is measured with the 44 pt guideline in the whole
        // suite (accessibility_test.dart).
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
      handle.dispose();
    });

    testWidgets('the empty state fits 320 px at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      final d = await open(tester, size: const Size(320, 1800), scale: 2);
      for (final page in [AppPage.today, AppPage.plan]) {
        d.shell.open(page);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$page');
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
      handle.dispose();
    });
  });
}
