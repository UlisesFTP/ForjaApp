import '../../../core/date_utils.dart';
import '../../../core/elapsed_timer.dart';
import '../../../domain/expert/today_advice.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/reschedule_planner.dart';
import '../../../domain/services/plan_generator.dart';
import '../../../domain/services/review_service.dart';
import '../../../domain/services/training_rules.dart';
import '../../core/view_model.dart';

class TodayViewModel extends ViewModel {
  TodayViewModel(
    this._workouts,
    this._catalog,
    this._profiles, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       rest = RestTimer(clock: clock) {
    selectedDate = dateOnly(_clock());
    watch(_workouts);
    watch(_profiles);
  }
  final WorkoutRepository _workouts;
  final ExerciseRepository _catalog;
  final ProfileRepository _profiles;
  final DateTime Function() _clock;

  /// The optional rest countdown of the sets panel. It lives here so it
  /// survives closing the panel; it is computed from timestamps.
  final RestTimer rest;
  late DateTime selectedDate;
  int dateDirection = 1;
  DateTime get today => dateOnly(_clock());
  List<DateTime> get week => weekOf(selectedDate);
  bool get isToday => dateKey(selectedDate) == dateKey(today);
  Routine? get routine => _workouts.routineOn(selectedDate);
  WorkoutSession? get session => _workouts.sessionOn(selectedDate);
  List<ExerciseLog> get entries =>
      routine == null ? const [] : session?.exercises ?? const [];
  WeightUnit get unit => _profiles.profile.unit;
  CheckIn? get checkIn => _workouts.checkInOn(selectedDate);
  CheckIn? get afterCheckIn => _workouts.afterCheckInOn(selectedDate);
  int get completed => entries.where((e) => e.completed).length;
  int get skipped => entries.where((e) => e.skipped).length;
  int get resolved => entries.where((e) => e.resolved).length;
  bool get allResolved => entries.isNotEmpty && resolved == entries.length;
  bool get hasPending => entries.any((e) => !e.resolved);

  /// Completed or saved with skipped exercises, on a day that still has its
  /// workout (a moved session is a rest day and cannot be edited).
  bool get finished =>
      routine != null &&
      (session?.status == SessionStatus.completed ||
          session?.status == SessionStatus.partial);
  String? get nextExerciseId =>
      entries.where((e) => !e.resolved).firstOrNull?.exerciseId;
  // The built-in example plan is still adapted to the profile, as in 0.1;
  // a plan the user accepted is shown as written.
  bool get _adapts =>
      _workouts.planFor(selectedDate).source == PlanSource.example;

  /// Tiredness or soreness today (or a low habitual energy the plan does not
  /// already account for, D41b): the lighter session is proposed, and stands
  /// until the person reverts it.
  bool get adjustmentProposed => routine != null && _lighter;
  bool get _lighter => TrainingRules.lighterSessionProposed(
    _profiles.profile,
    checkIn?.feeling,
    routine: routine,
    source: _workouts.planFor(selectedDate).source,
  );
  bool get adjustmentApplied =>
      adjustmentProposed && _workouts.adjustmentOn(selectedDate) != false;
  bool get injured => checkIn?.feeling == Feeling.injured;

  /// The monthly review is available; shown discreetly, never blocking.
  bool get reviewDue => ReviewService.status(_profiles.profile, today).due;

  /// The advice line: the rules' text and, back after a break, what to do
  /// in the first sessions (D41e). The same function feeds the minicoach.
  String? get recommendation => todayAdvice(
    profile: _profiles.profile,
    feeling: checkIn?.feeling,
    adaptToProfile: _adapts,
    adjust: adjustmentApplied,
    lighter: _lighter,
    trainingDay: isToday && routine != null,
    daysSinceLastWorkout: daysSinceLastWorkout(_workouts.history, today),
    startedToday: entries.any((e) => e.resolved || e.sets.isNotEmpty),
  );

  /// Rough length of the day's routine (warm-up, work and rest), instead of
  /// a fixed range (D41d). Null on a rest day.
  int? get routineMinutes {
    final r = routine;
    return r == null ? null : PlanGenerator.routineMinutes(r, exercise);
  }

  Routine? routineOn(DateTime date) => _workouts.routineOn(date);
  SessionStatus? statusOn(DateTime date) => _workouts.sessionOn(date)?.status;
  Exercise exercise(String id) => _catalog.exerciseById(id);
  ExerciseLog logOf(String id) => entries.firstWhere((e) => e.exerciseId == id);
  int restSeconds(String id) =>
      routine?.exercise(id)?.restSeconds ??
      PlanExercise.fromExercise(exercise(id)).restSeconds;

  // The lighter session only changes what is still pending: an exercise with
  // work already recorded keeps the plan as written.
  Prescription prescription(String id) {
    final e = exercise(id), log = entries.where((l) => l.exerciseId == id);
    final underway =
        log.isNotEmpty && (log.first.resolved || log.first.sets.isNotEmpty);
    return TrainingRules.prescription(
      routine?.exercise(id) ?? PlanExercise.fromExercise(e),
      e,
      _profiles.profile,
      checkIn?.feeling,
      adaptToProfile: _adapts,
      adjust: adjustmentApplied && !underway,
    );
  }

  String get nextRoutine {
    for (var i = 1; i <= 14; i++) {
      final date = nextDay(selectedDate, i), next = routineOn(date);
      if (next != null) return '${friendlyDate(date)} · ${next.name}';
    }
    return 'Por definir';
  }

  /// A move that brought this day's workout here / took it away, while it
  /// still stands.
  Reschedule? get moveInto => _workouts.rescheduleInto(selectedDate);
  Reschedule? get moveFrom => _workouts.rescheduleFrom(selectedDate);
  bool canUndo(Reschedule? move) => move != null && _workouts.canUndo(move);

  void selectDate(DateTime date) {
    if (busy) return;
    dateDirection = date.isBefore(selectedDate) ? -1 : 1;
    selectedDate = dateOnly(date);
    notifyListeners();
  }

  void goToday() => selectDate(today);
  Future<bool> toggle(String id) => run(() async {
    await _workouts.toggleExercise(selectedDate, id);
    final log = logOf(id);
    announce(
      '${exercise(id).name}: ${log.completed ? 'completado' : 'pendiente'}',
    );
  });
  Future<bool> setWeight(String id, double weightKg) => run(
    () => _workouts.updateWeight(selectedDate, id, weightKg),
    success: 'Peso guardado',
  );
  Future<bool> reorder(int oldIndex, int newIndex) => run(() async {
    final ids = entries.map((e) => e.exerciseId).toList();
    final id = ids.removeAt(oldIndex);
    ids.insert(newIndex, id);
    await _workouts.reorder(selectedDate, ids);
    announce('${exercise(id).name}, posición ${newIndex + 1} de ${ids.length}');
  });
  Future<bool> move(String id, int delta) async {
    final index = entries.indexWhere((e) => e.exerciseId == id),
        target = index + delta;
    if (index < 0 || target < 0 || target >= entries.length) return false;
    return reorder(index, target);
  }

  Future<bool> addSet(String id, SetEntry entry) => run(
    () => _workouts.addSet(selectedDate, id, entry),
    success: entry.status == SetStatus.skipped
        ? 'Serie omitida'
        : 'Serie guardada',
  );
  Future<bool> updateSet(String id, String setId, SetEntry entry) => run(
    () => _workouts.updateSet(selectedDate, id, setId, entry),
    success: 'Serie actualizada',
  );
  Future<bool> removeSet(String id, String setId) => run(
    () => _workouts.removeSet(selectedDate, id, setId),
    success: 'Serie eliminada',
  );
  Future<bool> skip(String id, String reason) => run(
    () => _workouts.setSkipped(selectedDate, id, true, reason: reason),
    success: '${exercise(id).name}: omitido',
  );
  Future<bool> unskip(String id) => run(
    () => _workouts.setSkipped(selectedDate, id, false),
    success: '${exercise(id).name}: pendiente',
  );
  Future<bool> setTechnique(String id, TechniqueRating? rating) => run(
    () => _workouts.setTechnique(selectedDate, id, rating),
    success: rating == null
        ? 'Técnica sin valorar'
        : rating == TechniqueRating.solid
        ? 'Técnica: sólida'
        : 'Técnica: inestable',
  );
  Future<bool> reopen() => run(
    () => _workouts.reopenSession(selectedDate),
    success: 'Sesión reabierta. Queda anotado en el historial.',
  );

  Future<bool> saveCheckIn(
    CheckIn value, {
    CheckInPhase phase = CheckInPhase.before,
  }) => run(
    () => _workouts.saveCheckIn(selectedDate, value, phase: phase),
    success: 'Check-in guardado',
  );
  Future<bool> setAdjustment(bool applied) => run(
    () => _workouts.setAdjustment(selectedDate, applied),
    success: applied ? 'Ajuste de intensidad aplicado' : 'Ajuste quitado',
  );

  /// What a partial result or an absence would move, shown before it is
  /// applied. Null when there is nothing to reschedule.
  ReschedulePreview? preview(SessionStatus status) {
    try {
      return _workouts.previewReschedule(selectedDate, status);
    } on StateError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  String? moveProblem(DateTime target) =>
      _workouts.rescheduleProblem(selectedDate, target);
  List<String> moveWarnings(SessionStatus status, DateTime target) =>
      _workouts.rescheduleWarnings(selectedDate, status, target);

  Future<bool> finish(
    SessionStatus status, {
    DateTime? moveTo,
    bool reschedule = true,
  }) => run(() async {
    final source = selectedDate;
    final moved = await _workouts.finishSession(
      source,
      status,
      moveTo: moveTo,
      reschedule: reschedule,
    );
    final move = moved == null ? null : _workouts.rescheduleInto(moved);
    if (moved != null && move != null) {
      announce(
        'Sesión movida al ${friendlyDate(moved)}',
        actionLabel: 'Deshacer',
        onAction: () => undoMove(move.id),
      );
    } else if (status == SessionStatus.completed &&
        session?.status == SessionStatus.partial) {
      announce('Sesión guardada como parcial: hay ejercicios omitidos');
    } else {
      announce(
        status == SessionStatus.completed
            ? 'Sesión completada'
            : status == SessionStatus.missed
            ? 'Ausencia registrada'
            : 'Sesión guardada como parcial',
      );
    }
  });

  Future<bool> undoMove(String id) =>
      run(() => _workouts.undoReschedule(id), success: 'Movimiento deshecho');
}
