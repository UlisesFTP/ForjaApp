/// Muscle groups the volume rules count. Coarse on purpose: the catalog's
/// own muscles text is the detail.
enum Muscle {
  quads('Cuádriceps', major: true),
  hamstrings('Isquios', major: true),
  glutes('Glúteos', major: true),
  calves('Gemelos'),
  chest('Pecho', major: true),
  shoulders('Hombros', major: true),
  back('Espalda', major: true),
  biceps('Bíceps'),
  triceps('Tríceps'),
  abs('Abdomen'),
  lowerBack('Zona lumbar');

  const Muscle(this.label, {this.major = false});
  final String label;

  /// Large groups whose weekly volume the plan rules check.
  final bool major;
}

/// Which muscles an exercise works: primary ones count a full set, secondary
/// ones half a set.
class MuscleWork {
  const MuscleWork(this.primary, [this.secondary = const []]);
  final List<Muscle> primary, secondary;
}

/// One entry per exercise of the catalog (checked by a test). Exercises
/// outside it (archived ones) count for nothing.
const muscleMap = <String, MuscleWork>{
  'squat': MuscleWork([Muscle.quads, Muscle.glutes]),
  'rdl': MuscleWork([Muscle.hamstrings, Muscle.glutes], [Muscle.lowerBack]),
  'press': MuscleWork([Muscle.quads], [Muscle.glutes]),
  'goblet': MuscleWork([Muscle.quads, Muscle.glutes]),
  'bodysquat': MuscleWork([Muscle.quads, Muscle.glutes]),
  'lunge': MuscleWork([Muscle.quads, Muscle.glutes], [Muscle.hamstrings]),
  'splitsquat': MuscleWork([Muscle.quads, Muscle.glutes], [Muscle.hamstrings]),
  'dbrdl': MuscleWork([Muscle.hamstrings, Muscle.glutes], [Muscle.lowerBack]),
  'glutebridge': MuscleWork([Muscle.glutes], [Muscle.hamstrings]),
  'legcurl': MuscleWork([Muscle.hamstrings]),
  'legext': MuscleWork([Muscle.quads]),
  'calf': MuscleWork([Muscle.calves]),
  'deadlift': MuscleWork(
    [Muscle.hamstrings, Muscle.glutes, Muscle.lowerBack],
    [Muscle.quads, Muscle.back],
  ),
  'bench': MuscleWork([Muscle.chest], [Muscle.triceps, Muscle.shoulders]),
  'dbbench': MuscleWork([Muscle.chest], [Muscle.triceps, Muscle.shoulders]),
  'chestpress': MuscleWork([Muscle.chest], [Muscle.triceps, Muscle.shoulders]),
  'pushup': MuscleWork([Muscle.chest], [Muscle.triceps, Muscle.shoulders]),
  'inclinedb': MuscleWork([Muscle.chest], [Muscle.shoulders, Muscle.triceps]),
  'fly': MuscleWork([Muscle.chest]),
  'shoulder': MuscleWork([Muscle.shoulders], [Muscle.triceps]),
  'ohp': MuscleWork([Muscle.shoulders], [Muscle.triceps]),
  'machshoulder': MuscleWork([Muscle.shoulders], [Muscle.triceps]),
  'lateral': MuscleWork([Muscle.shoulders]),
  'facepull': MuscleWork([Muscle.shoulders], [Muscle.back]),
  'row': MuscleWork([Muscle.back], [Muscle.biceps]),
  'pulldown': MuscleWork([Muscle.back], [Muscle.biceps]),
  'pullup': MuscleWork([Muscle.back], [Muscle.biceps]),
  'dbrow': MuscleWork([Muscle.back], [Muscle.biceps]),
  'barrow': MuscleWork([Muscle.back], [Muscle.biceps, Muscle.lowerBack]),
  'invrow': MuscleWork([Muscle.back], [Muscle.biceps]),
  'triceps': MuscleWork([Muscle.triceps]),
  'skull': MuscleWork([Muscle.triceps]),
  'benchdip': MuscleWork([Muscle.triceps], [Muscle.chest, Muscle.shoulders]),
  'curl': MuscleWork([Muscle.biceps]),
  'hammer': MuscleWork([Muscle.biceps]),
  'cablecurl': MuscleWork([Muscle.biceps]),
  'plank': MuscleWork([Muscle.abs]),
  'crunch': MuscleWork([Muscle.abs]),
  'legraise': MuscleWork([Muscle.abs]),
};
