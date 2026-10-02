import '../../../core/date_utils.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/progress_stats.dart';
import '../../core/view_model.dart';

class ProgressViewModel extends ViewModel {
  ProgressViewModel(
    this._repository,
    this._catalog,
    this._profiles, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    watch(_repository);
    watch(_profiles);
  }
  final WorkoutRepository _repository;
  final ExerciseRepository _catalog;
  final ProfileRepository _profiles;
  final DateTime Function() _clock;

  StatsRange range = StatsRange.month;
  // Charts have an equivalent table; the person can switch to it.
  bool asTable = false;

  void setRange(StatsRange value) {
    range = value;
    notifyListeners();
  }

  void toggleTable() {
    asTable = !asTable;
    notifyListeners();
  }

  DateTime get today => dateOnly(_clock());
  List<WorkoutSession> get history =>
      [..._repository.history]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
  List<WorkoutSession> get thisWeek {
    final keys = weekOf(_clock()).map(dateKey).toSet();
    return history.where((s) => keys.contains(s.dateKey)).toList();
  }

  int get completedThisWeek =>
      thisWeek.where((s) => s.status == SessionStatus.completed).length;
  int get completedTotal =>
      history.where((s) => s.status == SessionStatus.completed).length;
  int countStatus(SessionStatus status) =>
      thisWeek.where((s) => s.status == status).length;
  List<DateTime> get week => weekOf(_clock());
  SessionStatus? statusOn(DateTime date) => _repository.sessionOn(date)?.status;
  String routineName(String id) => _repository.routineById(id).name;
  String exerciseName(String id) => _catalog.exerciseById(id).name;
  LoadType _loadType(String id) => _catalog.exerciseById(id).loadType;

  (DateTime, DateTime) get bounds =>
      ProgressStats.bounds(range, today, _repository.history);

  /// Sessions inside the chosen range, newest first.
  List<WorkoutSession> get inRange {
    final (start, end) = bounds;
    final from = dateKey(start), to = dateKey(end);
    return [
      for (final s in history)
        if (s.dateKey.compareTo(from) >= 0 && s.dateKey.compareTo(to) <= 0) s,
    ];
  }

  Compliance get compliance {
    final (start, end) = bounds;
    return ProgressStats.compliance(
      sessions: _repository.history,
      reschedules: _repository.reschedules,
      start: start,
      end: end,
      today: today,
      planned: (d) => _repository.routineOn(d) != null,
    );
  }

  VolumeStats get volume {
    final (start, end) = bounds;
    return ProgressStats.volume(
      sessions: _repository.history,
      start: start,
      end: end,
      loadType: _loadType,
    );
  }

  List<ExerciseTrend> get trends {
    final (start, end) = bounds;
    return ProgressStats.trends(
      sessions: _repository.history,
      start: start,
      end: end,
      loadType: _loadType,
    );
  }

  WeightUnit get unit => _profiles.profile.unit;
}
