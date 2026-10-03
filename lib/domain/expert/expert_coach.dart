import 'engine/pipeline.dart';
import 'engine/rule.dart';
import 'facts/coach_facts.dart';
import 'facts/coach_inputs.dart';
import 'knowledge/knowledge_base.dart';
import 'model/recommendation.dart';

export 'engine/pipeline.dart' show ExpertResult, Firing;
export 'engine/rule.dart' show Vetoes;
export 'engine/safety_gate.dart';
export 'facts/coach_inputs.dart';
export 'kb_version.dart';
export 'model/coach_action.dart';
export 'model/recommendation.dart';
export 'model/veto.dart';

/// The local expert system: pure, offline and deterministic. It only gives
/// advice; every change still goes through the existing flows and the
/// person's confirmation.
class ExpertCoach {
  const ExpertCoach._();
  static final _engine = ExpertEngine(knowledgeBaseV1);

  static ExpertResult evaluate(CoachInputs inputs) =>
      _engine.evaluate(CoachFacts(inputs));

  /// Only the safety rules' vetoes: what Progreso and the sets panel need to
  /// hold back an increase (D41c) without evaluating everything.
  static Vetoes safetyVetoes(CoachInputs inputs) {
    final facts = CoachFacts(inputs);
    return Vetoes([
      for (final rule in _engine.rules)
        if (rule.family == RuleFamily.safety) ...rule.vetoes(facts),
    ]);
  }
}
