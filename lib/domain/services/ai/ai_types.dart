// The optional external assistant (F17, D38): what goes to the provider and
// what comes back, independent of any HTTP library. Nothing here holds the
// API key or is ever written to the database.

enum AiRole { system, user, assistant, tool }

/// A call the model asked for: a tool name and its arguments (JSON text).
class AiToolCall {
  const AiToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });
  final String id, name;

  /// Raw JSON text, as the model wrote it: always parsed and checked.
  final String arguments;
}

class AiMessage {
  const AiMessage({
    required this.role,
    this.content,
    this.toolCalls = const [],
    this.toolCallId,
    this.reasoning,
  });
  const AiMessage.system(String text)
    : this(role: AiRole.system, content: text);
  const AiMessage.user(String text) : this(role: AiRole.user, content: text);
  const AiMessage.tool(String id, String text)
    : this(role: AiRole.tool, content: text, toolCallId: id);

  final AiRole role;
  final String? content;
  final List<AiToolCall> toolCalls;

  /// The call a tool message answers.
  final String? toolCallId;

  /// The model's reasoning text (`reasoning_content`). It is sent back with
  /// its tool calls when the provider needs it, and is never shown or logged.
  final String? reasoning;
}

/// A tool the model may call, in the shape of an MCP tool.
class AiFunction {
  const AiFunction({
    required this.name,
    required this.description,
    required this.parameters,
  });
  final String name, description;

  /// JSON Schema of the arguments (an object).
  final Map<String, Object?> parameters;
}

class AiRequest {
  const AiRequest({
    required this.messages,
    required this.maxTokens,
    this.tools = const [],
    this.json = false,
    this.jsonProbe = false,
    this.temperature = 0.3,
    this.timeout = const Duration(seconds: 45),
  });
  final List<AiMessage> messages;
  final List<AiFunction> tools;

  /// Ask for a JSON object, but only once the connection test confirmed the
  /// provider supports it; otherwise the prompt alone asks for JSON.
  final bool json;

  /// Ask for JSON mode regardless (the connection test's probe).
  final bool jsonProbe;
  final int maxTokens;
  final double temperature;

  /// Longest wait for one answer.
  final Duration timeout;
}

/// Tokens counted by the provider for one answer.
class AiUsage {
  const AiUsage({
    this.prompt = 0,
    this.completion = 0,
    this.reasoning = 0,
    this.cached = 0,
  });
  final int prompt, completion, reasoning, cached;
  int get total => prompt + completion;
  AiUsage operator +(AiUsage o) => AiUsage(
    prompt: prompt + o.prompt,
    completion: completion + o.completion,
    reasoning: reasoning + o.reasoning,
    cached: cached + o.cached,
  );
}

class AiResponse {
  const AiResponse({
    required this.message,
    required this.usage,
    required this.model,
    required this.latency,
    this.finishReason,
  });
  final AiMessage message;
  final AiUsage usage;

  /// The model that answered, as the provider reports it.
  final String model;
  final Duration latency;
  final String? finishReason;
}

/// Why a request did not get an answer, in words for the person. A failure
/// never carries the request, the answer or the key.
sealed class AiFailure implements Exception {
  const AiFailure();
  String get message;
  @override
  String toString() => 'AiFailure($runtimeType)';
}

final class AiDisabled extends AiFailure {
  const AiDisabled();
  @override
  String get message =>
      'El asistente está desactivado. El minicoach local sigue funcionando.';
}

final class AiNotConsented extends AiFailure {
  const AiNotConsented();
  @override
  String get message =>
      'Falta tu consentimiento para este proveedor. Revísalo en Más → Asistente IA.';
}

final class AiNoKey extends AiFailure {
  const AiNoKey();
  @override
  String get message =>
      'Falta la clave. Escríbela en Más → Asistente IA (si el sistema la borró, vuelve a escribirla).';
}

final class AiFeatureOff extends AiFailure {
  const AiFeatureOff();
  @override
  String get message => 'Esta función del asistente está desactivada.';
}

final class AiDailyCap extends AiFailure {
  const AiDailyCap(this.cap);
  final int cap;
  @override
  String get message =>
      'Has llegado al tope de $cap peticiones de hoy. Puedes cambiarlo en Más → Asistente IA.';
}

final class AiBusy extends AiFailure {
  const AiBusy();
  @override
  String get message => 'Espera a que termine la petición anterior.';
}

final class AiOffline extends AiFailure {
  const AiOffline();
  @override
  String get message => 'Sin conexión. El minicoach local sigue funcionando.';
}

final class AiUnauthorized extends AiFailure {
  const AiUnauthorized();
  @override
  String get message =>
      'La clave no es válida o no tiene acceso a este modelo.';
}

final class AiQuota extends AiFailure {
  const AiQuota();
  @override
  String get message => 'Sin saldo o el plan del proveedor está agotado.';
}

final class AiRateLimited extends AiFailure {
  const AiRateLimited(this.retryAt);

  /// When the provider said to try again, if it did.
  final DateTime? retryAt;
  @override
  String get message {
    final at = retryAt?.toLocal();
    return at == null
        ? 'Límite del proveedor alcanzado; prueba más tarde.'
        : 'Límite del proveedor alcanzado; prueba a las '
              '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}.';
  }
}

final class AiContentFiltered extends AiFailure {
  const AiContentFiltered();
  @override
  String get message =>
      'El proveedor filtró la respuesta. Prueba a reformularlo.';
}

final class AiMisconfigured extends AiFailure {
  const AiMisconfigured(this.detail);

  /// Which setting is wrong, in words; never data.
  final String detail;
  @override
  String get message => 'Configuración del proveedor no válida: $detail';
}

final class AiRejected extends AiFailure {
  const AiRejected(this.status);
  final int status;
  @override
  String get message =>
      'El proveedor rechazó la petición (código $status). Revisa el modelo y la dirección.';
}

final class AiServer extends AiFailure {
  const AiServer();
  @override
  String get message =>
      'El proveedor tuvo un error. Prueba de nuevo en un rato.';
}

final class AiTimeout extends AiFailure {
  const AiTimeout();
  @override
  String get message => 'El proveedor tardó demasiado en responder.';
}

final class AiCancelled extends AiFailure {
  const AiCancelled();
  @override
  String get message => 'Petición cancelada.';
}

final class AiInvalidOutput extends AiFailure {
  const AiInvalidOutput();
  @override
  String get message =>
      'La respuesta no tenía el formato esperado. Puedes escribirlo a mano.';
}
