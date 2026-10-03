import '../../core/date_utils.dart';
import '../models/models.dart';
import '../services/training_rules.dart';
import 'facts/coach_facts.dart';
import 'knowledge/rules/safety_rules.dart' show breakAdvice;

/// Whole days from the latest day before [today] with real activity to
/// [today], or null when there is none (a new person is not "back").
int? daysSinceLastWorkout(Iterable<WorkoutSession> history, DateTime today) {
  final day = dateOnly(today), todayKey = dateKey(day);
  String? last;
  for (final s in history) {
    if (s.dateKey.compareTo(todayKey) < 0 &&
        CoachFacts.hasActivity(s) &&
        (last == null || s.dateKey.compareTo(last) > 0)) {
      last = s.dateKey;
    }
  }
  if (last == null) return null;
  final d = parseDateKey(last);
  return DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(d.year, d.month, d.day)).inDays;
}

/// The advice line of Hoy (D41e): the existing rules' text, and before it
/// what to do when coming back after a break, on a training day that has
/// not started yet. Shared by Hoy and the expert system, so they never
/// disagree.
String? todayAdvice({
  required UserProfile profile,
  required Feeling? feeling,
  required bool adaptToProfile,
  required bool adjust,
  required bool lighter,
  required bool trainingDay,
  int? daysSinceLastWorkout,
  bool startedToday = false,
}) {
  final base = TrainingRules.recommendation(
    profile,
    feeling,
    adaptToProfile: adaptToProfile,
    adjust: adjust,
    lighter: lighter,
  );
  if (feeling == Feeling.injured ||
      !trainingDay ||
      startedToday ||
      daysSinceLastWorkout == null) {
    return base;
  }
  final back = breakAdvice(daysSinceLastWorkout);
  if (back == null) return base;
  return base == null ? back : '$back $base';
}
