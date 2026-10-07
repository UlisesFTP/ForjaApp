import 'ai_types.dart';

/// Version of the consent text. A new version asks for consent again.
const aiConsentVersion = 'ai-consent-v1';

/// New values go at the end: settings and consent are stored by name.
enum AiProvider {
  opencodeGo,
  xiaomi,
  custom,
  opencodeZen,
  openai,
  openrouter,
  google,
  deepseek,
  mistral,
  groq,
}

/// The order the providers are offered in: the recommended one first, the
/// person's own address last.
const aiProviderOrder = [
  AiProvider.opencodeGo,
  AiProvider.opencodeZen,
  AiProvider.openai,
  AiProvider.google,
  AiProvider.deepseek,
  AiProvider.mistral,
  AiProvider.groq,
  AiProvider.openrouter,
  AiProvider.xiaomi,
  AiProvider.custom,
];

/// A model offered in the picker. Any other model can still be typed.
class AiModelOption {
  const AiModelOption(this.id, this.label, this.note);
  final String id, label, note;
}

/// A provider the person can choose. The key is always theirs (BYOK).
class AiProviderPreset {
  const AiProviderPreset({
    required this.provider,
    required this.label,
    required this.summary,
    required this.baseUrl,
    required this.model,
    required this.hosting,
    required this.retention,
    this.models = const [],
    this.keyHint = 'Créala en la consola de tu proveedor y pégala aquí.',
    this.sessionHeader = false,
    this.disableThinking = false,
    this.tokenParam = 'max_completion_tokens',
    this.sendTemperature = true,
    this.risk,
  });
  final AiProvider provider;
  final String label, baseUrl, model;

  /// One line for the provider picker.
  final String summary;

  /// Popular models of this provider, the default first.
  final List<AiModelOption> models;

  /// Where the key comes from; shown above the key field.
  final String keyHint;

  /// Where the provider says it runs and what it says it keeps; both shown
  /// "según el proveedor", never as FORJA's own guarantee.
  final String hosting, retention;

  /// Sends `x-opencode-session` (OpenCode routes by it).
  final bool sessionHeader;

  /// Sends `thinking: {type: disabled}` (MiMo models think by default).
  final bool disableThinking;

  /// The name of the output limit: OpenAI-style `max_completion_tokens`, or
  /// the older `max_tokens` that some providers still require.
  final String tokenParam;

  /// Some reasoning models only accept their default temperature.
  final bool sendTemperature;

  /// What the person should know before using it.
  final String? risk;

  /// The picker's entry for [id], if it is one of the popular models.
  AiModelOption? option(String id) {
    for (final m in models) {
      if (m.id == id) return m;
    }
    return null;
  }
}

const _unchecked = 'FORJA no ha revisado dónde se alojan.';
const _uncheckedRetention =
    'FORJA no ha revisado su política de retención: consúltala antes.';

const aiPresets = {
  AiProvider.opencodeGo: AiProviderPreset(
    provider: AiProvider.opencodeGo,
    label: 'OpenCode Go',
    summary: 'Suscripción de OpenCode con modelos económicos. Recomendado.',
    baseUrl: 'https://opencode.ai/zen/go/v1',
    model: 'mimo-v2.6-flash',
    models: [
      AiModelOption(
        'mimo-v2.6-flash',
        'MiMo V2.6 Flash',
        'Rápido y barato · recomendado',
      ),
      AiModelOption('mimo-v2.6-pro', 'MiMo V2.6 Pro', 'Más capaz, más lento'),
      AiModelOption(
        'deepseek-v4-flash',
        'DeepSeek V4 Flash',
        'Rápido y económico',
      ),
      AiModelOption('deepseek-v4-pro', 'DeepSeek V4 Pro', 'Más capaz'),
      AiModelOption('glm-5.3-flash', 'GLM 5.3 Flash', 'Rápido'),
      AiModelOption('kimi-k2.6', 'Kimi K2.6', 'Equilibrado'),
    ],
    keyHint: 'Cópiala de la consola de OpenCode (suscripción Go).',
    hosting: 'Según OpenCode, los modelos de Go se alojan en EE. UU.',
    retention:
        'Según OpenCode, MiMo-V2.6-Flash no guarda los datos (0 días) ni los '
        'usa para entrenar.',
    sessionHeader: true,
    disableThinking: true,
    risk:
        'OpenCode Go está pensado para agentes de programación y vigila el '
        'tráfico: usarlo desde una app de gimnasio podría hacer que OpenCode '
        'limite o suspenda tu cuenta. Tú asumes ese riesgo.',
  ),
  AiProvider.opencodeZen: AiProviderPreset(
    provider: AiProvider.opencodeZen,
    label: 'OpenCode Zen',
    summary: 'Pago por uso de OpenCode, sin los modelos gratuitos.',
    baseUrl: 'https://opencode.ai/zen/v1',
    model: 'deepseek-v4-flash',
    models: [
      AiModelOption(
        'deepseek-v4-flash',
        'DeepSeek V4 Flash',
        'Rápido y económico',
      ),
      AiModelOption('deepseek-v4-pro', 'DeepSeek V4 Pro', 'Más capaz'),
      AiModelOption('glm-5.3-flash', 'GLM 5.3 Flash', 'Rápido'),
      AiModelOption('kimi-k2.6', 'Kimi K2.6', 'Equilibrado'),
      AiModelOption('qwen3.8-max', 'Qwen 3.8 Max', 'Potente'),
      AiModelOption('mistral-large-4', 'Mistral Large 4', 'Potente'),
    ],
    keyHint: 'Cópiala de la consola de OpenCode (saldo Zen).',
    hosting: 'Servidores de OpenCode y del modelo elegido. $_unchecked',
    retention:
        'Los modelos «free» de Zen pueden usar tus datos para entrenar y '
        'FORJA los rechaza. En los de pago: $_uncheckedRetention',
    sessionHeader: true,
    disableThinking: true,
    risk:
        'OpenCode vigila el tráfico de sus servicios: usarlo desde otra app '
        'podría hacer que limite tu cuenta. Tú asumes ese riesgo.',
  ),
  AiProvider.openai: AiProviderPreset(
    provider: AiProvider.openai,
    label: 'OpenAI',
    summary: 'API de OpenAI (ChatGPT) con tu clave.',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-6-luna',
    models: [
      AiModelOption('gpt-6-luna', 'GPT-6 Luna', 'Económico y rápido'),
      AiModelOption('gpt-6-sol', 'GPT-6 Sol', 'Equilibrado y capaz'),
      AiModelOption('gpt-6.1-sol', 'GPT-6.1 Sol', 'El más reciente'),
    ],
    keyHint: 'Créala en platform.openai.com → API keys.',
    hosting: 'Servidores de OpenAI. $_unchecked',
    retention:
        'Según OpenAI, los datos de la API no se usan para entrenar por '
        'defecto; consulta cuánto tiempo los conserva.',
    sendTemperature: false,
  ),
  AiProvider.google: AiProviderPreset(
    provider: AiProvider.google,
    label: 'Google Gemini',
    summary: 'API de Gemini en modo compatible con OpenAI.',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
    model: 'gemini-3.8-flash',
    models: [
      AiModelOption(
        'gemini-3.8-flash',
        'Gemini 3.8 Flash',
        'Rápido · recomendado',
      ),
      AiModelOption('gemini-3.7-flash', 'Gemini 3.7 Flash', 'Rápido'),
    ],
    keyHint: 'Créala en Google AI Studio → Get API key.',
    hosting: 'Servidores de Google. $_unchecked',
    retention:
        'Con una clave de nivel gratuito Google puede usar tus datos para '
        'mejorar sus productos: usa una clave con facturación activa.',
    tokenParam: 'max_tokens',
  ),
  AiProvider.deepseek: AiProviderPreset(
    provider: AiProvider.deepseek,
    label: 'DeepSeek',
    summary: 'API directa de DeepSeek, muy económica.',
    baseUrl: 'https://api.deepseek.com/v1',
    model: 'deepseek-v4-flash',
    models: [
      AiModelOption(
        'deepseek-v4-flash',
        'DeepSeek V4 Flash',
        'Rápido y económico',
      ),
      AiModelOption('deepseek-v4-pro', 'DeepSeek V4 Pro', 'Más capaz'),
    ],
    keyHint: 'Créala en platform.deepseek.com → API keys.',
    hosting: 'Servidores de DeepSeek. $_unchecked',
    retention: _uncheckedRetention,
    tokenParam: 'max_tokens',
  ),
  AiProvider.mistral: AiProviderPreset(
    provider: AiProvider.mistral,
    label: 'Mistral',
    summary: 'API de Mistral AI.',
    baseUrl: 'https://api.mistral.ai/v1',
    model: 'mistral-small-latest',
    models: [
      AiModelOption(
        'mistral-small-latest',
        'Mistral Small',
        'Rápido y económico',
      ),
      AiModelOption('mistral-medium-latest', 'Mistral Medium', 'Equilibrado'),
      AiModelOption('mistral-large-latest', 'Mistral Large', 'Potente'),
    ],
    keyHint: 'Créala en console.mistral.ai → API keys.',
    hosting: 'Servidores de Mistral AI. $_unchecked',
    retention:
        'En el plan gratuito Mistral puede usar tus datos para entrenar: usa '
        'un plan de pago.',
    tokenParam: 'max_tokens',
  ),
  AiProvider.groq: AiProviderPreset(
    provider: AiProvider.groq,
    label: 'Groq',
    summary: 'Modelos abiertos con respuestas muy rápidas.',
    baseUrl: 'https://api.groq.com/openai/v1',
    model: 'llama-3.3-70b-versatile',
    models: [
      AiModelOption(
        'llama-3.3-70b-versatile',
        'Llama 3.3 70B',
        'Rápido · recomendado',
      ),
      AiModelOption('openai/gpt-oss-120b', 'GPT-OSS 120B', 'Potente'),
      AiModelOption('openai/gpt-oss-20b', 'GPT-OSS 20B', 'Muy rápido'),
    ],
    keyHint: 'Créala en console.groq.com → API Keys.',
    hosting: 'Servidores de Groq. $_unchecked',
    retention: _uncheckedRetention,
  ),
  AiProvider.openrouter: AiProviderPreset(
    provider: AiProvider.openrouter,
    label: 'OpenRouter',
    summary: 'Una sola clave para modelos de muchas empresas.',
    baseUrl: 'https://openrouter.ai/api/v1',
    model: 'xiaomi/mimo-v2.6-flash',
    models: [
      AiModelOption(
        'xiaomi/mimo-v2.6-flash',
        'MiMo V2.6 Flash',
        'Rápido y barato',
      ),
      AiModelOption(
        'deepseek/deepseek-v4-flash',
        'DeepSeek V4 Flash',
        'Económico',
      ),
      AiModelOption('google/gemini-3.8-flash', 'Gemini 3.8 Flash', 'Rápido'),
      AiModelOption('openai/gpt-6-luna', 'GPT-6 Luna', 'Económico'),
      AiModelOption(
        'anthropic/claude-sonnet-5.5',
        'Claude Sonnet 5.5',
        'Potente',
      ),
    ],
    keyHint: 'Créala en openrouter.ai → Keys.',
    hosting: 'OpenRouter reenvía tus datos al proveedor del modelo elegido.',
    retention:
        'Depende del modelo y de los ajustes de privacidad de tu cuenta. Los '
        'modelos «:free» pueden usar tus datos y FORJA los rechaza.',
    tokenParam: 'max_tokens',
  ),
  AiProvider.xiaomi: AiProviderPreset(
    provider: AiProvider.xiaomi,
    label: 'Xiaomi MiMo (API directa)',
    summary: 'API de Xiaomi con los mismos modelos MiMo.',
    baseUrl: 'https://api.xiaomimimo.com/v1',
    model: 'mimo-v2.6-flash',
    models: [
      AiModelOption(
        'mimo-v2.6-flash',
        'MiMo V2.6 Flash',
        'Rápido y barato · recomendado',
      ),
      AiModelOption('mimo-v2.6-pro', 'MiMo V2.6 Pro', 'Más capaz'),
    ],
    keyHint: 'Créala en la consola de Xiaomi MiMo.',
    hosting: 'Servidores de Xiaomi. $_unchecked',
    retention: _uncheckedRetention,
    disableThinking: true,
  ),
  AiProvider.custom: AiProviderPreset(
    provider: AiProvider.custom,
    label: 'Otro (compatible con OpenAI)',
    summary: 'Tu propia dirección https y tu propio modelo.',
    baseUrl: '',
    model: '',
    hosting: 'El que diga tu proveedor; FORJA no lo conoce.',
    retention: 'La que diga tu proveedor; FORJA no la conoce.',
  ),
};

/// What the assistant may read, as the consent lists it (D38: all on by
/// default, each one can be turned off).
enum DataCategory {
  profile('Perfil', 'Objetivo, experiencia, días, equipo y duración.'),
  body('Cuerpo', 'Peso corporal y edad, si los diste.'),
  training(
    'Entrenamiento',
    'Plan, sesiones, series, repeticiones, RIR, técnica, cardio y los consejos del minicoach.',
  ),
  wellbeing(
    'Bienestar',
    'Cómo te sentías antes y después: cansancio, DOMS, lesión.',
  ),
  nutrition('Nutrición', 'Comidas, calorías, macros y objetivos.'),
  notes(
    'Notas',
    'Lo que escribiste en el perfil, en los check-ins y en las sesiones.',
  );

  const DataCategory(this.label, this.description);
  final String label, description;
}

enum AiFeature {
  chat('Chat del coach'),
  mealEstimate('Describir comida');

  const AiFeature(this.label);
  final String label;
}

/// What the provider showed it can do in the connection test.
class AiCapabilities {
  const AiCapabilities({this.tools = false, this.jsonMode = false});
  final bool tools, jsonMode;
}

/// Non-critical preferences of the assistant (stored under `forja.ai.*`).
class AiSettings {
  const AiSettings({
    this.enabled = false,
    this.provider = AiProvider.opencodeGo,
    this.baseUrl = 'https://opencode.ai/zen/go/v1',
    this.model = 'mimo-v2.6-flash',
    this.features = const {AiFeature.chat, AiFeature.mealEstimate},
    this.dailyCap = 60,
    this.capabilities,
  });
  final bool enabled;
  final AiProvider provider;
  final String baseUrl, model;
  final Set<AiFeature> features;
  final int dailyCap;

  /// Null until the connection test ran for this provider.
  final AiCapabilities? capabilities;

  AiProviderPreset get preset => aiPresets[provider]!;

  AiSettings copyWith({
    bool? enabled,
    AiProvider? provider,
    String? baseUrl,
    String? model,
    Set<AiFeature>? features,
    int? dailyCap,
    AiCapabilities? Function()? capabilities,
  }) => AiSettings(
    enabled: enabled ?? this.enabled,
    provider: provider ?? this.provider,
    baseUrl: baseUrl ?? this.baseUrl,
    model: model ?? this.model,
    features: features ?? this.features,
    dailyCap: dailyCap ?? this.dailyCap,
    capabilities: capabilities == null ? this.capabilities : capabilities(),
  );

  /// Why these settings cannot be used, or null.
  String? get problem {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return 'la dirección debe empezar por https://';
    }
    final m = model.trim();
    if (m.isEmpty || m.length > 80 || m.contains(RegExp(r'\s'))) {
      return 'el modelo no es válido';
    }
    // The free tier may use the data to train the model.
    if (m.endsWith('-free') || m.endsWith(':free')) {
      return 'los modelos gratuitos («-free», «:free») pueden usar tus datos para entrenar';
    }
    if (dailyCap < 1 || dailyCap > 500) return 'el tope diario va de 1 a 500';
    return null;
  }
}

/// The person's explicit consent for one provider and address.
class AiConsent {
  const AiConsent({
    required this.version,
    required this.acceptedAt,
    required this.provider,
    required this.baseUrl,
    required this.categories,
  });
  final String version;
  final DateTime acceptedAt;
  final AiProvider provider;
  final String baseUrl;
  final Set<DataCategory> categories;

  /// Consent counts only for the same text, provider and address.
  bool validFor(AiSettings s) =>
      version == aiConsentVersion &&
      provider == s.provider &&
      baseUrl == s.baseUrl.trim();
}

/// Requests and tokens of one local day.
class AiUsageDay {
  const AiUsageDay({
    required this.day,
    this.requests = 0,
    this.usage = const AiUsage(),
  });
  final String day;
  final int requests;
  final AiUsage usage;
}

/// Where the settings, consent and daily usage live (SharedPreferences in
/// the app, memory in tests). Never the database or a backup.
abstract class AiSettingsStore {
  Future<AiSettings> loadSettings();
  Future<void> saveSettings(AiSettings settings);
  Future<AiConsent?> loadConsent();
  Future<void> saveConsent(AiConsent? consent);
  Future<AiUsageDay?> loadUsage();
  Future<void> saveUsage(AiUsageDay usage);

  /// True until [markInstalled]: on iOS a key in the Keychain can outlive
  /// an uninstall, and a fresh install must not inherit it.
  Future<bool> isFreshInstall();
  Future<void> markInstalled();

  /// Removes everything the assistant stored here, and nothing else.
  Future<void> forgetAll();
}

/// Where the API key lives: the platform's secure storage in the app.
abstract class SecretStore {
  Future<String?> readKey();
  Future<void> writeKey(String key);
  Future<void> deleteKey();
}

class MemoryAiSettingsStore implements AiSettingsStore {
  AiSettings settings = const AiSettings();
  AiConsent? consent;
  AiUsageDay? usage;

  /// Tests set it to check what a fresh install does.
  bool fresh = false;
  @override
  Future<AiSettings> loadSettings() async => settings;
  @override
  Future<void> saveSettings(AiSettings s) async => settings = s;
  @override
  Future<AiConsent?> loadConsent() async => consent;
  @override
  Future<void> saveConsent(AiConsent? c) async => consent = c;
  @override
  Future<AiUsageDay?> loadUsage() async => usage;
  @override
  Future<void> saveUsage(AiUsageDay u) async => usage = u;
  @override
  Future<bool> isFreshInstall() async => fresh;
  @override
  Future<void> markInstalled() async => fresh = false;
  @override
  Future<void> forgetAll() async {
    settings = const AiSettings();
    consent = null;
    usage = null;
  }
}

class MemorySecretStore implements SecretStore {
  String? key;
  @override
  Future<String?> readKey() async => key;
  @override
  Future<void> writeKey(String k) async => key = k;
  @override
  Future<void> deleteKey() async => key = null;
}
