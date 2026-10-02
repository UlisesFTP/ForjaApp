// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/database/forja_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

const stamp = '2026-09-30T12:00:00.000Z';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // Every upgrade path yields exactly the schema of the target version.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = ForjaDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  group('v1 to v2 keeps the data', () {
    Future<void> migrate({
      required bool onboarded,
      required Future<void> Function(v2.DatabaseAtV2 db) check,
    }) => verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: ForjaDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(
          oldDb.profiles,
          v1.ProfilesData(
            id: 1,
            experience: 'advanced',
            goal: 'muscle',
            weightKg: onboarded ? 82.5 : 70,
            age: onboarded ? 34 : 28,
            energy: 'low',
            note: 'Hombro derecho sensible',
            onboarded: onboarded ? 1 : 0,
            lastReview: onboarded ? '2026-09-01' : null,
            updatedAt: stamp,
          ),
        );
        batch.insert(
          oldDb.reminders,
          const v1.RemindersData(
            id: 1,
            enabled: 1,
            hour: 19,
            minute: 30,
            updatedAt: stamp,
          ),
        );
        batch.insert(
          oldDb.workoutSessions,
          const v1.WorkoutSessionsData(
            id: 's1',
            dateKey: '2026-09-29',
            routineId: 'legs',
            status: 'partial',
            note: 'Dormí poco',
            origin: 'legacySnapshotV1',
            updatedAt: stamp,
          ),
        );
        for (final (i, id) in ['rdl', 'squat', 'press'].indexed) {
          batch.insert(
            oldDb.sessionExercises,
            v1.SessionExercisesData(
              sessionId: 's1',
              exerciseId: id,
              position: i,
              weightKg: 30.0 + i,
              completed: i == 0 ? 1 : 0,
            ),
          );
        }
        batch.insert(
          oldDb.calendarOverrides,
          const v1.CalendarOverridesData(
            dateKey: '2026-09-29',
            routineId: null,
            updatedAt: stamp,
          ),
        );
        batch.insert(
          oldDb.foodEntries,
          const v1.FoodEntriesData(
            id: 'f1',
            seq: 1,
            dateKey: '2026-09-29',
            name: 'Café con leche ☕',
            calories: 120,
          ),
        );
      },
      validateItems: check,
    );

    test(
      'an answered profile keeps its values and gains the new defaults',
      () async {
        await migrate(
          onboarded: true,
          check: (db) async {
            final profile = await db.select(db.profiles).getSingle();
            expect(profile.weightKg, 82.5);
            expect(profile.age, 34);
            expect(profile.note, 'Hombro derecho sensible');
            expect(profile.onboarded, 1);
            expect(profile.lastReview, '2026-09-01');
            // New columns take their documented defaults.
            expect(
              profile.equipment,
              'barbell,dumbbell,machine,cable,bodyweight',
            );
            expect(profile.trainingDays, '2,4,6');
            expect(profile.sessionMinutes, 60);
            expect(profile.setupSkipped, 0);
            expect(profile.setupStep, 0);
            await _expectRestIntact(db);
          },
        );
      },
    );

    test('0.1 defaults on an unfinished profile become unknown', () async {
      await migrate(
        onboarded: false,
        check: (db) async {
          final profile = await db.select(db.profiles).getSingle();
          expect(profile.weightKg, isNull);
          expect(profile.age, isNull);
          expect(profile.onboarded, 0);
          expect(profile.experience, 'advanced');
          await _expectRestIntact(db);
        },
      );
    });
  });

  group('v2 to v3 keeps the data and invents nothing', () {
    test('check-ins become "before", sessions keep their checklist', () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 2,
        newVersion: 3,
        createOld: v2.DatabaseAtV2.new,
        createNew: v3.DatabaseAtV3.new,
        openTestedDatabase: ForjaDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.profiles,
            const v2.ProfilesData(
              id: 1,
              experience: 'beginner',
              goal: 'fitness',
              weightKg: 61.5,
              age: 41,
              energy: 'normal',
              note: 'Rodilla izquierda',
              onboarded: 1,
              equipment: 'dumbbell,bodyweight',
              trainingDays: '1,3,5',
              sessionMinutes: 45,
              setupSkipped: 0,
              setupStep: 7,
              updatedAt: stamp,
            ),
          );
          batch.insert(
            oldDb.workoutSessions,
            const v2.WorkoutSessionsData(
              id: 's1',
              dateKey: '2026-09-29',
              routineId: 'legs',
              status: 'completed',
              feeling: 'tired',
              note: 'Dormí poco',
              origin: 'app',
              createdAt: stamp,
              updatedAt: stamp,
            ),
          );
          for (final (i, id) in ['rdl', 'squat'].indexed) {
            batch.insert(
              oldDb.sessionExercises,
              v2.SessionExercisesData(
                sessionId: 's1',
                exerciseId: id,
                position: i,
                weightKg: 40.0 + i,
                completed: 1,
              ),
            );
          }
          batch.insert(
            oldDb.checkIns,
            const v2.CheckInsData(
              id: 'c1',
              dateKey: '2026-09-29',
              feeling: 'doms',
              note: 'Agujetas',
              createdAt: stamp,
              updatedAt: stamp,
            ),
          );
        },
        validateItems: (db) async {
          final profile = await db.select(db.profiles).getSingle();
          expect(profile.weightUnit, 'kg');
          expect(profile.weightKg, 61.5);
          expect(profile.trainingDays, '1,3,5');
          expect(profile.setupStep, 7);
          final checkIn = await db.select(db.checkIns).getSingle();
          expect(
            [checkIn.id, checkIn.phase, checkIn.feeling, checkIn.note],
            ['c1', 'before', 'doms', 'Agujetas'],
          );
          final exercises = await (db.select(
            db.sessionExercises,
          )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
          expect(exercises.map((e) => e.exerciseId), ['rdl', 'squat']);
          expect(exercises.map((e) => e.completed), [1, 1]);
          // Nothing about past work is invented: not skipped, no sets.
          expect(exercises.map((e) => e.skipped), [0, 0]);
          expect(exercises.map((e) => e.skipReason), [null, null]);
          for (final table in [
            'set_logs',
            'session_events',
            'reschedules',
            'session_adjustments',
          ]) {
            final n = await db
                .customSelect('SELECT COUNT(*) AS n FROM $table')
                .getSingle();
            expect(n.read<int>('n'), 0, reason: table);
          }
          // The widened key lets a date hold a before and an after answer.
          await db.customStatement(
            "INSERT INTO check_ins (id, date_key, phase, feeling, note, "
            "updated_at) VALUES ('c2', '2026-09-29', 'after', 'energetic', "
            "'', '$stamp')",
          );
          await expectLater(
            db.customStatement(
              "INSERT INTO check_ins (id, date_key, phase, feeling, note, "
              "updated_at) VALUES ('c3', '2026-09-29', 'after', 'normal', "
              "'', '$stamp')",
            ),
            throwsA(anything),
          );
        },
      );
    });
  });

  group('v3 to v4 keeps the data and invents nothing', () {
    test(
      'profile, sets and history stay; technique and reviews start empty',
      () async {
        await verifier.testWithDataIntegrity(
          oldVersion: 3,
          newVersion: 4,
          createOld: v3.DatabaseAtV3.new,
          createNew: v4.DatabaseAtV4.new,
          openTestedDatabase: ForjaDatabase.new,
          createItems: (batch, oldDb) {
            batch.insert(
              oldDb.profiles,
              const v3.ProfilesData(
                id: 1,
                experience: 'advanced',
                goal: 'strength',
                weightKg: 90.5,
                age: 30,
                energy: 'normal',
                note: 'Hombro',
                onboarded: 1,
                lastReview: '2026-08-01',
                equipment: 'barbell,dumbbell',
                trainingDays: '1,3,5',
                sessionMinutes: 75,
                setupSkipped: 0,
                setupStep: 7,
                weightUnit: 'lb',
                updatedAt: stamp,
              ),
            );
            batch.insert(
              oldDb.profileHistory,
              const v3.ProfileHistoryData(
                id: 'h1',
                seq: 1,
                recordedAt: stamp,
                reason: 'onboarding',
                payload: '{"experience":"advanced"}',
              ),
            );
            batch.insert(
              oldDb.workoutSessions,
              const v3.WorkoutSessionsData(
                id: 's1',
                dateKey: '2026-09-29',
                routineId: 'legs',
                status: 'completed',
                note: '',
                origin: 'app',
                createdAt: stamp,
                updatedAt: stamp,
              ),
            );
            batch.insert(
              oldDb.sessionExercises,
              const v3.SessionExercisesData(
                sessionId: 's1',
                exerciseId: 'squat',
                position: 0,
                weightKg: 100.0,
                completed: 1,
                skipped: 0,
              ),
            );
            batch.insert(
              oldDb.setLogs,
              const v3.SetLogsData(
                id: 'set1',
                sessionId: 's1',
                exerciseId: 'squat',
                position: 0,
                kind: 'work',
                number: 1,
                status: 'done',
                weightKg: 100.0,
                reps: 5,
              ),
            );
          },
          validateItems: (db) async {
            final profile = await db.select(db.profiles).getSingle();
            expect(profile.weightUnit, 'lb');
            expect(profile.lastReview, '2026-08-01');
            expect(profile.sessionMinutes, 75);
            expect(profile.reviewSnoozeUntil, isNull);
            final history = await db.select(db.profileHistory).getSingle();
            expect(history.reason, 'onboarding');
            expect(history.rulesVersion, isNull);
            final exercise = await db.select(db.sessionExercises).getSingle();
            expect(
              exercise.technique,
              isNull,
              reason: 'technique is not invented',
            );
            expect(exercise.completed, 1);
            final set = await db.select(db.setLogs).getSingle();
            expect(
              [set.id, set.weightKg, set.reps, set.rir],
              ['set1', 100.0, 5, null],
            );
            for (final table in ['progression_decisions', 'monthly_reviews']) {
              final n = await db
                  .customSelect('SELECT COUNT(*) AS n FROM $table')
                  .getSingle();
              expect(n.read<int>('n'), 0, reason: table);
            }
            // The unique key stops a second decision about the same suggestion.
            Future<void> decide(String id, int seq) => db.customStatement(
              "INSERT INTO progression_decisions (id, seq, exercise_id, "
              "rule_version, kind, based_on, status, decided_at) VALUES "
              "('$id', $seq, 'squat', 'prog-v1', 'increase', '2026-09-29', "
              "'accepted', '$stamp')",
            );
            await decide('d1', 1);
            await expectLater(decide('d2', 2), throwsA(anything));
          },
        );
      },
    );
  });

  group('v4 to v5 keeps the data', () {
    test('everything stays and the cardio tables start empty', () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 4,
        newVersion: 5,
        createOld: v4.DatabaseAtV4.new,
        createNew: v5.DatabaseAtV5.new,
        openTestedDatabase: ForjaDatabase.new,
        createItems: (batch, oldDb) {
          batch.insert(
            oldDb.reminders,
            const v4.RemindersData(
              id: 1,
              enabled: 1,
              hour: 7,
              minute: 15,
              updatedAt: stamp,
            ),
          );
          batch.insert(
            oldDb.foodEntries,
            const v4.FoodEntriesData(
              id: 'f1',
              seq: 1,
              dateKey: '2026-09-29',
              name: 'Avena',
              calories: 300,
            ),
          );
        },
        validateItems: (db) async {
          final reminder = await db.select(db.reminders).getSingle();
          expect(
            [reminder.enabled, reminder.hour, reminder.minute],
            [1, 7, 15],
          );
          final food = await db.select(db.foodEntries).getSingle();
          expect([food.id, food.name, food.calories], ['f1', 'Avena', 300]);
          for (final table in ['cardio_sessions', 'cardio_segments']) {
            final n = await db
                .customSelect('SELECT COUNT(*) AS n FROM $table')
                .getSingle();
            expect(n.read<int>('n'), 0, reason: table);
          }
          // Segments cascade with their session, and a position is unique.
          await db.customStatement(
            "INSERT INTO cardio_sessions (id, seq, activity, status, "
            "started_at, note, duration_corrected) VALUES ('c1', 1, 'walk', "
            "'active', '$stamp', '', 0)",
          );
          Future<void> segment(String id, int position) => db.customStatement(
            "INSERT INTO cardio_segments (id, session_id, position, "
            "started_at, intensity) VALUES ('$id', 'c1', $position, "
            "'$stamp', 'low')",
          );
          await segment('g1', 0);
          await expectLater(segment('g2', 0), throwsA(anything));
          await db.customStatement('PRAGMA foreign_keys = ON');
          await db.customStatement(
            "DELETE FROM cardio_sessions WHERE id = 'c1'",
          );
          final left = await db
              .customSelect('SELECT COUNT(*) AS n FROM cardio_segments')
              .getSingle();
          expect(left.read<int>('n'), 0);
        },
      );
    });
  });

  group('v5 to v6 keeps what was logged and invents no macros', () {
    test('existing food keeps calories as the manual number', () async {
      await verifier.testWithDataIntegrity(
        oldVersion: 5,
        newVersion: 6,
        createOld: v5.DatabaseAtV5.new,
        createNew: v6.DatabaseAtV6.new,
        openTestedDatabase: ForjaDatabase.new,
        createItems: (batch, oldDb) {
          for (final (i, name) in ['Avena', 'Café con leche ☕'].indexed) {
            batch.insert(
              oldDb.foodEntries,
              v5.FoodEntriesData(
                id: 'f$i',
                seq: i + 1,
                dateKey: '2026-09-29',
                name: name,
                calories: 120 + i * 100,
                createdAt: stamp,
              ),
            );
          }
        },
        validateItems: (db) async {
          final rows = await (db.select(
            db.foodEntries,
          )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
          expect(rows.map((r) => r.name), ['Avena', 'Café con leche ☕']);
          expect(rows.map((r) => r.calories), [120, 220]);
          for (final r in rows) {
            expect(r.portion, isNull);
            expect(r.unit, isNull);
            expect(r.proteinG, isNull, reason: 'unknown, not 0 g');
            expect(r.carbsG, isNull);
            expect(r.fatG, isNull);
            expect(r.caloriesSource, 'manual');
            expect(r.recipeId, isNull);
          }
          for (final table in [
            'food_favorites',
            'recipes',
            'recipe_ingredients',
            'nutrition_goals',
          ]) {
            final n = await db
                .customSelect('SELECT COUNT(*) AS n FROM $table')
                .getSingle();
            expect(n.read<int>('n'), 0, reason: table);
          }
          // A recipe cannot have zero servings, and its ingredients cascade.
          await expectLater(
            db.customStatement(
              "INSERT INTO recipes (id, seq, name, servings, notes, tags, "
              "created_at) VALUES ('r0', 1, 'x', 0, '', '[]', '$stamp')",
            ),
            throwsA(anything),
          );
          await db.customStatement(
            "INSERT INTO recipes (id, seq, name, servings, notes, tags, "
            "created_at) VALUES ('r1', 1, 'x', 2, '', '[]', '$stamp')",
          );
          await db.customStatement(
            "INSERT INTO recipe_ingredients (recipe_id, position, name) "
            "VALUES ('r1', 0, 'Sal')",
          );
          await db.customStatement('PRAGMA foreign_keys = ON');
          await db.customStatement("DELETE FROM recipes WHERE id = 'r1'");
          final left = await db
              .customSelect('SELECT COUNT(*) AS n FROM recipe_ingredients')
              .getSingle();
          expect(left.read<int>('n'), 0);
        },
      );
    });
  });
}

Future<void> _expectRestIntact(v2.DatabaseAtV2 db) async {
  final reminder = await db.select(db.reminders).getSingle();
  expect([reminder.enabled, reminder.hour, reminder.minute], [1, 19, 30]);
  final session = await db.select(db.workoutSessions).getSingle();
  expect(session.id, 's1');
  expect(session.status, 'partial');
  expect(session.note, 'Dormí poco');
  final exercises = await (db.select(
    db.sessionExercises,
  )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
  expect(exercises.map((e) => e.exerciseId), ['rdl', 'squat', 'press']);
  expect(exercises.map((e) => e.weightKg), [30.0, 31.0, 32.0]);
  expect(exercises.map((e) => e.completed), [1, 0, 0]);
  final override = await db.select(db.calendarOverrides).getSingle();
  expect(override.dateKey, '2026-09-29');
  expect(override.routineId, isNull);
  final food = await db.select(db.foodEntries).getSingle();
  expect([food.id, food.name, food.calories], ['f1', 'Café con leche ☕', 120]);
  // The new tables exist and start empty.
  for (final table in [
    'profile_history',
    'plan_versions',
    'plan_routines',
    'plan_routine_exercises',
  ]) {
    final n = await db
        .customSelect('SELECT COUNT(*) AS n FROM $table')
        .getSingle();
    expect(n.read<int>('n'), 0, reason: table);
  }
}
