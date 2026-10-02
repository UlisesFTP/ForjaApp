import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/reschedule_planner.dart';

import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

// Plan de ejemplo: martes piernas (squat, rdl, press), jueves empuje,
// sábado tirón.
void main() {
  final tuesday = DateTime(2026, 9, 29);
  final now = DateTime.utc(2026, 9, 29, 10);
  late StoreHarness h;
  late Opened db;
  setUp(() async {
    h = await StoreHarness.create();
    db = await h.open(clock: () => now);
  });
  tearDown(() => h.dispose());

  Future<Opened> reopen() async {
    await db.close();
    return db = await h.open(clock: () => now);
  }

  ExerciseLog log(Opened o, String id, [DateTime? date]) => o.repo
      .sessionOn(date ?? tuesday)!
      .exercises
      .firstWhere((e) => e.exerciseId == id);

  Future<void> doAll(Opened o, DateTime date) async {
    for (final e in o.repo.sessionOn(date)!.exercises) {
      await o.repo.toggleExercise(date, e.exerciseId);
    }
  }

  group('sets (F03)', () {
    test(
      'real reps, load and effort are stored, and unknown stays null',
      () async {
        final repo = db.repo;
        await repo.addSet(
          tuesday,
          'squat',
          const SetEntry(kind: SetKind.warmup, weightKg: 20, reps: 10),
        );
        await repo.addSet(
          tuesday,
          'squat',
          const SetEntry(weightKg: 52.5, reps: 8, rir: 2),
        );
        // One tap on the checklist records compliance only.
        await repo.addSet(tuesday, 'squat', const SetEntry());
        final sets = log(db, 'squat').sets;
        expect(sets.map((s) => s.kind), [
          SetKind.warmup,
          SetKind.work,
          SetKind.work,
        ]);
        expect(sets.map((s) => s.number), [1, 1, 2]);
        expect(sets[2].weightKg, isNull);
        expect(sets[2].reps, isNull);
        expect(sets[2].rir, isNull);
        // Unknown is not a zero, so it never counts as a repetition.
        expect(sets[2].reps, isNot(0));
        final reopened = await reopen();
        final stored = log(reopened, 'squat').sets;
        expect(stored.map((s) => s.toJson()), sets.map((s) => s.toJson()));
        expect(stored[2].reps, isNull);
      },
    );

    test('a set can be edited, removed and renumbered', () async {
      final repo = db.repo;
      for (var i = 0; i < 3; i++) {
        await repo.addSet(
          tuesday,
          'rdl',
          SetEntry(weightKg: 60.0 + i, reps: 8),
        );
      }
      final ids = log(db, 'rdl').sets.map((s) => s.id).toList();
      await repo.updateSet(
        tuesday,
        'rdl',
        ids[1],
        const SetEntry(weightKg: 62.5, reps: 6, rir: 1),
      );
      await repo.removeSet(tuesday, 'rdl', ids[0]);
      var sets = log(db, 'rdl').sets;
      expect(sets.map((s) => s.id), [ids[1], ids[2]]);
      expect(sets.map((s) => s.number), [1, 2]);
      expect(sets.first.weightKg, 62.5);
      sets = log(await reopen(), 'rdl').sets;
      expect(sets.map((s) => s.number), [1, 2]);
      expect(sets.first.rir, 1);
    });

    test('editing a single set in place persists across a restart', () async {
      final repo = db.repo;
      await repo.addSet(
        tuesday,
        'squat',
        const SetEntry(weightKg: 50, reps: 5),
      );
      await repo.addSet(
        tuesday,
        'squat',
        const SetEntry(weightKg: 50, reps: 5),
      );
      final second = log(db, 'squat').sets[1].id;
      // Same ids, same count: only the content changes.
      await repo.updateSet(
        tuesday,
        'squat',
        second,
        const SetEntry(weightKg: 55, reps: 4, rir: 1),
      );
      final stored = log(await reopen(), 'squat').sets;
      expect(stored.map((s) => s.id).last, second);
      expect(stored.last.weightKg, 55);
      expect(stored.last.reps, 4);
      expect(stored.last.rir, 1);
      expect(stored.first.weightKg, 50);
      // Turning a done set into a skipped one is a content change too.
      await db.repo.updateSet(
        tuesday,
        'squat',
        second,
        const SetEntry(status: SetStatus.skipped, skipReason: 'molestia'),
      );
      final skipped = log(await reopen(), 'squat').sets.last;
      expect(skipped.isDone, isFalse);
      expect(skipped.skipReason, 'molestia');
      expect(skipped.weightKg, isNull);
    });

    test(
      'changing a set from work to warm-up persists its kind and order',
      () async {
        // Regression: the update wrote everything but the kind, so a reopened
        // session showed the set as a work set again.
        final repo = db.repo;
        await repo.addSet(
          tuesday,
          'squat',
          const SetEntry(weightKg: 50, reps: 5),
        );
        await repo.addSet(
          tuesday,
          'squat',
          const SetEntry(weightKg: 60, reps: 5),
        );
        final second = log(db, 'squat').sets[1].id;
        await repo.updateSet(
          tuesday,
          'squat',
          second,
          const SetEntry(kind: SetKind.warmup, weightKg: 20, reps: 10),
        );
        final sets = log(await reopen(), 'squat').sets;
        expect(sets.map((s) => s.kind), [SetKind.warmup, SetKind.work]);
        expect(sets.map((s) => s.number), [1, 1]);
        expect(sets.first.id, second);
        expect(sets.first.weightKg, 20);
      },
    );

    test('invalid values are refused and nothing is stored', () async {
      final repo = db.repo;
      for (final bad in const [
        SetEntry(weightKg: -1),
        SetEntry(weightKg: 2500),
        SetEntry(weightKg: double.nan),
        SetEntry(reps: 1000),
        SetEntry(rir: 11),
        SetEntry(rir: -1),
        SetEntry(status: SetStatus.skipped, reps: 5),
        SetEntry(skipReason: 'x'),
      ]) {
        await expectLater(
          repo.addSet(tuesday, 'squat', bad),
          throwsArgumentError,
        );
      }
      expect((await db.counts()).values.every((n) => n == 0), isTrue);
      await expectLater(
        repo.addSet(tuesday, 'unknown', const SetEntry()),
        throwsArgumentError,
      );
      await expectLater(
        repo.updateSet(tuesday, 'squat', 'nope', const SetEntry()),
        throwsArgumentError,
      );
    });

    test('a skipped set is not a done set', () async {
      await db.repo.addSet(
        tuesday,
        'squat',
        const SetEntry(status: SetStatus.skipped, skipReason: 'molestia'),
      );
      await db.repo.addSet(tuesday, 'squat', const SetEntry(reps: 8));
      final squat = log(db, 'squat');
      expect(squat.sets.first.isDone, isFalse);
      expect(squat.sets.first.skipReason, 'molestia');
      expect(squat.workSets, hasLength(1));
    });

    test('reordering never moves a log to another exercise', () async {
      final repo = db.repo;
      await repo.addSet(
        tuesday,
        'squat',
        const SetEntry(weightKg: 50, reps: 5),
      );
      await repo.addSet(
        tuesday,
        'press',
        const SetEntry(weightKg: 90, reps: 10),
      );
      await repo.setSkipped(tuesday, 'rdl', true, reason: 'sin barra');
      await repo.reorder(tuesday, ['press', 'rdl', 'squat']);
      void expectLogs(Opened o) {
        expect(o.repo.sessionOn(tuesday)!.exercises.map((e) => e.exerciseId), [
          'press',
          'rdl',
          'squat',
        ]);
        expect(log(o, 'squat').sets.single.weightKg, 50);
        expect(log(o, 'press').sets.single.weightKg, 90);
        expect(log(o, 'rdl').skipped, isTrue);
        expect(log(o, 'rdl').sets, isEmpty);
      }

      expectLogs(db);
      expectLogs(await reopen());
      await db.repo.reorder(tuesday, ['squat', 'press', 'rdl']);
      expect(log(db, 'squat').sets.single.reps, 5);
      expect(log(await reopen(), 'press').sets.single.reps, 10);
    });

    test('concurrent set writes all land, in order, once', () async {
      final repo = db.repo;
      await Future.wait([
        for (var i = 1; i <= 6; i++)
          repo.addSet(tuesday, 'squat', SetEntry(weightKg: 40, reps: i)),
      ]);
      expect(log(db, 'squat').sets.map((s) => s.reps), [1, 2, 3, 4, 5, 6]);
      expect(log(await reopen(), 'squat').sets.map((s) => s.number), [
        1,
        2,
        3,
        4,
        5,
        6,
      ]);
      expect((await db.counts())['set_logs'], 6);
    });

    test(
      'a failed write keeps the old sets and later writes recover',
      () async {
        final repo = db.repo;
        await repo.addSet(tuesday, 'squat', const SetEntry(reps: 5));
        final before = await db.counts();
        h.fault.arm(
          (sql) => sql.startsWith('INSERT') && sql.contains('set_logs'),
        );
        await expectLater(
          repo.addSet(tuesday, 'squat', const SetEntry(reps: 6)),
          throwsInjected,
        );
        expect(log(db, 'squat').sets, hasLength(1));
        expect(await db.counts(), before);
        h.fault.disarm();
        await repo.addSet(tuesday, 'squat', const SetEntry(reps: 6));
        expect(log(await reopen(), 'squat').sets.map((s) => s.reps), [5, 6]);
      },
    );

    test('weights are stored unrounded in kilograms', () async {
      const odd = 22.679618500000002; // 50 lb
      await db.repo.addSet(tuesday, 'squat', const SetEntry(weightKg: odd));
      expect(log(await reopen(), 'squat').sets.single.weightKg, odd);
    });
  });

  group('skipped exercises and finishing (F03)', () {
    test('skipping needs a reason, can be undone and keeps the sets', () async {
      final repo = db.repo;
      await repo.addSet(tuesday, 'squat', const SetEntry(reps: 5));
      for (final reason in [null, '', '  ', 'x' * 121]) {
        await expectLater(
          repo.setSkipped(tuesday, 'squat', true, reason: reason),
          throwsArgumentError,
        );
      }
      await repo.setSkipped(tuesday, 'squat', true, reason: ' Sin tiempo ');
      expect(log(db, 'squat').skipped, isTrue);
      expect(log(db, 'squat').skipReason, 'Sin tiempo');
      expect(log(db, 'squat').completed, isFalse);
      // A skipped exercise takes no new sets until it is brought back.
      await expectLater(
        repo.addSet(tuesday, 'squat', const SetEntry()),
        throwsStateError,
      );
      expect(log(await reopen(), 'squat').skipped, isTrue);
      await db.repo.setSkipped(tuesday, 'squat', false);
      expect(log(db, 'squat').skipReason, isNull);
      expect(log(db, 'squat').sets, hasLength(1));
    });

    test('completing and skipping exclude each other', () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      await repo.setSkipped(tuesday, 'squat', true, reason: 'dolor');
      expect(log(db, 'squat').completed, isFalse);
      expect(log(db, 'squat').skipped, isTrue);
      await repo.toggleExercise(tuesday, 'squat');
      expect(log(db, 'squat').completed, isTrue);
      expect(log(db, 'squat').skipped, isFalse);
      expect(log(db, 'squat').skipReason, isNull);
    });

    test(
      'completing needs every exercise resolved; skips make it partial',
      () async {
        final repo = db.repo;
        await repo.toggleExercise(tuesday, 'squat');
        await expectLater(
          repo.finishSession(tuesday, SessionStatus.completed),
          throwsStateError,
        );
        await repo.setSkipped(tuesday, 'rdl', true, reason: 'sin barra');
        await repo.toggleExercise(tuesday, 'press');
        final moved = await repo.finishSession(
          tuesday,
          SessionStatus.completed,
        );
        expect(moved, isNull, reason: 'skipped work is not moved');
        expect(repo.sessionOn(tuesday)!.status, SessionStatus.partial);
        expect(repo.routineOn(tuesday), isNotNull);
        expect(repo.rescheduleFrom(tuesday), isNull);
        expect((await db.counts())['reschedules'], 0);
        final stored = (await reopen()).repo.sessionOn(tuesday)!;
        expect(stored.status, SessionStatus.partial);
        expect(stored.skippedCount, 1);
        expect(stored.completedCount, 2);
      },
    );

    test('"No terminé" moves only what was neither done nor skipped', () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      await repo.setSkipped(tuesday, 'rdl', true, reason: 'sin barra');
      final moved = await repo.finishSession(tuesday, SessionStatus.partial);
      expect(repo.sessionOn(moved!)!.exercises.map((e) => e.exerciseId), [
        'press',
      ]);
    });

    test('a partial result with nothing pending is refused', () async {
      await doAll(db, tuesday);
      await expectLater(
        db.repo.finishSession(tuesday, SessionStatus.partial),
        throwsStateError,
      );
    });
  });

  group('reopening (F03)', () {
    test(
      'editing a finished session reopens it and leaves an audit entry',
      () async {
        final repo = db.repo;
        await doAll(db, tuesday);
        await repo.finishSession(tuesday, SessionStatus.completed);
        await repo.toggleExercise(tuesday, 'press');
        expect(repo.sessionOn(tuesday)!.status, SessionStatus.scheduled);
        expect(repo.eventsOn(tuesday), hasLength(1));
        expect(repo.eventsOn(tuesday).single.kind, SessionEventKind.reopened);
        // Finishing again and editing a set audits every reopening.
        await repo.toggleExercise(tuesday, 'press');
        await repo.finishSession(tuesday, SessionStatus.completed);
        await repo.addSet(tuesday, 'squat', const SetEntry(reps: 8));
        expect(repo.eventsOn(tuesday), hasLength(2));
        final stored = (await reopen()).repo.eventsOn(tuesday);
        expect(stored, hasLength(2));
        expect(stored.map((e) => e.at), everyElement(now));
      },
    );

    test('editing an unfinished session records nothing', () async {
      await db.repo.toggleExercise(tuesday, 'squat');
      await db.repo.addSet(tuesday, 'squat', const SetEntry(reps: 8));
      expect(db.repo.eventsOn(tuesday), isEmpty);
    });

    test('reopening needs a finished session and counts once', () async {
      final repo = db.repo;
      await expectLater(repo.reopenSession(tuesday), throwsStateError);
      await doAll(db, tuesday);
      await repo.finishSession(tuesday, SessionStatus.completed);
      await repo.reopenSession(tuesday);
      await expectLater(repo.reopenSession(tuesday), throwsStateError);
      expect(repo.eventsOn(tuesday), hasLength(1));
      expect(repo.sessionOn(tuesday)!.status, SessionStatus.scheduled);
      // The checklist is untouched: reopening discards no record.
      expect(repo.sessionOn(tuesday)!.completedCount, 3);
    });

    test('a rest day cannot be reopened or edited', () async {
      final wednesday = DateTime(2026, 9, 30);
      await expectLater(db.repo.reopenSession(wednesday), throwsStateError);
      await expectLater(
        db.repo.addSet(wednesday, 'squat', const SetEntry()),
        throwsStateError,
      );
    });
  });

  group('check-ins and adjustments (F04)', () {
    test(
      'before and after are separate answers that survive restart',
      () async {
        final repo = db.repo;
        await repo.saveCheckIn(
          tuesday,
          const CheckIn(feeling: Feeling.tired, note: 'Dormí poco'),
        );
        expect(repo.afterCheckInOn(tuesday), isNull);
        await repo.saveCheckIn(
          tuesday,
          const CheckIn(
            feeling: Feeling.energetic,
            note: 'Mejor de lo esperado',
          ),
          phase: CheckInPhase.after,
        );
        // Saving the same phase again replaces it.
        await repo.saveCheckIn(
          tuesday,
          const CheckIn(feeling: Feeling.normal),
          phase: CheckInPhase.after,
        );
        final reopened = await reopen();
        expect(reopened.repo.checkInOn(tuesday)!.feeling, Feeling.tired);
        expect(reopened.repo.checkInOn(tuesday)!.note, 'Dormí poco');
        expect(reopened.repo.afterCheckInOn(tuesday)!.feeling, Feeling.normal);
        expect((await db.counts())['check_ins'], 2);
      },
    );

    test('"no answer" is not "normal"', () async {
      expect(db.repo.checkInOn(tuesday), isNull);
      expect(db.repo.afterCheckInOn(tuesday), isNull);
    });

    test(
      'the adjustment decision is per date, reversible and durable',
      () async {
        final repo = db.repo;
        expect(repo.adjustmentOn(tuesday), isNull);
        await repo.setAdjustment(tuesday, false);
        expect(repo.adjustmentOn(tuesday), isFalse);
        expect((await reopen()).repo.adjustmentOn(tuesday), isFalse);
        await db.repo.setAdjustment(tuesday, true);
        expect(db.repo.adjustmentOn(tuesday), isTrue);
        expect(db.repo.adjustmentOn(DateTime(2026, 10, 1)), isNull);
        expect((await reopen()).repo.adjustmentOn(tuesday), isTrue);
      },
    );

    test('feedback and adjustments never touch what was logged', () async {
      final repo = db.repo;
      await repo.addSet(
        tuesday,
        'squat',
        const SetEntry(weightKg: 50, reps: 5),
      );
      await repo.toggleExercise(tuesday, 'squat');
      final before = repo.sessionOn(tuesday)!.toJson();
      await repo.saveCheckIn(tuesday, const CheckIn(feeling: Feeling.injured));
      await repo.setAdjustment(tuesday, true);
      await repo.saveCheckIn(
        tuesday,
        const CheckIn(feeling: Feeling.doms),
        phase: CheckInPhase.after,
      );
      expect(repo.sessionOn(tuesday)!.toJson(), before);
    });
  });

  group('rescheduling (F05)', () {
    final wednesday = DateTime(2026, 9, 30);

    test(
      'the preview shows what would move and where, and saves nothing',
      () async {
        final repo = db.repo;
        await repo.toggleExercise(tuesday, 'squat');
        final counts = await db.counts();
        final partial = repo.previewReschedule(tuesday, SessionStatus.partial);
        expect(partial.pending, ['rdl', 'press']);
        expect(partial.suggested!.date, wednesday);
        // The source was a training day and Thursday is another one.
        expect(partial.suggested!.warnings, [
          'Entrenas el día anterior.',
          'Entrenas al día siguiente.',
        ]);
        final absence = repo.previewReschedule(tuesday, SessionStatus.missed);
        expect(absence.pending, ['squat', 'rdl', 'press']);
        // Thursday, Saturday and the days they hold are never offered.
        final dates = absence.options.map((o) => o.date.day).toList();
        expect(dates, containsAll([30, 2, 4, 5]));
        expect(dates, isNot(contains(1)));
        expect(dates, isNot(contains(3)));
        expect(await db.counts(), counts);
        expect(repo.routineOn(tuesday), isNotNull);
        expect(
          () => repo.previewReschedule(tuesday, SessionStatus.completed),
          throwsArgumentError,
        );
        expect(
          () => repo.previewReschedule(wednesday, SessionStatus.missed),
          throwsStateError,
        );
      },
    );

    test('a move creates the exception and the destination together', () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      final moved = await repo.finishSession(tuesday, SessionStatus.partial);
      expect(moved, wednesday);
      final move = repo.rescheduleInto(wednesday)!;
      expect(move.sourceDate, '2026-09-29');
      expect(move.targetDate, '2026-09-30');
      expect(move.kind, RescheduleKind.partial);
      expect(move.parentId, isNull);
      expect(repo.rescheduleFrom(tuesday)!.id, move.id);
      final reopened = await reopen();
      expect(reopened.repo.rescheduleInto(wednesday)!.id, move.id);
      expect(reopened.repo.routineOn(tuesday), isNull);
      expect(reopened.repo.routineOn(wednesday)!.id, 'legs');
      expect((await db.counts())['reschedules'], 1);
    });

    test(
      'a hand-picked date is used; collisions are explained, not displaced',
      () async {
        final repo = db.repo;
        final friday = DateTime(2026, 10, 2);
        await expectLater(
          repo.finishSession(
            tuesday,
            SessionStatus.missed,
            moveTo: DateTime(2026, 10, 1),
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('ya tiene un entrenamiento'),
            ),
          ),
        );
        for (final bad in [
          tuesday,
          DateTime(2026, 9, 28),
          DateTime(2026, 12, 20),
        ]) {
          await expectLater(
            repo.finishSession(tuesday, SessionStatus.missed, moveTo: bad),
            throwsStateError,
          );
        }
        // Refusals leave the day untouched.
        expect(repo.sessionOn(tuesday)!.status, SessionStatus.scheduled);
        expect((await db.counts())['reschedules'], 0);
        expect(
          await repo.finishSession(
            tuesday,
            SessionStatus.missed,
            moveTo: friday,
          ),
          friday,
        );
        expect(repo.routineOn(friday)!.id, 'legs');
        expect(repo.routineOn(wednesday), isNull);
      },
    );

    test('saving without moving leaves the pending where they are', () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      final moved = await repo.finishSession(
        tuesday,
        SessionStatus.partial,
        reschedule: false,
      );
      expect(moved, isNull);
      final session = repo.sessionOn(tuesday)!;
      expect(session.status, SessionStatus.partial);
      expect(session.exercises.where((e) => !e.resolved), hasLength(2));
      expect(repo.routineOn(tuesday), isNotNull);
      expect(repo.routineOn(wednesday), isNull);
      expect((await db.counts())['reschedules'], 0);
      expect(
        (await reopen()).repo.sessionOn(tuesday)!.status,
        SessionStatus.partial,
      );
    });

    test('pressing again does nothing more (idempotent)', () async {
      final repo = db.repo;
      final first = await repo.finishSession(tuesday, SessionStatus.missed);
      final counts = await db.counts();
      await expectLater(
        repo.finishSession(tuesday, SessionStatus.missed),
        throwsStateError,
      );
      await expectLater(
        repo.finishSession(tuesday, SessionStatus.partial),
        throwsStateError,
      );
      expect(await db.counts(), counts);
      expect(repo.rescheduleInto(first!)!.kind, RescheduleKind.missed);
      final id = repo.rescheduleFrom(tuesday)!.id;
      await repo.undoReschedule(id);
      final afterUndo = await db.counts();
      await repo.undoReschedule(id);
      expect(await db.counts(), afterUndo);
    });

    test(
      'undo restores the day while the destination is not started',
      () async {
        final repo = db.repo;
        await repo.toggleExercise(tuesday, 'squat');
        await repo.finishSession(tuesday, SessionStatus.partial);
        final move = repo.rescheduleFrom(tuesday)!;
        // Reordering the destination is not "starting" it.
        await repo.reorder(wednesday, ['press', 'rdl']);
        await repo.undoReschedule(move.id);
        void expectRestored(Opened o) {
          expect(o.repo.routineOn(tuesday)!.id, 'legs');
          expect(o.repo.routineOn(wednesday), isNull);
          expect(o.repo.sessionOn(wednesday), isNull);
          expect(o.repo.sessionOn(tuesday)!.status, SessionStatus.scheduled);
          expect(o.repo.sessionOn(tuesday)!.completedCount, 1);
          expect(o.repo.rescheduleFrom(tuesday), isNull);
          expect(o.repo.rescheduleInto(wednesday), isNull);
        }

        expectRestored(db);
        expectRestored(await reopen());
        // The undone entry stays in the history, marked.
        final counts = await db.counts();
        expect(counts['reschedules'], 1);
        expect(counts['session_events'], 1);
        // And the day can be moved again, now as a new entry.
        await db.repo.finishSession(tuesday, SessionStatus.missed);
        expect((await db.counts())['reschedules'], 2);
      },
    );

    test('a started destination cannot be undone', () async {
      final repo = db.repo;
      await repo.finishSession(tuesday, SessionStatus.missed);
      final id = repo.rescheduleFrom(tuesday)!.id;
      await repo.toggleExercise(wednesday, 'squat');
      await expectLater(repo.undoReschedule(id), throwsStateError);
      expect(repo.rescheduleFrom(tuesday), isNotNull);
      // Nor can one whose destination was marked skipped or has sets.
      await repo.toggleExercise(wednesday, 'squat');
      await repo.addSet(wednesday, 'rdl', const SetEntry(reps: 8));
      await expectLater(repo.undoReschedule(id), throwsStateError);
      await expectLater(repo.undoReschedule('missing'), throwsArgumentError);
    });

    test('chains keep their lineage and a move that was moved again cannot be undone', () async {
      final repo = db.repo;
      final first = await repo.finishSession(tuesday, SessionStatus.missed);
      final firstId = repo.rescheduleInto(first!)!.id;
      final second = await repo.finishSession(first, SessionStatus.missed);
      final move = repo.rescheduleInto(second!)!;
      expect(move.parentId, firstId);
      expect(second.isAfter(first), isTrue);
      await expectLater(repo.undoReschedule(firstId), throwsStateError);
      // Undo from the end of the chain, then the one before.
      await repo.undoReschedule(move.id);
      await repo.undoReschedule(firstId);
      expect(repo.routineOn(tuesday)!.id, 'legs');
      final reopened = await reopen();
      expect(reopened.repo.rescheduleFrom(tuesday), isNull);
      expect(reopened.repo.rescheduleFrom(first), isNull);
    });

    test('moves cross month and year boundaries', () async {
      final repo = db.repo;
      // A Saturday workout at the end of the year, moved across the new year.
      final saturday = DateTime(2026, 12, 26);
      final moved = await repo.finishSession(
        saturday,
        SessionStatus.missed,
        moveTo: DateTime(2027, 1, 1),
      );
      expect(moved, DateTime(2027, 1, 1));
      expect(repo.routineOn(DateTime(2027, 1, 1))!.id, 'pull');
      final reopened = await reopen();
      expect(
        reopened.repo.rescheduleInto(DateTime(2027, 1, 1))!.sourceDate,
        '2026-12-26',
      );
      // Month end: 30 September moves into October.
      final october = await reopened.repo.finishSession(
        DateTime(2026, 10, 3),
        SessionStatus.missed,
        moveTo: DateTime(2026, 10, 5),
      );
      expect(october, DateTime(2026, 10, 5));
    });

    test('a failure midway leaves no half-applied move', () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      final before = await db.counts();
      h.fault.arm(
        (sql) => sql.startsWith('INSERT') && sql.contains('reschedules'),
      );
      await expectLater(
        repo.finishSession(tuesday, SessionStatus.partial),
        throwsInjected,
      );
      expect(await db.counts(), before);
      expect(repo.rescheduleFrom(tuesday), isNull);
      expect(repo.routineOn(tuesday), isNotNull);
      expect(repo.routineOn(wednesday), isNull);
      h.fault.disarm();
      await repo.finishSession(tuesday, SessionStatus.partial);
      expect(repo.rescheduleFrom(tuesday), isNotNull);
      // A failing undo is atomic too.
      final withMove = await db.counts();
      h.fault.arm(
        (sql) => sql.startsWith('UPDATE') && sql.contains('reschedules'),
      );
      await expectLater(
        repo.undoReschedule(repo.rescheduleFrom(tuesday)!.id),
        throwsInjected,
      );
      expect(await db.counts(), withMove);
      expect(repo.routineOn(wednesday)!.id, 'legs');
    });
  });

  group('the planner (F05)', () {
    bool never(DateTime _) => false;

    test('prefers a gap with rest on both sides, then the earliest', () {
      // Training Monday, Tuesday and Thursday: Saturday has rest around it.
      bool trains(DateTime d) => const [1, 2, 4].contains(d.weekday);
      final options = ReschedulePlanner.options(
        source: DateTime(2026, 9, 28),
        status: SessionStatus.missed,
        trains: trains,
        occupied: trains,
      );
      expect(options.first.date.weekday, DateTime.saturday);
      expect(options.first.clean, isTrue);
      expect(options.last.clean, isFalse);
      expect(options.map((o) => o.date).toSet(), hasLength(options.length));
    });

    test(
      'a partial session still counts as a training day for its neighbours',
      () {
        final source = DateTime(2026, 9, 29);
        final partial = ReschedulePlanner.options(
          source: source,
          status: SessionStatus.partial,
          trains: (d) => d == source,
          occupied: (d) => d == source,
        );
        final missed = ReschedulePlanner.options(
          source: source,
          status: SessionStatus.missed,
          trains: (d) => d == source,
          occupied: (d) => d == source,
        );
        expect(partial.first.date, DateTime(2026, 10, 1));
        expect(missed.first.date, DateTime(2026, 9, 30));
      },
    );

    test('no free day offers no suggestion', () {
      final options = ReschedulePlanner.options(
        source: DateTime(2026, 9, 29),
        status: SessionStatus.missed,
        trains: (_) => true,
        occupied: (_) => true,
      );
      expect(options, isEmpty);
      final preview = ReschedulePreview(
        source: DateTime(2026, 9, 29),
        status: SessionStatus.missed,
        pending: const ['squat'],
        options: options,
      );
      expect(preview.hasGap, isFalse);
      expect(preview.suggested, isNull);
    });

    test('manual dates: after the source, near, and not occupied', () {
      final source = DateTime(2026, 9, 29);
      String? problem(DateTime d, {bool Function(DateTime)? occupied}) =>
          ReschedulePlanner.manualProblem(
            source: source,
            date: d,
            occupied: occupied ?? never,
          );
      expect(problem(DateTime(2026, 9, 30)), isNull);
      expect(problem(source), contains('posterior'));
      expect(problem(DateTime(2026, 9, 1)), contains('posterior'));
      expect(problem(DateTime(2026, 12, 31)), contains('60'));
      expect(problem(DateTime(2026, 11, 28)), isNull);
      expect(
        problem(DateTime(2026, 10, 1), occupied: (d) => d.day == 1),
        contains('no se desplaza'),
      );
    });
  });
}
