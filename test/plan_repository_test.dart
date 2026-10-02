import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/plan_editing.dart';

PlanVersion draftOn(
  List<int> days, {
  String name = 'Mi plan',
  List<PlanExercise>? exercises,
  required String prefix,
  PlanSource source = PlanSource.manual,
}) => PlanVersion(
  id: '$prefix-plan',
  status: PlanStatus.draft,
  source: source,
  name: name,
  createdAt: DateTime.utc(2026, 10, 1),
  days: [
    for (var i = 0; i < days.length; i++)
      PlanDay(
        days[i],
        Routine(
          id: '$prefix-r$i',
          name: 'Día ${i + 1}',
          focus: '',
          warmup: 'Calienta',
          exercises:
              exercises ??
              [
                PlanExercise.fromExercise(exerciseFor('goblet')),
                PlanExercise.fromExercise(exerciseFor('pushup')),
              ],
        ),
      ),
  ],
);

void main() {
  late LocalForjaRepository repo;
  var today = DateTime(2026, 10, 1);
  var ids = 0;
  setUp(() async {
    today = DateTime(2026, 10, 1);
    ids = 0;
    repo = LocalForjaRepository(
      MemoryForjaStore(),
      clock: () => today,
      newId: () => 'id${ids++}',
    );
    await repo.initialize();
  });
  tearDown(() => repo.dispose());

  final monday = DateTime(2026, 10, 5), tuesday = DateTime(2026, 10, 6);
  const mwf = [DateTime.monday, DateTime.wednesday, DateTime.friday];

  group('plan versions', () {
    test('without an accepted plan the example applies', () {
      expect(repo.planFor(DateTime(2026, 1, 1)).source, PlanSource.example);
      expect(repo.planFor(today).id, 'plan-example');
      expect(repo.routineOn(DateTime(2026, 9, 29))!.id, 'legs');
      expect(repo.routineOn(DateTime(2026, 10, 1))!.id, 'push');
      expect(repo.routineOn(DateTime(2026, 10, 3))!.id, 'pull');
      expect(repo.routineOn(DateTime(2026, 9, 30)), isNull);
      expect(repo.draft, isNull);
      expect(repo.plans, isEmpty);
    });
    test('a draft is stored but never used until accepted', () async {
      await repo.saveDraft(draftOn(mwf, prefix: 'a'));
      expect(repo.draft!.id, 'a-plan');
      expect(repo.plans.single.status, PlanStatus.draft);
      expect(repo.planFor(today).source, PlanSource.example);
      expect(
        repo.routineOn(monday),
        isNull,
        reason: 'Monday is rest in the example',
      );
    });
    test(
      'a new draft replaces the pending one, which is kept as rejected',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.saveDraft(draftOn(mwf, prefix: 'b'));
        expect(repo.draft!.id, 'b-plan');
        expect(repo.plans.map((p) => (p.id, p.status)), [
          ('a-plan', PlanStatus.rejected),
          ('b-plan', PlanStatus.draft),
        ]);
      },
    );
    test('editing the same draft updates it in place', () async {
      final first = draftOn(mwf, prefix: 'a');
      await repo.saveDraft(first);
      await repo.saveDraft(first.copyWith(name: 'Otro nombre'));
      expect(repo.plans, hasLength(1));
      expect(repo.draft!.name, 'Otro nombre');
    });
    test(
      'discarding keeps a rejected record and leaves the plan in use alone',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.discardDraft();
        expect(repo.draft, isNull);
        expect(repo.plans.single.status, PlanStatus.rejected);
        await repo.discardDraft(); // nothing pending: not an error
        expect(repo.plans, hasLength(1));
      },
    );
    test(
      'accepting applies from the chosen date and never rewrites earlier ones',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(monday);
        expect(repo.draft, isNull);
        final accepted = repo.plans.single;
        expect(accepted.status, PlanStatus.accepted);
        expect(accepted.effectiveFrom, '2026-10-05');
        expect(accepted.acceptedAt, isNotNull);
        // Before the start date the example still rules, including "yesterday".
        expect(repo.routineOn(DateTime(2026, 9, 29))!.id, 'legs');
        expect(repo.routineOn(DateTime(2026, 10, 1))!.id, 'push');
        expect(repo.routineOn(DateTime(2026, 10, 3))!.id, 'pull');
        expect(repo.planFor(DateTime(2026, 10, 4)).source, PlanSource.example);
        // From the start date on, the new plan applies.
        expect(repo.routineOn(monday)!.id, 'a-r0');
        expect(repo.routineOn(DateTime(2026, 10, 7))!.id, 'a-r1');
        expect(repo.routineOn(tuesday), isNull);
        expect(repo.planFor(monday).id, 'a-plan');
      },
    );
    test(
      'a session saved earlier keeps its routine when a newer plan arrives',
      () async {
        await repo.toggleExercise(tuesday, 'squat');
        final before = repo.sessionOn(tuesday)!;
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(today);
        expect(repo.routineOn(tuesday)!.id, 'legs');
        expect(
          repo.sessionOn(tuesday)!.exercises.map((e) => e.exerciseId),
          before.exercises.map((e) => e.exerciseId),
        );
        expect(repo.sessionOn(tuesday)!.exercises.first.completed, isTrue);
        // The same weekday a week later follows the new plan.
        expect(repo.routineOn(DateTime(2026, 10, 13)), isNull);
        expect(repo.routineOn(DateTime(2026, 10, 12))!.id, 'a-r0');
      },
    );
    test(
      'a later version replaces the previous one from its own date only',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(today);
        await repo.saveDraft(
          draftOn(const [
            DateTime.tuesday,
            DateTime.thursday,
            DateTime.saturday,
          ], prefix: 'b'),
        );
        await repo.acceptDraft(monday);
        expect(
          repo.routineOn(DateTime(2026, 10, 2))!.id,
          'a-r2',
          reason: 'Friday: still v1',
        );
        expect(
          repo.routineOn(DateTime(2026, 10, 7)),
          isNull,
          reason: 'Wednesday: v2 rests',
        );
        expect(repo.routineOn(tuesday)!.id, 'b-r0');
        expect(
          repo.plans.where((p) => p.status == PlanStatus.accepted),
          hasLength(2),
        );
      },
    );
    test(
      'a version accepted on the same date wins over the earlier one',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(monday);
        await repo.saveDraft(
          draftOn(const [
            DateTime.tuesday,
            DateTime.thursday,
            DateTime.saturday,
          ], prefix: 'b'),
        );
        await repo.acceptDraft(monday);
        expect(repo.routineOn(tuesday)!.id, 'b-r0');
        expect(repo.routineOn(monday), isNull);
      },
    );
    test(
      'old routine ids keep resolving; unknown ones render as archived',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(today);
        expect(repo.routineById('legs').name, 'Pierna & fuerza');
        expect(repo.routineById('a-r0').name, 'Día 1');
        final gone = repo.routineById('nobody');
        expect(gone.name, 'Rutina archivada');
        expect(gone.exercises, isEmpty);
      },
    );
    test('rescheduling uses the plan in force', () async {
      await repo.saveDraft(draftOn(mwf, prefix: 'a'));
      await repo.acceptDraft(today);
      // Monday is training day in the new plan; absence moves it to Tuesday.
      final moved = await repo.finishSession(monday, SessionStatus.missed);
      expect(moved, tuesday);
      expect(repo.routineOn(monday), isNull);
      expect(repo.routineOn(tuesday)!.id, 'a-r0');
    });
    test(
      'sessions start from the plan prescription and reference weights',
      () async {
        final custom = draftOn(
          mwf,
          prefix: 'a',
          exercises: [
            PlanExercise.fromExercise(exerciseFor('goblet'))
                .copyWith(referenceWeightKg: () => 22.5),
            PlanExercise.fromExercise(exerciseFor('pushup')),
          ],
        );
        await repo.saveDraft(custom);
        await repo.acceptDraft(today);
        final logs = repo.sessionOn(monday)!.exercises;
        expect(logs.map((l) => l.exerciseId), ['goblet', 'pushup']);
        expect(logs.first.weightKg, 22.5);
        expect(
          logs.last.weightKg,
          0,
          reason: 'body weight carries no reference load',
        );
      },
    );
  });
  group('what is refused', () {
    test('accepting without a draft', () async {
      await expectLater(repo.acceptDraft(today), throwsStateError);
    });
    test('a start date in the past', () async {
      await repo.saveDraft(draftOn(mwf, prefix: 'a'));
      await expectLater(
        repo.acceptDraft(DateTime(2026, 9, 30)),
        throwsArgumentError,
      );
      expect(repo.draft, isNotNull);
    });
    test('a start date before the plan already in use', () async {
      await repo.saveDraft(draftOn(mwf, prefix: 'a'));
      await repo.acceptDraft(monday);
      await repo.saveDraft(draftOn(mwf, prefix: 'b'));
      await expectLater(repo.acceptDraft(today), throwsStateError);
      expect(repo.draft!.id, 'b-plan');
    });
    test(
      'an incomplete plan cannot be accepted but can be saved as a draft',
      () async {
        final empty = draftOn(mwf, prefix: 'a', exercises: const []);
        await repo.saveDraft(empty);
        await expectLater(repo.acceptDraft(today), throwsArgumentError);
        expect(repo.draft, isNotNull);
        expect(repo.planFor(today).source, PlanSource.example);
      },
    );
    test('accepting twice does not duplicate the version', () async {
      await repo.saveDraft(draftOn(mwf, prefix: 'a'));
      await repo.acceptDraft(today);
      await expectLater(repo.acceptDraft(today), throwsStateError);
      expect(repo.plans, hasLength(1));
    });
    test('invalid drafts', () async {
      await expectLater(
        repo.saveDraft(
          draftOn(mwf, prefix: 'a').copyWith(status: PlanStatus.accepted),
        ),
        throwsArgumentError,
      );
      await expectLater(
        repo.saveDraft(draftOn(const [1, 1, 3], prefix: 'a')),
        throwsArgumentError,
      );
      await expectLater(
        repo.saveDraft(
          draftOn(
            mwf,
            prefix: 'a',
            exercises: [
              PlanExercise.fromExercise(const Exercise.archived('gone')),
            ],
          ),
        ),
        throwsArgumentError,
      );
      expect(repo.plans, isEmpty);
    });
    test(
      'routines must be new: ids of existing versions cannot be reused',
      () async {
        await repo.saveDraft(draftOn(mwf, prefix: 'a'));
        await repo.acceptDraft(today);
        final reuse = draftOn(mwf, prefix: 'b');
        final clash = reuse.copyWith(
          days: [
            PlanDay(
              DateTime.monday,
              Routine(
                id: 'a-r0',
                name: 'x',
                focus: '',
                warmup: '',
                exercises: reuse.days[0].routine.exercises,
              ),
            ),
            reuse.days[1],
            reuse.days[2],
          ],
        );
        await expectLater(repo.saveDraft(clash), throwsStateError);
        final againstExample = clash.copyWith(
          days: [
            PlanDay(
              DateTime.monday,
              Routine(
                id: 'legs',
                name: 'x',
                focus: '',
                warmup: '',
                exercises: reuse.days[0].routine.exercises,
              ),
            ),
            reuse.days[1],
            reuse.days[2],
          ],
        );
        await expectLater(repo.saveDraft(againstExample), throwsStateError);
      },
    );
  });
  group('editing a copy', () {
    test('cloning gives fresh ids so the plan in use cannot change', () async {
      final copy = cloneForEditing(
        examplePlan,
        now: DateTime.utc(2026, 10, 1),
        newId: () => 'n${ids++}',
      );
      expect(copy.status, PlanStatus.draft);
      expect(copy.source, PlanSource.manual);
      expect(copy.name, 'Mi plan');
      expect(
        copy.routines.map((r) => r.id).toSet().intersection({
          'legs',
          'push',
          'pull',
        }),
        isEmpty,
      );
      expect(
        [for (final d in copy.days) d.weekday],
        [DateTime.tuesday, DateTime.thursday, DateTime.saturday],
      );
      await repo.saveDraft(copy);
      await repo.saveDraft(
        copy.copyWith(
          days: [
            PlanDay(
              copy.days[0].weekday,
              copy.days[0].routine.copyWith(exercises: const []),
            ),
            copy.days[1],
            copy.days[2],
          ],
        ),
      );
      // The plan in use is untouched by the edits.
      expect(repo.routineById('legs').exercises, hasLength(3));
      expect(repo.routineOn(DateTime(2026, 9, 29))!.exercises, hasLength(3));
    });
    test('cloning an accepted generated plan keeps its name', () {
      final accepted = draftOn(
        mwf,
        name: 'Fuerza',
        prefix: 'g',
        source: PlanSource.generated,
      ).copyWith(status: PlanStatus.accepted);
      expect(cloneForEditing(accepted, now: DateTime.utc(2026)).name, 'Fuerza');
    });
  });
  group('profile', () {
    test('body weight and age may stay unknown', () async {
      await repo.saveProfile(const UserProfile(onboarded: true));
      expect(repo.profile.weightKg, isNull);
      expect(repo.profile.age, isNull);
    });
    test('values are validated, unknown is allowed', () async {
      for (final bad in [
        const UserProfile(weightKg: 24),
        const UserProfile(weightKg: 301),
        const UserProfile(weightKg: double.nan),
        const UserProfile(age: 13),
        const UserProfile(age: 101),
        const UserProfile(trainingDays: [1, 2]),
        const UserProfile(trainingDays: [1, 1, 2]),
        const UserProfile(trainingDays: [1, 2, 8]),
        const UserProfile(sessionMinutes: 19),
        const UserProfile(sessionMinutes: 181),
      ]) {
        await expectLater(repo.saveProfile(bad), throwsArgumentError);
      }
      expect(repo.profile.onboarded, isFalse);
      expect(repo.profileHistory, isEmpty);
    });
    test('training days are stored sorted', () async {
      await repo.saveProfile(
        const UserProfile(
          trainingDays: [DateTime.saturday, DateTime.monday, DateTime.thursday],
        ),
      );
      expect(repo.profile.trainingDays, [
        DateTime.monday,
        DateTime.thursday,
        DateTime.saturday,
      ]);
    });
    test(
      'recorded answers build an append-only history; progress is not recorded',
      () async {
        await repo.saveProfile(const UserProfile(setupStep: 2)); // progress
        expect(repo.profileHistory, isEmpty);
        await repo.saveProfile(
          const UserProfile(onboarded: true, goal: TrainingGoal.muscle),
          record: ProfileChange.onboarding,
        );
        today = DateTime(2026, 10, 2);
        await repo.saveProfile(
          const UserProfile(
            onboarded: true,
            goal: TrainingGoal.fitness,
            weightKg: 80,
          ),
          record: ProfileChange.edit,
        );
        final history = repo.profileHistory;
        expect(history.map((a) => a.reason), [
          ProfileChange.onboarding,
          ProfileChange.edit,
        ]);
        expect(history.map((a) => a.profile.goal), [
          TrainingGoal.muscle,
          TrainingGoal.fitness,
        ]);
        expect(history.last.profile.weightKg, 80);
        expect(history.map((a) => a.id), ['id0', 'id1']);
        expect(history.first.recordedAt.isUtc, isTrue);
        // The current profile moved on, the history did not change.
        expect(repo.profile.goal, TrainingGoal.fitness);
        expect(history.first.profile.goal, TrainingGoal.muscle);
      },
    );
  });
}
