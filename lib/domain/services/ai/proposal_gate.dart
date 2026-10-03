import '../../../core/date_utils.dart';
import '../../expert/expert_coach.dart';
import 'mcp/proposal_inbox.dart';

/// Checks every proposal of the external assistant again with the full local
/// data, whatever the assistant was allowed to see (F17, D38). A proposal
/// that fails is shown with its reason and offers nothing to accept.
class ProposalGate {
  const ProposalGate._();

  /// Why a food proposal cannot be used, or null.
  static String? food(FoodProposal p, DateTime today) {
    final name = p.name.trim();
    if (name.isEmpty || name.length > 80) return 'el nombre no es válido';
    if (p.kcal < 0 || p.kcal > 5000) return 'las calorías van de 0 a 5000';
    for (final g in [p.proteinG, p.carbsG, p.fatG]) {
      if (g != null && (!g.isFinite || g < 0 || g > 2000)) {
        return 'los macros van de 0 a 2000 g';
      }
    }
    final day = dateOnly(today);
    final DateTime date;
    try {
      date = parseDateKey(p.dateKey);
    } on FormatException {
      return 'la fecha no es válida';
    }
    if (dateKey(date) != p.dateKey ||
        date.isAfter(day) ||
        date.isBefore(nextDay(day, -30))) {
      return 'la fecha va de hace 30 días a hoy';
    }
    return null;
  }

  /// Why a pointed-out recommendation cannot be acted on now, or null: it
  /// must still be what the local rules say, and not held back by a veto.
  static String? recommendation(
    RecommendationProposal p,
    ExpertResult current,
  ) {
    for (final r in current.recommendations) {
      if (r.key != p.recommendation.key) continue;
      if (r.kind == RecommendationKind.blocked) return r.summary;
      final action = r.action;
      if (action != null) {
        final veto = SafetyGate.vet(action, current.vetoes);
        if (veto != null) return 'Sin aumento: ${veto.reason}';
      }
      return null;
    }
    return 'las reglas locales ya no lo recomiendan';
  }
}
