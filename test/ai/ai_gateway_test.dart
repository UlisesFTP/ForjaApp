import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/legacy/legacy_snapshot_source.dart';
import 'package:forja_app/data/services/ai/ai_gateway.dart';
import 'package:forja_app/data/services/ai/prefs_ai_settings_store.dart';
import 'package:forja_app/domain/services/ai/ai_client.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Counts calls and answers "ok"; a test can make it fail on any call.
class FakeClient implements AiChatClient {
  FakeClient({this.failOnCall = false, this.answer = 'ok'});
  final bool failOnCall;
  String answer;
  final requests = <AiRequest>[];
  final endpoints = <AiEndpoint>[];
  Completer<void>? hold;

  @override
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  }) async {
    if (failOnCall) fail('The network was called: ${request.messages.length}');
    requests.add(request);
    endpoints.add(endpoint);
    final h = hold;
    if (h != null) {
      await Future.any([h.future, ?cancel]);
      if (!h.isCompleted) throw const AiCancelled();
    }
    return AiResponse(
      message: AiMessage(
        role: AiRole.assistant,
        content: answer,
        toolCalls: request.tools.isEmpty
            ? const []
            : [
                AiToolCall(
                  id: 'c1',
                  name: request.tools.first.name,
                  arguments: '{}',
                ),
              ],
      ),
      usage: const AiUsage(prompt: 10, completion: 2),
      model: 'mimo-v2.6-flash',
      latency: const Duration(milliseconds: 300),
    );
  }
}

const _request = AiRequest(messages: [AiMessage.user('hola')], maxTokens: 50);

void main() {
  late MemorySecretStore secrets;
  late MemoryAiSettingsStore store;
  final now = DateTime(2026, 10, 2, 12);

  setUp(() {
    secrets = MemorySecretStore();
    store = MemoryAiSettingsStore();
  });

  AiGateway gateway(AiChatClient client) => AiGateway(
    client: client,
    secrets: secrets,
    store: store,
    clock: () => now,
  );

  group('no request without everything the person agreed to (F17)', () {
    test('off, no consent, no key or a feature off: the client is never '
        'called', () async {
      final g = gateway(FakeClient(failOnCall: true));
      addTearDown(g.dispose);
      await expectLater(
        g.request(AiFeature.chat, _request),
        throwsA(isA<AiDisabled>()),
      );
      // On but without consent.
      store.settings = const AiSettings(enabled: true);
      final g2 = gateway(FakeClient(failOnCall: true));
      addTearDown(g2.dispose);
      await expectLater(
        g2.request(AiFeature.chat, _request),
        throwsA(isA<AiNotConsented>()),
      );
      // Consent but no key.
      await g2.accept({...DataCategory.values});
      await expectLater(
        g2.request(AiFeature.chat, _request),
        throwsA(isA<AiNoKey>()),
      );
      // A feature turned off.
      await g2.saveKey('sk-test-key-0000000000');
      await g2.updateSettings(
        g2.settings.copyWith(features: {AiFeature.mealEstimate}),
      );
      await expectLater(
        g2.request(AiFeature.chat, _request),
        throwsA(isA<AiFeatureOff>()),
      );
    });

    test('loading and reading the state sends nothing', () async {
      store.settings = const AiSettings(enabled: true);
      secrets.key = 'sk-test-key-0000000000';
      final g = gateway(FakeClient(failOnCall: true));
      addTearDown(g.dispose);
      await g.load();
      expect(g.hasKey, isTrue);
      expect(g.keyTail, '0000');
      expect(g.ready, isFalse, reason: 'no consent yet');
    });

    test('another provider or address asks for consent again', () async {
      final client = FakeClient();
      final g = gateway(client);
      addTearDown(g.dispose);
      await g.saveKey('sk-test-key-0000000000');
      await g.accept({DataCategory.training});
      expect(g.ready, isTrue);
      await g.request(AiFeature.chat, _request);
      expect(client.requests, hasLength(1));
      await g.updateSettings(g.settings.copyWith(provider: AiProvider.xiaomi));
      expect(g.consentValid, isFalse);
      await expectLater(
        g.request(AiFeature.chat, _request),
        throwsA(isA<AiNotConsented>()),
      );
      await g.updateSettings(
        g.settings.copyWith(
          provider: AiProvider.xiaomi,
          baseUrl: 'https://api.xiaomimimo.com/v1',
        ),
      );
      await g.accept({DataCategory.training});
      // Changing only the model keeps the consent.
      await g.updateSettings(g.settings.copyWith(model: 'otro-modelo'));
      expect(g.consentValid, isTrue);
      expect(client.requests, hasLength(1));
    });

    test('the request carries the key, the session and the preset only to '
        'the client', () async {
      final client = FakeClient();
      final g = gateway(client);
      addTearDown(g.dispose);
      await g.saveKey('  sk-test-key-0000000000 ');
      await g.accept({DataCategory.training});
      final session = g.newSession();
      expect(session, matches(RegExp(r'^ses_[0-9a-f]{32}$')));
      await g.request(AiFeature.chat, _request, sessionId: session);
      final e = client.endpoints.single;
      expect(e.apiKey, 'sk-test-key-0000000000');
      expect(e.sessionId, session);
      expect(e.preset.sessionHeader, isTrue);
      expect(e.toString(), isNot(contains('sk-test')));
      expect(g.today.requests, 1);
      expect(g.today.usage.total, 12);
    });

    test('a daily cap, one request at a time, and stopping', () async {
      final client = FakeClient()..hold = Completer<void>();
      final g = gateway(client);
      addTearDown(g.dispose);
      await g.saveKey('sk-test-key-0000000000');
      await g.accept({DataCategory.training});
      final first = g.request(AiFeature.chat, _request);
      await expectLater(
        g.request(AiFeature.chat, _request),
        throwsA(isA<AiBusy>()),
      );
      // The app goes to the background: it stops.
      await Future<void>.delayed(Duration.zero);
      g.cancelAll();
      await expectLater(first, throwsA(isA<AiCancelled>()));
      client.hold = null;
      await g.updateSettings(g.settings.copyWith(dailyCap: 2));
      await g.request(AiFeature.chat, _request);
      await expectLater(
        g.request(AiFeature.chat, _request),
        throwsA(isA<AiDailyCap>()),
      );
    });

    test('settings that are not https or a "-free" model are refused', () {
      expect(
        const AiSettings(baseUrl: 'http://example.com/v1').problem,
        contains('https'),
      );
      expect(
        const AiSettings(model: 'mimo-v2.6-flash-free').problem,
        contains('-free'),
      );
      expect(const AiSettings().problem, isNull);
    });

    test('a fresh install drops a key left behind by an uninstall', () async {
      secrets.key = 'sk-old-key-00000000000';
      store.fresh = true;
      final g = gateway(FakeClient(failOnCall: true));
      addTearDown(g.dispose);
      await g.load();
      expect(secrets.key, isNull);
      expect(g.hasKey, isFalse);
    });

    test('regression: a key saved before the first load survives the '
        'fresh-install check', () async {
      store.fresh = true;
      final g = gateway(FakeClient());
      addTearDown(g.dispose);
      await g.saveKey('sk-test-key-0000000000');
      await g.load();
      expect(secrets.key, 'sk-test-key-0000000000');
      expect(g.hasKey, isTrue);
    });

    test('the connection test sends nothing personal and records what the '
        'provider supports', () async {
      final client = FakeClient(answer: '{"ok": true}');
      final g = gateway(client);
      addTearDown(g.dispose);
      await g.saveKey('sk-test-key-0000000000');
      // Works before consenting: nothing about the person goes.
      final report = await g.testConnection();
      expect(client.requests, hasLength(3));
      expect(client.requests[1].tools.single.name, 'probe_ping');
      expect(client.requests[2].jsonProbe, isTrue);
      final sent = [
        for (final r in client.requests)
          for (final m in r.messages) m.content,
      ].join(' ');
      expect(sent, isNot(contains('kg')));
      expect(report.capabilities.tools, isTrue);
      expect(report.capabilities.jsonMode, isTrue);
      expect(g.settings.capabilities?.tools, isTrue);
      expect(g.today.requests, 3);
    });
  });

  group('preferences under forja.ai.* only', () {
    test('settings, consent and usage survive; forgetting them keeps the 0.1 '
        'snapshot', () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            PreferencesLegacySnapshotSource.storageKey: '{"schemaVersion":1}',
          });
      final prefs = PrefsAiSettingsStore();
      await prefs.saveSettings(
        const AiSettings(
          enabled: true,
          dailyCap: 20,
          features: {AiFeature.chat},
        ),
      );
      await prefs.saveConsent(
        AiConsent(
          version: aiConsentVersion,
          acceptedAt: DateTime.utc(2026, 10, 2),
          provider: AiProvider.opencodeGo,
          baseUrl: 'https://opencode.ai/zen/go/v1',
          categories: {DataCategory.training, DataCategory.notes},
        ),
      );
      await prefs.saveUsage(
        const AiUsageDay(
          day: '2026-10-02',
          requests: 3,
          usage: AiUsage(prompt: 9),
        ),
      );
      final again = PrefsAiSettingsStore();
      final s = await again.loadSettings();
      expect(
        [s.enabled, s.dailyCap, s.features],
        [
          true,
          20,
          {AiFeature.chat},
        ],
      );
      final c = (await again.loadConsent())!;
      expect(c.categories, {DataCategory.training, DataCategory.notes});
      expect((await again.loadUsage())!.requests, 3);

      await again.forgetAll();
      final raw = SharedPreferencesAsync();
      expect(
        await raw.getString(PreferencesLegacySnapshotSource.storageKey),
        '{"schemaVersion":1}',
      );
      final keys = await raw.getKeys();
      expect(
        keys.where(
          (k) =>
              k.startsWith('forja.ai.') &&
              k != PrefsAiSettingsStore.installedKey,
        ),
        isEmpty,
      );
      expect((await again.loadSettings()).enabled, isFalse);
      expect(jsonEncode(keys.toList()), isNot(contains('apiKey')));
    });

    test(
      'damaged preferences fall back to the defaults (assistant off)',
      () async {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              PrefsAiSettingsStore.settingsKey: '{no es json',
              PrefsAiSettingsStore.consentKey: '[]',
            });
        final prefs = PrefsAiSettingsStore();
        expect((await prefs.loadSettings()).enabled, isFalse);
        expect(await prefs.loadConsent(), isNull);
      },
    );
  });
}
