import 'package:shared_preferences/shared_preferences.dart';

/// Where the 0.1 snapshot lives. Read-only: the original is never modified.
abstract class LegacySnapshotSource {
  /// Identifies this source in the import marker.
  String get id;
  Future<String?> readRaw();
}

/// The same storage backend 0.1 wrote to (`SharedPreferencesAsync`). Another
/// backend could read a different file and report "no data" by mistake.
class PreferencesLegacySnapshotSource implements LegacySnapshotSource {
  PreferencesLegacySnapshotSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();
  static const storageKey = 'forja_flutter_snapshot_v1';
  final SharedPreferencesAsync _preferences;
  @override
  String get id => storageKey;
  @override
  Future<String?> readRaw() => _preferences.getString(storageKey);
}
