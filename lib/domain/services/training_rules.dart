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

  /// The prescription the progression rules compare with (D41a): on the
  /// example plan, the one the screen shows after adapting it to the profile
  /// (beginner 2 sets and 3 reps in reserve; muscle 8–12 reps; fitness 12–15),
  /// without the day's lighter-session adjustment. A plan of one's own is
  /// taken as written.
  static PlanExercise effectivePlanned(
    PlanExercise planned,
    Exercise exercise,
    UserProfile profile, {
    required bool adaptToProfile,
  }) {
    if (!adaptToProfile) return planned;
    var result = planned;
    if (profile.experience == Experience.beginner) {
      result = result.copyWith(sets: 2, rir: 3);
    }
    if (exercise.loadType != LoadType.time) {
      result = switch (profile.goal) {
        TrainingGoal.strength => result,
        TrainingGoal.muscle => result.copyWith(repsMin: 8, repsMax: 12),
        TrainingGoal.fitness => result.copyWith(repsMin: 12, repsMax: 15),
      };
    }
    return result;
  }

  /// Whether today's lighter session is proposed (D41b). Tiredness or
  /// soreness today always propose it. A low habitual energy alone does not
  /// on a generated plan that already asks for 3 reps in reserve everywhere:
  /// the generator lightened it already, and lightening it every day again
  /// would count the same thing twice.
  static bool lighterSessionProposed(
    UserProfile profile,
    Feeling? feeling, {
    Routine? routine,
    PlanSource? source,
  }) {
    if (!needsLighterSession(profile, feeling)) return false;
    if (feeling == Feeling.tired || feeling == Feeling.doms) return true;
    final alreadyLight =
        source == PlanSource.generated &&
        routine != null &&
        routine.exercises.isNotEmpty &&
        routine.exercises.every((e) => e.rir >= 3);
    return !alreadyLight;
  }

  /// Low energy, tiredness or soreness propose a lighter session. An injury
  /// is not "tired": it pauses training instead (see [recommendation]).
  static bool needsLighterSession(UserProfile profile, Feeling? feeling) =>
      feeling != Feeling.injured &&
      (profile.energy == Energy.low ||
          feeling == Feeling.tired ||
          feeling == Feeling.doms);

  /// [lighter] says whether the lighter session is proposed today (see
  /// [lighterSessionProposed]); by default, whenever [needsLighterSession].
  static String? recommendation(
    UserProfile profile,
    Feeling? feeling, {
    bool adaptToProfile = false,
    bool adjust = true,
    bool? lighter,
  }) {
    if (feeling == Feeling.injured) {
      return 'Si hay lesión o dolor, pausa la sesión y busca valoración profesional.';
    }
    if (lighter ?? needsLighterSession(profile, feeling)) {
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
