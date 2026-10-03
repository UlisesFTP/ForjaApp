import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/backup/backup_codec.dart';
import 'package:forja_app/data/database/forja_database.dart'
    show currentSchemaVersion;
import 'package:forja_app/data/legacy/legacy_snapshot_source.dart';
import 'package:forja_app/data/services/ai/prefs_ai_settings_store.dart';
import 'package:forja_app/data/services/backup_service.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/sqlite_harness.dart';
import 'ai_gateway_test.dart' show FakeClient;

class _Vault implements BackupVault {
  final files = <String, String>{};
  @override
  Future<String> save(String name, String content) async {
    files[name] = content;
    return name;
  }

  @override
  Future<void> deleteAll() async => files.clear();
  @override
  Future<List<String>> names() async => files.keys.toList();
}

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

const _key = 'sk-forja-test-9f3c2a7b1d4e6f8a0c2e';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the key never leaves secure storage (F17, D38)', () {
    test(
      'not in the database, the backup, the preferences or a message',
      () async {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({
              PreferencesLegacySnapshotSource.storageKey: '{"schemaVersion":1}',
            });
        final h = await StoreHarness.create();
        addTearDown(h.dispose);
        final o = await h.open(clock: () => DateTime(2026, 10, 2, 12));
        final secrets = MemorySecretStore();
        final client = FakeClient();
        final d = await AppDependencies.create(
          store: MemoryForjaStore(),
          secrets: secrets,
          aiSettings: PrefsAiSettingsStore(),
          aiClient: client,
          clock: () => DateTime(2026, 10, 2, 12),
        );
        await d.ai.saveKey(_key);
        await d.ai.accept({...DataCategory.values});
        await d.repository.addFood(
          const FoodEntry(
            id: 'f',
            dateKey: '2026-10-02',
            name: 'Pan',
            calories: 80,
          ),
        );
        await d.ai.request(
          AiFeature.chat,
          const AiRequest(messages: [AiMessage.user('hola')], maxTokens: 20),
        );
        expect(client.endpoints.single.apiKey, _key, reason: 'only the client');

        expect(
          jsonEncode(d.repository.snapshot.toJson()),
          isNot(contains(_key)),
        );
        final backup = BackupCodec.encode(
          d.repository.snapshot,
          createdAt: DateTime.utc(2026, 10, 2),
          schema: currentSchemaVersion,
        );
        expect(backup, isNot(contains(_key)));
        final prefs = SharedPreferencesAsync();
        final all = await prefs.getAll();
        expect(all, isNotEmpty);
        for (final e in all.entries) {
          expect('${e.value}', isNot(contains(_key)), reason: e.key);
        }
        for (final failure in <AiFailure>[
          const AiUnauthorized(),
          const AiNoKey(),
          const AiMisconfigured('x'),
        ]) {
          expect(failure.toString() + failure.message, isNot(contains(_key)));
        }
        await d.dispose();
        // The database sees records only: it never gets the key.
        await o.repo.addFood(
          const FoodEntry(
            id: 'g',
            dateKey: '2026-10-02',
            name: 'Pan',
            calories: 80,
          ),
        );
        await o.close();
        final bytes = await h.file.readAsBytes();
        expect(latin1.decode(bytes, allowInvalid: true), isNot(contains(_key)));

        // Deleting everything removes the key and the assistant's settings,
        // and keeps the original 0.1 snapshot.
        final again = await AppDependencies.create(
          store: MemoryForjaStore(),
          backupVault: _Vault(),
          secrets: secrets,
          aiSettings: PrefsAiSettingsStore(),
          clock: () => DateTime(2026, 10, 2, 12),
        );
        addTearDown(() => unawaited(again.dispose()));
        await again.backups.deleteEverything();
        expect(secrets.key, isNull);
        expect(again.ai.settings.enabled, isFalse);
        expect(
          await prefs.getString(PreferencesLegacySnapshotSource.storageKey),
          '{"schemaVersion":1}',
        );
        expect(await prefs.getString(PrefsAiSettingsStore.consentKey), isNull);
      },
    );
  });

  group('the assistant sheet and the consent (F17)', () {
    Future<AppDependencies> start(
      WidgetTester tester, {
      Size size = const Size(390, 2600),
      double scale = 1,
      MemorySecretStore? secrets,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        secrets: secrets ?? MemorySecretStore(),
        aiSettings: MemoryAiSettingsStore(),
        aiClient: FakeClient(failOnCall: true),
        clock: () => DateTime(2026, 10, 2, 12),
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
      return d;
    }

    Future<void> openSheet(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
    }

    testWidgets('off by default; the key is hidden, never shown back, and '
        'only "Acepto y activar" turns it on', (tester) async {
      final secrets = MemorySecretStore();
      final d = await start(tester, secrets: secrets);
      expect(
        find.text('Desactivado · externo, con tu propia clave'),
        findsOneWidget,
      );
      await openSheet(tester);
      expect(find.text('Asistente IA'), findsOneWidget);
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('ai-key')),
      );
      expect(field.obscureText, isTrue);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.enableIMEPersonalizedLearning, isFalse);
      await tester.ensureVisible(find.byKey(const ValueKey('ai-key')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ai-key')), _key);
      await tester.pumpAndSettle();
      final save = find.byKey(const ValueKey('ai-save-key'));
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(secrets.key, _key);
      expect(find.textContaining('termina en …2e'), findsNothing);
      expect(find.textContaining('termina en …0c2e'), findsOneWidget);
      // The field was cleared: the key is nowhere in the widget tree.
      for (final e in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(e.controller.text, isNot(contains(_key)));
      }
      expect(find.textContaining(_key), findsNothing);

      // Turning it on opens the consent; going back does not consent.
      final toggle = find.byKey(const ValueKey('ai-enabled'));
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('ASISTENTE EXTERNO (IA)'), findsOneWidget);
      expect(find.textContaining('Lo que nunca se envía'), findsOneWidget);
      expect(find.textContaining('podría hacer que OpenCode'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('ai-consent-cancel')));
      await tester.pumpAndSettle();
      expect(d.ai.ready, isFalse);
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      // Notes off, then accept.
      final notes = find.byKey(const ValueKey('consent-notes'));
      await tester.ensureVisible(notes);
      await tester.pumpAndSettle();
      await tester.tap(notes);
      await tester.pumpAndSettle();
      final accept = find.byKey(const ValueKey('ai-consent-accept'));
      await tester.ensureVisible(accept);
      await tester.pumpAndSettle();
      await tester.tap(accept);
      await tester.pumpAndSettle();
      expect(d.ai.ready, isTrue);
      expect(d.ai.categories.contains(DataCategory.notes), isFalse);
      expect(d.ai.categories.contains(DataCategory.training), isTrue);
      expect(find.text('ASISTENTE EXTERNO (IA)'), findsNothing);
      // Turning it off withdraws the consent.
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(d.ai.ready, isFalse);
      expect(d.ai.consent, isNull);
    });

    testWidgets('the sheet fits 320 px at 200 % and meets the guidelines', (
      tester,
    ) async {
      await start(tester, size: const Size(320, 1200), scale: 2);
      await openSheet(tester);
      expect(tester.takeException(), isNull);
      final handle = tester.ensureSemantics();
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('pasting fills the field; the key can be deleted after a '
        'confirmation', (tester) async {
      final secrets = MemorySecretStore()..key = _key;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') {
              return {'text': 'sk-pegada-000000000000000'};
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await start(tester, secrets: secrets);
      await openSheet(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('ai-paste-key')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ai-paste-key')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('ai-key')))
            .controller!
            .text,
        'sk-pegada-000000000000000',
      );
      final delete = find.byKey(const ValueKey('ai-delete-key'));
      await tester.ensureVisible(delete);
      await tester.pumpAndSettle();
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(secrets.key, _key);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(secrets.key, isNull);
    });
  });
}
