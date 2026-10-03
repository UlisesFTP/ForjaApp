import '../model/coach_action.dart';
import '../model/recommendation.dart';
import '../model/veto.dart';
import 'rule.dart';

/// The mandatory last pass. An action that raises load or volume under a
/// matching veto never reaches the person as something to accept: it is
/// shown as blocked, with the reason. The same check vets any proposal made
/// from outside the rules (an external assistant).
class SafetyGate {
  const SafetyGate._();

  /// The veto that forbids [action], or null when it is allowed.
  static Veto? vet(CoachAction action, Vetoes vetoes) =>
      vetoes.blocking(action);

  static Recommendation apply(Recommendation r, Vetoes vetoes) {
    final action = r.action;
    if (action == null) return r;
    final veto = vet(action, vetoes);
    return veto == null ? r : r.blockedBy(veto.ruleId, veto.reason);
  }
}
