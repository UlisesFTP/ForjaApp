import '../../core/date_utils.dart';
import '../models/models.dart';

/// What one day means for the streak.
enum StreakDay {
  /// A workout was done (completed, partial, or with real activity).
  trained,

  /// A planned workout passed without any activity: it breaks the streak.
  missed,

  /// A missed workout that was moved to another day: neutral.
  moved,

  /// Today's workout is still to do: neutral until the day ends.
  pending,

  /// A planned workout still ahead.
  upcoming,

  /// No workout planned: neutral.
  rest,

  /// Before the person started: not held against them.
  untracked,
}

/// Streak of planned training days (rules `streak-v1`, decision D36).
///
/// Each planned training day on which the person trains adds one: a
/// completed or partial session, or real activity (an exercise ticked or a
/// set done) even if the session was never closed. Rest days are neutral. A
/// planned day that ends with no activity breaks the streak, unless it was
/// moved to another day: then the destination counts instead. Today's
/// workout does not break anything until the day is over. Days before the
/// person started (their first workout, or a day they marked as missed) are
/// not judged: a day saved with nothing done, such as an edited weight, does
/// not start the count. Pure, so every rule is tested with fixed dates.
class Streak {
  Streak({
    required Iterable<WorkoutSession> sessions,
    required Iterable<Reschedule> reschedules,
    required this.planned,
    required DateTime today,
  }) : _byDate = {for (final s in sessions) s.dateKey: s},
       _moved = {
         for (final r in reschedules)
           if (r.active) r.sourceDate,
       },
       today = dateOnly(today) {
    // Seen on a phone: a session saved only because a weight was edited,
    // with nothing done, made that very day the first miss.
    final keys = [
      for (final s in _byDate.values)
        if (_hasActivity(s) || s.status == SessionStatus.missed) s.dateKey,
    ]..sort();
    _start = keys.firstOrNull;
  }

  static const version = 'streak-v1';

  final Map<String, WorkoutSession> _byDate;
  final Set<String> _moved;

  /// Whether the plan has a workout on a date.
  final bool Function(DateTime date) planned;
  final DateTime today;
  late final String? _start;

  /// First day the streak looks at: the first workout or marked miss.
  DateTime? get trackingStart => _start == null ? null : parseDateKey(_start);

  static bool _hasActivity(WorkoutSession s) =>
      s.status == SessionStatus.completed ||
      s.status == SessionStatus.partial ||
      s.exercises.any((e) => e.completed || e.sets.any((x) => x.isDone));

  StreakDay dayOn(DateTime date) {
    final day = dateOnly(date);
    final key = dateKey(day);
    final now = dateKey(today);
    final saved = _byDate[key];
    final future = key.compareTo(now) > 0;
    if (!future && saved != null && _hasActivity(saved)) {
      return StreakDay.trained;
    }
    if (!planned(day)) return StreakDay.rest;
    if (future) return StreakDay.upcoming;
    if (_moved.contains(key)) return StreakDay.moved;
    if (key == now) return StreakDay.pending;
    if (_start == null || key.compareTo(_start) < 0) {
      return StreakDay.untracked;
    }
    return StreakDay.missed;
  }

  /// Trained days in a row up to today; today counts once trained.
  late final int current = () {
    final start = trackingStart;
    if (start == null) return 0;
    var count = 0;
    for (var day = today; !day.isBefore(start); day = nextDay(day, -1)) {
      switch (dayOn(day)) {
        case StreakDay.trained:
          count++;
        case StreakDay.missed:
          return count;
        default:
          break;
      }
    }
    return count;
  }();

  /// The longest run there has been, including the current one.
  late final int best = () {
    final start = trackingStart;
    if (start == null) return 0;
    var run = 0, top = 0;
    for (var day = start; !day.isAfter(today); day = nextDay(day, 1)) {
      switch (dayOn(day)) {
        case StreakDay.trained:
          run++;
          if (run > top) top = run;
        case StreakDay.missed:
          run = 0;
        default:
          break;
      }
    }
    return top;
  }();

  /// Today's state: trained, pending (to do today) or rest.
  StreakDay get todayState => dayOn(today);

  /// Trained and missed days between [from] and [to], inclusive.
  ({int trained, int missed}) countIn(DateTime from, DateTime to) {
    var trained = 0, missed = 0;
    for (
      var day = dateOnly(from);
      !day.isAfter(dateOnly(to));
      day = nextDay(day, 1)
    ) {
      switch (dayOn(day)) {
        case StreakDay.trained:
          trained++;
        case StreakDay.missed:
          missed++;
        default:
          break;
      }
    }
    return (trained: trained, missed: missed);
  }
}
