import 'dart:math';

import '../../../expert/expert_coach.dart';

/// Something the assistant proposed. It is shown as a card; only the person
/// can apply it, through the usual screens. Kept in memory for 30 minutes.
sealed class AiProposal {
  const AiProposal(this.id, this.createdAt);

  /// Opaque: `prp_` and 32 hex characters.
  final String id;
  final DateTime createdAt;
}

/// A food to log, which opens the food form filled in (source `estimated`).
final class FoodProposal extends AiProposal {
  const FoodProposal(
    super.id,
    super.createdAt, {
    required this.dateKey,
    required this.name,
    required this.kcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.portion,
    this.unit,
    this.confidence = 'low',
    this.assumptions = const [],
  });
  final String dateKey, name;
  final int kcal;
  final double? proteinG, carbsG, fatG, portion;
  final String? unit;
  final String confidence;
  final List<String> assumptions;
}

/// One of the minicoach's own recommendations, pointed out by the assistant.
final class RecommendationProposal extends AiProposal {
  const RecommendationProposal(super.id, super.createdAt, this.recommendation);
  final Recommendation recommendation;
}

/// The proposals of one conversation, in memory only.
class ProposalInbox {
  ProposalInbox({DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();
  final DateTime Function() _clock;
  final Random _random;
  final _items = <String, AiProposal>{};

  static const lifetime = Duration(minutes: 30);

  DateTime now() => _clock();

  String newId() =>
      'prp_${List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  void add(AiProposal p) => _items[p.id] = p;

  /// The proposal if it exists and has not expired.
  AiProposal? find(String id) {
    final p = _items[id];
    if (p == null) return null;
    if (_clock().difference(p.createdAt) > lifetime) {
      _items.remove(id);
      return null;
    }
    return p;
  }

  void remove(String id) => _items.remove(id);
  void clear() => _items.clear();
}
