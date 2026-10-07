import 'dart:convert';
import 'dart:io';

import 'package:forja_app/data/legacy/legacy_snapshot_v1_decoder.dart';
import 'package:forja_app/data/seed/catalog.dart';

/// A 0.1 snapshot covering every field, in the shape 0.1 wrote it.
String legacyFixtureRaw() =>
    File('test/fixtures/legacy_snapshot_v1_full.json').readAsStringSync();

Map<String, dynamic> legacyFixtureJson() =>
    jsonDecode(legacyFixtureRaw()) as Map<String, dynamic>;

LegacySnapshotV1Decoder catalogDecoder() => LegacySnapshotV1Decoder(
  routineIds: {for (final r in legacyTemplatePlan.routines) r.id},
  exerciseIds: {for (final e in exerciseCatalog) e.id},
);
