import '../../core/date_utils.dart';
import '../models/models.dart';

/// A date a session could move to, with the reasons to think twice.
class RescheduleOption {
  const RescheduleOption(this.date, [this.warnings = const []]);
  final DateTime date;
  final List<String> warnings;
  // Rest on both sides: the preferred kind of gap.
  bool get clean => warnings.isEmpty;
}

/// What moving a session would do, shown before anything is saved.
class ReschedulePreview {
  const ReschedulePreview({
    required this.source,
    required this.status,
    required this.pending,
    required this.options,
  });
  final DateTime source;
  final SessionStatus status;
  // Exercises that would move (all of them for an absence).
  final List<String> pending;
  // Free dates after [source], preferred first.
  final List<RescheduleOption> options;
  RescheduleOption? get suggested => options.isEmpty ? null : options.first;
  bool get hasGap => options.isNotEmpty;
}

/// Pure date logic for rescheduling; storage and rules live elsewhere.
class ReschedulePlanner {
  /// Days searched for a free slot, per the SDD (next 14 days).
  static const window = 14;

  /// Furthest date a person can pick by hand.
  static const manualWindow = 60;

  /// Free days within [window] after [source]: no routine and no saved
  /// session, so nothing is displaced. A day with rest on both sides comes
  /// first; otherwise the earliest one, with the back-to-back warning.
  /// [trains] says whether a date has a workout. An absence frees [source].
  static List<RescheduleOption> options({
    required DateTime source,
    required SessionStatus status,
    required bool Function(DateTime) trains,
    required bool Function(DateTime) occupied,
  }) {
    bool trainsOn(DateTime d) => dateKey(d) == dateKey(source)
        ? status != SessionStatus.missed
        : trains(d);
    final found = <RescheduleOption>[];
    for (var i = 1; i <= window; i++) {
      final date = nextDay(source, i);
      if (occupied(date)) continue;
      found.add(RescheduleOption(date, warningsFor(date, trainsOn)));
    }
    return [...found.where((o) => o.clean), ...found.where((o) => !o.clean)];
  }

  static List<String> warningsFor(
    DateTime date,
    bool Function(DateTime) trains,
  ) => [
    if (trains(nextDay(date, -1))) 'Entrenas el día anterior.',
    if (trains(nextDay(date, 1))) 'Entrenas al día siguiente.',
  ];

  /// Whether [date] may be picked by hand: after [source], not far away, and
  /// without a workout of its own. Returns the reason when it may not.
  static String? manualProblem({
    required DateTime source,
    required DateTime date,
    required bool Function(DateTime) occupied,
  }) {
    final target = dateOnly(date), from = dateOnly(source);
    if (!target.isAfter(from)) {
      return 'Elige una fecha posterior a la sesión.';
    }
    if (target.isAfter(nextDay(from, manualWindow))) {
      return 'Elige una fecha dentro de los próximos $manualWindow días.';
    }
    if (occupied(target)) {
      return 'Ese día ya tiene un entrenamiento; no se desplaza otra sesión.';
    }
    return null;
  }
}
