enum Equipment { barbell, dumbbell, machine, cable, bodyweight }

/// How the load of an exercise is expressed. For [time] the "reps" are seconds.
enum LoadType { external, bodyweight, time }

/// Movement family. Alternatives share muscle group and pattern.
enum MovementPattern {
  squat,
  hinge,
  lunge,
  horizontalPush,
  verticalPush,
  chestFly,
  lateralRaise,
  rearDelt,
  horizontalPull,
  verticalPull,
  armCurl,
  armExtension,
  legCurl,
  legExtension,
  calf,
  core,
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.group,
    required this.muscles,
    required this.description,
    required this.warmup,
    required this.tip,
    required this.equipment,
    required this.pattern,
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.rir,
    required this.restSeconds,
    this.loadType = LoadType.external,
    this.incrementKg = 2.5,
    this.defaultWeight = 0,
    this.tutorialUrl,
    this.archived = false,
  });

  /// Placeholder for an id that is no longer in the catalog, so history that
  /// references it keeps rendering.
  const Exercise.archived(String id)
    : this(
        id: id,
        name: 'Ejercicio archivado',
        group: 'Archivado',
        muscles: '—',
        description: 'Este ejercicio ya no está en el catálogo. Tus registros anteriores se conservan.',
        warmup: '',
        tip: '',
        equipment: Equipment.bodyweight,
        pattern: MovementPattern.core,
        sets: 1,
        repsMin: 1,
        repsMax: 1,
        rir: 2,
        restSeconds: 60,
        archived: true,
      );

  final String id, name, group, muscles, description, warmup, tip;
  final Equipment equipment;
  final MovementPattern pattern;
  final LoadType loadType;
  // Default prescription, used when the exercise is added to a routine.
  final int sets, repsMin, repsMax, rir, restSeconds;
  final double incrementKg, defaultWeight;
  // Only a verified HTTPS YouTube link; null means "search fallback".
  final String? tutorialUrl;
  final bool archived;

  String get reps =>
      loadType == LoadType.time ? '$repsMin–$repsMax s' : '$repsMin–$repsMax';
  Uri? get tutorial => tutorialUrl == null ? null : Uri.tryParse(tutorialUrl!);
  Uri get tutorialUri => Uri.https('www.youtube.com', '/results', {
    'search_query': '$name técnica gym shorts español',
  });
}
