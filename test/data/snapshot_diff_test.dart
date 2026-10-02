import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';

WorkoutSession session(String key, {bool done = false}) => WorkoutSession(
  dateKey: key,
  routineId: 'legs',
  exercises: [ExerciseLog(exerciseId: 'squat', weightKg: 40, completed: done)],
);

FoodEntry food(String id, [int calories = 100]) =>
    FoodEntry(id: id, dateKey: '2026-09-29', name: 'n$id', calories: calories);

void main() {
  test('an unchanged snapshot has no changes', () {
    final snapshot = AppSnapshot(
      sessions: {'2026-09-29': session('2026-09-29')},
      overrides: {'2026-09-29': null},
      food: [food('a')],
    );
    expect(diffSnapshots(snapshot, snapshot).isEmpty, isTrue);
    // copyWith reuses untouched values, which is what identity relies on.
    expect(diffSnapshots(snapshot, snapshot.copyWith()).isEmpty, isTrue);
  });
  test('only sessions whose value changed are rewritten', () {
    final a = session('2026-09-29'), b = session('2026-09-30');
    final before = AppSnapshot(sessions: {'2026-09-29': a, '2026-09-30': b});
    final next = before.copyWith(
      sessions: {
        ...before.sessions,
        '2026-09-30': session('2026-09-30', done: true),
      },
    );
    final changes = diffSnapshots(before, next);
    expect(changes.sessions.keys, ['2026-09-30']);
    expect(changes.removedSessions, isEmpty);
    expect(changes.profile, isNull);
  });
  test('a null override for a new date is a change, not an absence', () {
    final before = AppSnapshot(overrides: {'2026-09-30': 'legs'});
    final next = before.copyWith(
      overrides: {...before.overrides, '2026-09-29': null},
    );
    final changes = diffSnapshots(before, next);
    expect(changes.overrides, {'2026-09-29': null});
    expect(changes.overrides.containsKey('2026-09-29'), isTrue);
  });
  test('overrides that change value or disappear are reported', () {
    final before = AppSnapshot(
      overrides: {'a': 'legs', 'b': null, 'c': 'push'},
    );
    final next = before.copyWith(overrides: {'a': 'pull', 'b': null});
    final changes = diffSnapshots(before, next);
    expect(changes.overrides, {'a': 'pull'});
    expect(changes.removedOverrides, {'c'});
  });
  test('profile, reminder and check-ins are compared by identity', () {
    const profile = UserProfile(weightKg: 80, onboarded: true);
    final before = AppSnapshot(
      profile: profile,
      checkIns: {'2026-09-29': const CheckIn(feeling: Feeling.tired)},
    );
    final next = before.copyWith(
      reminder: const ReminderSettings(enabled: true),
      checkIns: {'2026-09-29': const CheckIn(feeling: Feeling.normal)},
    );
    final changes = diffSnapshots(before, next);
    expect(changes.profile, isNull);
    expect(changes.reminder!.enabled, isTrue);
    expect(changes.checkIns.keys, ['2026-09-29']);
  });
  test('food is added, updated and removed by id, keeping list order', () {
    final a = food('a'), b = food('b'), c = food('c');
    final before = AppSnapshot(food: [a, b]);
    final next = before.copyWith(food: [food('a', 250), c]);
    final changes = diffSnapshots(before, next);
    expect(changes.addedFood.map((f) => f.id), ['c']);
    expect(changes.updatedFood.map((f) => f.id), ['a']);
    expect(changes.removedFood, {'b'});
  });
  test('reordering food is refused instead of silently diverging', () {
    final before = AppSnapshot(food: [food('a'), food('b')]);
    final next = before.copyWith(food: [before.food[1], before.food[0]]);
    expect(() => diffSnapshots(before, next), throwsStateError);
  });
  test('insertAll carries the whole snapshot as new rows', () {
    final snapshot = AppSnapshot(
      sessions: {'2026-09-29': session('2026-09-29')},
      overrides: {'2026-09-29': null},
      checkIns: {'2026-09-29': const CheckIn(feeling: Feeling.doms)},
      food: [food('a'), food('b')],
    );
    final changes = SnapshotChanges.insertAll(snapshot);
    expect(changes.profile, same(snapshot.profile));
    expect(changes.reminder, same(snapshot.reminder));
    expect(changes.sessions, hasLength(1));
    expect(changes.overrides, {'2026-09-29': null});
    expect(changes.checkIns, hasLength(1));
    expect(changes.addedFood.map((f) => f.id), ['a', 'b']);
    expect(changes.isEmpty, isFalse);
  });
  test('content equality ignores map order but not list order', () {
    final one = AppSnapshot(overrides: {'a': 'legs', 'b': null});
    final other = AppSnapshot(overrides: {'b': null, 'a': 'legs'});
    expect(sameSnapshotContent(one, other), isTrue);
    final foods = AppSnapshot(food: [food('a'), food('b')]);
    final swapped = AppSnapshot(food: [food('b'), food('a')]);
    expect(sameSnapshotContent(foods, swapped), isFalse);
    expect(
      sameSnapshotContent(
        foods,
        foods.copyWith(food: [food('a'), food('b', 5)]),
      ),
      isFalse,
    );
  });
}
