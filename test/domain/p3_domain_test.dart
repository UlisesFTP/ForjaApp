import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/elapsed_timer.dart';
import 'package:forja_app/core/weight_units.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/training_rules.dart';

void main() {
  group('weight units', () {
    test('kilograms pass through; pounds convert with the exact factor', () {
      expect(WeightUnit.kg.fromKg(52.5), 52.5);
      expect(WeightUnit.lb.fromKg(45.359237), closeTo(100, 1e-12));
      expect(WeightUnit.lb.toKg(100), closeTo(45.359237, 1e-12));
    });

    test('text is rounded for display only, with no trailing zeros', () {
      expect(weightText(40, WeightUnit.kg), '40');
      expect(weightText(52.5, WeightUnit.kg), '52.5');
      expect(weightText(22.679618500000002, WeightUnit.lb), '50');
      expect(weightText(40, WeightUnit.lb), '88.18');
      expect(weightText(0, WeightUnit.kg), '0');
      expect(weightText(100.004, WeightUnit.kg), '100');
    });

    test('typed text accepts comma or dot and rejects non-numbers', () {
      expect(parseWeightKg('52,5', WeightUnit.kg), 52.5);
      expect(parseWeightKg(' 100 ', WeightUnit.lb), closeTo(45.359237, 1e-12));
      for (final bad in ['', 'abc', 'NaN', 'Infinity', '1,2,3']) {
        expect(parseWeightKg(bad, WeightUnit.kg), isNull, reason: bad);
      }
    });

    test('a round trip through the unit never drifts', () {
      for (var kg = 0.0; kg <= 400; kg += 0.37) {
        final back = WeightUnit.lb.toKg(WeightUnit.lb.fromKg(kg));
        expect(back, closeTo(kg, 1e-9));
      }
    });
  });

  group('timers built on timestamps', () {
    test('elapsed time is recomputed from the clock, not from ticks', () {
      var now = DateTime(2026, 9, 29, 10);
      final timer = ElapsedTimer(clock: () => now)..start();
      now = now.add(const Duration(minutes: 7, seconds: 3));
      // Nothing "ticked": the app may have been in the background.
      expect(timer.elapsed, const Duration(minutes: 7, seconds: 3));
      timer.pause();
      now = now.add(const Duration(hours: 1));
      expect(timer.elapsed, const Duration(minutes: 7, seconds: 3));
      expect(timer.isPaused, isTrue);
      timer.start();
      now = now.add(const Duration(seconds: 30));
      expect(timer.elapsed, const Duration(minutes: 7, seconds: 33));
    });

    test('a pause at the very instant of the start is still a pause', () {
      final now = DateTime(2026, 9, 29);
      final timer = ElapsedTimer(clock: () => now)
        ..start()
        ..pause();
      expect(timer.isPaused, isTrue);
      expect(timer.isRunning, isFalse);
      timer.reset();
      expect(timer.isStarted, isFalse);
    });

    test('a clock moved backwards never gives negative time', () {
      var now = DateTime(2026, 9, 29, 10);
      final timer = ElapsedTimer(clock: () => now)..start();
      now = now.subtract(const Duration(minutes: 5));
      expect(timer.elapsed, Duration.zero);
    });

    test('it can be rebuilt from stored timestamps', () {
      final since = DateTime(2026, 9, 29, 10);
      final restored = ElapsedTimer.restore(
        banked: const Duration(minutes: 2),
        runningSince: since,
        clock: () => since.add(const Duration(minutes: 3)),
      );
      expect(restored.isRunning, isTrue);
      expect(restored.elapsed, const Duration(minutes: 5));
      final paused = ElapsedTimer.restore(
        banked: const Duration(minutes: 2),
        clock: () => since,
      );
      expect(paused.isPaused, isTrue);
      expect(paused.elapsed, const Duration(minutes: 2));
    });

    test('the rest countdown runs down, pauses, finishes and cancels', () {
      var now = DateTime(2026, 9, 29, 10);
      final rest = RestTimer(clock: () => now);
      expect(rest.isActive, isFalse);
      rest.start(90);
      now = now.add(const Duration(seconds: 30));
      expect(rest.remaining, const Duration(seconds: 60));
      rest.pause();
      now = now.add(const Duration(minutes: 5));
      expect(rest.remaining, const Duration(seconds: 60));
      rest.resume();
      now = now.add(const Duration(seconds: 61));
      expect(rest.remaining, Duration.zero);
      expect(rest.isDone, isTrue);
      // A finished countdown does not restart by itself.
      rest.resume();
      expect(rest.isDone, isTrue);
      rest.cancel();
      expect(rest.isActive, isFalse);
      expect(() => rest.start(0), throwsArgumentError);
    });

    test('clock text', () {
      expect(clockText(const Duration(seconds: 5)), '0:05');
      expect(clockText(const Duration(minutes: 12, seconds: 9)), '12:09');
    });
  });

  group('the lighter session', () {
    final planned = legacyTemplatePlan.routines.first.exercises.first;
    final exercise = exerciseFor(planned.exerciseId);
    const normal = UserProfile();

    test('tired and sore propose it; an injury does not', () {
      expect(TrainingRules.needsLighterSession(normal, Feeling.tired), isTrue);
      expect(TrainingRules.needsLighterSession(normal, Feeling.doms), isTrue);
      expect(
        TrainingRules.needsLighterSession(
          const UserProfile(energy: Energy.low),
          null,
        ),
        isTrue,
      );
      expect(
        TrainingRules.needsLighterSession(normal, Feeling.injured),
        isFalse,
      );
      // High energy never raises the load by itself.
      expect(
        TrainingRules.needsLighterSession(normal, Feeling.energetic),
        isFalse,
      );
      expect(TrainingRules.needsLighterSession(normal, null), isFalse);
    });

    test('reverting leaves the plan as written', () {
      final plain = TrainingRules.prescription(
        planned,
        exercise,
        normal,
        Feeling.normal,
      );
      final lighter = TrainingRules.prescription(
        planned,
        exercise,
        normal,
        Feeling.tired,
      );
      final reverted = TrainingRules.prescription(
        planned,
        exercise,
        normal,
        Feeling.tired,
        adjust: false,
      );
      expect(lighter.sets, planned.sets - 1);
      expect(lighter.rir, 'RIR 3');
      expect(reverted.sets, plain.sets);
      expect(reverted.rir, plain.rir);
    });

    test('an injury shows "Pausar" and never a lighter prescription', () {
      final p = TrainingRules.prescription(
        planned,
        exercise,
        normal,
        Feeling.injured,
      );
      expect(p.rir, 'Pausar');
      expect(p.sets, planned.sets);
      expect(
        TrainingRules.recommendation(normal, Feeling.injured),
        contains('pausa la sesión'),
      );
    });

    test('the recommendation says when the adjustment was reverted', () {
      expect(
        TrainingRules.recommendation(normal, Feeling.tired),
        contains('Intensidad ajustada'),
      );
      expect(
        TrainingRules.recommendation(normal, Feeling.tired, adjust: false),
        contains('quitado'),
      );
    });
  });

  group('the diff covers the new records', () {
    final move = Reschedule(
      id: 'm1',
      sourceDate: '2026-09-29',
      targetDate: '2026-09-30',
      kind: RescheduleKind.missed,
      createdAt: DateTime.utc(2026, 9, 29),
    );
    final event = SessionEvent(
      id: 'e1',
      dateKey: '2026-09-29',
      kind: SessionEventKind.reopened,
      at: DateTime.utc(2026, 9, 29),
    );

    test('new moves, events, after check-ins and adjustments are written', () {
      final before = AppSnapshot();
      final after = before.copyWith(
        reschedules: [move],
        sessionEvents: [event],
        afterCheckIns: const {'2026-09-29': CheckIn(feeling: Feeling.normal)},
        adjustments: const {'2026-09-29': false},
      );
      final changes = diffSnapshots(before, after);
      expect(changes.reschedules.single.id, 'm1');
      expect(changes.sessionEvents.single.id, 'e1');
      expect(changes.afterCheckIns.keys, ['2026-09-29']);
      expect(changes.adjustments, {'2026-09-29': false});
      expect(changes.isEmpty, isFalse);
      // The same state again is no change at all.
      expect(diffSnapshots(after, after).isEmpty, isTrue);
    });

    test('an undo rewrites only the undone entry', () {
      final before = AppSnapshot(reschedules: [move]);
      final after = before.copyWith(
        reschedules: [move.copyWith(undoneAt: DateTime.utc(2026, 9, 29, 1))],
      );
      final changes = diffSnapshots(before, after);
      expect(changes.reschedules.single.undoneAt, isNotNull);
      expect(changes.sessionEvents, isEmpty);
    });

    test('a decision that flips, or disappears, is a change', () {
      final before = AppSnapshot(adjustments: const {'a': true, 'b': false});
      final flipped = before.copyWith(adjustments: const {'a': false});
      final changes = diffSnapshots(before, flipped);
      expect(changes.adjustments, {'a': false});
      expect(changes.removedAdjustments, {'b'});
    });

    test('moves and events can only grow', () {
      final grown = AppSnapshot(reschedules: [move], sessionEvents: [event]);
      expect(() => diffSnapshots(grown, AppSnapshot()), throwsStateError);
      expect(
        () => diffSnapshots(AppSnapshot(sessionEvents: [event]), AppSnapshot()),
        throwsStateError,
      );
    });

    test('the oracle sees every new field', () {
      final a = AppSnapshot(reschedules: [move]);
      final b = AppSnapshot(
        reschedules: [move.copyWith(undoneAt: DateTime.utc(2026, 10))],
      );
      expect(sameSnapshotContent(a, b), isFalse);
      expect(
        sameSnapshotContent(
          AppSnapshot(adjustments: const {'x': true}),
          AppSnapshot(adjustments: const {'x': false}),
        ),
        isFalse,
      );
      expect(
        sameSnapshotContent(
          AppSnapshot(
            afterCheckIns: const {'x': CheckIn(feeling: Feeling.normal)},
          ),
          AppSnapshot(),
        ),
        isFalse,
      );
    });

    test('0.1 JSON keeps its exact shape despite the richer logs', () {
      final snapshot = AppSnapshot(
        sessions: {
          'd': WorkoutSession(
            dateKey: 'd',
            routineId: 'legs',
            exercises: [
              ExerciseLog(
                exerciseId: 'squat',
                weightKg: 40,
                skipped: true,
                skipReason: 'x',
                sets: const [SetLog(id: 's', kind: SetKind.work, number: 1)],
              ),
            ],
          ),
        },
      );
      final legacy = snapshot.legacyJson()['sessions'] as Map;
      final exercise =
          ((legacy['d'] as Map)['exercises'] as List).single as Map;
      expect(exercise.keys, ['exerciseId', 'weightKg', 'completed']);
      expect(snapshot.toJson()['sessions'], isNot(equals(legacy)));
    });
  });
}
