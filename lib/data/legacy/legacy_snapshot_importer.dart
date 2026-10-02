import '../../domain/models/storage_failure.dart';
import '../database/tables.dart';
import '../services/drift_forja_store.dart';
import 'legacy_snapshot_source.dart';
import 'legacy_snapshot_v1_decoder.dart';

/// Brings the 0.1 snapshot into the database exactly once. The original is
/// only ever read. When it cannot be imported, nothing is written and a
/// [StorageFailure] explains why.
class LegacySnapshotImporter {
  LegacySnapshotImporter({
    required this.store,
    required this.source,
    required this.decoder,
  });
  final DriftForjaStore store;
  final LegacySnapshotSource source;
  final LegacySnapshotV1Decoder decoder;

  /// With [skip], the user chose to start empty: the source is marked as
  /// handled and the original stays where it is.
  Future<void> run({bool skip = false}) async {
    if (await store.legacyImport(source.id) != null) return;
    if (skip) {
      await store.markLegacy(source.id, LegacyImportStatus.skipped);
      return;
    }
    final String? raw;
    try {
      raw = await source.readRaw();
    } catch (error) {
      // A failed read is not "no data": retrying may find it.
      throw StorageUnavailable(error);
    }
    if (raw == null) {
      await store.markLegacy(source.id, LegacyImportStatus.absent);
      return;
    }
    switch (decoder.decode(raw)) {
      case LegacyNewerVersion():
        throw LegacyFutureVersion(raw);
      case LegacyInvalid(:final issues):
        throw LegacyDataRejected(issues, raw);
      case LegacyDecoded(:final snapshot, :final repairs):
        await store.importLegacy(source.id, snapshot, notes: repairs);
    }
  }
}
