import '../../../core/date_utils.dart';
import '../../../domain/expert/facts/coach_inputs.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';

/// Reads what the expert system needs from the repository contracts. It only
/// reads: nothing is computed or stored here.
CoachInputs buildCoachInputs({
  required DateTime today,
  required WorkoutRepository workouts,
  required ProfileRepository profiles,
  required PlanRepository plans,
  required ProgressionRepository progression,
  required ExerciseRepository catalog,
  CardioRepository? cardio,
  NutritionRepository? nutrition,
}) {
  final day = dateOnly(today);
  final history = workouts.history;
  final checkDays = <String>{
    for (var i = 0; i < CoachInputs.checkInDays; i++) dateKey(nextDay(day, -i)),
    for (final s in history) s.dateKey,
  };
  final checkIns = <String, CheckIn>{};
  final afterCheckIns = <String, CheckIn>{};
  for (final key in checkDays) {
    final date = parseDateKey(key);
    final before = workouts.checkInOn(date);
    if (before != null) checkIns[key] = before;
    final after = workouts.afterCheckInOn(date);
    if (after != null) afterCheckIns[key] = after;
  }
  final food = <String, List<FoodEntry>>{};
  if (nutrition != null) {
    for (var i = 0; i < CoachInputs.foodDays; i++) {
      final date = nextDay(day, -i);
      food[dateKey(date)] = nutrition.foodOn(date);
    }
  }
  return CoachInputs(
    today: day,
    profile: profiles.profile,
    plan: workouts.planFor(day),
    draft: plans.draft,
    routineOn: workouts.routineOn,
    history: history,
    catalog: catalog.exercises,
    checkIns: checkIns,
    afterCheckIns: afterCheckIns,
    adjustmentToday: workouts.adjustmentOn(day),
    reschedules: workouts.reschedules,
    progressionDecisions: progression.progressionDecisions,
    reviews: profiles.reviews,
    cardio: cardio?.cardioHistory ?? const [],
    food: food,
    goals: nutrition?.goals ?? const NutritionGoals(),
  );
}
