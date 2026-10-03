import 'dart:async';

import '../../../data/services/ai/ai_gateway.dart';
import '../../../data/services/ai/coach_agent.dart';
import '../../../domain/expert/expert_coach.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../../domain/services/ai/ai_types.dart';
import '../../../domain/services/ai/mcp/proposal_inbox.dart';
import '../../../domain/services/ai/proposal_gate.dart';
import '../../core/view_model.dart';

enum ChatRole { person, assistant, local }

/// One message of the conversation. [local] ones come from the app itself
/// (a safety notice, the local rules when offline), never from the AI.
class ChatEntry {
  const ChatEntry({
    required this.role,
    required this.text,
    this.turn,
    this.notices = const [],
    this.recommendations = const [],
  });
  final ChatRole role;
  final String text;
  final AgentTurn? turn;

  /// The app's own notices shown with an answer ("Sin aumento: …").
  final List<String> notices;

  /// Local recommendations shown when the assistant cannot answer.
  final List<Recommendation> recommendations;
}

/// The coach chat (F17). The history lives only in memory while the page is
/// open (D38): closing it forgets everything.
class CoachChatViewModel extends ViewModel {
  CoachChatViewModel({
    required AiGateway gateway,
    required this._agent,
    required this._expert,
    required this._clock,
  }) : _gateway = gateway {
    watch(gateway);
    _session = gateway.newSession();
  }
  final AiGateway _gateway;
  final CoachAgent _agent;
  final ExpertResult Function() _expert;
  final DateTime Function() _clock;
  late final String _session;

  static const maxLength = 1000;

  /// How many earlier messages travel with each question.
  static const window = 12;

  final entries = <ChatEntry>[];
  Completer<void>? _stop;
  bool _closed = false;

  bool get available => _gateway.featureOn(AiFeature.chat);
  bool get working => _stop != null;
  String get provider =>
      '${_gateway.settings.model} vía ${_gateway.settings.preset.label}';
  AiUsageDay get today => _gateway.today;
  ProposalInbox get inbox => _agent.server.context.inbox;

  static final _redFlags = RegExp(
    r'dolor (en el |de )?pecho|desmay|me mareo mucho|falta de aire|no puedo respirar|palpitaciones',
    caseSensitive: false,
  );

  void stop() {
    final s = _stop;
    if (s != null && !s.isCompleted) s.complete();
  }

  void _notify() {
    if (!_closed) notifyListeners();
  }

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || working) return;
    if (question.length > maxLength) {
      announce('Escribe como mucho $maxLength caracteres.');
      return;
    }
    entries.add(ChatEntry(role: ChatRole.person, text: question));
    // A local check before anything is sent: the app says it, not the AI.
    if (_redFlags.hasMatch(question)) {
      entries.add(
        const ChatEntry(
          role: ChatRole.local,
          text:
              'Si notas dolor en el pecho, mareo o desmayo, o una falta de aire '
              'desproporcionada, para y busca atención médica ahora. El '
              'asistente no es un diagnóstico.',
        ),
      );
    }
    final stop = _stop = Completer<void>();
    _notify();
    final expert = _expert();
    final loadVeto = expert.vetoes.all
        .where((v) => v.kind == VetoKind.loadIncrease)
        .firstOrNull;
    try {
      final history = [
        for (final e
            in entries
                .where((e) => e.role != ChatRole.local)
                .toList()
                .reversed
                .take(window)
                .toList()
                .reversed)
          e.role == ChatRole.person
              ? AiMessage.user(e.text)
              : AiMessage(role: AiRole.assistant, content: e.text),
      ];
      final turn = await _agent.run(
        history,
        sessionId: _session,
        vetoed: loadVeto != null,
        cancel: stop.future,
      );
      entries.add(
        ChatEntry(
          role: ChatRole.assistant,
          text: turn.reply,
          turn: turn,
          notices: [
            // The local veto holds whatever the answer says.
            if (loadVeto != null)
              'Sin aumento: ${loadVeto.reason} Las reglas locales mandan.',
          ],
        ),
      );
    } on AiFailure catch (e) {
      final offline = e is AiOffline || e is AiTimeout || e is AiServer;
      entries.add(
        ChatEntry(
          role: ChatRole.local,
          text: offline
              ? '${e.message} Esto dicen las reglas locales:'
              : e.message,
          recommendations: offline
              ? expert.recommendations.take(3).toList()
              : const [],
        ),
      );
    } finally {
      _stop = null;
      _notify();
    }
  }

  /// Why a proposal cannot be used now, or null (checked again with the
  /// full local data, D38).
  String? problemWith(AiProposal p) => switch (p) {
    FoodProposal() => ProposalGate.food(p, _clock()),
    RecommendationProposal() => ProposalGate.recommendation(p, _expert()),
  };

  @override
  void dispose() {
    _closed = true;
    stop();
    entries.clear();
    inbox.clear();
    super.dispose();
  }
}
