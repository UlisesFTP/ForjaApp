// Storage failures the startup screen can explain and recover from.
// None of them means data was deleted; [originalData] is never modified.
sealed class StorageFailure implements Exception {
  const StorageFailure();

  /// Untouched legacy data that the user can copy out, when it exists.
  String? get originalData => switch (this) {
    LegacyDataRejected(:final raw) => raw,
    LegacyFutureVersion(:final raw) => raw,
    _ => null,
  };

  /// Whether starting empty is offered, keeping the original where it is.
  bool get canSkipImport => originalData != null;
}

/// The 0.1 snapshot cannot be imported. [issues] are `path: reason` entries
/// without personal values.
class LegacyDataRejected extends StorageFailure {
  const LegacyDataRejected(this.issues, this.raw);
  final List<String> issues;
  final String raw;
}

/// The 0.1 snapshot declares a schema version newer than this app understands.
class LegacyFutureVersion extends StorageFailure {
  const LegacyFutureVersion(this.raw);
  final String raw;
}

/// The database was created by a newer app version and is left untouched.
class DatabaseNewerThanApp extends StorageFailure {
  const DatabaseNewerThanApp({
    required this.databaseVersion,
    required this.appVersion,
  });
  final int databaseVersion, appVersion;
}

/// Reading or writing the local storage failed. Retrying may succeed.
class StorageUnavailable extends StorageFailure {
  const StorageUnavailable([this.cause]);
  final Object? cause;
}
