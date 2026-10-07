import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/ai/openai_compatible_client.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/services/ai/ai_client.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'ai_gateway_test.dart' show FakeClient;

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

void main() {
  group('the provider catalog (F17)', () {
    test('every provider has a preset, an order slot and a usable default', () {
      expect(aiPresets.keys.toSet(), AiProvider.values.toSet());
      expect(aiProviderOrder.toSet(), AiProvider.values.toSet());
      expect(aiProviderOrder.length, AiProvider.values.length);
      expect(aiProviderOrder.first, AiProvider.opencodeGo);
      for (final p in AiProvider.values) {
        final preset = aiPresets[p]!;
        expect(preset.provider, p);
        expect(preset.label, isNotEmpty);
        expect(preset.summary, isNotEmpty);
        expect(preset.hosting, isNotEmpty, reason: '$p');
        expect(preset.retention, isNotEmpty, reason: '$p');
        if (p == AiProvider.custom) {
          expect(preset.models, isEmpty);
          continue;
        }
        expect(Uri.parse(preset.baseUrl).scheme, 'https', reason: '$p');
        expect(preset.models, isNotEmpty, reason: '$p');
        // The default is the first popular model.
        expect(preset.models.first.id, preset.model, reason: '$p');
        final ids = preset.models.map((m) => m.id).toList();
        expect(ids.toSet().length, ids.length, reason: 'unique ids in $p');
        for (final m in preset.models) {
          expect(m.id, matches(RegExp(r'^[A-Za-z0-9._/:-]{1,80}$')));
          expect(m.label, isNotEmpty);
        }
        final s = AiSettings(
          provider: p,
          baseUrl: preset.baseUrl,
          model: preset.model,
        );
        expect(s.problem, isNull, reason: '$p');
        expect(
          preset.models.every(
            (m) =>
                AiSettings(
                  provider: p,
                  baseUrl: preset.baseUrl,
                  model: m.id,
                ).problem ==
                null,
          ),
          isTrue,
          reason: 'no free-tier model is offered in $p',
        );
      }
    });

    test('free-tier models are refused, whichever way they are named', () {
      for (final m in ['mimo-v2.6-flash-free', 'google/gemma:free']) {
        expect(
          AiSettings(
            provider: AiProvider.openrouter,
            baseUrl: 'https://openrouter.ai/api/v1',
            model: m,
          ).problem,
          isNotNull,
          reason: m,
        );
      }
    });

    test('providers that train on free tiers say so before consent', () {
      expect(aiPresets[AiProvider.google]!.retention, contains('gratuito'));
      expect(aiPresets[AiProvider.mistral]!.retention, contains('gratuito'));
      expect(aiPresets[AiProvider.opencodeZen]!.retention, contains('free'));
    });

    test('only OpenCode routes by session; each provider names its output '
        'limit the way it expects', () async {
      final bodies = <AiProvider, Map<String, dynamic>>{};
      final headers = <AiProvider, Map<String, String>>{};
      for (final p in AiProvider.values) {
        final preset = aiPresets[p]!;
        final endpoint = AiEndpoint(
          baseUrl: preset.baseUrl.isEmpty
              ? 'https://example.com/v1'
              : preset.baseUrl,
          model: preset.model.isEmpty ? 'modelo' : preset.model,
          apiKey: 'sk-test-0000000000',
          preset: preset,
          sessionId: 'ses_0123456789abcdef0123456789abcdef',
        );
        bodies[p] = jsonDecode(
          jsonEncode(
            OpenAiCompatibleClient.body(
              const AiRequest(
                messages: [AiMessage.user('hola')],
                maxTokens: 321,
              ),
              endpoint,
            ),
          ),
        ) as Map<String, dynamic>;
        headers[p] = OpenAiCompatibleClient.headers(endpoint);
      }
      for (final p in AiProvider.values) {
        final b = bodies[p]!, preset = aiPresets[p]!;
        expect(b[preset.tokenParam], 321, reason: '$p');
        final other = preset.tokenParam == 'max_tokens'
            ? 'max_completion_tokens'
            : 'max_tokens';
        expect(b.containsKey(other), isFalse, reason: '$p sends one limit');
        expect(
          headers[p]!.containsKey('x-opencode-session'),
          p == AiProvider.opencodeGo || p == AiProvider.opencodeZen,
          reason: '$p',
        );
        expect(headers[p]!['Authorization'], startsWith('Bearer '));
      }
      expect(bodies[AiProvider.openai]!.containsKey('temperature'), isFalse);
      expect(bodies[AiProvider.groq]!.containsKey('temperature'), isTrue);
      expect(bodies[AiProvider.deepseek]!['max_tokens'], 321);
      expect(bodies[AiProvider.google]!['max_tokens'], 321);
      expect(bodies[AiProvider.opencodeGo]!['thinking'], {'type': 'disabled'});
      expect(bodies[AiProvider.openai]!.containsKey('thinking'), isFalse);
    });
  });

  // Regression (seen on the phone, 2026-10-07): after a cold start Más said
  // "Desactivado" for an assistant that was on, until the sheet was opened.
  testWidgets('a saved, active assistant shows as active right after start', (
    tester,
  ) async {
    final settings = MemoryAiSettingsStore()
      ..settings = const AiSettings(enabled: true);
    settings.consent = AiConsent(
      version: aiConsentVersion,
      acceptedAt: DateTime.utc(2026, 10, 7),
      provider: AiProvider.opencodeGo,
      baseUrl: 'https://opencode.ai/zen/go/v1',
      categories: {...DataCategory.values},
    );
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      secrets: MemorySecretStore()..key = 'sk-forja-test-9f3c2a7b1d4e6f8a0c2e',
      aiSettings: settings,
      aiClient: FakeClient(failOnCall: true),
      clock: () => DateTime(2026, 10, 7, 12),
    );
    addTearDown(() => unawaited(d.dispose()));
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 2600);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ForjaApp(dependencies: d, offerOnboarding: false));
    d.shell.open(AppPage.more);
    await tester.pumpAndSettle();
    expect(d.ai.ready, isTrue);
    expect(find.text('Activo · con tu clave'), findsOneWidget);
  });

  // Regression (seen on the phone, 2026-10-07): "Describir comida" failed
  // with "falta la cabecera de sesión" because only the chat sent a session.
  test('a one-off request still carries a session id', () async {
    final client = FakeClient();
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      secrets: MemorySecretStore(),
      aiSettings: MemoryAiSettingsStore(),
      aiClient: client,
      clock: () => DateTime(2026, 10, 7, 12),
    );
    addTearDown(() => unawaited(d.dispose()));
    await d.ai.saveKey('sk-forja-test-9f3c2a7b1d4e6f8a0c2e');
    await d.ai.accept({...DataCategory.values});
    for (var i = 0; i < 2; i++) {
      await d.ai.request(
        AiFeature.mealEstimate,
        const AiRequest(messages: [AiMessage.user('2 huevos')], maxTokens: 20),
      );
    }
    final ids = client.endpoints.map((e) => e.sessionId).toList();
    expect(ids, hasLength(2));
    for (final id in ids) {
      expect(id, matches(RegExp(r'^ses_[0-9a-f]{32}$')));
    }
  });

  group('the provider and model menus', () {
    Future<AppDependencies> open(
      WidgetTester tester, {
      Size size = const Size(390, 2600),
      double scale = 1,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        secrets: MemorySecretStore(),
        aiSettings: MemoryAiSettingsStore(),
        aiClient: FakeClient(failOnCall: true),
        clock: () => DateTime(2026, 10, 7, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
      return d;
    }

    Future<void> tapKey(WidgetTester tester, String key) async {
      final f = find.byKey(ValueKey(key));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('the steps are named and the state says what comes next', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Paso 1 · Proveedor y modelo'), findsOneWidget);
      expect(find.text('Paso 2 · Tu clave'), findsOneWidget);
      expect(find.text('Paso 3 · Probar la conexión'), findsOneWidget);
      expect(find.textContaining('Siguiente paso: pega tu clave'), findsOne);
      expect(find.text('Modelo'), findsOneWidget);
      expect(find.text('MiMo V2.6 Flash'), findsOneWidget);
      // Testing needs a key: the button says why it is off.
      expect(find.textContaining('Guarda tu clave (paso 2)'), findsOneWidget);
    });

    testWidgets('choosing a provider fills its address and model and asks '
        'for consent again', (tester) async {
      final d = await open(tester);
      await d.ai.saveKey('sk-forja-test-9f3c2a7b1d4e6f8a0c2e');
      await d.ai.accept({...DataCategory.values});
      expect(d.ai.ready, isTrue);
      await tester.pumpAndSettle();
      await tapKey(tester, 'ai-provider-picker');
      for (final p in AiProvider.values) {
        expect(find.byKey(ValueKey('ai-provider-${p.name}')), findsOneWidget);
      }
      await tester.tap(find.byKey(const ValueKey('ai-provider-deepseek')));
      await tester.pumpAndSettle();
      expect(d.ai.settings.provider, AiProvider.deepseek);
      expect(d.ai.settings.baseUrl, 'https://api.deepseek.com/v1');
      expect(d.ai.settings.model, 'deepseek-v4-flash');
      expect(d.ai.consent, isNull);
      expect(d.ai.ready, isFalse);
      expect(find.text('DeepSeek V4 Flash'), findsWidgets);
    });

    testWidgets('the model menu lists the popular models; picking one keeps '
        'the consent', (tester) async {
      final d = await open(tester);
      await d.ai.saveKey('sk-forja-test-9f3c2a7b1d4e6f8a0c2e');
      await d.ai.accept({...DataCategory.values});
      await tester.pumpAndSettle();
      await tapKey(tester, 'ai-model-picker');
      for (final m in aiPresets[AiProvider.opencodeGo]!.models) {
        expect(find.byKey(ValueKey('ai-model-${m.id}')), findsOneWidget);
      }
      await tester.tap(find.byKey(const ValueKey('ai-model-deepseek-v4-pro')));
      await tester.pumpAndSettle();
      expect(d.ai.settings.model, 'deepseek-v4-pro');
      expect(d.ai.settings.provider, AiProvider.opencodeGo);
      expect(d.ai.ready, isTrue, reason: 'a model change is not a new consent');
      expect(find.text('DeepSeek V4 Pro'), findsWidgets);
    });

    testWidgets('"Otro modelo" shows a field; a free model is refused', (
      tester,
    ) async {
      final d = await open(tester);
      expect(find.byKey(const ValueKey('ai-model')), findsNothing);
      await tapKey(tester, 'ai-model-picker');
      await tester.tap(find.byKey(const ValueKey('ai-model-other')));
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('ai-model'));
      expect(field, findsOneWidget);
      await tester.enterText(field, 'mimo-v2.6-flash-free');
      await tapKey(tester, 'ai-save-model');
      expect(d.ai.settings.model, 'mimo-v2.6-flash-free');
      expect(find.textContaining('modelos gratuitos'), findsWidgets);
      await tester.enterText(field, 'glm-5.3');
      await tapKey(tester, 'ai-save-model');
      expect(d.ai.settings.model, 'glm-5.3');
      expect(d.ai.settings.problem, isNull);
    });

    testWidgets('the custom provider asks for address and model', (
      tester,
    ) async {
      final d = await open(tester);
      await tapKey(tester, 'ai-provider-picker');
      await tester.tap(find.byKey(const ValueKey('ai-provider-custom')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ai-model-picker')), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('ai-base-url')),
        'http://inseguro.example/v1',
      );
      await tester.enterText(
        find.byKey(const ValueKey('ai-model')),
        'mi-modelo',
      );
      await tapKey(tester, 'ai-save-address');
      expect(d.ai.settings.problem, contains('https'));
      await tester.enterText(
        find.byKey(const ValueKey('ai-base-url')),
        'https://api.ejemplo.com/v1',
      );
      await tapKey(tester, 'ai-save-address');
      expect(d.ai.settings.problem, isNull);
      expect(d.ai.settings.model, 'mi-modelo');
    });

    testWidgets('the menus fit 320 px at 200 % and meet the guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester, size: const Size(320, 1400), scale: 2);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tapKey(tester, 'ai-provider-picker');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      expect(tester.takeException(), isNull);
      final groq = find.byKey(const ValueKey('ai-provider-groq'));
      await tester.ensureVisible(groq);
      await tester.pumpAndSettle();
      await tester.tap(groq);
      await tester.pumpAndSettle();
      await tapKey(tester, 'ai-model-picker');
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  });
}
