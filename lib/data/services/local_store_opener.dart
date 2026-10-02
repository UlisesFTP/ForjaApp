import 'package:drift/drift.dart';

import '../../domain/models/storage_failure.dart';
import '../database/forja_database.dart';
import '../database/production_connection.dart';
import '../legacy/legacy_snapshot_importer.dart';
import '../legacy/legacy_snapshot_source.dart';
import '../legacy/legacy_snapshot_v1_decoder.dart';
import '../seed/catalog.dart';
import 'drift_forja_store.dart';

/// Opens the database, runs migrations and imports the 0.1 snapshot. On any
/// failure the database is closed first, so a retry never opens a second
/// connection to the same file.
class LocalStoreOpener {
  LocalStoreOpener({
    QueryExecutor Function()? connection,
    LegacySnapshotSource? source,
    this.clock,
  }) : _connection = connection ?? openProductionConnection,
       _source = source ?? PreferencesLegacySnapshotSource();
  final QueryExecutor Function() _connection;
  final LegacySnapshotSource _source;
  final DateTime Function()? clock;

  Future<DriftForjaStore> open({bool skipLegacyImport = false}) async {
    final database = ForjaDatabase(_connection());
    final store = DriftForjaStore(database, clock: clock);
    try {
      await store.open();
      await LegacySnapshotImporter(
        store: store,
        source: _source,
        decoder: LegacySnapshotV1Decoder(
          // 0.1 only ever referenced its fixed template's routines.
          routineIds: {for (final r in examplePlan.routines) r.id},
          exerciseIds: {for (final e in exerciseCatalog) e.id},
        ),
      ).run(skip: skipLegacyImport);
      return store;
    } catch (error, stack) {
      // Closing must not hide the original failure.
      try {
        await database.close();
      } catch (_) {}
      Error.throwWithStackTrace(
        error is StorageFailure ? error : StorageUnavailable(error),
        stack,
      );
    }
  }
}
