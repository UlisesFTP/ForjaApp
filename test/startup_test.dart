import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/storage_failure.dart';
import 'package:forja_app/ui/shell/widgets/shell_view.dart';
import 'package:forja_app/ui/startup/view_models/startup_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

class _SpyStore extends MemoryForjaStore {
  bool closed = false;
  @override
  Future<void> close() async => closed = true;
}

Future<AppDependencies> ready([ForjaStore? store]) => AppDependencies.create(
  store: store ?? MemoryForjaStore(),
  launcher: _Launcher(),
  clock: () => DateTime(2026, 9, 29),
);

const raw = '{"schemaVersion": 1, "profile": {"note": "Hombro derecho"}}';
final rejected = LegacyDataRejected(const ['profile.age: fuera de rango'], raw);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'DM Sans',
    )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
    await (FontLoader('Barlow Condensed')
          ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
        .load();
  });

  Future<void> boot(
    WidgetTester tester,
    AppDependenciesFactory create, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, 844),
          textScaler: TextScaler.linear(scale),
        ),
        child: ForjaBootstrap(create: create),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  AppDependenciesFactory failing(StorageFailure failure) =>
      ({bool skipLegacyImport = false}) async => throw failure;

  group('failure screens', () {
    final cases = <String, (StorageFailure, String, List<String>)>{
      'storage unavailable': (
        const StorageUnavailable(),
        'No pudimos abrir FORJA',
        [],
      ),
      'database newer than the app': (
        const DatabaseNewerThanApp(databaseVersion: 9, appVersion: 1),
        'Esta versión es más antigua que tus datos',
        [],
      ),
      'legacy data rejected': (
        rejected,
        'No pudimos importar tus registros',
        ['Copiar datos originales', 'Continuar sin importar'],
      ),
      'legacy data from a newer version': (
        const LegacyFutureVersion(raw),
        'Tus registros son de una versión más nueva',
        ['Copiar datos originales', 'Continuar sin importar'],
      ),
    };
    cases.forEach((name, spec) {
      testWidgets(name, (tester) async {
        await boot(tester, failing(spec.$1));
        expect(find.text(spec.$2), findsOneWidget);
        // Every failure says the data was not deleted.
        expect(
          find.textContaining(RegExp(r'No se han? borrado')),
          findsWidgets,
        );
        expect(find.text('Reintentar'), findsOneWidget);
        for (final label in [
          'Copiar datos originales',
          'Continuar sin importar',
        ]) {
          expect(
            find.text(label),
            spec.$3.contains(label) ? findsOneWidget : findsNothing,
            reason: '$name / $label',
          );
        }
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });
    testWidgets('rejected data lists what failed, without its content', (
      tester,
    ) async {
      await boot(tester, failing(rejected));
      expect(find.text('Qué falló'), findsOneWidget);
      expect(find.text('profile.age: fuera de rango'), findsOneWidget);
      expect(find.textContaining('Hombro'), findsNothing);
    });
  });
  testWidgets('shows progress while opening, then the app', (tester) async {
    final gate = Completer<AppDependencies>();
    await boot(tester, ({bool skipLegacyImport = false}) => gate.future);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(ShellView), findsNothing);
    gate.complete(await ready());
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(ShellView), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
  testWidgets('retry opens again and the failure can resolve', (tester) async {
    var calls = 0;
    await boot(tester, ({bool skipLegacyImport = false}) async {
      calls++;
      if (calls == 1) throw const StorageUnavailable();
      return ready();
    });
    expect(find.text('Reintentar'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byType(ShellView), findsOneWidget);
  });
  testWidgets('an unexpected error is shown as a recoverable failure', (
    tester,
  ) async {
    await boot(tester, ({bool skipLegacyImport = false}) async {
      throw StateError('boom');
    });
    expect(find.text('No pudimos abrir FORJA'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
  });
  group('copying the original data', () {
    String? copied;
    bool clipboardFails = false;
    setUp(() {
      copied = null;
      clipboardFails = false;
    });
    void mockClipboard(WidgetTester tester) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            if (clipboardFails) throw PlatformException(code: 'denied');
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
    }

    testWidgets('puts it on the clipboard and announces it', (tester) async {
      mockClipboard(tester);
      await boot(tester, failing(rejected));
      expect(find.textContaining('Pégalos solo donde confíes'), findsOneWidget);
      await tester.tap(find.text('Copiar datos originales'));
      await tester.pump();
      await tester.pump();
      expect(copied, raw);
      expect(find.text('Datos originales copiados'), findsOneWidget);
    });
    testWidgets(
      'a clipboard failure is explained and the screen stays usable',
      (tester) async {
        mockClipboard(tester);
        clipboardFails = true;
        await boot(tester, failing(rejected));
        await tester.tap(find.text('Copiar datos originales'));
        await tester.pump();
        await tester.pump();
        expect(copied, isNull);
        // Shown inline and announced as a snack bar, like every other form.
        final live = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.liveRegion == true,
        );
        expect(
          find.descendant(
            of: live,
            matching: find.text('No se pudo copiar. Vuelve a intentarlo.'),
          ),
          findsWidgets,
        );
        expect(find.text('Reintentar'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
  testWidgets(
    'continuing without importing asks first, then retries with skip',
    (tester) async {
      final skips = <bool>[];
      await boot(tester, ({bool skipLegacyImport = false}) async {
        skips.add(skipLegacyImport);
        if (!skipLegacyImport) throw rejected;
        return ready();
      });
      expect(skips, [false]);
      final dialog = find.byType(AlertDialog);
      await tester.tap(find.text('Continuar sin importar'));
      await tester.pumpAndSettle();
      expect(dialog, findsOneWidget);
      expect(find.textContaining('siguen en este teléfono'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      expect(skips, [false], reason: 'cancelling must not skip anything');
      await tester.tap(find.text('Continuar sin importar'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: dialog,
          matching: find.text('Continuar sin importar'),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(skips, [false, true]);
      expect(find.byType(ShellView), findsOneWidget);
    },
  );
  testWidgets('closing while opening releases the storage that finishes late', (
    tester,
  ) async {
    final spy = _SpyStore();
    final gate = Completer<AppDependencies>();
    await boot(tester, ({bool skipLegacyImport = false}) => gate.future);
    await tester.pumpWidget(const SizedBox());
    gate.complete(await ready(spy));
    await tester.pump();
    await tester.pump();
    expect(spy.closed, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    '320 px at 200% text scrolls without overflow and keeps 48 px targets',
    (tester) async {
      final many = LegacyDataRejected([
        for (var i = 0; i < 20; i++)
          'sessions[2026-09-$i].exercises[0].weightKg: fuera de rango',
      ], raw);
      await boot(tester, failing(many), width: 320, scale: 2);
      expect(tester.takeException(), isNull);
      final scroll = find.byType(SingleChildScrollView);
      expect(scroll, findsOneWidget);
      for (final label in [
        'Reintentar',
        'Copiar datos originales',
        'Continuar sin importar',
      ]) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        await tester.ensureVisible(button);
        await tester.pump();
        expect(
          tester.getSize(button).height,
          greaterThanOrEqualTo(48),
          reason: label,
        );
        expect(
          tester.getSize(button).width,
          lessThanOrEqualTo(320),
          reason: label,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'the title is a header and the screen reader can reach every action',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await boot(tester, failing(rejected));
        final header = find.ancestor(
          of: find.text('No pudimos importar tus registros'),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.header == true,
          ),
        );
        expect(header, findsOneWidget);
        for (final label in [
          'Reintentar',
          'Copiar datos originales',
          'Continuar sin importar',
        ]) {
          expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
        }
      } finally {
        handle.dispose();
      }
    },
  );
  group('view model', () {
    test('opening twice at once calls the factory once', () async {
      var calls = 0;
      final gate = Completer<AppDependencies>();
      final vm = StartupViewModel(({bool skipLegacyImport = false}) {
        calls++;
        return gate.future;
      }, copyToClipboard: (_) async {});
      addTearDown(vm.dispose);
      final first = vm.open(), second = vm.open();
      gate.complete(await ready());
      await Future.wait([first, second]);
      expect(calls, 1);
      expect(vm.status, StartupStatus.ready);
    });
    test('skipping is ignored when there is nothing to skip', () async {
      var skips = 0;
      final vm = StartupViewModel(({bool skipLegacyImport = false}) async {
        if (skipLegacyImport) skips++;
        throw const StorageUnavailable();
      }, copyToClipboard: (_) async {});
      addTearDown(vm.dispose);
      await vm.open();
      await vm.continueWithoutImport();
      expect(skips, 0);
      expect(vm.status, StartupStatus.failed);
    });
    test('a failure then a success clears the failure', () async {
      var calls = 0;
      final vm = StartupViewModel(({bool skipLegacyImport = false}) async {
        if (++calls == 1) throw rejected;
        return ready();
      }, copyToClipboard: (_) async {});
      addTearDown(vm.dispose);
      await vm.open();
      expect(vm.failure, same(rejected));
      await vm.open();
      expect(vm.failure, isNull);
      expect(vm.status, StartupStatus.ready);
    });
  });
}
