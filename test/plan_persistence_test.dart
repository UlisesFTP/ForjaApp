import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/plan_editing.dart';
import 'package:forja_app/domain/services/plan_generator.dart';

import 'support/sqlite_harness.dart';

PlanVersion draft(String prefix, {List<int>? days, String name = 'Mi plan'}) =>
    PlanVersion(
      id: '$prefix-plan',
      status: PlanStatus.draft,
      source: PlanSource.manual,
      name: name,
      createdAt: DateTime.utc(2026, 10, 1, 8),
      days: [
        for (var i = 0; i < 3; i++)
          PlanDay(
            (days ?? const [1, 3, 5])[i],
            Routine(
              id: '$prefix-r$i',
              name: 'Día ${i + 1} ñ',
              focus: 'Foco',
              warmup: 'Calienta 5 min',
              exercises: [
                PlanExercise.fromExercise(exerciseFor('goblet'))
                    .copyWith(referenceWeightKg: () => 22.5),
                PlanExercise.fromExercise(exerciseFor('pushup')),
                PlanExercise.fromExercise(exerciseFor('plank')),
              ],
            ),
          ),
      ],
    );

void main() {
  late StoreHarness h;
  late Opened db;
  final today = DateTime(2026, 10, 1);
  DateTime clock() => today;
  setUp(() async {
    h = await StoreHarness.create();
    db = await h.open(clock: clock);
  });
  tearDown(() => h.dispose());

  test('plans and the answer history survive a restart exactly', () async {
    final mirror = LocalForjaRepository(
      MemoryForjaStore(),
      clock: clock,
      newId: () => 'a',
    );
    await mirror.initialize();
    addTearDown(mirror.dispose);
    final answers = [
      (
        const UserProfile(
          onboarded: true,
          goal: TrainingGoal.muscle,
          weightKg: 82.5,
          age: 34,
          equipment: {Equipment.dumbbell},
          trainingDays: [1, 3, 5],
          sessionMinutes: 45,
          setupStep: 7,
        ),
        ProfileChange.onboarding,
      ),
      (const UserProfile(skippedSetup: true), ProfileChange.skipped),
    ];
    for (final repo in [mirror, db.repo]) {
      for (final (profile, reason) in answers) {
        await repo.saveProfile(profile, record: reason);
      }
      await repo.saveDraft(draft('a'));
      await repo.acceptDraft(DateTime(2026, 10, 5));
      await repo.saveDraft(draft('b', days: const [2, 4, 6], name: 'Segundo'));
    }
    await db.close();
    final reopened = await h.open(clock: clock);
    final stored = await reopened.store.load();
    expect(reopened.repo.plans.map((p) => (p.id, p.status.name)), [
      ('a-plan', 'accepted'),
      ('b-plan', 'draft'),
    ]);
    expect(reopened.repo.plans.first.effectiveFrom, '2026-10-05');
    expect(
      reopened
          .repo
          .plans
          .first
          .routines
          .first
          .exercises
          .first
          .referenceWeightKg,
      22.5,
    );
    expect(
      reopened.repo.plans.first.routines.first.exercises.last.referenceWeightKg,
      isNull,
    );
    expect(reopened.repo.plans.first.routines.first.name, 'Día 1 ñ');
    expect(reopened.repo.profileHistory.map((a) => a.reason), [
      ProfileChange.onboarding,
      ProfileChange.skipped,
    ]);
    expect(reopened.repo.profileHistory.first.profile.equipment, {
      Equipment.dumbbell,
    });
    expect(reopened.repo.profileHistory.first.profile.weightKg, 82.5);
    expect(reopened.repo.profile.skippedSetup, isTrue);
    expect(reopened.repo.profile.weightKg, isNull);
    // The stored plans are exactly what the memory mirror holds.
    expect(
      stored.plans.map((p) => p.toJson()),
      mirror.plans.map((p) => p.toJson()),
    );
  });
  test('editing a draft rewrites it in place and never touches an accepted version', () async {
    final repo = db.repo;
    await repo.saveDraft(draft('a'));
    await repo.acceptDraft(today);
    final accepted = repo.plans.first.toJson();
    await repo.saveDraft(draft('b'));
    final edited = draft('b', name: 'Editado').copyWith(
      days: [
        for (final d in draft('b').days)
          PlanDay(
            d.weekday,
            d.routine.copyWith(
              exercises: d.routine.exercises.reversed.toList(),
            ),
          ),
      ],
    );
    await repo.saveDraft(edited);
    await db.close();
    final reopened = await h.open(clock: clock);
    expect(reopened.repo.plans.first.toJson(), accepted);
    final stored = reopened.repo.draft!;
    expect(stored.name, 'Editado');
    expect(stored.routines.first.exerciseIds, ['plank', 'pushup', 'goblet']);
    final counts = await reopened.counts();
    expect(counts['plan_versions'], 2);
    expect(counts['plan_routines'], 6);
    expect(counts['plan_routine_exercises'], 18);
  });
  test(
    'the schema keeps one routine per weekday and cascades deletes',
    () async {
      final repo = db.repo;
      await repo.saveDraft(draft('a'));
      await expectLater(
        db.db.customStatement(
          "INSERT INTO plan_routines (id, plan_id, weekday, name, focus, warmup) VALUES ('dup', 'a-plan', 1, 'x', '', '')",
        ),
        throwsA(anything),
      );
      await expectLater(
        db.db.customStatement(
          "INSERT INTO plan_routines (id, plan_id, weekday, name, focus, warmup) VALUES ('bad', 'a-plan', 8, 'x', '', '')",
        ),
        throwsA(anything),
      );
      await expectLater(
        db.db.customStatement(
          "INSERT INTO plan_routines (id, plan_id, weekday, name, focus, warmup) VALUES ('orphan', 'nope', 2, 'x', '', '')",
        ),
        throwsA(anything),
      );
      await db.db.customStatement("DELETE FROM plan_versions");
      final counts = await db.counts();
      expect(
        [counts['plan_routines'], counts['plan_routine_exercises']],
        [0, 0],
      );
    },
  );
  test('a failing plan save leaves the previous draft intact', () async {
    final repo = db.repo;
    await repo.saveDraft(draft('a'));
    final before = await db.counts();
    final stored = repo.draft!.toJson();
    h.fault.arm(
      (sql) =>
          sql.startsWith('INSERT') && sql.contains('plan_routine_exercises'),
    );
    await expectLater(
      repo.saveDraft(draft('a', name: 'Fallido')),
      throwsA(anything),
    );
    h.fault.disarm();
    expect(await db.counts(), before);
    expect(repo.draft!.toJson(), stored);
    await db.close();
    expect((await h.open(clock: clock)).repo.draft!.name, 'Mi plan');
  });
  test('an answer that fails to store does not enter the history', () async {
    final repo = db.repo;
    h.fault.arm(
      (sql) => sql.startsWith('INSERT') && sql.contains('profile_history'),
    );
    await expectLater(
      repo.saveProfile(
        const UserProfile(onboarded: true),
        record: ProfileChange.edit,
      ),
      throwsA(anything),
    );
    h.fault.disarm();
    expect(repo.profileHistory, isEmpty);
    expect(repo.profile.onboarded, isFalse);
    expect((await db.counts())['profile_history'], 0);
    expect((await db.counts())['profiles'], 0);
  });
  test('a seeded random run of plan and profile commands matches memory across restarts', () async {
    final random = Random(77);
    var mirrorIds = 0, dbIds = 0;
    String mirrorId() => 'id${mirrorIds++}';
    String dbId() => 'id${dbIds++}';
    final mirrorStore = MemoryForjaStore();
    final mirror = LocalForjaRepository(
      mirrorStore,
      clock: clock,
      newId: mirrorId,
    );
    await mirror.initialize();
    addTearDown(mirror.dispose);
    // A repository whose ids continue across restarts, like the mirror's.
    Future<Opened> reopen() async {
      // The harness keeps (and later disposes) the repository it created;
      // this one shares its store and continues the id sequence.
      final database = await h.open(clock: clock);
      final repo = LocalForjaRepository(
        database.store,
        clock: clock,
        newId: dbId,
      );
      await repo.initialize();
      return Opened(database.db, database.store, repo);
    }

    await db.close();
    db = await reopen();
    var planSeq = 0;
    Future<void> both(
      Future<void> Function(LocalForjaRepository r) command,
      int step,
    ) async {
      Object? expected, actual;
      try {
        await command(mirror);
      } catch (e) {
        expected = e;
      }
      try {
        await command(db.repo);
      } catch (e) {
        actual = e;
      }
      expect(actual.runtimeType, expected.runtimeType, reason: 'step $step');
      expect(
        sameSnapshotContent(await mirrorStore.load(), await db.store.load()),
        isTrue,
        reason: 'diverged at step $step',
      );
    }

    for (var step = 0; step < 220; step++) {
      switch (random.nextInt(8)) {
        case 0:
          final profile = UserProfile(
            experience: Experience.values[random.nextInt(3)],
            goal: TrainingGoal.values[random.nextInt(3)],
            weightKg: random.nextBool() ? null : 20 + random.nextInt(300) / 1.0,
            age: random.nextBool() ? null : 10 + random.nextInt(100),
            energy: Energy.values[random.nextInt(3)],
            onboarded: random.nextBool(),
            equipment: {
              for (final e in Equipment.values)
                if (random.nextBool()) e,
            },
            trainingDays: [
              for (final d in [1, 2, 3, 4, 5, 6, 7]..shuffle(random)) d,
            ].take(random.nextInt(5) == 0 ? 2 : 3).toList(),
            sessionMinutes: [15, 30, 45, 60, 90, 200][random.nextInt(6)],
            skippedSetup: random.nextBool(),
            setupStep: random.nextInt(8),
            note: random.nextBool() ? '' : 'ñ nota',
          );
          final reason = random.nextBool()
              ? null
              : ProfileChange.values[random.nextInt(4)];
          await both((r) => r.saveProfile(profile, record: reason), step);
        case 1:
          final base = cloneForEditing(
            mirror.planFor(today),
            now: DateTime.utc(2026, 10, 1, step % 24),
            newId: () => 'p${planSeq++}',
          );
          await both(
            (r) => r.saveDraft(base.copyWith(name: 'Plan $step')),
            step,
          );
        case 2:
          final generated = PlanGenerator.generate(
            mirror.profile,
            catalog: exerciseCatalog,
            now: DateTime.utc(2026, 10, 1, step % 24),
            newId: () => 'g${planSeq++}',
          );
          if (generated.ok) {
            await both((r) => r.saveDraft(generated.draft!), step);
          }
        case 3:
          final current = mirror.draft;
          if (current == null) continue;
          final day = random.nextInt(3);
          final routine = current.days[day].routine;
          final changed = current.copyWith(
            days: [
              for (var i = 0; i < 3; i++)
                i == day
                    ? PlanDay(
                        current.days[i].weekday,
                        routine.copyWith(
                          exercises: random.nextInt(4) == 0
                              ? const []
                              : routine.exercises.reversed.toList(),
                        ),
                      )
                    : current.days[i],
            ],
          );
          await both((r) => r.saveDraft(changed), step);
        case 4:
          final from = DateTime(2026, 9, 29 + random.nextInt(16));
          await both((r) => r.acceptDraft(from), step);
        case 5:
          await both((r) => r.discardDraft(), step);
        case 6:
          final date = DateTime(2026, 10, 1 + random.nextInt(14));
          final routine = mirror.routineOn(date);
          if (routine == null || routine.exercises.isEmpty) continue;
          final id = routine
              .exercises[random.nextInt(routine.exercises.length)]
              .exerciseId;
          await both((r) => r.toggleExercise(date, id), step);
        default:
          final date = DateTime(2026, 10, 1 + random.nextInt(14));
          final status = SessionStatus.values[random.nextInt(4)];
          await both((r) => r.finishSession(date, status), step);
      }
      if (step % 30 == 29) {
        await db.close();
        db = await reopen();
        expect(
          sameSnapshotContent(await mirrorStore.load(), await db.store.load()),
          isTrue,
          reason: 'storage differs after restart at step $step',
        );
      }
    }
    final integrity = await db.db
        .customSelect('PRAGMA integrity_check')
        .getSingle();
    expect(integrity.read<String>('integrity_check'), 'ok');
    expect(await db.db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    final counts = await db.counts();
    expect(
      counts['plan_versions'],
      greaterThan(3),
      reason: 'plans were exercised',
    );
    expect(counts['profile_history'], greaterThan(3));
    expect(mirror.plans.any((p) => p.status == PlanStatus.accepted), isTrue);
  });
}
