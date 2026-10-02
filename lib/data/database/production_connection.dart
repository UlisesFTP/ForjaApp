import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// The app database file in the private support directory, opened on a
/// background isolate. Kept apart from the schema so tests open their own.
QueryExecutor openProductionConnection() => driftDatabase(
  name: 'forja',
  native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory),
);
