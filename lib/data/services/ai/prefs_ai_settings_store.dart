import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/services/ai/ai_settings.dart';
import '../../../domain/services/ai/ai_types.dart';

/// The assistant's non-critical settings, consent and daily usage in
/// SharedPreferences, all under `forja.ai.*` (SDD §2). Deleting them removes
/// only these keys: the original 0.1 snapshot stays where it is.
class PrefsAiSettingsStore implements AiSettingsStore {
  PrefsAiSettingsStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _prefs;

  static const settingsKey = 'forja.ai.settings';
  static const consentKey = 'forja.ai.consent';
  static const usageKey = 'forja.ai.usage';
  static const installedKey = 'forja.ai.installed';
  static const keys = {settingsKey, consentKey, usageKey, installedKey};

  Future<Map<String, dynamic>?> _read(String key) async {
    try {
      final text = await _prefs.getString(key);
      if (text == null) return null;
      final value = jsonDecode(text);
      return value is Map<String, dynamic> ? value : null;
    } catch (_) {
      return null;
    }
  }

  static T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  @override
  Future<AiSettings> loadSettings() async {
    final m = await _read(settingsKey);
    if (m == null) return const AiSettings();
    const d = AiSettings();
    final caps = m['capabilities'];
    final cap = m['dailyCap'];
    return AiSettings(
      enabled: m['enabled'] == true,
      provider: _enum(AiProvider.values, m['provider'], d.provider),
      baseUrl: m['baseUrl'] is String ? m['baseUrl'] as String : d.baseUrl,
      model: m['model'] is String ? m['model'] as String : d.model,
      features: {
        for (final f in (m['features'] is List ? m['features'] as List : []))
          for (final v in AiFeature.values)
            if (v.name == f) v,
      },
      dailyCap: cap is int && cap >= 1 && cap <= 500 ? cap : d.dailyCap,
      capabilities: caps is Map
          ? AiCapabilities(
              tools: caps['tools'] == true,
              jsonMode: caps['jsonMode'] == true,
            )
          : null,
    );
  }

  @override
  Future<void> saveSettings(AiSettings s) => _prefs.setString(
    settingsKey,
    jsonEncode({
      'enabled': s.enabled,
      'provider': s.provider.name,
      'baseUrl': s.baseUrl,
      'model': s.model,
      'features': [for (final f in s.features) f.name],
      'dailyCap': s.dailyCap,
      if (s.capabilities != null)
        'capabilities': {
          'tools': s.capabilities!.tools,
          'jsonMode': s.capabilities!.jsonMode,
        },
    }),
  );

  @override
  Future<AiConsent?> loadConsent() async {
    final m = await _read(consentKey);
    final at = DateTime.tryParse('${m?['acceptedAt']}');
    if (m == null || at == null || m['version'] is! String) return null;
    return AiConsent(
      version: m['version'] as String,
      acceptedAt: at.toUtc(),
      provider: _enum(AiProvider.values, m['provider'], AiProvider.custom),
      baseUrl: '${m['baseUrl']}',
      categories: {
        for (final c
            in (m['categories'] is List ? m['categories'] as List : []))
          for (final v in DataCategory.values)
            if (v.name == c) v,
      },
    );
  }

  @override
  Future<void> saveConsent(AiConsent? c) => c == null
      ? _prefs.remove(consentKey)
      : _prefs.setString(
          consentKey,
          jsonEncode({
            'version': c.version,
            'acceptedAt': c.acceptedAt.toUtc().toIso8601String(),
            'provider': c.provider.name,
            'baseUrl': c.baseUrl,
            'categories': [for (final x in c.categories) x.name],
          }),
        );

  @override
  Future<AiUsageDay?> loadUsage() async {
    final m = await _read(usageKey);
    if (m == null || m['day'] is! String) return null;
    int n(String k) => m[k] is int ? m[k] as int : 0;
    return AiUsageDay(
      day: m['day'] as String,
      requests: n('requests'),
      usage: AiUsage(
        prompt: n('prompt'),
        completion: n('completion'),
        reasoning: n('reasoning'),
        cached: n('cached'),
      ),
    );
  }

  @override
  Future<void> saveUsage(AiUsageDay u) => _prefs.setString(
    usageKey,
    jsonEncode({
      'day': u.day,
      'requests': u.requests,
      'prompt': u.usage.prompt,
      'completion': u.usage.completion,
      'reasoning': u.usage.reasoning,
      'cached': u.usage.cached,
    }),
  );

  @override
  Future<bool> isFreshInstall() async =>
      await _prefs.getBool(installedKey) != true;

  @override
  Future<void> markInstalled() => _prefs.setBool(installedKey, true);

  @override
  Future<void> forgetAll() async {
    for (final key in keys) {
      await _prefs.remove(key);
    }
    // Still the same installation: a key written later is not stale.
    await markInstalled();
  }
}
