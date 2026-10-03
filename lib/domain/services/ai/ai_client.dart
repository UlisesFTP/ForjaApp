import 'ai_settings.dart';
import 'ai_types.dart';

/// Where and how one request goes. Built by the gateway for each call; the
/// key is read from secure storage just before and never kept here.
class AiEndpoint {
  const AiEndpoint({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    required this.preset,
    this.sessionId,
    this.capabilities,
  });
  final String baseUrl, model, apiKey;
  final AiProviderPreset preset;

  /// One per conversation (OpenCode Go routes by it).
  final String? sessionId;
  final AiCapabilities? capabilities;

  @override
  String toString() => 'AiEndpoint(${preset.label}, $model)';
}

/// An OpenAI-compatible chat client. Implementations never retry what the
/// person did not ask for twice, and never log bodies or keys.
abstract class AiChatClient {
  /// [cancel] completes when the request must stop (the person pressed
  /// stop, or the app went to the background).
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  });
}

/// The default everywhere (tests included): never touches the network.
class DisabledAiChatClient implements AiChatClient {
  const DisabledAiChatClient();
  @override
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  }) => Future.error(const AiDisabled());
}
