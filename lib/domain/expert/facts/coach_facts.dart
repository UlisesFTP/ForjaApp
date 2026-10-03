import '../../../core/date_utils.dart';
import '../../models/models.dart';
import '../../services/cardio_math.dart';
import '../../services/plan_generator.dart';
import '../../services/progress_stats.dart';
import '../../services/progression_engine.dart';
import '../../services/progression_inputs.dart';
import '../../services/training_rules.dart';
import '../knowledge/muscle_map.dart';
import '../knowledge/thresholds.dart';
import '../today_advice.dart';
import 'coach_inputs.dart';

/// The working memory of one evaluation: typed views over [CoachInputs],
/// computed once and never stored.
class CoachFacts {
  CoachFacts(this.inputs);
  final CoachInputs inputs;

  DateTime get today => inputs.today;
  late final String todayKey = dateKey(today);
  UserProfile get profile => inputs.profile;

  // --- Calendar --------------------------------------------------------------

  /// Whole calendar days from [key] to today (UTC, so daylight saving never
  /// shifts it). Positive in the past.
  int daysAgo(String key) {
    final d = parseDateKey(key);
    return DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(d.year, d.month, d.day)).inDays;
  }

  String keyDaysAgo(int days) => dateKey(nextDay(today, -days));

  /// Date keys from [days] - 1 days ago up to today, oldest first.
  List<String> lastDays(int days) => [
    for (var i = days - 1; i >= 0; i--) keyDaysAgo(i),
  ];

  bool plannedOn(String key) => inputs.routineOn(parseDateKey(key)) != null;
  bool get trainingToday => plannedOn(todayKey);

  // --- Check-ins ---------------------------------------------------------------

  Feeling? feelingBefore(String key) => inputs.checkIns[key]?.feeling;
  Feeling? feelingAfter(String key) => inputs.afterCheckIns[key]?.feeling;
  Feeling? get feelingToday => feelingBefore(todayKey);

  /// Dates within the last [days] days (today included) with a check-in,
  /// before or after training, that says [feeling]. Oldest first.
  List<String> datesFeeling(Feeling feeling, int days) {
    final from = keyDaysAgo(days - 1);
    final keys = <String>{
      for (final e in inputs.checkIns.entries)
        if (e.value.feeling == feeling &&
            e.key.compareTo(from) >= 0 &&
            e.key.compareTo(todayKey) <= 0)
          e.key,
      for (final e in inputs.afterCheckIns.entries)
        if (e.value.feeling == feeling &&
            e.key.compareTo(from) >= 0 &&
            e.key.compareTo(todayKey) <= 0)
          e.key,
    };
    return keys.toList()..sort();
  }

  // --- Sessions ----------------------------------------------------------------

  /// Something was really done: a finished session, a ticked exercise or a
  /// set recorded.
  static bool hasActivity(WorkoutSession s) =>
      s.status == SessionStatus.completed ||
      s.status == SessionStatus.partial ||
      s.exercises.any((e) => e.completed || e.sets.any((x) => x.isDone));

  /// Sessions up to today, oldest first.
  late final List<WorkoutSession> pastSessions = [
    for (final s in inputs.history)
      if (s.dateKey.compareTo(todayKey) <= 0) s,
  ];

  /// The latest day before today with real activity, if any.
  late final String? lastActivityBeforeToday = () {
    for (final s in pastSessions.reversed) {
      if (s.dateKey.compareTo(todayKey) < 0 && hasActivity(s)) {
        return s.dateKey;
      }
    }
    return null;
  }();

  // --- Exercises and progression ---------------------------------------------

  late final Map<String, Exercise> _byId = {
    for (final e in inputs.catalog) e.id: e,
  };
  Exercise exercise(String id) => _byId[id] ?? Exercise.archived(id);

  PlanExercise plannedFor(String id) =>
      plannedExerciseIn(inputs.plan, exercise(id), profile: profile);

  List<Exposure> exposures(String id) => exposuresOf(
    id,
    inputs.history,
    today,
    (key) => inputs.checkIns[key]?.feeling,
  );

  /// The progression rules' verdict for every exercise with work, exactly as
  /// the Progress screen computes it.
  late final Map<String, ProgressionSuggestion> progression = {
    for (final id in (exercisesWithWork(inputs.history).toList()..sort()))
      id: ProgressionEngine.evaluate(
        planned: plannedFor(id),
        exercise: exercise(id),
        exposures: exposures(id),
        feelingNow: feelingToday,
      ),
  };

  ProgressionDecision? decisionAbout(ProgressionSuggestion s) =>
      _decisionAbout(inputs.progressionDecisions, s);

  /// Completed, not skipped exposures of an exercise, oldest first.
  List<Exposure> completedExposures(String id) =>
      exposures(id).where((e) => e.log.completed && !e.log.skipped).toList()
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

  /// Completed exposures with every planned work set recorded with load and
  /// reps: the ones a load comparison can trust.
  List<Exposure> fullExposures(String id) {
    final planned = plannedFor(id);
    return [
      for (final e in completedExposures(id))
        if (e.log.workSets.length >= planned.sets &&
            e.log.workSets.every((s) => s.weightKg != null && s.reps != null))
          e,
    ];
  }

  /// [stallSessions] full sessions in a row at one load without more total
  /// reps. Never true while the progression rules suggest an increase.
  bool stalled(String id) {
    if (exercise(id).loadType != LoadType.external) return false;
    if (progression[id]?.kind == ProgressionKind.increase) return false;
    final full = fullExposures(id);
    if (full.length < Thresholds.stallSessions) return false;
    final last = full.sublist(full.length - Thresholds.stallSessions);
    final loads = [
      for (final e in last)
        for (final s in e.log.workSets) s.weightKg!,
    ];
    if (loads.any((w) => (w - loads.first).abs() > 1e-6)) return false;
    int reps(Exposure e) =>
        e.log.workSets.fold(0, (sum, s) => sum + (s.reps ?? 0));
    return reps(last.last) <= reps(last.first);
  }

  // --- Adherence -----------------------------------------------------------------

  /// The first day the person used the app: first workout or marked miss.
  late final String? trackingStart = () {
    for (final s in inputs.history) {
      if (hasActivity(s) || s.status == SessionStatus.missed) return s.dateKey;
    }
    return null;
  }();

  late final Set<String> movedSources = {
    for (final r in inputs.reschedules)
      if (r.active) r.sourceDate,
  };

  late final Map<String, WorkoutSession> _sessionsByDate = {
    for (final s in inputs.history) s.dateKey: s,
  };
  WorkoutSession? sessionOn(String key) => _sessionsByDate[key];

  Compliance compliance(DateTime start, DateTime end) =>
      ProgressStats.compliance(
        sessions: inputs.history,
        reschedules: inputs.reschedules,
        start: start,
        end: end,
        today: today,
        planned: (d) => inputs.routineOn(d) != null,
        trackingStart: trackingStart,
      );

  // --- Plan ------------------------------------------------------------------------

  int routineMinutes(Routine routine) =>
      PlanGenerator.routineMinutes(routine, exercise);

  /// Sets per week of each muscle in the plan in use: a primary muscle
  /// counts a full set, a secondary one half.
  late final Map<Muscle, double> weeklySets = () {
    final sets = <Muscle, double>{};
    for (final day in inputs.plan.days) {
      for (final e in day.routine.exercises) {
        final work = muscleMap[e.exerciseId];
        if (work == null) continue;
        for (final m in work.primary) {
          sets[m] = (sets[m] ?? 0) + e.sets;
        }
        for (final m in work.secondary) {
          sets[m] = (sets[m] ?? 0) + e.sets / 2;
        }
      }
    }
    return sets;
  }();

  /// Training days per week on which each muscle is worked as a primary one.
  late final Map<Muscle, int> weeklyDays = () {
    final days = <Muscle, int>{};
    for (final day in inputs.plan.days) {
      final muscles = {
        for (final e in day.routine.exercises)
          ...?muscleMap[e.exerciseId]?.primary,
      };
      for (final m in muscles) {
        days[m] = (days[m] ?? 0) + 1;
      }
    }
    return days;
  }();

  // --- Cardio ------------------------------------------------------------------------

  /// Minutes of finished cardio started within the last [days] days (today
  /// included), counted as moderate-equivalent: a MET under 3 counts nothing
  /// and 6 or more counts double (WHO 2020).
  int moderateMinutes(int days) {
    final from = keyDaysAgo(days - 1);
    var minutes = 0.0;
    for (final c in inputs.cardio) {
      final key = dateKey(c.startedAt.toLocal());
      if (key.compareTo(from) < 0 || key.compareTo(todayKey) > 0) continue;
      for (final s in c.segments) {
        final end = s.endedAt;
        if (end == null) continue;
        final met = CardioMath.met(c.activity, s.intensity);
        final factor = met >= Thresholds.vigorousMet
            ? 2
            : met >= Thresholds.moderateMet
            ? 1
            : 0;
        minutes += factor * s.duration(end).inSeconds / 60;
      }
    }
    return minutes.round();
  }

  // --- Nutrition ---------------------------------------------------------------------

  /// Food entries of a day, or empty when none were logged (or provided).
  List<FoodEntry> foodOn(String key) => inputs.food[key] ?? const [];

  /// Days among the [days] before today (today excluded: it is not over)
  /// with at least one entry.
  List<String> loggedDays(int days) => [
    for (var i = days; i >= 1; i--)
      if (foodOn(keyDaysAgo(i)).isNotEmpty) keyDaysAgo(i),
  ];

  /// Any food logged in the provided window, today included.
  bool get usesNutrition => inputs.food.values.any((l) => l.isNotEmpty);

  // --- Today -------------------------------------------------------------------

  /// The example plan is adapted to the profile; a plan of one's own is
  /// shown as written.
  bool get adaptsToProfile => inputs.plan.source == PlanSource.example;

  bool get lighterSessionProposed =>
      trainingToday &&
      TrainingRules.lighterSessionProposed(
        profile,
        feelingToday,
        routine: inputs.routineOn(today),
        source: inputs.plan.source,
      );

  bool get lighterSessionApplied =>
      lighterSessionProposed && inputs.adjustmentToday != false;

  /// The advice line Hoy shows for today.
  String? get todayLine => todayAdvice(
    profile: profile,
    feeling: feelingToday,
    adaptToProfile: adaptsToProfile,
    adjust: lighterSessionApplied,
    lighter: TrainingRules.lighterSessionProposed(
      profile,
      feelingToday,
      routine: inputs.routineOn(today),
      source: inputs.plan.source,
    ),
    trainingDay: trainingToday,
    daysSinceLastWorkout: daysSinceLastWorkout(inputs.history, today),
    startedToday: switch (sessionOn(todayKey)) {
      final s? => hasActivity(s),
      null => false,
    },
  );
}

ProgressionDecision? _decisionAbout(
  Iterable<ProgressionDecision> decisions,
  ProgressionSuggestion s,
) => decisionAbout(decisions, s);
