import 'coach_action.dart';
import 'recommendation.dart';

/// What a veto forbids.
enum VetoKind {
  /// No load increase (an injury, pain, a long break).
  loadIncrease,

  /// No added sets (fatigue that suggests a lighter period).
  volumeIncrease,

  /// No nutrition ranges (for example, a minor).
  nutritionRanges,
}

/// A safety rule's "no". Vetoes are derived before any recommendation and the
/// safety gate applies them to every action, including an external
/// assistant's proposals.
class Veto {
  const Veto({
    required this.kind,
    required this.ruleId,
    required this.reason,
    this.exerciseId,
    this.because = const [],
  });
  final VetoKind kind;
  final String ruleId;

  /// Plain-language reason, shown as "Sin aumento: …".
  final String reason;

  /// Null: applies to every exercise.
  final String? exerciseId;
  final List<FactRef> because;

  bool covers(CoachAction action) {
    final matches = switch (kind) {
      VetoKind.loadIncrease => action.raisesLoad,
      VetoKind.volumeIncrease => action.raisesVolume,
      VetoKind.nutritionRanges => false,
    };
    if (!matches) return false;
    return exerciseId == null || exerciseId == action.exerciseId;
  }
}
