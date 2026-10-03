import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/database/forja_database.dart';
import 'package:forja_app/data/legacy/legacy_snapshot_source.dart';
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/local_store_opener.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/models/storage_failure.dart';

import '../support/sqlite_harness.dart';

class NoLegacy implements LegacySnapshotSource {
  @override
  String get id => 'none';
  @override
  Future<String?> readRaw() async => null;
}

void main() {
  final tuesday = DateTime(2026, 9, 29);
  late StoreHarness h;
  setUp(() async => h = await StoreHarness.create());
  tearDown(() => h.dispose());

  group('schema', () {
    test(
      'enforces foreign keys and keeps the single-row tables single',
      () async {
        final o = await h.open();
        final pragma = await o.db
            .customSelect('PRAGMA foreign_keys')
            .getSingle();
        expect(pragma.read<int>('foreign_keys'), 1);
        await expectLater(
          o.db
              .into(o.db.sessionExercises)
              .insert(
                SessionExercisesCompanion.insert(
                  sessionId: 'no-such-session',
                  exerciseId: 'squat',
                  position: 0,
                  weightKg: 40,
                  completed: false,
                ),
              ),
          throwsA(anything),
        );
        ProfilesCompanion profile(int id) => ProfilesCompanion.insert(
          id: Value(id),
          experience: Experience.beginner,
          goal: TrainingGoal.fitness,
          weightKg: const Value(70),
          age: const Value(30),
          energy: Energy.normal,
          note: '',
          onboarded: false,
          updatedAt: DateTime.utc(2026),
        );
        await o.db.into(o.db.profiles).insert(profile(1));
        await expectLater(
          o.db.into(o.db.profiles).insert(profile(2)),
          throwsA(anything),
        );
      },
    );
    test('rejects values that are never valid', () async {
      final o = await h.open();
      await expectLater(
        o.db
            .into(o.db.reminders)
            .insert(
              RemindersCompanion.insert(
                enabled: true,
                hour: 24,
                minute: 0,
                updatedAt: DateTime.utc(2026),
              ),
            ),
        throwsA(anything),
      );
      await o.repo.toggleExercise(tuesday, 'squat');
      // A valid statement works, so the failures below come from the CHECKs.
      await o.db.customStatement('UPDATE session_exercises SET weight_kg = 41');
      await expectLater(
        o.db.customStatement('UPDATE session_exercises SET weight_kg = -1'),
        throwsA(anything),
      );
      await expectLater(
        o.db.customStatement('UPDATE session_exercises SET position = -1'),
        throwsA(anything),
      );
    });
    test('deleting a session deletes its exercises', () async {
      final o = await h.open();
      await o.repo.toggleExercise(tuesday, 'squat');
      expect((await o.counts())['session_exercises'], 3);
      await o.db.customStatement('DELETE FROM workout_sessions');
      expect((await o.counts())['session_exercises'], 0);
    });
    test('one session per calendar date', () async {
      final o = await h.open();
      await o.repo.toggleExercise(tuesday, 'squat');
      await expectLater(
        o.db.customStatement(
          "INSERT INTO workout_sessions (id, date_key, routine_id, status, note, origin, updated_at) VALUES ('other', '2026-09-29', 'legs', 'scheduled', '', 'app', '2026-09-29T00:00:00.000Z')",
        ),
        throwsA(anything),
      );
    });
  });
  group('identity', () {
    test(
      'a session keeps its id and creation time across updates and restarts',
      () async {
        var tick = 0;
        DateTime clock() =>
            DateTime.utc(2026, 9, 29, 12).add(Duration(minutes: tick++));
        Future<Stamped> row(Opened o) async {
          final rows = await o.db
              .customSelect(
                'SELECT id, created_at, updated_at FROM workout_sessions',
              )
              .get();
          return Stamped(
            rows.single.read<String>('id'),
            rows.single.read<String>('created_at'),
            rows.single.read<String>('updated_at'),
          );
        }

        var o = await h.open(clock: clock);
        await o.repo.toggleExercise(tuesday, 'squat');
        final first = await row(o);
        await o.repo.updateWeight(tuesday, 'squat', 55);
        final second = await row(o);
        await o.close();
        o = await h.open(clock: clock);
        await o.repo.updateWeight(tuesday, 'squat', 60);
        final third = await row(o);
        expect(second.id, first.id);
        expect(third.id, first.id);
        expect(second.created, first.created);
        expect(third.created, first.created);
        expect(second.updated.compareTo(first.updated), greaterThan(0));
        expect(third.updated.compareTo(second.updated), greaterThan(0));
        expect(first.created, startsWith('2026-09-29T12:0'));
        expect(first.created, endsWith('Z'));
      },
    );
    test('reordering updates exercise rows in place', () async {
      final o = await h.open();
      await o.repo.toggleExercise(tuesday, 'squat');
      Future<Map<String, (int, int)>> rows() async => {
        for (final r
            in await o.db
                .customSelect(
                  'SELECT rowid AS rid, exercise_id, position FROM session_exercises',
                )
                .get())
          r.read<String>('exercise_id'): (
            r.read<int>('rid'),
            r.read<int>('position'),
          ),
      };
      final before = await rows();
      await o.repo.reorder(tuesday, ['press', 'squat', 'rdl']);
      final after = await rows();
      expect(after.keys.toSet(), before.keys.toSet());
      for (final id in before.keys) {
        expect(after[id]!.$1, before[id]!.$1, reason: '$id keeps its row');
      }
      expect(after['press']!.$2, 0);
      expect(after['squat']!.$2, 1);
      expect(after['rdl']!.$2, 2);
    });
    test('food keeps its order and ids across removals and restarts', () async {
      var o = await h.open();
      FoodEntry entry(String id) =>
          FoodEntry(id: id, dateKey: '2026-09-29', name: id, calories: 100);
      for (final id in ['a', 'b', 'c']) {
        await o.repo.addFood(entry(id));
      }
      await o.repo.removeFood('b');
      await o.repo.addFood(entry('d'));
      await o.close();
      o = await h.open();
      expect(o.repo.foodOn(tuesday).map((f) => f.id), ['a', 'c', 'd']);
    });
  });
  test('commits that edit or remove rows are stored faithfully', () async {
    final o = await h.open();
    ExerciseLog log(String id, {bool done = false}) =>
        ExerciseLog(exerciseId: id, weightKg: 20, completed: done);
    WorkoutSession session(String key, List<ExerciseLog> logs) =>
        WorkoutSession(dateKey: key, routineId: 'legs', exercises: logs);
    final first = AppSnapshot(
      sessions: {
        '2026-09-29': session('2026-09-29', [
          log('squat'),
          log('rdl'),
          log('press'),
        ]),
        '2026-09-30': session('2026-09-30', [log('press')]),
      },
      overrides: {'2026-09-29': null, '2026-09-30': 'legs'},
      checkIns: {
        '2026-09-29': const CheckIn(feeling: Feeling.tired),
        '2026-09-30': const CheckIn(feeling: Feeling.normal),
      },
      food: [
        const FoodEntry(
          id: 'a',
          dateKey: '2026-09-29',
          name: 'a',
          calories: 100,
        ),
        const FoodEntry(
          id: 'b',
          dateKey: '2026-09-29',
          name: 'b',
          calories: 200,
        ),
      ],
    );
    await o.store.commit(AppSnapshot(), first);
    expect(sameSnapshotContent(await o.store.load(), first), isTrue);
    // Drop an exercise, delete a session, an override and a check-in, edit a food.
    final second = first.copyWith(
      sessions: {
        '2026-09-29': session('2026-09-29', [
          log('rdl', done: true),
          log('squat'),
        ]),
      },
      overrides: {'2026-09-29': null},
      checkIns: {'2026-09-29': first.checkIns['2026-09-29']!},
      food: [
        const FoodEntry(
          id: 'a',
          dateKey: '2026-09-30',
          name: 'a2',
          calories: 150,
        ),
      ],
    );
    await o.store.commit(first, second);
    expect(sameSnapshotContent(await o.store.load(), second), isTrue);
    final counts = await o.counts();
    expect(counts['workout_sessions'], 1);
    expect(counts['session_exercises'], 2, reason: 'removed session cascades');
    expect(counts['calendar_overrides'], 1);
    expect(counts['check_ins'], 1);
    expect(counts['food_entries'], 1);
    await o.close();
    final reopened = await h.open();
    expect(sameSnapshotContent(await reopened.store.load(), second), isTrue);
  });
  group('lifecycle', () {
    test('closing waits for writes in flight and they all persist', () async {
      var o = await h.open();
      final writes = [
        for (var i = 1; i <= 8; i++)
          o.repo.updateWeight(tuesday, 'squat', i * 10),
      ];
      // Not awaited on purpose: shutdown happens while they are queued.
      await o.close();
      await Future.wait(writes);
      o = await h.open();
      expect(o.repo.sessionOn(tuesday)!.exercises.first.weightKg, 80);
    });
    test('works over a background isolate, as in production', () async {
      var o = await h.open(background: true);
      await o.repo.updateWeight(tuesday, 'squat', 52.5);
      await o.repo.toggleExercise(tuesday, 'squat');
      await o.repo.saveCheckIn(tuesday, const CheckIn(feeling: Feeling.doms));
      await o.close();
      o = await h.open(background: true);
      final log = o.repo.sessionOn(tuesday)!.exercises.first;
      expect(log.weightKg, 52.5);
      expect(log.completed, isTrue);
      expect(o.repo.checkInOn(tuesday)!.feeling, Feeling.doms);
    });
    test(
      'a database written by a newer version is refused and left untouched',
      () async {
        var o = await h.open();
        await o.repo.addFood(
          const FoodEntry(
            id: 'a',
            dateKey: '2026-09-29',
            name: 'x',
            calories: 100,
          ),
        );
        await o.db.customStatement('PRAGMA user_version = 99');
        await o.close();
        final versions = <int>[], foods = <int>[];
        final opener = LocalStoreOpener(
          source: NoLegacy(),
          connection: () => NativeDatabase(
            h.file,
            setup: (raw) {
              versions.add(raw.userVersion);
              foods.add(
                raw.select('SELECT COUNT(*) AS n FROM food_entries').first['n']
                    as int,
              );
            },
          ),
        );
        for (var attempt = 0; attempt < 2; attempt++) {
          await expectLater(
            opener.open(),
            throwsA(
              isA<DatabaseNewerThanApp>()
                  .having((f) => f.databaseVersion, 'database', 99)
                  .having((f) => f.appVersion, 'app', currentSchemaVersion),
            ),
          );
        }
        // Each failed attempt saw the same version and data; none changed them.
        expect(versions, [99, 99]);
        expect(foods, [1, 1]);
      },
    );
  });
  test(
    'a seeded random run of commands matches memory exactly, across restarts',
    () async {
      final random = Random(20260929);
      final mirrorStore = MemoryForjaStore();
      // Both sides draw ids from the same sequence, restarted per command, so
      // ids the repository invents (moves, audit entries) can be compared.
      var idSeq = 0;
      String nextId() => 'id${idSeq++}';
      DateTime fixedNow() => DateTime.utc(2026, 9, 28, 12);
      final mirror = LocalForjaRepository(
        mirrorStore,
        newId: nextId,
        clock: fixedNow,
      );
      await mirror.initialize();
      addTearDown(mirror.dispose);
      var o = await h.open(newId: nextId, clock: fixedNow);
      final dates = [for (var d = 28; d <= 41; d++) DateTime(2026, 9, d)];
      final exerciseIds = [for (final e in exerciseCatalog) e.id];
      var foodSeq = 0;
      final foodIds = <String>[];

      Future<void> run(
        int step,
        Future<void> Function(LocalForjaRepository repo) command,
      ) async {
        Object? expected, actual;
        idSeq = step * 1000;
        try {
          await command(mirror);
        } catch (e) {
          expected = e;
        }
        idSeq = step * 1000;
        try {
          await command(o.repo);
        } catch (e) {
          actual = e;
        }
        expect(
          actual.runtimeType,
          expected.runtimeType,
          reason: 'step $step: memory threw $expected, storage threw $actual',
        );
        final a = await mirrorStore.load(), b = await o.store.load();
        expect(
          sameSnapshotContent(a, b),
          isTrue,
          reason:
              'storage diverged from memory at step $step: '
              '${firstDifference(a.toJson(), b.toJson())}',
        );
      }

      for (var step = 0; step < 1000; step++) {
        final date = dates[random.nextInt(dates.length)];
        final current =
            mirror.sessionOn(date)?.exercises ?? const <ExerciseLog>[];
        final id = current.isNotEmpty && random.nextInt(10) > 0
            ? current[random.nextInt(current.length)].exerciseId
            : exerciseIds[random.nextInt(exerciseIds.length)];
        switch (random.nextInt(26)) {
          case 0 || 1 || 2:
            await run(step, (r) => r.toggleExercise(date, id));
          case 3:
            final weight = random.nextInt(6) == 0
                ? [-5.0, double.nan, 2500.0][random.nextInt(3)]
                : random.nextInt(4000) / 20;
            await run(step, (r) => r.updateWeight(date, id, weight));
          case 4:
            final ids = [for (final e in current) e.exerciseId]
              ..shuffle(random);
            await run(step, (r) => r.reorder(date, ids));
          case 5:
            final entry = CheckIn(
              feeling: Feeling.values[random.nextInt(Feeling.values.length)],
              note: random.nextBool() ? '' : 'nota ${random.nextInt(99)} ñ✓',
            );
            await run(step, (r) => r.saveCheckIn(date, entry));
          case 6:
            final profile = UserProfile(
              experience: Experience.values[random.nextInt(3)],
              goal: TrainingGoal.values[random.nextInt(3)],
              weightKg: 20 + random.nextInt(300) / 1.0,
              age: 10 + random.nextInt(100),
              energy: Energy.values[random.nextInt(3)],
              note: random.nextBool() ? '' : 'perfil ${random.nextInt(9)}',
              onboarded: random.nextBool(),
              lastReview: random.nextBool()
                  ? null
                  : '2026-09-0${1 + random.nextInt(9)}',
            );
            await run(step, (r) => r.saveProfile(profile));
          case 7:
            if (random.nextBool() || foodIds.isEmpty) {
              final food = FoodEntry(
                id: 'f${foodSeq++}',
                dateKey: '2026-09-${28 + random.nextInt(3)}',
                name: random.nextInt(8) == 0 ? ' ' : 'comida $foodSeq',
                calories: random.nextInt(6000),
              );
              await run(step, (r) => r.addFood(food));
              foodIds.add(food.id);
            } else {
              final remove = foodIds.removeAt(random.nextInt(foodIds.length));
              await run(step, (r) => r.removeFood(remove));
            }
          case 8:
            final reminder = ReminderSettings(
              enabled: random.nextBool(),
              hour: random.nextInt(26) - 1,
              minute: random.nextInt(62) - 1,
            );
            await run(step, (r) => r.saveReminder(reminder));
          case 9 || 10 || 11:
            // Sets: add, edit, remove and skip, with some invalid values.
            final session = mirror.sessionOn(date);
            final log = session?.exercises
                .where((e) => e.exerciseId == id)
                .firstOrNull;
            final sets = log?.sets ?? const <SetLog>[];
            final entry = SetEntry(
              kind: random.nextInt(4) == 0 ? SetKind.warmup : SetKind.work,
              status: random.nextInt(6) == 0
                  ? SetStatus.skipped
                  : SetStatus.done,
              weightKg: random.nextBool() ? null : random.nextInt(2400) / 10,
              reps: random.nextBool() ? null : random.nextInt(1100),
              rir: random.nextBool() ? null : random.nextInt(13) - 1,
            );
            switch (random.nextInt(4)) {
              case 0 || 1:
                await run(step, (r) => r.addSet(date, id, entry));
              case 2 when sets.isNotEmpty:
                final target = sets[random.nextInt(sets.length)].id;
                await run(step, (r) => r.updateSet(date, id, target, entry));
              case 3 when sets.isNotEmpty:
                final target = sets[random.nextInt(sets.length)].id;
                await run(step, (r) => r.removeSet(date, id, target));
              default:
                final skip = random.nextBool();
                final reason = random.nextInt(5) == 0 ? ' ' : 'sin tiempo';
                await run(
                  step,
                  (r) => r.setSkipped(date, id, skip, reason: reason),
                );
            }
          case 12:
            final entry = CheckIn(
              feeling: Feeling.values[random.nextInt(Feeling.values.length)],
              note: random.nextBool() ? '' : 'después ${random.nextInt(9)}',
            );
            await run(
              step,
              (r) => r.saveCheckIn(date, entry, phase: CheckInPhase.after),
            );
          case 13:
            final applied = random.nextBool();
            await run(step, (r) => r.setAdjustment(date, applied));
          case 14:
            await run(step, (r) => r.reopenSession(date));
          case 15:
            // Undo the latest still-standing move, if any.
            final standing = mirror.rescheduleFrom(date);
            if (standing != null) {
              await run(step, (r) => r.undoReschedule(standing.id));
            } else {
              await run(step, (r) => r.reopenSession(date));
            }
          case 16:
            // A move to a hand-picked date (may be refused).
            final status = random.nextBool()
                ? SessionStatus.partial
                : SessionStatus.missed;
            final to = dates[random.nextInt(dates.length)];
            await run(step, (r) => r.finishSession(date, status, moveTo: to));
          case 17:
            final rating = [
              null,
              TechniqueRating.solid,
              TechniqueRating.unstable,
            ][random.nextInt(3)];
            await run(step, (r) => r.setTechnique(date, id, rating));
          case 18:
            final based = '2026-09-${28 + random.nextInt(3)}';
            final status = random.nextBool()
                ? DecisionStatus.accepted
                : DecisionStatus.rejected;
            final to = 60 + random.nextInt(8) * 2.5;
            await run(
              step,
              (r) => r.decideProgression(
                exerciseId: id,
                kind: ProgressionKind.increase,
                basedOn: based,
                ruleVersion: 'prog-v1',
                status: status,
                fromKg: 60,
                toKg: to,
              ),
            );
          case 19:
            final until = DateTime(2026, 10, 1 + random.nextInt(20));
            await run(step, (r) => r.snoozeReview(until));
          case 20:
            final accepted = random.nextBool();
            final review = MonthlyReview(
              id: 'rv${random.nextInt(4)}',
              reviewedOn: '2026-10-0${1 + random.nextInt(9)}',
              outcome: accepted
                  ? ReviewOutcome.accepted
                  : ReviewOutcome.rejected,
              rulesVersion: 'review-v1',
              sessionsDone: random.nextInt(6),
              sessionsDue: 6,
              answers: {
                'pain': random.nextBool(),
                'note': 'ñ ${random.nextInt(9)}',
              },
              proposal: ['línea ${random.nextInt(9)}'],
              createdAt: fixedNow(),
            );
            final minutes = 30 + random.nextInt(8) * 15;
            await run(
              step,
              (r) => r.completeReview(
                review,
                profile: accepted
                    ? r.profile.copyWith(sessionMinutes: minutes)
                    : null,
              ),
            );
          case 21:
            final at = DateTime.utc(
              2026,
              10,
              1,
              random.nextInt(20),
              random.nextInt(60),
            );
            final activity = CardioActivity
                .values[random.nextInt(CardioActivity.values.length)];
            final intensity = CardioIntensity.values[random.nextInt(3)];
            final target = random.nextBool() ? null : 30;
            switch (random.nextInt(4)) {
              case 0:
                await run(
                  step,
                  (r) => r.startCardio(
                    activity: activity,
                    intensity: intensity,
                    at: at,
                    targetMinutes: target,
                  ),
                );
              case 1:
                await run(step, (r) => r.pauseCardio(at));
              case 2:
                await run(
                  step,
                  (r) => r.resumeCardio(at, intensity: intensity),
                );
              default:
                await run(step, (r) => r.changeCardioIntensity(at, intensity));
            }
          case 22:
            final at = DateTime.utc(
              2026,
              10,
              1,
              random.nextInt(20),
              random.nextInt(60),
            );
            final id = mirror.activeCardio?.id ?? 'none';
            if (random.nextInt(3) == 0) {
              await run(step, (r) => r.discardCardio(id));
            } else {
              final corrected = random.nextInt(4) == 0
                  ? Duration(minutes: random.nextInt(90))
                  : null;
              final feeling = random.nextBool() ? null : Feeling.normal;
              final cardioNote = random.nextBool() ? '' : 'rodaje';
              await run(
                step,
                (r) => r.finishCardio(
                  id,
                  at,
                  correctedDuration: corrected,
                  feedback: feeling,
                  note: cardioNote,
                ),
              );
            }
          case 23 || 24:
            // Nutrition: foods with portion/macros, edits, undo, favorites,
            // recipes and goals, with some invalid values.
            final n = random.nextInt(5);
            final kcal = random.nextInt(5200);
            final p = random.nextBool() ? null : random.nextInt(300) / 2;
            final c = random.nextBool() ? null : random.nextInt(300) / 2;
            final f = random.nextBool() ? null : random.nextInt(120) / 2;
            final portion = random.nextBool() ? null : random.nextInt(40) / 4;
            final entry = FoodEntry(
              id: 'n${random.nextInt(12)}',
              dateKey: '2026-09-${28 + random.nextInt(3)}',
              name: random.nextInt(9) == 0 ? ' ' : 'plato $n',
              calories: kcal,
              portion: portion,
              unit: random.nextBool() ? null : 'g',
              proteinG: p,
              carbsG: c,
              fatG: f,
            );
            switch (random.nextInt(8)) {
              case 0 || 1:
                await run(step, (r) => r.addFood(entry));
              case 2:
                await run(step, (r) => r.updateFood(entry));
              case 3:
                await run(step, (r) => r.removeFood(entry.id));
              case 4:
                await run(step, (r) => r.restoreFood(entry));
              case 5:
                final fav = FavoriteFood(
                  id: 'v${random.nextInt(6)}',
                  name: 'fav $n',
                  calories: kcal,
                  proteinG: p,
                );
                if (random.nextBool()) {
                  await run(step, (r) => r.addFavorite(fav));
                } else {
                  await run(step, (r) => r.removeFavorite(fav.id));
                }
              case 6:
                final recipe = Recipe(
                  id: 'q${random.nextInt(4)}',
                  name: 'receta $n',
                  servings: random.nextInt(8) / 2,
                  createdAt: fixedNow(),
                  tags: random.nextBool() ? const [] : const ['rápida'],
                  allergens: random.nextBool() ? null : const ['gluten'],
                  ingredients: [
                    for (var i = 0; i <= random.nextInt(3); i++)
                      Ingredient(
                        name: 'ing $i',
                        quantity: random.nextBool() ? null : 1.5 * (i + 1),
                        calories: random.nextBool()
                            ? null
                            : random.nextInt(900),
                        proteinG: p,
                      ),
                  ],
                );
                if (random.nextInt(4) == 0) {
                  await run(step, (r) => r.deleteRecipe(recipe.id));
                } else {
                  await run(step, (r) => r.saveRecipe(recipe));
                }
              default:
                final goals = NutritionGoals(
                  kcal: random.nextBool() ? null : 400 + random.nextInt(3000),
                  proteinG: p,
                );
                await run(step, (r) => r.saveGoals(goals));
            }
          default:
            final status = SessionStatus.values[random.nextInt(4)];
            await run(step, (r) => r.finishSession(date, status));
        }
        if (step % 40 == 39) {
          await o.close();
          o = await h.open(newId: nextId, clock: fixedNow);
          expect(
            sameSnapshotContent(await mirrorStore.load(), await o.store.load()),
            isTrue,
            reason: 'storage differs after restart at step $step',
          );
        }
      }
      final integrity = await o.db
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      expect(integrity.read<String>('integrity_check'), 'ok');
      expect(
        await o.db.customSelect('PRAGMA foreign_key_check').get(),
        isEmpty,
      );
      // The run must have exercised real state, not only rejected commands.
      final counts = await o.counts();
      expect(counts['workout_sessions'], greaterThan(3));
      expect(counts['food_entries'], greaterThan(5));
      expect(counts['set_logs'], greaterThan(3));
      expect(counts['reschedules'], greaterThan(0));
      expect(counts['session_events'], greaterThan(0));
      expect(counts['progression_decisions'], greaterThan(0));
      expect(counts['monthly_reviews'], greaterThan(0));
      expect(counts['cardio_sessions'], greaterThan(0));
      expect(counts['cardio_segments'], greaterThan(1));
      expect(counts['food_favorites'], greaterThan(0));
      expect(counts['recipes'], greaterThan(0));
      expect(counts['recipe_ingredients'], greaterThan(1));
    },
  );
}

// A stored session's id and timestamps, as the database holds them.
class Stamped {
  Stamped(this.id, this.created, this.updated);
  final String id, created, updated;
}

/// Path of the first difference between two JSON values, for readable
/// failures when storage and memory disagree.
String firstDifference(Object? a, Object? b, [String path = r'$']) {
  if (a is Map && b is Map) {
    for (final key in {...a.keys, ...b.keys}) {
      final d = firstDifference(a[key], b[key], '$path.$key');
      if (d.isNotEmpty) return d;
    }
    return '';
  }
  if (a is List && b is List) {
    for (var i = 0; i < (a.length > b.length ? a.length : b.length); i++) {
      final d = firstDifference(
        i < a.length ? a[i] : '<none>',
        i < b.length ? b[i] : '<none>',
        '$path[$i]',
      );
      if (d.isNotEmpty) return d;
    }
    return '';
  }
  return a == b ? '' : '$path: memory=$a storage=$b';
}
