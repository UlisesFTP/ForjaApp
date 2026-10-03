import 'package:flutter/foundation.dart';

import '../../../core/date_utils.dart';
import '../../../domain/expert/expert_coach.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/progression_engine.dart';
import '../../../domain/services/progression_inputs.dart';
import '../../core/view_model.dart';
import '../../coach/view_models/coach_inputs_builder.dart';

/// Per-exercise progression suggestions built from recorded work. It never
/// applies anything: accepting records the person's decision, rejecting
/// records it too, and past sessions stay as they are.
class ProgressionViewModel extends ViewModel {
  /// With [profiles] the example plan is compared as the screen shows it
  /// (D41a); with [profiles] and [plans] a recent injury or pain holds an
  /// increase back (D41c).
  ProgressionViewModel(
    this._workouts,
    this._progression,
    this._catalog, {
    DateTime Function()? clock,
    ProfileRepository? profiles,
    PlanRepository? plans,
  }) : _clock = clock ?? DateTime.now,
       _profiles = profiles,
       _planRepository = plans {
    final sources = <Listenable>{_workouts, _progression, ?profiles};
    // Before `watch`: the cached vetoes go before the screen rebuilds.
    for (final s in sources) {
      s.addListener(_invalidate);
    }
    _listened = sources;
    for (final s in sources) {
      watch(s);
    }
  }
  final WorkoutRepository _workouts;
  final ProgressionRepository _progression;
  final ExerciseRepository _catalog;
  final ProfileRepository? _profiles;
  final PlanRepository? _planRepository;
  final DateTime Function() _clock;
  late final Set<Listenable> _listened;
  Vetoes? _vetoes;
  String? _vetoDay;

  void _invalidate() => _vetoes = null;

  /// The safety rules' vetoes for today, computed only when an increase is
  /// on screen and reused until data changes.
  Vetoes get _safety {
    final profiles = _profiles, plans = _planRepository;
    if (profiles == null || plans == null) return Vetoes(const []);
    final day = dateKey(dateOnly(_clock()));
    final cached = _vetoes;
    if (cached != null && _vetoDay == day) return cached;
    _vetoDay = day;
    return _vetoes = ExpertCoach.safetyVetoes(
      buildCoachInputs(
        today: _clock(),
        workouts: _workouts,
        profiles: profiles,
        plans: plans,
        progression: _progression,
        catalog: _catalog,
      ),
    );
  }

  /// Why an increase is held back (an injury or pain in the last days, a
  /// long break), or null when it is allowed.
  Veto? vetoFor(ProgressionSuggestion s) {
    if (!s.actionable) return null;
    return SafetyGate.vet(
      IncreaseLoad(
        exercise: s.exerciseId,
        basedOn: s.basedOn,
        fromKg: s.fromKg!,
        toKg: s.toKg!,
      ),
      _safety,
    );
  }

  Exercise exercise(String id) => _catalog.exerciseById(id);

  PlanExercise _plannedFor(String id) => plannedExerciseIn(
    _workouts.planFor(_clock()),
    _catalog.exerciseById(id),
    profile: _profiles?.profile,
  );

  List<Exposure> exposures(String id) => exposuresOf(
    id,
    _workouts.history,
    _clock(),
    (key) => _workouts.checkInOn(parseDateKey(key))?.feeling,
  );

  ProgressionSuggestion suggestion(String id) => ProgressionEngine.evaluate(
    planned: _plannedFor(id),
    exercise: _catalog.exerciseById(id),
    exposures: exposures(id),
    feelingNow: _workouts.checkInOn(_clock())?.feeling,
  );

  /// Exercises with at least one completed session, with their suggestion.
  List<ProgressionSuggestion> get suggestions {
    final result = [
      for (final id in exercisesWithWork(_workouts.history)) suggestion(id),
    ];
    result.sort(
      (a, b) =>
          exercise(a.exerciseId).name.compareTo(exercise(b.exerciseId).name),
    );
    return result;
  }

  /// What was decided about this very suggestion, if anything.
  ProgressionDecision? decisionFor(ProgressionSuggestion s) =>
      decisionAbout(_progression.progressionDecisions, s);

  double? workingWeight(String id) => _workouts.workingWeight(id);

  Future<bool> accept(ProgressionSuggestion s) => run(
    () => vetoFor(s) != null
        ? throw StateError('Sin aumento: ${vetoFor(s)!.reason}')
        : _progression.decideProgression(
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

  @override
  void dispose() {
    for (final s in _listened) {
      s.removeListener(_invalidate);
    }
    super.dispose();
  }

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
