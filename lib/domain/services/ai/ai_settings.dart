import 'ai_types.dart';

/// Version of the consent text. A new version asks for consent again.
const aiConsentVersion = 'ai-consent-v1';

enum AiProvider { opencodeGo, xiaomi, custom }

/// A provider the person can choose. The key is always theirs (BYOK).
class AiProviderPreset {
  const AiProviderPreset({
    required this.provider,
    required this.label,
    required this.baseUrl,
    required this.model,
    required this.hosting,
    required this.retention,
    this.sessionHeader = false,
    this.disableThinking = false,
    this.risk,
  });
  final AiProvider provider;
  final String label, baseUrl, model;

  /// Where the provider says it runs and what it says it keeps; both shown
  /// "según el proveedor", never as FORJA's own guarantee.
  final String hosting, retention;

  /// Sends `x-opencode-session` (OpenCode Go routes by it).
  final bool sessionHeader;

  /// Sends `thinking: {type: disabled}` (MiMo models think by default).
  final bool disableThinking;

  /// What the person should know before using it.
  final String? risk;
}

const aiPresets = {
  AiProvider.opencodeGo: AiProviderPreset(
    provider: AiProvider.opencodeGo,
    label: 'OpenCode Go',
    baseUrl: 'https://opencode.ai/zen/go/v1',
    model: 'mimo-v2.6-flash',
    hosting: 'Según OpenCode, los modelos de Go se alojan en EE. UU.',
    retention: 'Según OpenCode, MiMo-V2.6-Flash no guarda los datos (0 días) ni los usa para entrenar.',
    sessionHeader: true,
    disableThinking: true,
    risk:
        'OpenCode Go está pensado para agentes de programación y vigila el '
        'tráfico: usarlo desde una app de gimnasio podría hacer que OpenCode '
        'limite o suspenda tu cuenta. Tú asumes ese riesgo.',
  ),
  AiProvider.xiaomi: AiProviderPreset(
    provider: AiProvider.xiaomi,
    label: 'Xiaomi MiMo (API directa)',
    baseUrl: 'https://api.xiaomimimo.com/v1',
    model: 'mimo-v2.6-flash',
    hosting: 'Servidores de Xiaomi; FORJA no ha revisado dónde se alojan.',
    retention: 'FORJA no ha revisado la política de retención de Xiaomi: consúltala antes.',
    disableThinking: true,
  ),
  AiProvider.custom: AiProviderPreset(
    provider: AiProvider.custom,
    label: 'Personalizado (compatible con OpenAI)',
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
    if (m.endsWith('-free')) {
      return 'los modelos «-free» pueden usar tus datos para entrenar';
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
