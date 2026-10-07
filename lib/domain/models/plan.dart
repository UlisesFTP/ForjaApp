import 'exercise.dart';

/// One exercise as prescribed by a routine. Immutable once its plan version is
/// accepted.
class PlanExercise {
  const PlanExercise({
    required this.exerciseId,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.rir,
    required this.restSeconds,
    this.incrementKg = 2.5,
    this.referenceWeightKg,
  });

  factory PlanExercise.fromExercise(Exercise e, {double? weight}) =>
      PlanExercise(
        exerciseId: e.id,
        sets: e.sets,
        repsMin: e.repsMin,
        repsMax: e.repsMax,
        rir: e.rir,
        restSeconds: e.restSeconds,
        incrementKg: e.incrementKg,
        referenceWeightKg:
            weight ?? (e.defaultWeight > 0 ? e.defaultWeight : null),
      );

  final String exerciseId;
  final int sets, repsMin, repsMax, rir, restSeconds;
  final double incrementKg;
  // An example value to start from, never a prescribed load.
  final double? referenceWeightKg;

  PlanExercise copyWith({
    String? exerciseId,
    int? sets,
    int? repsMin,
    int? repsMax,
    int? rir,
    int? restSeconds,
    double? incrementKg,
    double? Function()? referenceWeightKg,
  }) => PlanExercise(
    exerciseId: exerciseId ?? this.exerciseId,
    sets: sets ?? this.sets,
    repsMin: repsMin ?? this.repsMin,
    repsMax: repsMax ?? this.repsMax,
    rir: rir ?? this.rir,
    restSeconds: restSeconds ?? this.restSeconds,
    incrementKg: incrementKg ?? this.incrementKg,
    referenceWeightKg: referenceWeightKg == null
        ? this.referenceWeightKg
        : referenceWeightKg(),
  );

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sets': sets,
    'repsMin': repsMin,
    'repsMax': repsMax,
    'rir': rir,
    'restSeconds': restSeconds,
    'incrementKg': incrementKg,
    'referenceWeightKg': referenceWeightKg,
  };
}

class Routine {
  Routine({
    required this.id,
    required this.name,
    required this.focus,
    required this.warmup,
    required List<PlanExercise> exercises,
  }) : exercises = List.unmodifiable(exercises);
  final String id, name, focus, warmup;
  final List<PlanExercise> exercises;
  List<String> get exerciseIds => [for (final e in exercises) e.exerciseId];
  PlanExercise? exercise(String exerciseId) {
    for (final e in exercises) {
      if (e.exerciseId == exerciseId) return e;
    }
    return null;
  }

  Routine copyWith({
    String? name,
    String? focus,
    String? warmup,
    List<PlanExercise>? exercises,
  }) => Routine(
    id: id,
    name: name ?? this.name,
    focus: focus ?? this.focus,
    warmup: warmup ?? this.warmup,
    exercises: exercises ?? this.exercises,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'focus': focus,
    'warmup': warmup,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

class PlanDay {
  const PlanDay(this.weekday, this.routine);
  // DateTime.monday … DateTime.sunday.
  final int weekday;
  final Routine routine;
}

enum PlanStatus { draft, accepted, rejected }

/// Where a plan came from. `none` is the empty plan of an install that has
/// not created one yet (D45); it is never stored.
enum PlanSource { example, generated, manual, none }

/// A weekly plan. Accepted versions are never mutated: changing a plan
/// creates a new version, so history keeps pointing at what was done.
class PlanVersion {
  PlanVersion({
    required this.id,
    required this.status,
    required this.source,
    required this.name,
    required this.createdAt,
    required List<PlanDay> days,
    this.effectiveFrom,
    this.acceptedAt,
  }) : days = List.unmodifiable(days);
  final String id, name;
  final PlanStatus status;
  final PlanSource source;
  // Calendar date key; null while it is a draft.
  final String? effectiveFrom;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final List<PlanDay> days;

  List<Routine> get routines => [for (final d in days) d.routine];
  Routine? routineOnWeekday(int weekday) {
    for (final d in days) {
      if (d.weekday == weekday) return d.routine;
    }
    return null;
  }

  PlanVersion copyWith({
    PlanStatus? status,
    PlanSource? source,
    String? name,
    String? Function()? effectiveFrom,
    DateTime? acceptedAt,
    List<PlanDay>? days,
  }) => PlanVersion(
    id: id,
    status: status ?? this.status,
    source: source ?? this.source,
    name: name ?? this.name,
    createdAt: createdAt,
    effectiveFrom: effectiveFrom == null ? this.effectiveFrom : effectiveFrom(),
    acceptedAt: acceptedAt ?? this.acceptedAt,
    days: days ?? this.days,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.name,
    'source': source.name,
    'name': name,
    'effectiveFrom': effectiveFrom,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'acceptedAt': acceptedAt?.toUtc().toIso8601String(),
    'days': [
      for (final d in days)
        {'weekday': d.weekday, 'routine': d.routine.toJson()},
    ],
  };
}

/// What the screens show for an exercise today: the plan's prescription after
/// any feeling-based adjustment.
class Prescription {
  const Prescription({
    required this.sets,
    required this.reps,
    required this.rir,
    this.restSeconds = 90,
  });
  final int sets, restSeconds;
  final String reps, rir;
}
