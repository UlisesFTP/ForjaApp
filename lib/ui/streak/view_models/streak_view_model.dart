import '../../../core/date_utils.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/streak_rules.dart';
import '../../core/view_model.dart';

/// Trained and missed days of one month.
typedef MonthCount = ({int month, int trained, int missed});

/// The streak badge and its monthly and yearly calendars.
class StreakViewModel extends ViewModel {
  StreakViewModel(this._repository, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    final now = today;
    month = DateTime(now.year, now.month);
    year = now.year;
    _last = streak.current;
    _repository.addListener(_changed);
  }

  final WorkoutRepository _repository;
  final DateTime Function() _clock;

  /// First day of the month shown in the monthly calendar.
  late DateTime month;

  /// Year shown in the yearly heat map.
  late int year;

  /// Grows each time the streak grows, so the flame can celebrate it.
  int celebrate = 0;

  late int _last;
  Streak? _cache;
  DateTime? _cacheDay;

  DateTime get today => dateOnly(_clock());

  /// Computed once per change of the data or of the day.
  Streak get streak {
    final day = today;
    if (_cache == null || _cacheDay != day) {
      _cache = Streak(
        sessions: _repository.history,
        reschedules: _repository.reschedules,
        planned: (date) => _repository.routineOn(date) != null,
        today: day,
      );
      _cacheDay = day;
    }
    return _cache!;
  }

  // The cache must be dropped before the views rebuild, so this is the only
  // listener on the repository (not [watch]).
  void _changed() {
    _cache = null;
    final now = streak.current;
    if (now > _last) celebrate++;
    _last = now;
    notifyListeners();
  }

  int get current => streak.current;
  int get best => streak.best;
  StreakDay get todayState => streak.todayState;
  StreakDay dayOn(DateTime date) => streak.dayOn(date);

  /// "Racha: 5 entrenos seguidos…", for the badge and screen readers.
  String get summary {
    final n = current;
    final run = n == 1 ? '1 entreno seguido' : '$n entrenos seguidos';
    return 'Racha: $run. $todayMessage';
  }

  String get todayMessage => switch (todayState) {
    StreakDay.trained => 'Hoy ya sumaste un entreno.',
    StreakDay.pending =>
      current == 0
          ? 'Entrena hoy para empezar tu racha.'
          : 'Hoy toca entrenar: completa la sesión para sumar.',
    StreakDay.moved =>
      current == 0
          ? 'Moviste el entreno de hoy.'
          : 'Moviste el entreno de hoy: la racha sigue.',
    _ =>
      current == 0
          ? 'Hoy es descanso. Tu racha empieza con tu próximo entreno.'
          : 'Hoy es descanso: tu racha sigue.',
  };

  /// Whether the flame is lit: the streak is alive and nothing is pending
  /// today (as in Duolingo, today's workout lights it).
  bool get lit => current > 0 && todayState != StreakDay.pending;

  void shiftMonth(int delta) {
    month = DateTime(month.year, month.month + delta);
    notifyListeners();
  }

  void shiftYear(int delta) {
    year += delta;
    notifyListeners();
  }

  /// The month as weeks from Monday: blanks before the 1st and after the
  /// last day.
  List<DateTime?> get monthCells {
    final first = month;
    final days = DateTime(first.year, first.month + 1, 0).day;
    final cells = <DateTime?>[
      for (var i = 1; i < first.weekday; i++) null,
      for (var d = 1; d <= days; d++) DateTime(first.year, first.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  ({int trained, int missed}) get monthCount =>
      streak.countIn(month, DateTime(month.year, month.month + 1, 0));

  /// Columns of the yearly heat map: weeks from Monday; days outside the
  /// year are blank.
  List<List<DateTime?>> get yearWeeks {
    final first = DateTime(year), last = DateTime(year, 12, 31);
    var start = nextDay(first, 1 - first.weekday);
    final weeks = <List<DateTime?>>[];
    while (!start.isAfter(last)) {
      weeks.add([
        for (var i = 0; i < 7; i++)
          () {
            final day = nextDay(start, i);
            return day.year == year ? day : null;
          }(),
      ]);
      start = nextDay(start, 7);
    }
    return weeks;
  }

  List<MonthCount> get yearMonths => [
    for (var m = 1; m <= 12; m++)
      () {
        final c = streak.countIn(DateTime(year, m), DateTime(year, m + 1, 0));
        return (month: m, trained: c.trained, missed: c.missed);
      }(),
  ];

  int get yearTrained => yearMonths.fold(0, (n, m) => n + m.trained);

  @override
  void dispose() {
    _repository.removeListener(_changed);
    super.dispose();
  }
}
