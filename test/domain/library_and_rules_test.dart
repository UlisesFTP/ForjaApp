import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/exercise_library.dart';
import 'package:forja_app/domain/services/plan_validator.dart';
import 'package:forja_app/domain/services/training_rules.dart';

Exercise ex(String id) => exerciseFor(id);
PlanExercise planned(String id, {int sets = 3, int rir = 2}) =>
    PlanExercise.fromExercise(ex(id)).copyWith(sets: sets, rir: rir);

Set<String> idsOf(Iterable<Exercise> list) => {for (final e in list) e.id};

void main() {
  group('search', () {
    test('ignores accents and case in both directions', () {
      expect(
        foldAccents('Extensión de TRÍCEPS ñandú'),
        'extension de triceps nandu',
      );
      for (final query in ['triceps', 'tríceps', 'TRICEPS', 'extension']) {
        expect(
          idsOf(searchExercises(exerciseCatalog, query: query)),
          contains('triceps'),
          reason: query,
        );
      }
    });
    test('every word must match, in any order', () {
      expect(
        idsOf(searchExercises(exerciseCatalog, query: 'pecho mancuernas')),
        {'dbbench', 'inclinedb'},
      );
      expect(
        idsOf(searchExercises(exerciseCatalog, query: 'mancuernas pecho')),
        {'dbbench', 'inclinedb'},
      );
      expect(searchExercises(exerciseCatalog, query: 'zzzz'), isEmpty);
      expect(
        searchExercises(exerciseCatalog, query: '   '),
        hasLength(exerciseCatalog.length),
      );
    });
    test('filters by muscle group and equipment, and they combine', () {
      final chest = searchExercises(exerciseCatalog, group: 'Pecho');
      expect(chest.map((e) => e.group).toSet(), {'Pecho'});
      final dumbbellChest = searchExercises(
        exerciseCatalog,
        group: 'Pecho',
        equipment: {Equipment.dumbbell},
      );
      expect(idsOf(dumbbellChest), {'dbbench', 'inclinedb'});
      expect(
        searchExercises(
          exerciseCatalog,
          query: 'polea',
          equipment: {Equipment.cable},
        ).every((e) => e.equipment == Equipment.cable),
        isTrue,
      );
    });
  });
  group('alternatives', () {
    test('share muscle group and movement and respect the equipment', () {
      final all = {...Equipment.values};
      final alternatives = alternativesFor(ex('bench'), exerciseCatalog, all);
      expect(idsOf(alternatives), {
        'dbbench',
        'chestpress',
        'pushup',
        'inclinedb',
      });
      expect(idsOf(alternatives), isNot(contains('bench')));
      for (final e in alternatives) {
        expect(e.group, 'Pecho');
        expect(e.pattern, MovementPattern.horizontalPush);
      }
      expect(
        idsOf(
          alternativesFor(ex('bench'), exerciseCatalog, {Equipment.bodyweight}),
        ),
        {'pushup'},
      );
    });
    test('an exercise nobody else shares has none', () {
      expect(
        alternativesFor(ex('fly'), exerciseCatalog, {...Equipment.values}),
        isEmpty,
      );
    });
    test('an archived exercise has none', () {
      expect(
        alternativesFor(const Exercise.archived('gone'), exerciseCatalog, {
          ...Equipment.values,
        }),
        isEmpty,
      );
    });
  });
  group('prescription', () {
    const profile = UserProfile();
    test('a plan the user accepted is shown as written', () {
      final p = TrainingRules.prescription(
        planned('squat', sets: 5, rir: 1).copyWith(repsMin: 3, repsMax: 5),
        ex('squat'),
        const UserProfile(
          experience: Experience.beginner,
          goal: TrainingGoal.fitness,
        ),
        null,
      );
      expect([p.sets, p.reps, p.rir], [5, '3–5', 'RIR 1']);
      expect(p.restSeconds, ex('squat').restSeconds);
    });
    test('the example plan is still adapted to the profile, as in 0.1', () {
      final beginner = TrainingRules.prescription(
        planned('squat', sets: 4),
        ex('squat'),
        const UserProfile(experience: Experience.beginner),
        null,
        adaptToProfile: true,
      );
      expect([beginner.sets, beginner.rir], [2, 'RIR 3']);
      final muscle = TrainingRules.prescription(
        planned('squat'),
        ex('squat'),
        const UserProfile(goal: TrainingGoal.muscle),
        null,
        adaptToProfile: true,
      );
      expect(muscle.reps, '8–12');
      final timed = TrainingRules.prescription(
        planned('plank').copyWith(repsMin: 30, repsMax: 45),
        ex('plank'),
        const UserProfile(goal: TrainingGoal.fitness),
        null,
        adaptToProfile: true,
      );
      expect(timed.reps, '30–45 s');
    });
    test('tiredness and soreness remove a set and add reserve', () {
      for (final feeling in [Feeling.tired, Feeling.doms]) {
        final p = TrainingRules.prescription(
          planned('squat', sets: 4),
          ex('squat'),
          profile,
          feeling,
        );
        expect([p.sets, p.rir], [3, 'RIR 3'], reason: '$feeling');
      }
      // Never below two sets.
      expect(
        TrainingRules.prescription(
          planned('squat', sets: 2),
          ex('squat'),
          profile,
          Feeling.tired,
        ).sets,
        2,
      );
    });
    test('an injury pauses the prescription', () {
      expect(
        TrainingRules.prescription(
          planned('squat'),
          ex('squat'),
          profile,
          Feeling.injured,
        ).rir,
        'Pausar',
      );
      expect(
        TrainingRules.recommendation(profile, Feeling.injured),
        contains('pausa la sesión'),
      );
    });
    test('recommendations come from simple rules and say so', () {
      expect(TrainingRules.recommendation(profile, null), isNull);
      expect(
        TrainingRules.recommendation(profile, Feeling.tired),
        contains('menos series'),
      );
      expect(
        TrainingRules.recommendation(
          const UserProfile(experience: Experience.beginner),
          null,
          adaptToProfile: true,
        ),
        contains('2 series'),
      );
      // A plan of the user's own is not second-guessed by the profile.
      expect(
        TrainingRules.recommendation(
          const UserProfile(experience: Experience.beginner),
          null,
        ),
        isNull,
      );
    });
  });
  group('cardio estimate', () {
    test('needs a known body weight; unknown is not a default', () {
      expect(
        TrainingRules.estimatedCalories(
          CardioActivity.walk,
          null,
          const Duration(hours: 1),
        ),
        isNull,
      );
      expect(
        TrainingRules.estimatedCalories(
          CardioActivity.bicycle,
          70,
          const Duration(hours: 1),
        ),
        490,
      );
      expect(
        TrainingRules.estimatedCalories(CardioActivity.walk, 70, Duration.zero),
        0,
      );
    });
  });
  group('plan validation', () {
    PlanVersion plan({
      String name = 'Mi plan',
      List<int> days = const [1, 3, 5],
      List<PlanExercise>? exercises,
      String routineName = 'Día',
    }) => PlanVersion(
      id: 'p',
      status: PlanStatus.draft,
      source: PlanSource.manual,
      name: name,
      createdAt: DateTime.utc(2026),
      days: [
        for (var i = 0; i < days.length; i++)
          PlanDay(
            days[i],
            Routine(
              id: 'r$i',
              name: routineName,
              focus: '',
              warmup: '',
              exercises: exercises ?? [planned('squat')],
            ),
          ),
      ],
    );
    List<String> issues(PlanVersion p, {bool accept = true}) =>
        PlanValidator.validate(
          p,
          forAcceptance: accept,
          isKnown: (id) => !exerciseFor(id).archived,
        );

    test('a sound plan has no issues', () => expect(issues(plan()), isEmpty));
    // D45: any number of distinct weekdays (the person's own plan may have
    // four); before, exactly three.
    test('distinct, valid weekdays; at least one to accept', () {
      expect(
        issues(plan(days: [1, 1, 3])),
        contains('Cada día del plan debe ser un día distinto de la semana.'),
      );
      expect(issues(plan(days: [0, 3, 5])), isNotEmpty);
      expect(issues(plan(days: [1, 3])), isEmpty);
      expect(issues(plan(days: [1, 3, 4, 6])), isEmpty);
      expect(
        issues(plan(days: [])),
        contains('Añade al menos un día de entrenamiento.'),
      );
      expect(issues(plan(days: []), accept: false), isEmpty);
    });
    test('names are required and bounded', () {
      expect(issues(plan(name: '  ')), isNotEmpty);
      expect(issues(plan(name: 'x' * 41)), isNotEmpty);
      expect(issues(plan(routineName: '')), isNotEmpty);
    });
    test('a draft may be empty but an accepted plan may not', () {
      final empty = plan(exercises: const []);
      expect(issues(empty, accept: false), isEmpty);
      expect(issues(empty), contains('Día: añade al menos un ejercicio.'));
    });
    test('prescription ranges', () {
      for (final bad in [
        planned('squat').copyWith(sets: 0),
        planned('squat').copyWith(sets: 11),
        planned('squat').copyWith(repsMin: 0),
        planned('squat').copyWith(repsMin: 9, repsMax: 8),
        planned('squat').copyWith(repsMax: 301),
        planned('squat').copyWith(rir: 6),
        planned('squat').copyWith(rir: -1),
        planned('squat').copyWith(restSeconds: 601),
        planned('squat').copyWith(incrementKg: -1),
        planned('squat').copyWith(incrementKg: double.nan),
        planned('squat').copyWith(referenceWeightKg: () => 2001),
        planned('squat').copyWith(referenceWeightKg: () => double.infinity),
      ]) {
        expect(
          issues(plan(exercises: [bad]), accept: false),
          isNotEmpty,
          reason: '${bad.toJson()}',
        );
      }
      expect(
        issues(
          plan(
            exercises: [
              planned('squat').copyWith(referenceWeightKg: () => null),
            ],
          ),
        ),
        isEmpty,
      );
    });
    test('repeated or unknown exercises', () {
      expect(
        issues(plan(exercises: [planned('squat'), planned('squat')])),
        isNotEmpty,
      );
      expect(
        issues(
          plan(
            exercises: [
              PlanExercise.fromExercise(const Exercise.archived('gone')),
            ],
          ),
        ),
        contains('Día: hay un ejercicio que ya no existe en el catálogo.'),
      );
    });
  });
}
