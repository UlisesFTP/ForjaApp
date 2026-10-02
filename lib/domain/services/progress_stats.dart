import '../../core/date_utils.dart';
import '../models/models.dart';

enum StatsRange { week, month, all }

/// Sessions planned and already due in a range, by outcome. Future dates are
/// never counted, and a session that was moved counts once (at its new date).
class Compliance {
  const Compliance({
    required this.done,
    required this.partial,
    required this.missed,
    required this.unrecorded,
    required this.moved,
  });
  final int done, partial, missed, unrecorded, moved;

  /// Denominator: planned sessions whose date has passed.
  int get due => done + partial + missed + unrecorded;

  /// Null when nothing was due: no data is not 0 %.
  double? get ratio => due == 0 ? null : done / due;
  String get fraction => '$done/$due';

  static const policy =
      'Cumplimiento = sesiones completas ÷ sesiones planificadas ya vencidas. '
      'Las parciales, ausencias y días sin registro se muestran aparte. '
      'Las fechas futuras no cuentan y una sesión movida cuenta una sola vez, '
      'en su nueva fecha.';
}

/// External volume: weight × repetitions of recorded work sets with a
/// loadable exercise. Warm-ups, bodyweight/time exercises, unknown values and
/// imported 0.1 records (which have no sets) are left out.
class VolumeStats {
  const VolumeStats({
    required this.kgReps,
    required this.setsCounted,
    required this.setsTotal,
  });
  final double kgReps;
  final int setsCounted, setsTotal;

  /// Share of work sets with enough data to count. Null with no work sets.
  double? get coverage => setsTotal == 0 ? null : setsCounted / setsTotal;
  bool get hasData => setsCounted > 0;
}

class TrendPoint {
  const TrendPoint({
    required this.dateKey,
    required this.topWeightKg,
    required this.totalReps,
    required this.kgReps,
  });
  final String dateKey;
  final double topWeightKg;
  final int totalReps;
  final double kgReps;
}

class PersonalBest {
  const PersonalBest(this.weightKg, this.reps, this.dateKey);
  final double weightKg;
  final int reps;
  final String dateKey;
}

class ExerciseTrend {
  const ExerciseTrend(this.exerciseId, this.points, this.best);
  final String exerciseId;
  final List<TrendPoint> points;
  // Observed, not predicted.
  final PersonalBest? best;
}

class ProgressStats {
  /// First and last date (inclusive) of [range] ending today. `all` starts
  /// at the earliest saved session.
  static (DateTime, DateTime) bounds(
    StatsRange range,
    DateTime today,
    Iterable<WorkoutSession> sessions,
  ) {
    final end = dateOnly(today);
    switch (range) {
      case StatsRange.week:
        return (weekOf(end).first, end);
      case StatsRange.month:
        return (DateTime(end.year, end.month), end);
      case StatsRange.all:
        final keys = sessions.map((s) => s.dateKey).toList()..sort();
        return (keys.isEmpty ? end : parseDateKey(keys.first), end);
    }
  }

  static bool _in(String key, DateTime start, DateTime end) =>
      key.compareTo(dateKey(start)) >= 0 && key.compareTo(dateKey(end)) <= 0;

  /// [planned] tells whether the plan has a workout on a date.
  static Compliance compliance({
    required Iterable<WorkoutSession> sessions,
    required Iterable<Reschedule> reschedules,
    required DateTime start,
    required DateTime end,
    required DateTime today,
    required bool Function(DateTime) planned,
    // Earliest date the person has any record on; planned days before it are
    // not held against them.
    String? trackingStart,
  }) {
    final now = dateKey(dateOnly(today));
    final byDate = {for (final s in sessions) s.dateKey: s};
    final movedSources = {
      for (final r in reschedules)
        if (r.active) r.sourceDate,
    };
    var done = 0, partial = 0, missed = 0, unrecorded = 0, moved = 0;
    for (final s in byDate.values) {
      if (!_in(s.dateKey, start, end) || s.dateKey.compareTo(now) > 0) continue;
      if (movedSources.contains(s.dateKey)) {
        moved++;
        continue;
      }
      switch (s.status) {
        case SessionStatus.completed:
          done++;
        case SessionStatus.partial:
          partial++;
        case SessionStatus.missed:
          missed++;
        case SessionStatus.scheduled:
          // Planned, over, and never finished or recorded.
          if (s.dateKey.compareTo(now) < 0) unrecorded++;
      }
    }
    final first = trackingStart ?? (byDate.keys.toList()..sort()).firstOrNull;
    if (first != null) {
      var day = dateOnly(start);
      while (!day.isAfter(end) && dateKey(day).compareTo(now) < 0) {
        final key = dateKey(day);
        if (key.compareTo(first) >= 0 &&
            !byDate.containsKey(key) &&
            planned(day)) {
          unrecorded++;
        }
        day = nextDay(day);
      }
    }
    return Compliance(
      done: done,
      partial: partial,
      missed: missed,
      unrecorded: unrecorded,
      moved: moved,
    );
  }

  static VolumeStats volume({
    required Iterable<WorkoutSession> sessions,
    required DateTime start,
    required DateTime end,
    required LoadType Function(String) loadType,
  }) {
    var kgReps = 0.0, counted = 0, total = 0;
    for (final s in sessions) {
      if (!_in(s.dateKey, start, end)) continue;
      for (final e in s.exercises) {
        if (loadType(e.exerciseId) != LoadType.external) continue;
        for (final set in e.workSets) {
          total++;
          final w = set.weightKg, r = set.reps;
          if (w == null || r == null) continue;
          counted++;
          kgReps += w * r;
        }
      }
    }
    return VolumeStats(kgReps: kgReps, setsCounted: counted, setsTotal: total);
  }

  /// Per-exercise evolution of load and repetitions, from recorded work sets
  /// with both values. An exercise with none has no trend (never a zero line).
  static List<ExerciseTrend> trends({
    required Iterable<WorkoutSession> sessions,
    required DateTime start,
    required DateTime end,
    required LoadType Function(String) loadType,
  }) {
    final points = <String, List<TrendPoint>>{};
    final best = <String, PersonalBest>{};
    final ordered = sessions.toList()
      ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    for (final s in ordered) {
      if (!_in(s.dateKey, start, end)) continue;
      for (final e in s.exercises) {
        if (loadType(e.exerciseId) != LoadType.external) continue;
        final sets = [
          for (final set in e.workSets)
            if (set.weightKg != null && set.reps != null) set,
        ];
        if (sets.isEmpty) continue;
        var top = 0.0, reps = 0, kgReps = 0.0;
        for (final set in sets) {
          final w = set.weightKg!, r = set.reps!;
          if (w > top) top = w;
          reps += r;
          kgReps += w * r;
          final current = best[e.exerciseId];
          if (r >= 1 && (current == null || w > current.weightKg)) {
            best[e.exerciseId] = PersonalBest(w, r, s.dateKey);
          }
        }
        points
            .putIfAbsent(e.exerciseId, () => [])
            .add(
              TrendPoint(
                dateKey: s.dateKey,
                topWeightKg: top,
                totalReps: reps,
                kgReps: kgReps,
              ),
            );
      }
    }
    return [
      for (final entry in points.entries)
        ExerciseTrend(entry.key, entry.value, best[entry.key]),
    ];
  }
}
