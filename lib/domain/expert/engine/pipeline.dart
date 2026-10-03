import '../../services/progression_engine.dart';
import '../facts/coach_facts.dart';
import '../kb_version.dart';
import '../model/recommendation.dart';
import '../model/veto.dart';
import 'rule.dart';
import 'safety_gate.dart';

/// One step of the trace: which rule produced what.
class Firing {
  const Firing(this.ruleId, this.outcome, this.subject);
  final String ruleId;

  /// `veto`, `recommendation` or `blocked`.
  final String outcome;
  final String subject;

  @override
  String toString() => '$ruleId → $outcome ($subject)';
}

class ExpertResult {
  ExpertResult({
    required List<Recommendation> recommendations,
    required this.vetoes,
    required List<Firing> trace,
    required this.progression,
    required this.todayLine,
  }) : recommendations = List.unmodifiable(recommendations),
       trace = List.unmodifiable(trace);

  /// In precedence order, after the safety gate.
  final List<Recommendation> recommendations;
  final Vetoes vetoes;
  final List<Firing> trace;

  /// The progression rules' verdict per exercise (as the Progress screen).
  final Map<String, ProgressionSuggestion> progression;

  /// The advice line of Hoy for today.
  final String? todayLine;
  String get kbVersion => expertKbVersion;
}

/// Ordered evaluation: facts → vetoes → recommendations → safety gate.
/// Conflicts are resolved by salience, then specificity, then rule id, then
/// key: never by chance, so the same data always gives the same answer.
class ExpertEngine {
  ExpertEngine(List<ExpertRule> rules)
    : rules = List<ExpertRule>.unmodifiable(
        <ExpertRule>[...rules]..sort(_byPrecedence),
      );
  final List<ExpertRule> rules;

  static int _byPrecedence(ExpertRule a, ExpertRule b) {
    final s = b.salience.compareTo(a.salience);
    if (s != 0) return s;
    final p = b.specificity.compareTo(a.specificity);
    return p != 0 ? p : a.id.compareTo(b.id);
  }

  ExpertResult evaluate(CoachFacts facts) {
    final trace = <Firing>[];
    final vetoList = <Veto>[];
    for (final rule in rules) {
      for (final v in rule.vetoes(facts)) {
        assert(v.ruleId == rule.id, 'A veto names its own rule');
        vetoList.add(v);
        trace.add(Firing(rule.id, 'veto', v.exerciseId ?? 'todo'));
      }
    }
    final vetoes = Vetoes(vetoList);

    final seen = <String>{};
    final recommendations = <Recommendation>[];
    for (final rule in rules) {
      for (final raw in rule.recommend(facts, vetoes)) {
        assert(raw.ruleId == rule.id, 'A recommendation names its own rule');
        // Each rule fires once per binding.
        if (!seen.add(raw.key)) continue;
        final r = SafetyGate.apply(raw, vetoes);
        recommendations.add(r);
        trace.add(
          Firing(
            rule.id,
            r.kind == RecommendationKind.blocked ? 'blocked' : 'recommendation',
            r.subject,
          ),
        );
      }
    }
    recommendations.sort((a, b) {
      final s = b.salience.compareTo(a.salience);
      if (s != 0) return s;
      final p = b.specificity.compareTo(a.specificity);
      if (p != 0) return p;
      final r = a.ruleId.compareTo(b.ruleId);
      return r != 0 ? r : a.key.compareTo(b.key);
    });
    return ExpertResult(
      recommendations: recommendations,
      vetoes: vetoes,
      trace: trace,
      progression: facts.progression,
      todayLine: facts.todayLine,
    );
  }
}
