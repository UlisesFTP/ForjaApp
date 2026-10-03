import '../../core/date_utils.dart';
import '../models/models.dart';
import 'progression_engine.dart';
import 'training_rules.dart';

// What the progression rules are given for an exercise. The progression
// screen and the expert system both build their inputs here, so they always
// evaluate exactly the same thing.

/// The prescription an exercise is compared with: the first routine of
/// [plan] that has it, else the catalog default. On the example plan it is
/// adapted to [profile], as the screen shows it (D41a).
PlanExercise plannedExerciseIn(
  PlanVersion plan,
  Exercise exercise, {
  UserProfile? profile,
}) {
  var planned = PlanExercise.fromExercise(exercise);
  for (final routine in plan.routines) {
    final found = routine.exercise(exercise.id);
    if (found != null) {
      planned = found;
      break;
    }
  }
  return profile == null
      ? planned
      : TrainingRules.effectivePlanned(
          planned,
          exercise,
          profile,
          adaptToProfile: plan.source == PlanSource.example,
        );
}

/// Every session up to [today] in which [exerciseId] appears, in [history]
/// order, with how the person felt before training that day.
List<Exposure> exposuresOf(
  String exerciseId,
  Iterable<WorkoutSession> history,
  DateTime today,
  Feeling? Function(String dateKey) feelingOn,
) {
  final last = dateKey(dateOnly(today));
  return [
    for (final session in history)
      if (session.dateKey.compareTo(last) <= 0)
        for (final log in session.exercises)
          if (log.exerciseId == exerciseId)
            Exposure(
              dateKey: session.dateKey,
              log: log,
              feeling: feelingOn(session.dateKey),
            ),
  ];
}

/// Exercises with at least one completed session: the ones that get a
/// suggestion.
Set<String> exercisesWithWork(Iterable<WorkoutSession> history) => {
  for (final s in history)
    for (final e in s.exercises)
      if (e.completed) e.exerciseId,
};

/// What was decided about this very suggestion, if anything, under any
/// version of the rules: a decision is final for its exercise and date
/// (D21, D41a).
ProgressionDecision? decisionAbout(
  Iterable<ProgressionDecision> decisions,
  ProgressionSuggestion suggestion,
) {
  for (final d in decisions) {
    if (d.exerciseId == suggestion.exerciseId &&
        d.basedOn == suggestion.basedOn) {
      return d;
    }
  }
  return null;
}
