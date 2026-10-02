import '../models/models.dart';

/// Version of the MET table. Values are rounded figures in the spirit of the
/// Compendium of Physical Activities (Ainsworth et al.), kept as a versioned
/// table so they can be reviewed; they have NOT been checked against the
/// published source yet. The result is an approximation, not a measurement.
const cardioMetTableVersion = 'met-v1';

const _met = {
  CardioActivity.walk: {
    CardioIntensity.low: 2.8,
    CardioIntensity.moderate: 3.5,
    CardioIntensity.high: 4.8,
  },
  CardioActivity.treadmill: {
    CardioIntensity.low: 4.5,
    CardioIntensity.moderate: 6.0,
    CardioIntensity.high: 8.3,
  },
  CardioActivity.bicycle: {
    CardioIntensity.low: 5.0,
    CardioIntensity.moderate: 7.0,
    CardioIntensity.high: 10.0,
  },
  CardioActivity.elliptical: {
    CardioIntensity.low: 4.5,
    CardioIntensity.moderate: 5.5,
    CardioIntensity.high: 7.5,
  },
};

enum CardioCoherence {
  ok,

  /// The clock went backwards: a segment would end before it began, or begins
  /// in the future.
  clockBehind,

  /// A running segment far longer than any plausible workout (a forgotten
  /// session, or a clock that jumped forward).
  implausible,
}

class CardioMath {
  /// Longest a single running segment may look before it is questioned.
  static const implausibleAfter = Duration(hours: 12);

  /// A little tolerance for clocks that differ by a moment.
  static const skew = Duration(minutes: 2);

  static double met(CardioActivity activity, CardioIntensity intensity) =>
      _met[activity]![intensity]!;

  /// kcal ≈ MET × kg × hours, summed over segments with the weight and
  /// intensity each one had. Null when any segment with time lacks a weight:
  /// no estimate is better than one made from a guess. Rounding is for
  /// display only.
  static double? kcal(CardioSession session, DateTime now) {
    var total = 0.0;
    for (final s in session.segments) {
      final d = s.duration(now);
      if (d == Duration.zero) continue;
      final w = s.weightKg;
      if (w == null) return null;
      total += met(session.activity, s.intensity) * w * d.inSeconds / 3600;
    }
    return total;
  }

  static CardioCoherence coherence(CardioSession session, DateTime now) {
    for (final s in session.segments) {
      final end = s.endedAt;
      if (end != null && end.isBefore(s.startedAt)) {
        return CardioCoherence.clockBehind;
      }
      if (end == null && s.startedAt.isAfter(now.add(skew))) {
        return CardioCoherence.clockBehind;
      }
      if (end == null && now.difference(s.startedAt) > implausibleAfter) {
        return CardioCoherence.implausible;
      }
    }
    return CardioCoherence.ok;
  }

  /// Whether the duration should be confirmed before the session is saved.
  static bool needsCorrection(CardioSession session, DateTime now) =>
      coherence(session, now) != CardioCoherence.ok;

  static String clock(Duration d) {
    final s = d.inSeconds;
    return '${(s ~/ 3600).toString().padLeft(2, '0')}:${(s % 3600 ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
