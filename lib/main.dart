import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_dependencies.dart';
import 'app/forja_app.dart';
import 'data/services/local_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  runApp(
    ForjaBootstrap(
      // Production wires the native notifications; tests use no-op ones.
      create: ({bool skipLegacyImport = false}) => AppDependencies.create(
        skipLegacyImport: skipLegacyImport,
        notifications: LocalNotificationService(),
      ),
    ),
  );
}

/// The fonts are bundled under the SIL Open Font License; their text appears
/// on the licences page next to the packages'.
Stream<LicenseEntry> fontLicenses() async* {
  for (final (name, file) in [
    ('DM Sans', 'assets/fonts/OFL-DMSans.txt'),
    ('Barlow Condensed', 'assets/fonts/OFL-BarlowCondensed.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString(file));
  }
}

void registerFontLicenses() => LicenseRegistry.addLicense(fontLicenses);
