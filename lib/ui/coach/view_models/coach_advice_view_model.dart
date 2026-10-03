import 'package:flutter/foundation.dart';

import '../../../core/date_utils.dart';
import '../../../domain/expert/expert_coach.dart';
import '../../../domain/expert/knowledge/knowledge_base.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/progression_engine.dart';
import '../../core/view_model.dart';
import 'coach_inputs_builder.dart';

/// The expert system's advice for the Coach page (F16). It is created when
/// the page opens and released when it closes, and it evaluates only while
/// the page is visible: never at startup or in the background. It saves
/// nothing by itself: accepting goes through the existing commands.
class CoachAdviceViewModel extends ViewModel {
  CoachAdviceViewModel({
    required WorkoutRepository workouts,
    required ProfileRepository profiles,
    required PlanRepository plans,
    required ProgressionRepository progression,
    required ExerciseRepository catalog,
    required CoachRepository coach,
    CardioRepository? cardio,
    NutritionRepository? nutrition,
    DateTime Function()? clock,
  }) : _workouts = workouts,
       _profiles = profiles,
       _plans = plans,
       _progression = progression,
       _exercises = catalog,
       _coach = coach,
       _cardio = cardio,
       _nutrition = nutrition,
       _clock = clock ?? DateTime.now {
    final sources = <Listenable>{
      workouts,
      profiles,
      plans,
      progression,
      coach,
      ?cardio,
      ?nutrition,
    };
    // Registered before `watch`, so the cached result is dropped before the
    // page is told to rebuild.
    for (final s in sources) {
      s.addListener(_invalidate);
    }
    _listened = sources;
    for (final s in sources) {
      watch(s);
    }
  }

  final WorkoutRepository _workouts;
  final ProfileRepository _profiles;
  final PlanRepository _plans;
  final ProgressionRepository _progression;
  final ExerciseRepository _exercises;
  final CoachRepository _coach;
  final CardioRepository? _cardio;
  final NutritionRepository? _nutrition;
  final DateTime Function() _clock;
  late final Set<Listenable> _listened;

  ExpertResult? _result;
  String? _resultDay;

  /// How many evaluations ran; lets tests check the page stays lazy.
  @visibleForTesting
  int evaluations = 0;

  void _invalidate() => _result = null;

  DateTime get today => dateOnly(_clock());

  /// The current evaluation, computed on first use and reused until any
  /// source changes or the day changes.
  ExpertResult get result {
    final day = dateKey(today);
    final cached = _result;
    if (cached != null && _resultDay == day) return cached;
    evaluations++;
    _resultDay = day;
    return _result = ExpertCoach.evaluate(
      buildCoachInputs(
        today: today,
        workouts: _workouts,
        profiles: _profiles,
        plans: _plans,
        progression: _progression,
        catalog: _exercises,
        cardio: _cardio,
        nutrition: _nutrition,
      ),
    );
  }

  bool get needsProfile => !_profiles.profile.onboarded;

  bool muted(RuleFamily family) =>
      family != RuleFamily.safety &&
      _coach.coachPreferences.any((p) => p.family == family.name && p.muted);

  /// Hidden after "Ahora no" until the rule's cooldown ends, or for good once
  /// accepted.
  bool _hidden(Recommendation r) {
    if (muted(r.family)) return true;
    final cooldown = ruleById(r.ruleId)?.cooldownDays ?? r.family.cooldownDays;
    for (final d in _coach.coachDecisions) {
      if (d.recKey == r.key && d.status == CoachDecisionStatus.accepted) {
        return true;
      }
      if (d.ruleId == r.ruleId &&
          d.subject == r.subject &&
          d.status == CoachDecisionStatus.dismissed) {
        final until = nextDay(dateOnly(d.decidedAt.toLocal()), cooldown);
        if (today.isBefore(until)) return true;
      }
    }
    return false;
  }

  List<Recommendation> get visible => [
    for (final r in result.recommendations)
      if (!_hidden(r)) r,
  ];

  /// About today: safety and readiness.
  List<Recommendation> get forToday => [
    for (final r in visible)
      if (r.family == RuleFamily.safety || r.family == RuleFamily.readiness) r,
  ];

  /// Things to do, most important first.
  List<Recommendation> get suggestions => [
    for (final r in visible)
      if (r.kind == RecommendationKind.suggestion &&
          r.family != RuleFamily.safety &&
          r.family != RuleFamily.readiness)
        r,
  ];

  /// Cautions, information and what the safety rules held back.
  List<Recommendation> get notes => [
    for (final r in visible)
      if (r.kind != RecommendationKind.suggestion &&
          r.family != RuleFamily.safety &&
          r.family != RuleFamily.readiness)
        r,
  ];

  /// Only one family's advice (the plan review on Plan).
  List<Recommendation> ofFamily(RuleFamily family) => [
    for (final r in visible)
      if (r.family == family) r,
  ];

  /// The rules that fired about [r]'s subject, for the "por qué" sheet.
  List<Firing> traceOf(Recommendation r) => [
    for (final f in result.trace)
      if (f.ruleId == r.ruleId || f.ruleId == r.vetoedBy) f,
  ];

  Future<bool> dismiss(Recommendation r) => run(
    () => _coach.decideCoach(
      ruleId: r.ruleId,
      subject: r.subject,
      anchor: r.anchor,
      kbVersion: expertKbVersion,
      status: CoachDecisionStatus.dismissed,
      summary: r.title,
    ),
    success:
        'Oculto durante ${ruleById(r.ruleId)?.cooldownDays ?? r.family.cooldownDays} días.',
  );

  /// Accepts a load increase through the same decision as Progreso (first
  /// decision final, applied to new sessions only). Other actions only
  /// navigate and are handled by the page.
  Future<bool> acceptIncrease(Recommendation r) {
    final action = r.action;
    if (action is! IncreaseLoad || r.kind != RecommendationKind.suggestion) {
      return Future.value(false);
    }
    return run(() async {
      await _progression.decideProgression(
        exerciseId: action.exercise,
        kind: ProgressionKind.increase,
        basedOn: action.basedOn,
        ruleVersion: progressionRulesVersion,
        status: DecisionStatus.accepted,
        fromKg: action.fromKg,
        toKg: action.toKg,
      );
      await _coach.decideCoach(
        ruleId: r.ruleId,
        subject: r.subject,
        anchor: r.anchor,
        kbVersion: expertKbVersion,
        status: CoachDecisionStatus.accepted,
        summary: r.title,
      );
    }, success: 'Aumento aceptado. Se aplica a las próximas sesiones.');
  }

  Future<bool> setMuted(RuleFamily family, bool value) => run(
    () => _coach.setCoachMuted(family.name, value),
    success: value
        ? 'Consejos de ${family.label.toLowerCase()} ocultos'
        : 'Consejos de ${family.label.toLowerCase()} visibles',
  );

  @override
  void dispose() {
    for (final s in _listened) {
      s.removeListener(_invalidate);
    }
    super.dispose();
  }
}
