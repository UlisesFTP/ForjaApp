import '../../core/ids.dart';
import '../models/labels.dart';
import '../models/models.dart';

class GeneratedPlan {
  const GeneratedPlan({this.draft, this.notes = const [], this.failure});
  final PlanVersion? draft;
  // Short explanations to show next to the draft.
  final List<String> notes;
  // Why no plan was produced; the editor stays available.
  final String? failure;
  bool get ok => draft != null;
}

class _Template {
  const _Template(this.name, this.focus, this.warmup, this.slots);
  final String name, focus, warmup;
  final List<MovementPattern> slots;
}

const _fullBody = [
  _Template(
    'Cuerpo completo A',
    'Piernas · empuje · tirón',
    '5 min de cardio suave + movilidad general',
    [
      MovementPattern.squat,
      MovementPattern.horizontalPush,
      MovementPattern.horizontalPull,
      MovementPattern.core,
      MovementPattern.lateralRaise,
      MovementPattern.armCurl,
      MovementPattern.calf,
    ],
  ),
  _Template(
    'Cuerpo completo B',
    'Cadera · hombro · espalda',
    '5 min de cardio suave + movilidad de cadera y hombros',
    [
      MovementPattern.hinge,
      MovementPattern.verticalPush,
      MovementPattern.verticalPull,
      MovementPattern.lunge,
      MovementPattern.armExtension,
      MovementPattern.core,
      MovementPattern.rearDelt,
    ],
  ),
  _Template(
    'Cuerpo completo C',
    'Piernas · pecho · espalda',
    '5 min de cardio suave + movilidad general',
    [
      MovementPattern.squat,
      MovementPattern.verticalPush,
      MovementPattern.horizontalPull,
      MovementPattern.legCurl,
      MovementPattern.armCurl,
      MovementPattern.core,
      MovementPattern.chestFly,
    ],
  ),
];

const _split = [
  _Template(
    'Empuje',
    'Pecho · hombro · tríceps',
    '5 min de caminata + movilidad de hombros',
    [
      MovementPattern.horizontalPush,
      MovementPattern.verticalPush,
      MovementPattern.horizontalPush,
      MovementPattern.lateralRaise,
      MovementPattern.armExtension,
      MovementPattern.chestFly,
      MovementPattern.armExtension,
    ],
  ),
  _Template(
    'Tirón',
    'Espalda · bíceps',
    '5 min de remo suave + movilidad escapular',
    [
      MovementPattern.verticalPull,
      MovementPattern.horizontalPull,
      MovementPattern.rearDelt,
      MovementPattern.armCurl,
      MovementPattern.horizontalPull,
      MovementPattern.armCurl,
      MovementPattern.core,
    ],
  ),
  _Template(
    'Pierna',
    'Tren inferior',
    '5 min de bici + movilidad de cadera y tobillos',
    [
      MovementPattern.squat,
      MovementPattern.hinge,
      MovementPattern.lunge,
      MovementPattern.legCurl,
      MovementPattern.calf,
      MovementPattern.core,
      MovementPattern.legExtension,
    ],
  ),
];

// Equipment preference by experience: easier-to-learn first for beginners.
const _preference = {
  Experience.beginner: [
    Equipment.machine,
    Equipment.dumbbell,
    Equipment.cable,
    Equipment.bodyweight,
    Equipment.barbell,
  ],
  Experience.intermediate: [
    Equipment.barbell,
    Equipment.dumbbell,
    Equipment.machine,
    Equipment.cable,
    Equipment.bodyweight,
  ],
  Experience.advanced: [
    Equipment.barbell,
    Equipment.dumbbell,
    Equipment.cable,
    Equipment.machine,
    Equipment.bodyweight,
  ],
};

/// Builds a draft from local, versioned templates. It follows simple rules
/// (experience, goal, equipment, time); it is not a personalized prescription
/// and never presents an empty plan as a success.
class PlanGenerator {
  static const templateVersion = 1;

  static GeneratedPlan generate(
    UserProfile profile, {
    required List<Exercise> catalog,
    required DateTime now,
    IdGenerator newId = randomId,
  }) {
    final days = [...profile.trainingDays]..sort();
    if (days.length != 3 ||
        days.toSet().length != 3 ||
        days.any((d) => d < DateTime.monday || d > DateTime.sunday)) {
      return const GeneratedPlan(
        failure: 'Elige exactamente tres días distintos de entrenamiento.',
      );
    }
    final available = {...profile.equipment, Equipment.bodyweight};
    final rank = _preference[profile.experience]!;
    final templates = profile.experience == Experience.beginner
        ? _fullBody
        : _split;
    final target = ((profile.sessionMinutes - 10) / 9).round().clamp(3, 7);
    Exercise exerciseOf(String id) => catalog.firstWhere(
      (e) => e.id == id,
      orElse: () => Exercise.archived(id),
    );
    int minutes(Routine r) => routineMinutes(r, exerciseOf);
    final used = <String>{};
    final notes = <String>[];
    final routines = <Routine>[];
    for (final template in templates) {
      final inRoutine = <String>{};
      final picked = <PlanExercise>[];
      for (final pattern in template.slots) {
        if (picked.length == target) break;
        final options =
            [
              for (final e in catalog)
                if (e.pattern == pattern &&
                    available.contains(e.equipment) &&
                    !inRoutine.contains(e.id))
                  e,
            ]..sort((a, b) {
              final reuse =
                  (used.contains(a.id) ? 1 : 0) - (used.contains(b.id) ? 1 : 0);
              if (reuse != 0) return reuse;
              final byEquipment =
                  rank.indexOf(a.equipment) - rank.indexOf(b.equipment);
              // Catalog order breaks ties, so the result is deterministic.
              return byEquipment != 0
                  ? byEquipment
                  : catalog.indexOf(a) - catalog.indexOf(b);
            });
        if (options.isEmpty) continue;
        final choice = options.first;
        inRoutine.add(choice.id);
        picked.add(_prescribe(choice, profile));
      }
      var routine = Routine(
        id: newId(),
        name: template.name,
        focus: template.focus,
        warmup: template.warmup,
        exercises: picked,
      );
      while (routine.exercises.length > 3 &&
          minutes(routine) > profile.sessionMinutes) {
        routine = routine.copyWith(
          exercises: routine.exercises.sublist(0, routine.exercises.length - 1),
        );
      }
      if (routine.exercises.length < 3) {
        return const GeneratedPlan(
          failure: 'Con el equipo y el tiempo elegidos no hay suficientes ejercicios compatibles. Añade equipo o crea el plan a mano en el editor.',
        );
      }
      used.addAll(routine.exerciseIds);
      routines.add(routine);
      notes.add(
        '${routine.name}: ${routine.exercises.length} ejercicios · unos ${minutes(routine)} min.',
      );
    }
    notes.add(
      'Borrador creado con plantillas locales (v$templateVersion) según tu experiencia, objetivo, equipo y tiempo. Son reglas simples, no una prescripción personalizada: revísalo y edítalo antes de aceptarlo.',
    );
    return GeneratedPlan(
      draft: PlanVersion(
        id: newId(),
        status: PlanStatus.draft,
        source: PlanSource.generated,
        name: 'Plan de 3 días · ${goalLabels[profile.goal]}',
        createdAt: now,
        days: [for (var i = 0; i < 3; i++) PlanDay(days[i], routines[i])],
      ),
      notes: notes,
    );
  }

  static PlanExercise _prescribe(Exercise e, UserProfile profile) {
    var planned = PlanExercise.fromExercise(e);
    var sets = planned.sets, rir = planned.rir;
    var repsMin = planned.repsMin, repsMax = planned.repsMax;
    if (profile.experience == Experience.beginner) {
      sets = 2;
      rir = 3;
    }
    if (profile.energy == Energy.low) {
      if (sets > 2) sets--;
      rir = 3;
    }
    if (e.loadType != LoadType.time) {
      switch (profile.goal) {
        case TrainingGoal.strength:
          break;
        case TrainingGoal.muscle:
          repsMin = 8;
          repsMax = 12;
        case TrainingGoal.fitness:
          repsMin = 12;
          repsMax = 15;
      }
    }
    planned = planned.copyWith(
      sets: sets,
      rir: rir,
      repsMin: repsMin,
      repsMax: repsMax,
    );
    return planned;
  }

  /// Rough session length in minutes: warm-up plus work and rest per set.
  /// [exerciseOf] tells which exercises are timed (their "reps" are seconds).
  static int routineMinutes(
    Routine routine,
    Exercise Function(String id) exerciseOf,
  ) {
    var seconds = 8 * 60;
    for (final e in routine.exercises) {
      final average = (e.repsMin + e.repsMax) / 2;
      final timed = exerciseOf(e.exerciseId).loadType == LoadType.time;
      final work = timed ? average.round() : (average * 3).round();
      seconds += e.sets * (work + e.restSeconds) + 30;
    }
    return (seconds / 60).round();
  }
}
