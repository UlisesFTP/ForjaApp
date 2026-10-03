import '../facts/coach_facts.dart';
import '../model/coach_action.dart';
import '../model/recommendation.dart';
import '../model/veto.dart';

/// One production rule of the knowledge base. It may forbid things (vetoes,
/// derived first) and recommend things (derived after every veto is known).
abstract class ExpertRule {
  const ExpertRule();

  /// Stable id, `family.name`; stored with every decision.
  String get id;
  RuleFamily get family;
  Evidence get evidence;

  /// Number of conditions: with equal salience the more specific rule wins.
  int get specificity;
  int get salience => family.salience;

  /// Days a recommendation stays hidden after "Ahora no".
  int get cooldownDays => family.cooldownDays;

  /// [f] is the working memory of this evaluation.
  Iterable<Veto> vetoes(CoachFacts f) => const [];

  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) => const [];

  /// Builds a recommendation of this rule.
  Recommendation make({
    required String subject,
    required String anchor,
    required RecommendationKind kind,
    required String title,
    required String summary,
    required List<FactRef> because,
    String? threshold,
    CoachAction? action,
  }) => Recommendation(
    ruleId: id,
    family: family,
    subject: subject,
    anchor: anchor,
    kind: kind,
    title: title,
    summary: summary,
    because: because,
    evidence: evidence,
    salience: salience,
    specificity: specificity,
    threshold: threshold,
    action: action,
  );

  Veto veto(
    VetoKind kind,
    String reason, {
    String? exerciseId,
    List<FactRef> because = const [],
  }) => Veto(
    kind: kind,
    ruleId: id,
    reason: reason,
    exerciseId: exerciseId,
    because: because,
  );
}

/// Every veto of an evaluation, in precedence order.
class Vetoes {
  Vetoes(Iterable<Veto> vetoes) : all = List.unmodifiable(vetoes);
  final List<Veto> all;

  bool any(VetoKind kind, {String? exerciseId}) => all.any(
    (v) =>
        v.kind == kind &&
        (v.exerciseId == null ||
            exerciseId == null ||
            v.exerciseId == exerciseId),
  );

  /// The first veto that forbids [action], if any.
  Veto? blocking(CoachAction action) {
    for (final v in all) {
      if (v.covers(action)) return v;
    }
    return null;
  }
}
