import 'dart:async';
import 'dart:convert';

import '../../../core/date_utils.dart';
import '../../../data/services/ai/ai_gateway.dart';
import '../../../domain/services/ai/ai_prompts.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../../domain/services/ai/ai_types.dart';
import '../../../domain/services/ai/meal_estimate.dart';
import '../../core/view_model.dart';

/// "Describir comida (IA)" (F17): only the text the person typed (and the
/// date) goes to their provider. The answer is checked and only fills the
/// food form; nothing is saved here.
class MealEstimateViewModel extends ViewModel {
  MealEstimateViewModel(this._gateway, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    watch(_gateway);
  }
  final AiGateway _gateway;
  final DateTime Function() _clock;

  static const maxLength = 1000;

  MealEstimate? estimate;
  AiUsage? usage;
  Completer<void>? _stop;

  bool get available => _gateway.featureOn(AiFeature.mealEstimate);
  bool get working => _stop != null;
  String get provider =>
      '${_gateway.settings.model} vía ${_gateway.settings.preset.label}';

  void stop() {
    final s = _stop;
    if (s != null && !s.isCompleted) s.complete();
  }

  Future<bool> estimateFrom(String description) async {
    final text = description.trim();
    if (text.isEmpty) {
      announce('Describe qué comiste y cuánto.');
      return false;
    }
    if (text.length > maxLength) {
      announce('Escribe como mucho $maxLength caracteres.');
      return false;
    }
    final stop = _stop = Completer<void>();
    estimate = null;
    usage = null;
    try {
      return await run(() async {
        final messages = <AiMessage>[
          const AiMessage.system(mealEstimatePrompt),
          AiMessage.user(
            jsonEncode({
              'descripcion_userText': text,
              'fecha': dateKey(dateOnly(_clock())),
            }),
          ),
        ];
        var used = const AiUsage();
        Future<AiResponse> ask(List<AiMessage> m) async {
          final r = await _gateway.request(
            AiFeature.mealEstimate,
            AiRequest(
              messages: m,
              maxTokens: 600,
              json: true,
              timeout: const Duration(seconds: 30),
            ),
            cancel: stop.future,
          );
          used = used + r.usage;
          return r;
        }

        final first = await ask(messages);
        try {
          estimate = MealEstimate.parse(first.message.content ?? '');
        } on FormatException {
          // One repair attempt; after that the person types it by hand.
          final second = await ask([
            ...messages,
            first.message,
            const AiMessage.user(mealRepairPrompt),
          ]);
          try {
            estimate = MealEstimate.parse(second.message.content ?? '');
          } on FormatException {
            throw const AiInvalidOutput();
          }
        }
        usage = used;
      });
    } finally {
      _stop = null;
      if (!_closed) notifyListeners();
    }
  }

  bool _closed = false;

  @override
  void dispose() {
    // Closing the sheet stops a request in flight.
    _closed = true;
    stop();
    super.dispose();
  }
}
