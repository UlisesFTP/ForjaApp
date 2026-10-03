import 'coach_action.dart';

/// Families of rules, in order of precedence.
enum RuleFamily {
  safety(1000, 'Seguridad', 3),
  readiness(800, 'Preparación', 3),
  progression(600, 'Progresión', 14),
  plan(400, 'Plan y volumen', 28),
  adherence(300, 'Constancia', 7),
  cardio(200, 'Cardio', 7),
  nutrition(200, 'Nutrición', 7),
  logging(100, 'Registro', 14);

  const RuleFamily(this.salience, this.label, this.cooldownDays);

  /// Higher wins: safety before anything else.
  final int salience;
  final String label;

  /// Days a recommendation of this family stays hidden after "Ahora no".
  final int cooldownDays;
}

enum RecommendationKind {
  /// Something to do, usually with an action.
  suggestion,

  /// A warning to keep in mind.
  caution,

  /// Context or an explanation.
  info,

  /// A suggestion the safety gate stopped; it shows why and offers nothing.
  blocked,
}

/// How strong the support for a rule's threshold is.
enum EvidenceLevel {
  high('alta'),
  moderate('media'),
  heuristic('heurística');

  const EvidenceLevel(this.label);
  final String label;
}

/// The support behind a rule: its level and where it comes from.
class Evidence {
  const Evidence(this.level, this.source);
  final EvidenceLevel level;

  /// Short reference, shown in the "por qué" sheet.
  final String source;
}

/// One fact a recommendation rests on, dated when it comes from a record.
class FactRef {
  const FactRef(this.label, this.value, {this.date});
  final String label, value;

  /// Calendar date key of the record, if any.
  final String? date;

  @override
  String toString() =>
      date == null ? '$label: $value' : '$label ($date): $value';
}

/// What the expert system says, with everything needed to explain it.
class Recommendation {
  const Recommendation({
    required this.ruleId,
    required this.family,
    required this.subject,
    required this.anchor,
    required this.kind,
    required this.title,
    required this.summary,
    required this.because,
    required this.evidence,
    required this.salience,
    required this.specificity,
    this.threshold,
    this.action,
    this.vetoedBy,
  });

  final String ruleId;
  final RuleFamily family;

  /// What it is about (an exercise id, a muscle, "today", "nutrition"...).
  final String subject;

  /// The data point it is pinned to (usually a date), so the same advice
  /// about newer data is a new recommendation.
  final String anchor;
  final RecommendationKind kind;
  final String title, summary;
  final List<FactRef> because;
  final Evidence evidence;

  /// The threshold the rule used, in words ("14 días", "4 series").
  final String? threshold;
  final CoachAction? action;

  /// The rule whose veto blocked this one.
  final String? vetoedBy;
  final int salience, specificity;

  /// Stable identity, without the rules version (D37).
  String get key => '$ruleId|$subject|$anchor';

  Recommendation blockedBy(String ruleId, String reason) => Recommendation(
    ruleId: this.ruleId,
    family: family,
    subject: subject,
    anchor: anchor,
    kind: RecommendationKind.blocked,
    title: 'Sin aumento por ahora',
    summary: 'Sin aumento: $reason',
    because: because,
    evidence: evidence,
    salience: salience,
    specificity: specificity,
    threshold: threshold,
    vetoedBy: ruleId,
  );
}
