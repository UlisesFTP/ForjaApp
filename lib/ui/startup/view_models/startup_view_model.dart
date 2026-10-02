import 'dart:async';

import '../../../app/app_dependencies.dart';
import '../../../domain/models/storage_failure.dart';
import '../../core/view_model.dart';

typedef AppDependenciesFactory = Future<AppDependencies> Function({
  bool skipLegacyImport,
});

enum StartupStatus { loading, ready, failed }

/// Opens the app data and explains, in recoverable terms, why it could not.
class StartupViewModel extends ViewModel {
  StartupViewModel(
    this._create, {
    required Future<void> Function(String text) copyToClipboard,
  }) : _copy = copyToClipboard;
  final AppDependenciesFactory _create;
  final Future<void> Function(String text) _copy;
  StartupStatus status = StartupStatus.loading;
  StorageFailure? failure;
  AppDependencies? dependencies;
  bool _opening = false, _closed = false;

  /// Safe to call again after a failure; a call while another runs is ignored.
  Future<void> open({bool skipLegacyImport = false}) async {
    if (_opening) return;
    _opening = true;
    status = StartupStatus.loading;
    failure = null;
    notifyListeners();
    try {
      final result = await _create(skipLegacyImport: skipLegacyImport);
      if (_closed) {
        await result.dispose();
        return;
      }
      dependencies = result;
      status = StartupStatus.ready;
    } on StorageFailure catch (error) {
      failure = error;
      status = StartupStatus.failed;
    } catch (error) {
      failure = StorageUnavailable(error);
      status = StartupStatus.failed;
    } finally {
      _opening = false;
      if (!_closed) notifyListeners();
    }
  }

  /// Starts empty, leaving the original data untouched where it is.
  Future<void> continueWithoutImport() => failure?.canSkipImport == true
      ? open(skipLegacyImport: true)
      : Future.value();

  Future<bool> copyOriginal() => run(() async {
    final data = failure?.originalData;
    if (data == null) return;
    try {
      await _copy(data);
    } catch (_) {
      throw StateError('No se pudo copiar. Vuelve a intentarlo.');
    }
  }, success: 'Datos originales copiados');

  @override
  void dispose() {
    _closed = true;
    unawaited(dependencies?.dispose());
    super.dispose();
  }
}
