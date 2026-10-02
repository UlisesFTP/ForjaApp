import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/progress/view_models/progress_view_model.dart';
import 'package:forja_app/ui/today/view_models/today_view_model.dart';

import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

void main() {
  final tuesday = DateTime(2026, 9, 29);
  late StoreHarness h;
  late Opened db;
  setUp(() async {
    h = await StoreHarness.create();
    db = await h.open();
  });
  tearDown(() => h.dispose());
  test('weights, completion, order, profile, check-in, food and preferences survive restart', () async {
    final repo = db.repo;
    await repo.updateWeight(tuesday, 'squat', 52.5);
    await repo.toggleExercise(tuesday, 'squat');
    final ids = repo
        .sessionOn(tuesday)!
        .exercises
        .map((e) => e.exerciseId)
        .toList()
        .reversed
        .toList();
    await repo.reorder(tuesday, ids);
    await repo.saveCheckIn(
      tuesday,
      const CheckIn(feeling: Feeling.tired, note: 'Dormí poco'),
    );
    await repo.saveProfile(
      const UserProfile(weightKg: 82, age: 34, onboarded: true),
    );
    await repo.addFood(
      const FoodEntry(
        id: 'food1',
        dateKey: '2026-09-29',
        name: 'Desayuno',
        calories: 420,
      ),
    );
    await repo.saveReminder(
      const ReminderSettings(enabled: true, hour: 19, minute: 30),
    );
    await db.close();
    final reopened = await h.open();
    final session = reopened.repo.sessionOn(tuesday)!;
    expect(session.exercises.map((e) => e.exerciseId).toList(), ids);
    expect(session.exercises.last.weightKg, 52.5);
    expect(session.exercises.last.completed, true);
    expect(reopened.repo.checkInOn(tuesday)!.note, 'Dormí poco');
    expect(reopened.repo.profile.weightKg, 82);
    expect(reopened.repo.foodOn(tuesday).single.calories, 420);
    expect(reopened.repo.reminder.minute, 30);
  });
  test(
    'failed write leaves committed state intact and later writes recover',
    () async {
      final repo = db.repo;
      h.fault.arm((sql) => sql.startsWith('INSERT'));
      await expectLater(
        repo.updateWeight(tuesday, 'squat', 55),
        throwsInjected,
      );
      expect(repo.sessionOn(tuesday)!.exercises.first.weightKg, 40);
      expect((await db.counts()).values.every((n) => n == 0), isTrue);
      h.fault.disarm();
      await repo.updateWeight(tuesday, 'squat', 60);
      expect(repo.sessionOn(tuesday)!.exercises.first.weightKg, 60);
      await db.close();
      final reopened = await h.open();
      expect(reopened.repo.sessionOn(tuesday)!.exercises.first.weightKg, 60);
    },
  );
  test('a failing commit rolls back and later writes recover', () async {
    final repo = db.repo;
    h.fault.failCommit = true;
    await expectLater(repo.updateWeight(tuesday, 'squat', 55), throwsInjected);
    expect(repo.sessionOn(tuesday)!.exercises.first.weightKg, 40);
    expect((await db.counts()).values.every((n) => n == 0), isTrue);
    h.fault.disarm();
    await repo.updateWeight(tuesday, 'squat', 60);
    expect(repo.sessionOn(tuesday)!.exercises.first.weightKg, 60);
  });
  test(
    'a reschedule that fails midway leaves no half-applied change',
    () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      final before = await db.counts();
      // Sessions are written first, the calendar override last.
      h.fault.arm(
        (sql) => sql.startsWith('INSERT') && sql.contains('calendar_overrides'),
      );
      await expectLater(
        repo.finishSession(tuesday, SessionStatus.partial),
        throwsInjected,
      );
      expect(await db.counts(), before);
      expect(repo.sessionOn(tuesday)!.status, SessionStatus.scheduled);
      expect(repo.routineOn(tuesday), isNotNull);
      h.fault.disarm();
      expect(
        await repo.finishSession(tuesday, SessionStatus.partial),
        DateTime(2026, 9, 30),
      );
    },
  );
  test(
    'a full disk reports the failure and stores nothing half-written',
    () async {
      final repo = db.repo;
      await repo.addFood(
        const FoodEntry(
          id: 'seed',
          dateKey: '2026-09-29',
          name: 'a',
          calories: 1,
        ),
      );
      // Freeze the file at its current size: any growth now fails like a full disk.
      final pages = (await db.db.customSelect('PRAGMA page_count').getSingle())
          .read<int>('page_count');
      await db.db.customStatement('PRAGMA max_page_count = $pages');
      var stored = 1, failures = 0;
      for (var i = 0; i < 600 && failures == 0; i++) {
        try {
          await repo.addFood(
            FoodEntry(
              id: 'f$i',
              dateKey: '2026-09-29',
              name: 'x' * 200,
              calories: 100,
            ),
          );
          stored++;
        } catch (_) {
          failures++;
        }
      }
      expect(failures, 1, reason: 'the disk should fill up');
      expect(repo.foodOn(tuesday), hasLength(stored));
      expect((await db.counts())['food_entries'], stored);
      await repo.removeFood('seed');
      expect(repo.foodOn(tuesday), hasLength(stored - 1));
    },
  );
  test('concurrent writes merge against latest committed state', () async {
    final repo = db.repo;
    final ids = repo
        .sessionOn(tuesday)!
        .exercises
        .map((e) => e.exerciseId)
        .toList()
        .reversed
        .toList();
    await Future.wait([
      repo.updateWeight(tuesday, 'squat', 50),
      repo.toggleExercise(tuesday, 'squat'),
      repo.reorder(tuesday, ids),
      repo.saveCheckIn(tuesday, const CheckIn(feeling: Feeling.doms)),
    ]);
    void expectState(Opened o) {
      final session = o.repo.sessionOn(tuesday)!;
      final log = session.exercises.firstWhere((e) => e.exerciseId == 'squat');
      expect(log.weightKg, 50);
      expect(log.completed, true);
      expect(session.exercises.map((e) => e.exerciseId).toList(), ids);
      expect(o.repo.checkInOn(tuesday)!.feeling, Feeling.doms);
    }

    expectState(db);
    await db.close();
    expectState(await h.open());
  });
  test(
    'partial moves only pending exercises and preserves original history',
    () async {
      final repo = db.repo;
      await repo.toggleExercise(tuesday, 'squat');
      final moved = await repo.finishSession(tuesday, SessionStatus.partial);
      expect(moved, DateTime(2026, 9, 30));
      void expectMoved(Opened o) {
        expect(o.repo.routineOn(tuesday), isNull);
        expect(o.repo.sessionOn(tuesday)!.status, SessionStatus.partial);
        expect(o.repo.sessionOn(moved!)!.exercises.map((e) => e.exerciseId), [
          'rdl',
          'press',
        ]);
        expect(o.repo.sessionOn(tuesday)!.exercises.first.completed, true);
      }

      expectMoved(db);
      final vm = TodayViewModel(repo, repo, repo, clock: () => tuesday);
      addTearDown(vm.dispose);
      expect(vm.entries, isEmpty);
      vm.selectDate(moved!);
      expect(vm.entries.length, 2);
      // The explicit rest day must survive a restart.
      await db.close();
      expectMoved(await h.open());
    },
  );
  test(
    'absence moves full routine; occupied rest history is not overwritten',
    () async {
      final repo = db.repo;
      final sunday = DateTime(2026, 10, 4), monday = DateTime(2026, 10, 5);
      // Saturday moves to Sunday; then Sunday moves to Monday, retaining Sunday history.
      await repo.finishSession(DateTime(2026, 10, 3), SessionStatus.missed);
      await repo.finishSession(sunday, SessionStatus.missed);
      expect(repo.sessionOn(monday)!.exercises.length, 3);
      // Thursday searches Friday before the already occupied Sunday.
      final target = await repo.finishSession(
        DateTime(2026, 10, 1),
        SessionStatus.missed,
      );
      expect(target, DateTime(2026, 10, 2));
      expect(repo.sessionOn(sunday)!.status, SessionStatus.missed);
      await db.close();
      final reopened = (await h.open()).repo;
      expect(reopened.sessionOn(monday)!.exercises.length, 3);
      expect(reopened.sessionOn(sunday)!.status, SessionStatus.missed);
      expect(reopened.sessionOn(DateTime(2026, 10, 2))!.exercises.length, 3);
      expect(reopened.routineOn(DateTime(2026, 10, 1)), isNull);
    },
  );
  test(
    'finishing the same session twice does not duplicate the move',
    () async {
      final repo = db.repo;
      final moved = await repo.finishSession(tuesday, SessionStatus.missed);
      final counts = await db.counts();
      await expectLater(
        repo.finishSession(tuesday, SessionStatus.missed),
        throwsStateError,
      );
      expect(await db.counts(), counts);
      expect(repo.sessionOn(moved!)!.exercises.length, 3);
    },
  );
  test('complete requires checklist; unchecking restores editable status and stats', () async {
    final repo = db.repo;
    await expectLater(
      repo.finishSession(tuesday, SessionStatus.completed),
      throwsStateError,
    );
    for (final log in repo.sessionOn(tuesday)!.exercises) {
      await repo.toggleExercise(tuesday, log.exerciseId);
    }
    await repo.finishSession(tuesday, SessionStatus.completed);
    final progress = ProgressViewModel(repo, repo, repo, clock: () => tuesday);
    addTearDown(progress.dispose);
    expect(progress.completedThisWeek, 1);
    await repo.toggleExercise(tuesday, 'squat');
    expect(progress.completedThisWeek, 0);
  });
  test('invalid reorder and weight do not mutate storage', () async {
    final repo = db.repo;
    await expectLater(
      repo.reorder(tuesday, ['squat', 'squat', 'press']),
      throwsArgumentError,
    );
    await expectLater(
      repo.updateWeight(tuesday, 'squat', double.nan),
      throwsArgumentError,
    );
    expect((await db.counts()).values.every((n) => n == 0), isTrue);
  });
}
