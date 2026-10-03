// Guards for what the delivery documents promise: signing, permissions,
// secrets and the version shown to the person.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/main.dart' show registerFontLicenses;
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

String read(String path) => File(path).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('release signing', () {
    final gradle = read('android/app/build.gradle.kts');

    test(
      'a release is never signed with the debug key without an explicit opt-in',
      () {
        expect(gradle, contains('FORJA_ALLOW_DEBUG_SIGNING'));
        expect(gradle, contains('key.properties'));
        expect(gradle, contains('throw GradleException'));
        // The old template line that signed every release with the debug key.
        expect(
          gradle,
          isNot(contains('// Signing with the debug keys for now')),
        );
      },
    );

    test('keys, keystores and local SDK paths are ignored by Git', () {
      final ignore = read('.gitignore');
      expect(ignore, contains('android/key.properties'));
      expect(ignore, contains('**/*.jks'));
      expect(ignore, contains('**/*.keystore'));
      expect(File('android/key.properties.example').existsSync(), isTrue);
      final example = read('android/key.properties.example');
      expect(
        RegExp(
          r'^(storePassword|keyPassword)=\S',
          multiLine: true,
        ).hasMatch(example),
        isFalse,
        reason: 'the example carries no passwords',
      );
      // android/local.properties holds the SDK path of one machine.
      expect(read('android/.gitignore'), contains('local.properties'));
    });
  });

  group('manifest', () {
    final manifest = read('android/app/src/main/AndroidManifest.xml');

    test('only the permissions the app explains', () {
      final declared = RegExp(r'uses-permission android:name="([^"]+)"')
          .allMatches(manifest)
          .map((m) => m.group(1))
          .toList();
      // INTERNET only for the optional assistant, off by default (D38).
      expect(declared, [
        'android.permission.RECEIVE_BOOT_COMPLETED',
        'android.permission.INTERNET',
      ]);
      for (final forbidden in [
        'ACCESS_FINE_LOCATION',
        'ACCESS_NETWORK_STATE',
        'READ_CONTACTS',
        'CAMERA',
        'SCHEDULE_EXACT_ALARM',
        'USE_EXACT_ALARM',
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
      ]) {
        expect(manifest, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test(
      'data stays out of the system backups, receivers are not exported',
      () {
        expect(manifest, contains('android:allowBackup="false"'));
        // Android 12+: not in cloud backups nor device-to-device transfers,
        // which allowBackup alone does not stop on some phones (D38).
        expect(
          manifest,
          contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
        );
        final rules = read(
          'android/app/src/main/res/xml/data_extraction_rules.xml',
        );
        for (final section in ['cloud-backup', 'device-transfer']) {
          final body = RegExp(
            '<$section>(.*?)</$section>',
            dotAll: true,
          ).firstMatch(rules)!.group(1)!;
          for (final domain in ['root', 'file', 'database', 'sharedpref']) {
            expect(
              body,
              contains('<exclude domain="$domain" path="."/>'),
              reason: '$section $domain',
            );
          }
        }
        for (final receiver in RegExp(
          r'<receiver[^>]*>',
        ).allMatches(manifest)) {
          expect(receiver.group(0), contains('android:exported="false"'));
        }
      },
    );
  });

  group('no secrets or machine paths in what is shared', () {
    final roots = [
      'lib',
      'docs',
      'android/app/src',
      'ios/Runner',
      'README.md',
      'AGENTS.md',
      'CHANGELOG.md',
      '.github',
      'pubspec.yaml',
    ];
    final patterns = {
      'a local SDK path': RegExp(
        r'AppData[\\/]Local|Android[\\/]Sdk|sdk\.dir\s*=',
      ),
      'a private key': RegExp(r'BEGIN (RSA |EC )?PRIVATE KEY'),
      'a filled password': RegExp(r'(storePassword|keyPassword)\s*=\s*\S'),
      // API keys of the assistant's providers (D38): typed only on the phone.
      'an API key': RegExp(r'\b(sk|tp)-[A-Za-z0-9]{20,}'),
      'a bearer token': RegExp(r'Bearer [A-Za-z0-9._-]{20,}'),
      'an API key variable': RegExp(r'(OPENCODE|MIMO)_API_KEY\s*=\s*\S'),
    };

    Iterable<File> files() sync* {
      for (final root in roots) {
        final type = FileSystemEntity.typeSync(root);
        if (type == FileSystemEntityType.file) {
          yield File(root);
        } else if (type == FileSystemEntityType.directory) {
          for (final e in Directory(root).listSync(recursive: true)) {
            if (e is! File) continue;
            final name = e.path.replaceAll('\\', '/');
            if (RegExp(r'\.(png|ttf|jar|so|ico|webp)$').hasMatch(name)) {
              continue;
            }
            // ENTREGA/TESTING/CONTEXTO describe the practice by name; the
            // patterns above only match actual values.
            yield e;
          }
        }
      }
    }

    test('sources, docs and native projects hold none', () {
      for (final file in files()) {
        final String text;
        try {
          text = file.readAsStringSync();
        } on FileSystemException {
          continue;
        } on FormatException {
          continue;
        }
        for (final entry in patterns.entries) {
          expect(
            entry.value.hasMatch(text),
            isFalse,
            reason: '${entry.key} in ${file.path}',
          );
        }
      }
    });
  });

  test('no key is built into the app from the command line', () {
    // A --dart-define value ends up inside the APK; the key is only typed
    // on the phone (D38).
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is File && e.path.endsWith('.dart')) {
        expect(
          e.readAsStringSync(),
          isNot(contains('fromEnvironment')),
          reason: e.path,
        );
      }
    }
  });

  group('version and licences', () {
    test('the version shown on the licences page is the one in pubspec', () {
      final pubspec = RegExp(
        r'^version:\s*(\S+?)\+(\d+)',
        multiLine: true,
      ).firstMatch(read('pubspec.yaml'))!;
      final shell = read('lib/ui/shell/widgets/shell_view.dart');
      expect(shell, contains("applicationVersion: '${pubspec.group(1)}'"));
      // The assistant's User-Agent says the same version.
      expect(
        read('lib/core/app_info.dart'),
        contains("appVersion = '${pubspec.group(1)}'"),
      );
    });

    testWidgets(
      'open-source licences, including the bundled fonts, are reachable',
      (tester) async {
        registerFontLicenses();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 2400);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final d = await AppDependencies.create(
          store: MemoryForjaStore(),
          launcher: _Launcher(),
          clock: () => DateTime(2026, 10, 1),
        );
        // dispose() is asynchronous and a testWidgets tearDown cannot await it.
        addTearDown(() => unawaited(d.dispose()));
        await tester.pumpWidget(
          ForjaApp(dependencies: d, offerOnboarding: false),
        );
        d.shell.open(AppPage.more);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Licencias'));
        // One frame shows the page opened; its content loads the licences with
        // real asynchronous work that a fake clock cannot drive.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byType(LicensePage), findsOneWidget);
        // The font licence texts ship as assets and are what the collector
        // registered at startup reads (loading assets needs a real bundle, so
        // the files themselves are checked).
        final pubspec = read('pubspec.yaml');
        for (final file in ['OFL-DMSans.txt', 'OFL-BarlowCondensed.txt']) {
          expect(pubspec, contains('assets/fonts/$file'));
          expect(read('assets/fonts/$file'), contains('SIL Open Font License'));
          expect(read('lib/main.dart'), contains('assets/fonts/$file'));
        }
      },
    );
  });

  test(
    'the launch and notification resources the manifest relies on exist',
    () {
      for (final path in [
        'android/app/src/main/res/drawable/ic_stat_forja.xml',
        'android/app/src/main/res/drawable-nodpi/splash_logo.png',
        'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png',
        'android/app/src/main/res/values-v31/styles.xml',
        'android/app/src/main/res/raw/keep.xml',
        'android/app/proguard-rules.pro',
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
        '.github/workflows/ci.yml',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
      // The notification icon is referenced by name from Dart.
      expect(
        read('lib/data/services/local_notification_service.dart'),
        contains('ic_stat_forja'),
      );
      // The CI must never publish.
      final ci = read('.github/workflows/ci.yml').toLowerCase();
      for (final bad in [
        'upload-appstore',
        'play-store',
        'fastlane',
        'supply',
        'testflight',
        'pub publish',
      ]) {
        expect(ci, isNot(contains(bad)), reason: bad);
      }
    },
  );
}
