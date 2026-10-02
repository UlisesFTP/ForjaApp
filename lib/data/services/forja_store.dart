import '../../domain/models/models.dart';

/// Persistence port of the local repository. Implementations are atomic: a
/// failed [commit] leaves the previously committed state untouched.
abstract class ForjaStore {
  Future<AppSnapshot> load();
  Future<void> commit(AppSnapshot previous, AppSnapshot next);

  /// Replaces everything the person stored with [next] in one transaction
  /// (restoring a backup, or deleting all data with an empty snapshot). On
  /// failure nothing changes. Import markers are kept.
  Future<void> replaceAll(AppSnapshot next);
  Future<void> close();
}

// Useful for widget tests and demos. Not used in production startup.
class MemoryForjaStore implements ForjaStore {
  MemoryForjaStore([AppSnapshot? initial]) : _state = initial ?? AppSnapshot();
  AppSnapshot _state;
  @override
  Future<AppSnapshot> load() async => _state;
  @override
  Future<void> commit(AppSnapshot previous, AppSnapshot next) async {
    _state = next;
  }

  @override
  Future<void> replaceAll(AppSnapshot next) async {
    _state = next;
  }

  @override
  Future<void> close() async {}
}
