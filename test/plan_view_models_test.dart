import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/coach/view_models/coach_view_model.dart';
import 'package:forja_app/ui/exercises/view_models/exercises_view_model.dart';
import 'package:forja_app/ui/plan/view_models/plan_editor_view_model.dart';
import 'package:forja_app/ui/plan/view_models/plan_view_model.dart';

void main() {
  late LocalForjaRepository repo;
  late CoachViewModel coach;
  late PlanViewModel plan;
  final today = DateTime(2026, 10, 1); // a Thursday
  var ids = 0;
  setUp(() async {
    ids = 0;
    String id() => 'id${ids++}';
    repo = LocalForjaRepository(
      MemoryForjaStore(),
      clock: () => today,
      newId: id,
    );
    await repo.initialize();
    coach = CoachViewModel(repo, repo, repo, clock: () => today, newId: id);
    plan = PlanViewModel(repo, repo, repo, repo, clock: () => today, newId: id);
  });
  tearDown(() {
    coach.dispose();
    plan.dispose();
    repo.dispose();
  });

  const answers = UserProfile(
    experience: Experience.beginner,
    goal: TrainingGoal.muscle,
    trainingDays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
    equipment: {Equipment.dumbbell, Equipment.machine},
    sessionMinutes: 45,
  );

  group('onboarding', () {
    test('is offered until finished or skipped', () async {
      expect(coach.needsOnboarding, isTrue);
      expect(coach.usingExample, isFalse);
      await coach.skipSetup();
      expect(coach.needsOnboarding, isFalse);
      expect(coach.usingExample, isTrue);
      expect(repo.profileHistory.single.reason, ProfileChange.skipped);
      expect(repo.draft, isNull, reason: 'skipping keeps the example plan');
      expect(repo.profile.onboarded, isFalse);
    });
    test(
      'each step is saved so it can be resumed, without filling the history',
      () async {
        expect(
          await coach.saveProgress(
            answers.copyWith(experience: Experience.advanced),
            1,
          ),
          isTrue,
        );
        expect(repo.profile.setupStep, 1);
        expect(repo.profile.experience, Experience.advanced);
        expect(await coach.saveProgress(answers, 4), isTrue);
        expect(repo.profile.setupStep, 4);
        expect(repo.profile.onboarded, isFalse);
        expect(coach.needsOnboarding, isTrue, reason: 'still unfinished');
        expect(repo.profileHistory, isEmpty);
      },
    );
    test(
      'finishing stores the answers, records them and proposes a plan',
      () async {
        expect(
          await coach.finishOnboarding(
            answers.copyWith(weightKg: () => 80, age: () => 30),
          ),
          isTrue,
        );
        final p = repo.profile;
        expect(
          [p.onboarded, p.skippedSetup, p.setupStep, p.weightKg, p.age],
          [true, false, 7, 80.0, 30],
        );
        expect(p.lastReview, '2026-10-01');
        expect(repo.profileHistory.single.reason, ProfileChange.onboarding);
        final draft = repo.draft!;
        expect(draft.source, PlanSource.generated);
        expect([for (final d in draft.days) d.weekday], [1, 3, 5]);
        expect(coach.proposal!.ok, isTrue);
        expect(coach.message, contains('borrador de plan'));
        // Nothing is in force until the draft is accepted.
        expect(repo.planFor(today).source, PlanSource.example);
      },
    );
    test('weight and age are optional', () async {
      expect(await coach.finishOnboarding(answers), isTrue);
      expect(repo.profile.weightKg, isNull);
      expect(repo.profile.age, isNull);
    });
    test('invalid answers change nothing and say why', () async {
      expect(
        await coach.finishOnboarding(answers.copyWith(trainingDays: [1, 2])),
        isFalse,
      );
      expect(coach.error, contains('tres días'));
      expect(repo.profile.onboarded, isFalse);
      expect(repo.draft, isNull);
      expect(repo.profileHistory, isEmpty);
    });
    test('an impossible plan is explained, but the profile is saved', () async {
      final hard = answers.copyWith(
        experience: Experience.advanced,
        equipment: {},
      );
      expect(await coach.finishOnboarding(hard), isTrue);
      expect(repo.profile.onboarded, isTrue);
      expect(repo.draft, isNull);
      expect(coach.proposal!.ok, isFalse);
      expect(coach.message, contains('no hay suficientes ejercicios'));
    });
    test('a second tap while saving is ignored', () async {
      final first = coach.finishOnboarding(answers);
      expect(await coach.finishOnboarding(answers), isFalse);
      expect(await first, isTrue);
      expect(repo.profileHistory, hasLength(1));
    });
  });
  group('profile edits', () {
    test(
      'record a version and propose a draft, leaving the plan in use alone',
      () async {
        await coach.finishOnboarding(answers);
        await repo.acceptDraft(today);
        final inUse = repo.planFor(today).id;
        await coach.saveEdit(
          answers.copyWith(goal: TrainingGoal.fitness, sessionMinutes: 60),
        );
        expect(repo.profileHistory.map((a) => a.reason), [
          ProfileChange.onboarding,
          ProfileChange.edit,
        ]);
        expect(repo.draft!.name, contains('Mejorar condición'));
        expect(repo.planFor(today).id, inUse);
      },
    );
    test('never overwrite a draft the person edited by hand', () async {
      await coach.finishOnboarding(answers);
      await plan.discardDraft();
      expect(await plan.startEditing(), isTrue);
      final manual = repo.draft!;
      expect(manual.source, PlanSource.manual);
      await coach.saveEdit(answers.copyWith(goal: TrainingGoal.fitness));
      expect(repo.draft!.id, manual.id);
      expect(coach.proposal!.notes.single, contains('no se reemplazó'));
      expect(repo.profile.goal, TrainingGoal.fitness);
    });
    test('the history is visible and ordered', () async {
      await coach.finishOnboarding(answers);
      await coach.saveEdit(answers.copyWith(goal: TrainingGoal.strength));
      expect(coach.history.map((a) => a.profile.goal), [
        TrainingGoal.muscle,
        TrainingGoal.strength,
      ]);
    });
  });
  group('plan screen', () {
    test('shows the example until a plan is accepted', () {
      expect(plan.activePlan.source, PlanSource.example);
      expect(plan.versions, isEmpty);
      expect(plan.draft, isNull);
    });
    test('editing starts from a copy of the plan in use', () async {
      expect(await plan.startEditing(), isTrue);
      final draft = plan.draft!;
      expect(draft.source, PlanSource.manual);
      expect(
        draft.routines.map((r) => r.name),
        examplePlan.routines.map((r) => r.name),
      );
      expect(
        draft.routines.map((r) => r.id).toSet().intersection({
          'legs',
          'push',
          'pull',
        }),
        isEmpty,
      );
      // Asking again reuses the draft instead of piling up copies.
      await plan.startEditing();
      expect(repo.plans, hasLength(1));
    });
    test(
      'generating uses the profile and keeps notes for the screen',
      () async {
        await repo.saveProfile(answers.copyWith(onboarded: true));
        expect(await plan.generateFromProfile(), isTrue);
        expect(repo.draft!.source, PlanSource.generated);
        expect(plan.proposal!.notes, isNotEmpty);
        expect(plan.message, contains('Borrador creado'));
      },
    );
    test('a plan that cannot be generated says so', () async {
      await repo.saveProfile(
        answers.copyWith(experience: Experience.advanced, equipment: {}),
      );
      await plan.generateFromProfile();
      expect(repo.draft, isNull);
      expect(plan.proposal!.ok, isFalse);
      expect(plan.message, contains('no hay suficientes'));
    });
    test('accepted versions are listed newest first', () async {
      await coach.finishOnboarding(answers);
      await repo.acceptDraft(today);
      await coach.saveEdit(answers.copyWith(goal: TrainingGoal.fitness));
      await repo.acceptDraft(DateTime(2026, 10, 5));
      expect(plan.versions.map((p) => p.effectiveFrom), [
        '2026-10-05',
        '2026-10-01',
      ]);
      expect(plan.activePlan.effectiveFrom, '2026-10-01');
    });
  });
  group('plan editor', () {
    late PlanEditorViewModel editor;
    setUp(() async {
      await plan.startEditing();
      editor = PlanEditorViewModel(repo, repo, repo, clock: () => today);
    });
    tearDown(() => editor.dispose());

    test('needs a draft', () async {
      await repo.discardDraft();
      expect(() => PlanEditorViewModel(repo, repo, repo), throwsStateError);
    });
    test('changes are in a working copy until saved', () async {
      expect(editor.dirty, isFalse);
      editor.renamePlan('Otro');
      editor.renameRoutine(0, 'Pierna A');
      expect(editor.dirty, isTrue);
      expect(repo.draft!.name, 'Mi plan', reason: 'nothing stored yet');
      expect(await editor.save(), isTrue);
      expect(repo.draft!.name, 'Otro');
      expect(repo.draft!.days[0].routine.name, 'Pierna A');
      expect(editor.dirty, isFalse);
    });
    test('weekdays stay distinct', () {
      expect(editor.setWeekday(0, DateTime.thursday), isFalse);
      expect(editor.working.days[0].weekday, DateTime.tuesday);
      expect(editor.setWeekday(0, DateTime.monday), isTrue);
      expect(editor.working.days[0].weekday, DateTime.monday);
    });
    test('exercises can be moved, added, replaced and removed', () {
      expect(editor.working.days[0].routine.exerciseIds, [
        'squat',
        'rdl',
        'press',
      ]);
      editor.moveExercise(0, 2, 0);
      expect(editor.working.days[0].routine.exerciseIds, [
        'press',
        'squat',
        'rdl',
      ]);
      editor.moveExercise(0, 0, 9); // out of range: ignored
      expect(editor.working.days[0].routine.exerciseIds, [
        'press',
        'squat',
        'rdl',
      ]);
      expect(editor.addExercise(0, exerciseFor('calf')), isTrue);
      expect(
        editor.addExercise(0, exerciseFor('calf')),
        isFalse,
        reason: 'already there',
      );
      expect(editor.replaceExercise(0, 1, exerciseFor('goblet')), isTrue);
      expect(
        editor.replaceExercise(0, 1, exerciseFor('press')),
        isFalse,
        reason: 'already there',
      );
      expect(editor.working.days[0].routine.exerciseIds, [
        'press',
        'goblet',
        'rdl',
        'calf',
      ]);
      editor.removeExercise(0, 0);
      expect(editor.working.days[0].routine.exerciseIds, [
        'goblet',
        'rdl',
        'calf',
      ]);
      // The replacement carries its own default prescription.
      expect(
        editor.working.days[0].routine.exercises.first.restSeconds,
        exerciseFor('goblet').restSeconds,
      );
    });
    test('prescription edits are kept', () {
      final planned = editor.working.days[0].routine.exercises.first;
      editor.updateExercise(
        0,
        0,
        planned.copyWith(
          sets: 5,
          repsMin: 3,
          repsMax: 5,
          rir: 1,
          restSeconds: 200,
          referenceWeightKg: () => 60,
        ),
      );
      final updated = editor.working.days[0].routine.exercises.first;
      expect(
        [
          updated.sets,
          updated.repsMin,
          updated.repsMax,
          updated.rir,
          updated.restSeconds,
          updated.referenceWeightKg,
        ],
        [5, 3, 5, 1, 200, 60.0],
      );
    });
    test(
      'alternatives respect the equipment and exclude what the routine has',
      () async {
        await repo.saveProfile(
          const UserProfile(equipment: {Equipment.dumbbell}),
        );
        // squat (barbell) → goblet (dumbbell) and the body-weight squat.
        final options = editor.alternatives(0, 0).map((e) => e.id).toSet();
        expect(options, {'goblet', 'bodysquat'});
        editor.addExercise(0, exerciseFor('goblet'));
        expect(editor.alternatives(0, 0).map((e) => e.id).toSet(), {
          'bodysquat',
        });
      },
    );
    test('issues block acceptance and name the routine', () {
      expect(editor.issues, isEmpty);
      editor.removeExercise(0, 0);
      editor.removeExercise(0, 0);
      editor.removeExercise(0, 0);
      expect(
        editor.issues,
        contains('Pierna & fuerza: añade al menos un ejercicio.'),
      );
      editor.renameRoutine(0, '');
      expect(editor.issues.any((i) => i.contains('nombre')), isTrue);
    });
    test('can start today or on the next Monday', () {
      expect(editor.startOptions, [
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 5),
      ]);
    });
    test(
      'accepting stores the edits and turns the draft into a version',
      () async {
        editor.renamePlan('Plan aceptado');
        editor.moveExercise(1, 0, 2);
        expect(await editor.accept(DateTime(2026, 10, 5)), isTrue);
        expect(repo.draft, isNull);
        final accepted = repo.plans.single;
        expect(accepted.name, 'Plan aceptado');
        expect(accepted.effectiveFrom, '2026-10-05');
        expect(accepted.routines[1].exerciseIds, [
          'shoulder',
          'triceps',
          'bench',
        ]);
        // The example the copy came from is untouched.
        expect(examplePlan.routines[1].exerciseIds, [
          'bench',
          'shoulder',
          'triceps',
        ]);
      },
    );
    test('an invalid edit is explained and nothing is stored', () async {
      editor.removeExercise(0, 0);
      editor.removeExercise(0, 0);
      editor.removeExercise(0, 0);
      expect(await editor.accept(today), isFalse);
      expect(editor.error, contains('añade al menos un ejercicio'));
      expect(repo.draft, isNotNull);
      expect(repo.plans.every((p) => p.status != PlanStatus.accepted), isTrue);
    });
    test('discarding rejects the draft', () async {
      expect(await editor.discard(), isTrue);
      expect(repo.draft, isNull);
      expect(repo.plans.single.status, PlanStatus.rejected);
    });
  });
  group('library', () {
    late ExercisesViewModel library;
    setUp(() => library = ExercisesViewModel(repo, repo));
    tearDown(() => library.dispose());

    test('lists everything, then narrows by search, muscle and equipment', () {
      expect(library.filtered, hasLength(exerciseCatalog.length));
      library.search('TRICEPS');
      expect(
        library.filtered.map((e) => e.id),
        containsAll(['triceps', 'skull', 'benchdip']),
      );
      library.filter('Brazos');
      expect(library.filtered.every((e) => e.group == 'Brazos'), isTrue);
      library.filterEquipment(Equipment.bodyweight);
      expect(library.filtered.map((e) => e.id), ['benchdip']);
      library.filterEquipment(null);
      library.search('');
      library.filter('Todos');
      expect(library.categories.first, 'Todos');
      expect(
        library.categories,
        containsAll([
          'Piernas',
          'Pecho',
          'Espalda',
          'Hombros',
          'Brazos',
          'Core',
        ]),
      );
    });
    test(
      '"only my equipment" follows the profile and always allows body weight',
      () async {
        await repo.saveProfile(
          const UserProfile(equipment: {Equipment.dumbbell}),
        );
        library.toggleMyEquipment(true);
        expect(library.filtered.map((e) => e.equipment).toSet(), {
          Equipment.dumbbell,
          Equipment.bodyweight,
        });
        expect(
          library.alternatives(exerciseFor('bench')).map((e) => e.id).toSet(),
          {'dbbench', 'inclinedb', 'pushup'},
        );
      },
    );
    test('an explicit equipment filter wins over "my equipment"', () {
      library.toggleMyEquipment(true);
      library.filterEquipment(Equipment.barbell);
      expect(
        library.filtered.every((e) => e.equipment == Equipment.barbell),
        isTrue,
      );
    });
  });
}
