import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/models/models.dart';

/// A Monday; the example plan trains on Tuesday, Thursday and Saturday.
final monday = DateTime(2026, 10, 5);

SetLog workSet(int n, {double? kg = 60, int? reps, int? rir}) => SetLog(
  id: 'set$n',
  kind: SetKind.work,
  number: n,
  weightKg: kg,
  reps: reps,
  rir: rir,
);

/// A logged exercise with [sets] work sets at the top of its catalog range.
ExerciseLog logged(
  String id, {
  int? sets,
  double kg = 60,
  int? reps,
  int? rir,
  bool completed = true,
  TechniqueRating? technique = TechniqueRating.solid,
}) {
  final planned = PlanExercise.fromExercise(exerciseFor(id));
  return ExerciseLog(
    exerciseId: id,
    weightKg: kg,
    completed: completed,
    technique: technique,
    sets: [
      for (var i = 1; i <= (sets ?? planned.sets); i++)
        workSet(
          i,
          kg: kg,
          reps: reps ?? planned.repsMax,
          rir: rir ?? planned.rir,
        ),
    ],
  );
}

WorkoutSession session(
  String date,
  List<ExerciseLog> logs, {
  SessionStatus status = SessionStatus.completed,
}) => WorkoutSession(
  dateKey: date,
  routineId: 'r',
  exercises: logs,
  status: status,
);

CoachInputs coachInputs({
  DateTime? today,
  UserProfile profile = const UserProfile(),
  PlanVersion? plan,
  PlanVersion? draft,
  List<WorkoutSession> history = const [],
  Map<String, CheckIn> checkIns = const {},
  Map<String, CheckIn> afterCheckIns = const {},
  bool? adjustmentToday,
  List<ProgressionDecision> decisions = const [],
  List<MonthlyReview> reviews = const [],
  List<CardioSession> cardio = const [],
  Map<String, List<FoodEntry>> food = const {},
  NutritionGoals goals = const NutritionGoals(),
  List<Reschedule> reschedules = const [],
  Routine? Function(DateTime)? routineOn,
}) {
  final p = plan ?? examplePlan;
  return CoachInputs(
    today: today ?? monday,
    profile: profile,
    plan: p,
    draft: draft,
    routineOn: routineOn ?? (d) => p.routineOnWeekday(d.weekday),
    history: history,
    catalog: exerciseCatalog,
    checkIns: checkIns,
    afterCheckIns: afterCheckIns,
    adjustmentToday: adjustmentToday,
    progressionDecisions: decisions,
    reviews: reviews,
    cardio: cardio,
    food: food,
    goals: goals,
    reschedules: reschedules,
  );
}

/// The example plan's routines under another source (a plan of one's own).
PlanVersion examplePlanCopy(PlanSource source) =>
    examplePlan.copyWith(source: source);

String daysBefore(DateTime day, int n) => dateKey(nextDay(day, -n));

/// A finished cardio session that started at 10:00 local time on [date].
CardioSession cardioOn(
  String date,
  int minutes, {
  CardioActivity activity = CardioActivity.walk,
  CardioIntensity intensity = CardioIntensity.moderate,
  Feeling? feedback = Feeling.normal,
  String? id,
}) {
  final start = parseDateKey(date).add(const Duration(hours: 10)).toUtc();
  final end = start.add(Duration(minutes: minutes));
  return CardioSession(
    id: id ?? 'c$date$minutes${activity.name}',
    activity: activity,
    startedAt: start,
    segments: [
      CardioSegment(
        id: 'seg$date',
        startedAt: start,
        endedAt: end,
        intensity: intensity,
        weightKg: 70,
      ),
    ],
    status: CardioStatus.finished,
    finishedAt: end,
    feedback: feedback,
  );
}

FoodEntry foodOn(
  String date,
  int kcal, {
  double? protein,
  double? carbs,
  double? fat,
  String? id,
}) => FoodEntry(
  id: id ?? 'f$date$kcal',
  dateKey: date,
  name: 'Comida',
  calories: kcal,
  proteinG: protein,
  carbsG: carbs,
  fatG: fat,
);

MonthlyReview reviewOn(String date, {bool pain = false}) => MonthlyReview(
  id: 'r$date',
  reviewedOn: date,
  outcome: ReviewOutcome.accepted,
  rulesVersion: 'review-v1',
  sessionsDone: 10,
  sessionsDue: 12,
  answers: {'pain': pain},
  proposal: const [],
  createdAt: parseDateKey(date).toUtc(),
);
