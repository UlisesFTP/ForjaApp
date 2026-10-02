import '../models/models.dart';

// Explicit rules, not an AI coach or a personalized medical prediction.
class TrainingRules {
  /// What a screen shows for [planned]. A plan the user accepted is taken as
  /// is, apart from today's feeling. The built-in example plan (0.1's fixed
  /// template) is still adapted to the profile, as 0.1 did.
  static Prescription prescription(
    PlanExercise planned,
    Exercise exercise,
    UserProfile profile,
    Feeling? feeling, {
    bool adaptToProfile = false,
    // False when the person reverted the lighter-session proposal (or the
    // exercise is already underway): the plan is shown as written.
    bool adjust = true,
  }) {
    var sets = planned.sets;
    var rir = planned.rir;
    var reps = exercise.loadType == LoadType.time
        ? '${planned.repsMin}–${planned.repsMax} s'
        : '${planned.repsMin}–${planned.repsMax}';
    final beginner =
        adaptToProfile && profile.experience == Experience.beginner;
    if (beginner) sets = 2;
    final tired = adjust && needsLighterSession(profile, feeling);
    if (tired && sets > 2) sets--;
    if (adaptToProfile && exercise.loadType != LoadType.time) {
      reps = switch (profile.goal) {
        TrainingGoal.strength => reps,
        TrainingGoal.muscle => '8–12',
        TrainingGoal.fitness => '12–15',
      };
    }
    final label = feeling == Feeling.injured
        ? 'Pausar'
        : tired || beginner
        ? 'RIR 3'
        : 'RIR $rir';
    return Prescription(
      sets: sets,
      reps: reps,
      rir: label,
      restSeconds: planned.restSeconds,
    );
  }

  /// Low energy, tiredness or soreness propose a lighter session. An injury
  /// is not "tired": it pauses training instead (see [recommendation]).
  static bool needsLighterSession(UserProfile profile, Feeling? feeling) =>
      feeling != Feeling.injured &&
      (profile.energy == Energy.low ||
          feeling == Feeling.tired ||
          feeling == Feeling.doms);

  static String? recommendation(
    UserProfile profile,
    Feeling? feeling, {
    bool adaptToProfile = false,
    bool adjust = true,
  }) {
    if (feeling == Feeling.injured) {
      return 'Si hay lesión o dolor, pausa la sesión y busca valoración profesional.';
    }
    if (needsLighterSession(profile, feeling)) {
      return adjust
          ? 'Intensidad ajustada: menos series y 3 repeticiones en reserva.'
          : 'Ajuste de intensidad quitado: sigues el plan tal como está.';
    }
    if (!adaptToProfile) return null;
    if (profile.experience == Experience.beginner) {
      return 'Plan inicial: 2 series por ejercicio y 3 repeticiones en reserva.';
    }
    if (profile.goal == TrainingGoal.fitness) {
      return 'Repeticiones más altas y control del ritmo.';
    }
    return null;
  }

  static double met(CardioActivity activity) => switch (activity) {
    CardioActivity.walk => 3.5,
    CardioActivity.treadmill => 6,
    CardioActivity.bicycle => 7,
    CardioActivity.elliptical => 5.5,
  };

  /// Null when the body weight is unknown: no estimate is better than a
  /// number made up from a default.
  static int? estimatedCalories(
    CardioActivity activity,
    double? weightKg,
    Duration elapsed,
  ) => weightKg == null
      ? null
      : (met(activity) * weightKg * elapsed.inSeconds / 3600).round();
}
