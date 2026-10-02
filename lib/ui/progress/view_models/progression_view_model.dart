import '../../../core/date_utils.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/progression_engine.dart';
import '../../core/view_model.dart';

/// Per-exercise progression suggestions built from recorded work. It never
/// applies anything: accepting records the person's decision, rejecting
/// records it too, and past sessions stay as they are.
class ProgressionViewModel extends ViewModel {
  ProgressionViewModel(
    this._workouts,
    this._progression,
    this._catalog, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    watch(_workouts);
    watch(_progression);
  }
  final WorkoutRepository _workouts;
  final ProgressionRepository _progression;
  final ExerciseRepository _catalog;
  final DateTime Function() _clock;

  Exercise exercise(String id) => _catalog.exerciseById(id);

  PlanExercise _plannedFor(String id) {
    for (final routine in _workouts.planFor(_clock()).routines) {
      final planned = routine.exercise(id);
      if (planned != null) return planned;
    }
    return PlanExercise.fromExercise(_catalog.exerciseById(id));
  }

  List<Exposure> exposures(String id) {
    final today = dateKey(dateOnly(_clock()));
    final found = <Exposure>[];
    for (final session in _workouts.history) {
      if (session.dateKey.compareTo(today) > 0) continue;
      for (final log in session.exercises) {
        if (log.exerciseId != id) continue;
        found.add(
          Exposure(
            dateKey: session.dateKey,
            log: log,
            feeling: _workouts
                .checkInOn(parseDateKey(session.dateKey))
                ?.feeling,
          ),
        );
      }
    }
    return found;
  }

  ProgressionSuggestion suggestion(String id) => ProgressionEngine.evaluate(
    planned: _plannedFor(id),
    exercise: _catalog.exerciseById(id),
    exposures: exposures(id),
    feelingNow: _workouts.checkInOn(_clock())?.feeling,
  );

  /// Exercises with at least one completed session, with their suggestion.
  List<ProgressionSuggestion> get suggestions {
    final ids = <String>{
      for (final s in _workouts.history)
        for (final e in s.exercises)
          if (e.completed) e.exerciseId,
    };
    final result = [for (final id in ids) suggestion(id)];
    result.sort(
      (a, b) =>
          exercise(a.exerciseId).name.compareTo(exercise(b.exerciseId).name),
    );
    return result;
  }

  /// What was decided about this very suggestion, if anything.
  ProgressionDecision? decisionFor(ProgressionSuggestion s) {
    for (final d in _progression.progressionDecisions) {
      if (d.exerciseId == s.exerciseId &&
          d.basedOn == s.basedOn &&
          d.ruleVersion == progressionRulesVersion) {
        return d;
      }
    }
    return null;
  }

  double? workingWeight(String id) => _workouts.workingWeight(id);

  Future<bool> accept(ProgressionSuggestion s) => run(
    () => _progression.decideProgression(
      exerciseId: s.exerciseId,
      kind: s.kind,
      basedOn: s.basedOn,
      ruleVersion: progressionRulesVersion,
      status: DecisionStatus.accepted,
      fromKg: s.fromKg,
      toKg: s.toKg,
    ),
    success: 'Aumento aceptado. Se aplica a las próximas sesiones.',
  );

  Future<bool> reject(ProgressionSuggestion s) => run(
    () => _progression.decideProgression(
      exerciseId: s.exerciseId,
      kind: s.kind,
      basedOn: s.basedOn,
      ruleVersion: progressionRulesVersion,
      status: DecisionStatus.rejected,
      fromKg: s.fromKg,
      toKg: s.toKg,
    ),
    success: 'Sugerencia rechazada. No cambia nada.',
  );
}
