import '../../../core/date_utils.dart';
import '../../models/models.dart';

/// Everything the expert system reads, as plain data. A ViewModel fills it
/// from the existing repository contracts; nothing here is stored. Lists are
/// put in a fixed order so the result never depends on how they arrive.
class CoachInputs {
  CoachInputs({
    required DateTime today,
    required this.profile,
    required this.plan,
    required this.routineOn,
    required Iterable<WorkoutSession> history,
    required Iterable<Exercise> catalog,
    this.draft,
    Map<String, CheckIn> checkIns = const {},
    Map<String, CheckIn> afterCheckIns = const {},
    this.adjustmentToday,
    Iterable<Reschedule> reschedules = const [],
    Iterable<ProgressionDecision> progressionDecisions = const [],
    Iterable<MonthlyReview> reviews = const [],
    Iterable<CardioSession> cardio = const [],
    Map<String, List<FoodEntry>> food = const {},
    this.goals = const NutritionGoals(),
  }) : today = dateOnly(today),
       history = _sorted(history, (a, b) => a.dateKey.compareTo(b.dateKey)),
       catalog = _sorted(catalog, (a, b) => a.id.compareTo(b.id)),
       checkIns = Map.unmodifiable(checkIns),
       afterCheckIns = Map.unmodifiable(afterCheckIns),
       reschedules = _sorted(
         reschedules,
         (a, b) => _then(a.createdAt.compareTo(b.createdAt), a.id, b.id),
       ),
       progressionDecisions = _sorted(
         progressionDecisions,
         (a, b) => _then(a.decidedAt.compareTo(b.decidedAt), a.id, b.id),
       ),
       reviews = _sorted(
         reviews,
         (a, b) => _then(a.reviewedOn.compareTo(b.reviewedOn), a.id, b.id),
       ),
       cardio = _sorted(
         cardio,
         (a, b) => _then(a.startedAt.compareTo(b.startedAt), a.id, b.id),
       ),
       food = Map.unmodifiable({
         for (final e in food.entries)
           e.key: _sorted(e.value, (a, b) => a.id.compareTo(b.id)),
       });

  static List<T> _sorted<T>(Iterable<T> items, int Function(T, T) compare) =>
      List<T>.unmodifiable(<T>[...items]..sort(compare));

  static int _then(int first, String a, String b) =>
      first != 0 ? first : a.compareTo(b);

  /// How many days of check-ins a ViewModel should provide, counting back
  /// from today (the session dates of the history are needed too).
  static const checkInDays = 42;

  /// How many days of food entries a ViewModel should provide.
  static const foodDays = 14;

  final DateTime today;
  final UserProfile profile;

  /// The plan in use today, and the pending draft if any.
  final PlanVersion plan;
  final PlanVersion? draft;

  /// The workout planned on a date (after moves and overrides), or null.
  final Routine? Function(DateTime date) routineOn;

  /// Saved sessions, oldest first.
  final List<WorkoutSession> history;
  final List<Exercise> catalog;

  /// Before / after training check-ins by date key.
  final Map<String, CheckIn> checkIns, afterCheckIns;

  /// Today's decision about the lighter session: true kept, false reverted,
  /// null undecided.
  final bool? adjustmentToday;
  final List<Reschedule> reschedules;
  final List<ProgressionDecision> progressionDecisions;
  final List<MonthlyReview> reviews;

  /// Finished cardio sessions, oldest first.
  final List<CardioSession> cardio;

  /// Food entries by date key (only the days provided).
  final Map<String, List<FoodEntry>> food;
  final NutritionGoals goals;
}
