import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../data/services/ai/coach_agent.dart';
import '../../../domain/services/ai/mcp/proposal_inbox.dart';
import '../../core/ai_widgets.dart';
import '../../core/widgets.dart';
import '../view_models/coach_chat_view_model.dart';

/// Opens the chat with a fresh [vm]; closing the page forgets the
/// conversation (D38).
Future<void> showCoachChat(
  BuildContext context, {
  required CoachChatViewModel vm,
  required Future<void> Function(BuildContext, FoodProposal) onFood,
  required Future<void> Function(BuildContext) onRecommendation,
}) async {
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoachChatPage(
          vm: vm,
          onFood: onFood,
          onRecommendation: onRecommendation,
        ),
      ),
    );
  } finally {
    vm.dispose();
  }
}

class CoachChatPage extends StatefulWidget {
  const CoachChatPage({
    super.key,
    required this.vm,
    required this.onFood,
    required this.onRecommendation,
  });
  final CoachChatViewModel vm;
  final Future<void> Function(BuildContext, FoodProposal) onFood;
  final Future<void> Function(BuildContext) onRecommendation;
  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends State<CoachChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  /// On the newest message, to show its beginning after an answer.
  final _last = GlobalKey();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    await widget.vm.send(text);
    // Show where the answer begins.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _last.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Asistente'),
      backgroundColor: ForjaColors.paper,
      foregroundColor: ForjaColors.ink,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      top: false,
      child: VmObserver(
        viewModel: widget.vm,
        builder: (context) {
          final vm = widget.vm;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  // Everything scrolls but the question box, so the
                  // conversation keeps its room with large text.
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      children: [
                        AiBadge(detail: vm.provider),
                        const SizedBox(height: 12),
                        if (vm.entries.isEmpty)
                          Text(
                            vm.available
                                ? 'Pregunta sobre tu entrenamiento, tu cardio o '
                                      'tus comidas. Consultará lo que permitiste '
                                      'y cada respuesta dirá qué miró. Solo '
                                      'propone: tú decides.'
                                : 'El asistente no está activo: actívalo en '
                                      'Más → Asistente IA. El minicoach local '
                                      'sigue funcionando sin él.',
                          ),
                        for (final (i, e) in vm.entries.indexed)
                          KeyedSubtree(
                            key: i == vm.entries.length - 1 ? _last : null,
                            child: _entry(context, e),
                          ),
                        Text(
                          'Hoy: ${vm.today.requests} peticiones · '
                          '${vm.today.usage.total} tokens. La conversación se '
                          'borra al cerrar.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (vm.working)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: LinearProgressIndicator(),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('chat-input'),
                            controller: _input,
                            enabled: vm.available && !vm.working,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: CoachChatViewModel.maxLength,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              labelText: 'Tu pregunta',
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        vm.working
                            ? IconButton(
                                key: const ValueKey('chat-stop'),
                                tooltip: 'Detener',
                                onPressed: vm.stop,
                                icon: const Icon(Icons.stop_circle_outlined),
                              )
                            : IconButton(
                                key: const ValueKey('chat-send'),
                                tooltip: 'Enviar',
                                onPressed: vm.available ? _send : null,
                                icon: const Icon(Icons.send),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _entry(BuildContext context, ChatEntry e) {
    final theme = Theme.of(context).textTheme;
    final child = switch (e.role) {
      ChatRole.person => SurfaceCard(light: true, child: Text(e.text)),
      ChatRole.local => SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('FORJA', style: theme.labelLarge),
            const SizedBox(height: 4),
            Text(e.text),
            for (final r in e.recommendations)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('• ${r.title}: ${r.summary}'),
              ),
          ],
        ),
      ),
      ChatRole.assistant => SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Asistente externo (IA)', style: theme.labelLarge),
            const SizedBox(height: 4),
            // Plain text only: no links or images from the model.
            Text(e.text),
            for (final n in e.notices)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  n,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            for (final p in e.turn?.proposals ?? const <AiProposal>[])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _proposal(context, p),
              ),
            if (e.turn != null) _trace(context, e.turn!),
          ],
        ),
      ),
    };
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10,
        left: e.role == ChatRole.person ? 32 : 0,
        right: e.role == ChatRole.person ? 0 : 16,
      ),
      child: Semantics(container: true, child: child),
    );
  }

  Widget _proposal(BuildContext context, AiProposal p) {
    final problem = widget.vm.problemWith(p);
    final (title, detail) = switch (p) {
      FoodProposal() => (
        'Propuesta: ${p.name} · ${p.kcal} kcal',
        'Para el ${shortDate(parseDateKey(p.dateKey))}. Se abrirá el '
            'formulario para revisarla; nada se guarda hasta que tú la '
            'guardes.',
      ),
      RecommendationProposal() => (
        p.recommendation.title,
        p.recommendation.summary,
      ),
    };
    // A paper card: ink text and a dark button, so both stand out.
    return SurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: ForjaColors.ink),
          ),
          const SizedBox(height: 4),
          Text(detail),
          if (problem != null)
            Text(
              'No se puede usar: $problem',
              style: const TextStyle(fontWeight: FontWeight.w700),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                key: ValueKey('chat-proposal-${p.id}'),
                style: FilledButton.styleFrom(
                  backgroundColor: ForjaColors.ink,
                  foregroundColor: ForjaColors.paper,
                ),
                onPressed: () => switch (p) {
                  FoodProposal() => widget.onFood(context, p),
                  RecommendationProposal() => widget.onRecommendation(context),
                },
                child: Text(
                  p is FoodProposal
                      ? 'Revisar y guardar'
                      : 'Ver en el minicoach',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _trace(BuildContext context, AgentTurn turn) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: const Text('Qué miró la IA'),
    children: [
      if (turn.capsule)
        const Text(
          'Tu proveedor no confirmó las herramientas: se envió un resumen '
          'local de lo que permitiste.',
        ),
      if (turn.trace.isEmpty) const Text('Nada de tus datos.'),
      for (final t in turn.trace)
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '• ${t.title}'
            '${t.arguments.isEmpty ? '' : ' (${t.arguments})'}'
            '${t.isError ? ' · no respondida' : ''}',
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${turn.usage.prompt} tokens de entrada · ${turn.usage.completion} '
          'de salida · ${(turn.latency.inMilliseconds / 1000).toStringAsFixed(1)} s'
          '${turn.model.isEmpty ? '' : ' · ${turn.model}'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      if (turn.trace.isNotEmpty)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => _showSent(context, turn.trace),
            child: const Text('Ver datos enviados'),
          ),
        ),
    ],
  );

  Future<void> _showSent(BuildContext context, List<TraceItem> trace) =>
      showForjaSheet<void>(
        context,
        title: 'Datos enviados',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lo que la app envió a tu proveedor en esta respuesta (solo se '
              'muestra aquí, en tu teléfono).',
            ),
            for (final t in trace) ...[
              const SizedBox(height: 12),
              Text(t.title, style: Theme.of(context).textTheme.titleSmall),
              SelectableText(t.sent),
            ],
          ],
        ),
      );
}
