import '../../../data/backup/backup_codec.dart';
import '../../../data/services/backup_service.dart';
import '../../core/view_model.dart';

/// Backup, import and delete-everything. Every action that changes or
/// exports data is explicit: nothing runs on its own.
class DataViewModel extends ViewModel {
  DataViewModel(this._service);
  final BackupService _service;

  /// What the picked file holds, once it passed every check, awaiting the
  /// person's confirmation. Nothing is replaced until [confirmImport].
  BackupPreview? preview;
  String? pickedName;

  /// Why a picked file was refused, in words for the person.
  String? refusal;
  List<String> issues = const [];

  /// Counts the screen reacts to (a restore or a delete happened).
  int changes = 0;

  /// What the last export or import did, written in the panel itself: the
  /// snackbar of a message sits under the open sheet, so the person would not
  /// otherwise see that it worked.
  String? exportNotice;
  String? importNotice;

  /// Saves a copy where the person chooses. False when cancelled or failed.
  Future<bool> exportCopy() async {
    var saved = false;
    exportNotice = null;
    final ok = await run(() async {
      saved = await _service.exportCopy();
      exportNotice = saved
          ? 'Listo: la copia se guardó en el destino que elegiste.'
          : 'No se guardó nada: cancelaste la exportación.';
      announce(saved ? 'Copia guardada' : 'Exportación cancelada');
    });
    return ok && saved;
  }

  /// Lets the person choose a file and checks it. Nothing is stored.
  Future<bool> pickBackup() async {
    preview = null;
    refusal = null;
    importNotice = null;
    issues = const [];
    pickedName = null;
    var found = false;
    final ok = await run(() async {
      try {
        final picked = await _service.pick();
        if (picked == null) return;
        pickedName = picked.name;
        preview = _service.preview(picked);
        found = true;
      } on BackupFailure catch (e) {
        refusal = e.message;
        issues = e.issues;
      }
    });
    notifyListeners();
    return ok && found;
  }

  void cancelImport() {
    preview = null;
    pickedName = null;
    notifyListeners();
  }

  /// Replaces the data with the previewed file, after saving the current data
  /// to a private safety copy. A failure changes nothing.
  Future<bool> confirmImport() async {
    final p = preview;
    if (p == null) return false;
    final ok = await run(() async {
      try {
        await _service.replaceWith(p);
      } on BackupFailure catch (e) {
        refusal = e.message;
        throw StateError(e.message);
      }
      preview = null;
      pickedName = null;
      changes++;
      importNotice =
          'Listo: tus datos se reemplazaron por los de la copia. Lo que había '
          'antes quedó en una copia previa privada de la app.';
      announce('Datos importados. Se guardó una copia previa en la app.');
    });
    return ok;
  }

  /// Deletes everything. The screen asks for explicit confirmation first.
  Future<bool> deleteEverything() async {
    final ok = await run(() async {
      await _service.deleteEverything();
      preview = null;
      changes++;
      announce('Se eliminaron todos tus datos');
    });
    return ok;
  }
}
