import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/date_utils.dart';
import '../../../domain/services/ai/ai_client.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../../domain/services/ai/ai_types.dart';

/// The only way out to the network (F17, D38). A request goes only when the
/// assistant is on, the consent is valid for this provider and address,
/// there is a key, the feature is on, today's cap is not reached, nothing
/// else of that feature is in flight, and the person asked for it. Nothing
/// runs at startup, in the background or when data changes.
class AiGateway extends ChangeNotifier {
  AiGateway({
    required this._client,
    required this._secrets,
    required this._store,
    DateTime Function()? clock,
    Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? Random.secure();

  final AiChatClient _client;
  final SecretStore _secrets;
  final AiSettingsStore _store;
  final DateTime Function() _clock;
  final Random _random;

  AiSettings settings = const AiSettings();
  AiConsent? consent;
  bool hasKey = false;

  /// The last characters of the key, to recognise it ("…1234").
  String? keyTail;
  AiUsageDay _usage = const AiUsageDay(day: '');
  Future<void>? _loading;
  final _inFlight = <AiFeature>{};
  final _stops = <Completer<void>>{};
  bool _disposed = false;

  /// Reads the stored settings once. Calling it again does nothing.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    if (await _store.isFreshInstall()) {
      // A Keychain item can survive an uninstall: a new install starts
      // without a key.
      await _secrets.deleteKey();
      await _store.markInstalled();
    }
    settings = await _store.loadSettings();
    consent = await _store.loadConsent();
    _usage = await _store.loadUsage() ?? const AiUsageDay(day: '');
    final key = await _secrets.readKey();
    hasKey = key != null && key.isNotEmpty;
    keyTail = hasKey ? _tail(key!) : null;
    _notify();
  }

  static String _tail(String key) =>
      key.length <= 8 ? '' : key.substring(key.length - 4);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool get consentValid => consent?.validFor(settings) ?? false;

  /// Everything needed to send something, apart from a feature switch.
  bool get ready =>
      settings.enabled && consentValid && hasKey && settings.problem == null;

  bool featureOn(AiFeature feature) =>
      ready && settings.features.contains(feature);

  /// What the person allowed the assistant to read.
  Set<DataCategory> get categories =>
      consentValid ? consent!.categories : const {};

  String get _today => dateKey(dateOnly(_clock()));
  AiUsageDay get today =>
      _usage.day == _today ? _usage : AiUsageDay(day: _today);
  bool busy(AiFeature feature) => _inFlight.contains(feature);

  /// A new conversation id (`ses_` and 32 hex characters).
  String newSession() =>
      'ses_${List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';

  /// Sends [request] for [feature], or throws an [AiFailure] saying why
  /// not. [cancel] stops it (the stop button).
  Future<AiResponse> request(
    AiFeature feature,
    AiRequest request, {
    String? sessionId,
    Future<void>? cancel,
  }) async {
    await load();
    if (!settings.enabled) throw const AiDisabled();
    if (!consentValid) throw const AiNotConsented();
    final problem = settings.problem;
    if (problem != null) throw AiMisconfigured(problem);
    if (!settings.features.contains(feature)) throw const AiFeatureOff();
    if (_inFlight.contains(feature)) throw const AiBusy();
    if (today.requests >= settings.dailyCap) {
      throw AiDailyCap(settings.dailyCap);
    }
    // Marked before any wait, so two quick taps never send two requests.
    _inFlight.add(feature);
    final stop = Completer<void>();
    _stops.add(stop);
    _notify();
    try {
      final key = await _secrets.readKey();
      if (key == null || key.isEmpty) {
        hasKey = false;
        keyTail = null;
        throw const AiNoKey();
      }
      unawaited(
        cancel?.then((_) {
          if (!stop.isCompleted) stop.complete();
        }),
      );
      // An attempt counts against the cap even if it fails.
      _usage = AiUsageDay(
        day: today.day,
        requests: today.requests + 1,
        usage: today.usage,
      );
      await _store.saveUsage(_usage);
      final response = await _client.complete(
        request,
        AiEndpoint(
          baseUrl: settings.baseUrl.trim(),
          model: settings.model.trim(),
          apiKey: key,
          preset: settings.preset,
          sessionId: sessionId,
          capabilities: settings.capabilities,
        ),
        cancel: stop.future,
      );
      _usage = AiUsageDay(
        day: today.day,
        requests: today.requests,
        usage: today.usage + response.usage,
      );
      await _store.saveUsage(_usage);
      return response;
    } finally {
      _inFlight.remove(feature);
      _stops.remove(stop);
      _notify();
    }
  }

  /// Stops every request in flight (the app went to the background).
  void cancelAll() {
    for (final stop in [..._stops]) {
      if (!stop.isCompleted) stop.complete();
    }
  }

  // ---- settings, changed only from the assistant's sheet

  /// Saves a key the person typed. It goes to secure storage only.
  Future<void> saveKey(String key) async {
    // After the first load: the fresh-install check must never remove a key
    // typed in this very session.
    await load();
    final k = key.trim();
    if (k.isEmpty || k.length > 400 || k.contains(RegExp(r'\s'))) {
      throw ArgumentError('La clave no tiene un formato válido.');
    }
    await _secrets.writeKey(k);
    hasKey = true;
    keyTail = _tail(k);
    _notify();
  }

  Future<void> deleteKey() async {
    await load();
    await _secrets.deleteKey();
    hasKey = false;
    keyTail = null;
    _notify();
  }

  /// Changes the settings. Another provider or address needs consent again.
  Future<void> updateSettings(AiSettings next) async {
    await load();
    final keepsConsent =
        next.provider == settings.provider &&
        next.baseUrl.trim() == settings.baseUrl.trim();
    settings = next;
    await _store.saveSettings(next);
    if (!keepsConsent && consent != null) {
      consent = null;
      await _store.saveConsent(null);
    }
    _notify();
  }

  /// Records the person's consent ("Acepto y activar") and turns it on.
  Future<void> accept(Set<DataCategory> categories) async {
    await load();
    final problem = settings.problem;
    if (problem != null) throw ArgumentError(problem);
    consent = AiConsent(
      version: aiConsentVersion,
      acceptedAt: _clock().toUtc(),
      provider: settings.provider,
      baseUrl: settings.baseUrl.trim(),
      categories: {...categories},
    );
    await _store.saveConsent(consent);
    settings = settings.copyWith(enabled: true);
    await _store.saveSettings(settings);
    _notify();
  }

  /// Narrows or widens what the assistant may read; the person does it
  /// explicitly, on the assistant's sheet.
  Future<void> setCategory(DataCategory category, bool allowed) async {
    await load();
    final c = consent;
    if (c == null) return;
    consent = AiConsent(
      version: c.version,
      acceptedAt: c.acceptedAt,
      provider: c.provider,
      baseUrl: c.baseUrl,
      categories: allowed ? {...c.categories, category} : {...c.categories}
        ..remove(category),
    );
    await _store.saveConsent(consent);
    _notify();
  }

  /// Turns it off; the consent is withdrawn too.
  Future<void> disable() async {
    await load();
    cancelAll();
    settings = settings.copyWith(enabled: false);
    consent = null;
    await _store.saveSettings(settings);
    await _store.saveConsent(null);
    _notify();
  }

  /// Removes the key, consent, settings and counters ("Borrar todo" and
  /// "Desactivar y borrar todo lo del asistente").
  Future<void> forgetAll() async {
    await load();
    cancelAll();
    await _secrets.deleteKey();
    await _store.forgetAll();
    settings = const AiSettings();
    consent = null;
    hasKey = false;
    keyTail = null;
    _usage = const AiUsageDay(day: '');
    _notify();
  }

  /// Records what the connection test found.
  Future<void> setCapabilities(AiCapabilities capabilities) async {
    settings = settings.copyWith(capabilities: () => capabilities);
    await _store.saveSettings(settings);
    _notify();
  }

  bool testing = false;

  /// Checks the key, address and model with three tiny requests that carry
  /// no personal data: a plain "ok", one call to a dummy tool, and JSON
  /// mode. It works before consenting (nothing about the person is sent),
  /// counts against today's cap, and records what the provider supports.
  Future<AiConnectionReport> testConnection({Future<void>? cancel}) async {
    await load();
    final problem = settings.problem;
    if (problem != null) throw AiMisconfigured(problem);
    if (testing) throw const AiBusy();
    if (today.requests + 3 > settings.dailyCap) {
      throw AiDailyCap(settings.dailyCap);
    }
    final key = await _secrets.readKey();
    if (key == null || key.isEmpty) throw const AiNoKey();
    testing = true;
    _notify();
    final stop = Completer<void>();
    _stops.add(stop);
    unawaited(
      cancel?.then((_) {
        if (!stop.isCompleted) stop.complete();
      }),
    );
    final endpoint = AiEndpoint(
      baseUrl: settings.baseUrl.trim(),
      model: settings.model.trim(),
      apiKey: key,
      preset: settings.preset,
      sessionId: newSession(),
    );
    var usage = const AiUsage();
    Future<AiResponse> send(AiRequest r) async {
      _usage = AiUsageDay(
        day: today.day,
        requests: today.requests + 1,
        usage: today.usage,
      );
      final response = await _client.complete(r, endpoint, cancel: stop.future);
      usage = usage + response.usage;
      return response;
    }

    try {
      final hello = await send(
        const AiRequest(
          messages: [
            AiMessage.system('Responde solo: ok'),
            AiMessage.user('ok'),
          ],
          maxTokens: 5,
          timeout: Duration(seconds: 30),
        ),
      );
      var tools = false, json = false;
      try {
        final probe = await send(
          const AiRequest(
            messages: [
              AiMessage.system(
                'Prueba técnica. Llama a la herramienta probe_ping sin texto.',
              ),
              AiMessage.user('Llama a probe_ping.'),
            ],
            tools: [
              AiFunction(
                name: 'probe_ping',
                description: 'Prueba de conexión: no hace nada.',
                parameters: {
                  'type': 'object',
                  'properties': <String, Object?>{},
                  'additionalProperties': false,
                },
              ),
            ],
            maxTokens: 60,
            timeout: Duration(seconds: 30),
          ),
        );
        tools = probe.message.toolCalls.any((c) => c.name == 'probe_ping');
      } on AiRejected {
        tools = false;
      }
      try {
        final probe = await send(
          const AiRequest(
            messages: [
              AiMessage.system('Devuelve solo un objeto JSON.'),
              AiMessage.user('Devuelve {"ok": true}'),
            ],
            jsonProbe: true,
            maxTokens: 30,
            timeout: Duration(seconds: 30),
          ),
        );
        final text = probe.message.content ?? '';
        json = text.contains('{') && text.contains('ok');
      } on AiRejected {
        json = false;
      }
      final capabilities = AiCapabilities(tools: tools, jsonMode: json);
      await setCapabilities(capabilities);
      return AiConnectionReport(
        model: hello.model,
        latency: hello.latency,
        capabilities: capabilities,
        usage: usage,
      );
    } finally {
      _usage = AiUsageDay(
        day: today.day,
        requests: today.requests,
        usage: today.usage + usage,
      );
      await _store.saveUsage(_usage);
      testing = false;
      _stops.remove(stop);
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    cancelAll();
    super.dispose();
  }
}

/// What the connection test found.
class AiConnectionReport {
  const AiConnectionReport({
    required this.model,
    required this.latency,
    required this.capabilities,
    required this.usage,
  });
  final String model;
  final Duration latency;
  final AiCapabilities capabilities;
  final AiUsage usage;
}
