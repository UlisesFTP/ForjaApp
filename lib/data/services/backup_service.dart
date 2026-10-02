import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../backup/backup_codec.dart';
import '../repositories/local_forja_repository.dart';
import '../../domain/models/models.dart';

/// A file the person chose to import.
class PickedBackup {
  const PickedBackup(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
}

/// The system's file dialogs. The person always chooses where a copy goes and
/// which file is read: nothing is exported or imported silently.
abstract class BackupFiles {
  /// Saves [bytes] where the person chooses. False when they cancel.
  Future<bool> saveCopy({required String fileName, required Uint8List bytes});

  /// Lets the person pick a file. Null when they cancel. A file over the size
  /// limit is refused with a [BackupFailure] before it is read.
  Future<PickedBackup?> pickBackup();
}

/// Private storage for the automatic copy made before data is replaced, so a
/// wrong import can be undone by hand.
abstract class BackupVault {
  /// Stores [content] under [name] atomically and returns where.
  Future<String> save(String name, String content);

  /// Removes every copy this vault made.
  Future<void> deleteAll();
  Future<List<String>> names();
}

class FilePickerBackupFiles implements BackupFiles {
  @override
  Future<bool> saveCopy({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
      dialogTitle: 'Guardar copia de seguridad',
    );
    return saved != null;
  }

  @override
  Future<PickedBackup?> pickBackup() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Elegir copia de seguridad',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    final size = file.lengthSync() ?? await file.length();
    if (size != null && size > backupMaxBytes) {
      throw const BackupFailure(
        BackupProblem.tooLarge,
        'El archivo supera los 20 MiB y no se lee.',
      );
    }
    return PickedBackup(file.name, await file.readAsBytes());
  }
}

/// Copies live in a private folder of the app, under the support directory.
class FileBackupVault implements BackupVault {
  FileBackupVault({this.directory});
  // A fixed folder (tests); null uses the app's private support directory.
  final Directory? directory;
  Directory? _resolved;
  // Only files with this exact shape are ever touched or removed.
  static final _pattern = RegExp(r'^forja-previo-\d{8}-\d{6}\.json$');
  static const keep = 3;

  Future<Directory> _dir() async {
    final base =
        _resolved ??
        directory ??
        Directory('${(await getApplicationSupportDirectory()).path}/backups');
    await base.create(recursive: true);
    return _resolved = base;
  }

  bool _ours(File f, Directory dir) {
    final name = f.uri.pathSegments.last;
    return _pattern.hasMatch(name) &&
        f.parent.absolute.path == dir.absolute.path;
  }

  @override
  Future<String> save(String name, String content) async {
    if (!_pattern.hasMatch(name)) {
      throw ArgumentError('Nombre de copia no válido.');
    }
    final dir = await _dir();
    final target = File('${dir.path}/$name');
    final temp = File('${dir.path}/$name.tmp');
    await temp.writeAsString(content, flush: true);
    await temp.rename(target.path);
    // Keep only the latest few.
    final all = [
      for (final f in await dir.list().toList())
        if (f is File && _ours(f, dir)) f,
    ]..sort((a, b) => a.path.compareTo(b.path));
    for (final old in all.take(all.length > keep ? all.length - keep : 0)) {
      await old.delete();
    }
    return target.path;
  }

  @override
  Future<List<String>> names() async {
    final dir = await _dir();
    return [
      for (final f in await dir.list().toList())
        if (f is File && _ours(f, dir)) f.uri.pathSegments.last,
    ]..sort();
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _dir();
    for (final f in await dir.list().toList()) {
      if (f is File && (_ours(f, dir) || f.path.endsWith('.tmp'))) {
        await f.delete();
      }
    }
  }
}

/// The file name the person sees uses their local time (a copy made at 18:15
/// must not say tomorrow); the private safety copies use UTC so that they
/// sort in the order they were made even if the time zone changes.
String _stamp(DateTime t, {required bool seconds, bool local = false}) {
  String two(int n) => n.toString().padLeft(2, '0');
  final u = local ? t.toLocal() : t.toUtc();
  return '${u.year}${two(u.month)}${two(u.day)}-${two(u.hour)}${two(u.minute)}${seconds ? two(u.second) : ''}';
}

/// Export, import (replace) and delete-everything over the repository. Every
/// step that changes data is explicit and preceded by what the person needs
/// to undo it.
class BackupService {
  BackupService({
    required this.repository,
    required this.codec,
    required this.vault,
    required this.files,
    required this.schema,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;
  final LocalForjaRepository repository;
  final BackupCodec codec;
  final BackupVault vault;
  final BackupFiles files;
  final int schema;
  final DateTime Function() _clock;

  String _text(AppSnapshot s) =>
      BackupCodec.encode(s, createdAt: _clock(), schema: schema);

  /// Writes a copy where the person chooses. Reads one committed snapshot, so
  /// the file is consistent even while the app keeps working. False when
  /// cancelled.
  Future<bool> exportCopy() {
    final bytes = Uint8List.fromList(utf8.encode(_text(repository.snapshot)));
    return files.saveCopy(
      fileName:
          'forja-respaldo-${_stamp(_clock(), seconds: false, local: true)}.json',
      bytes: bytes,
    );
  }

  Future<PickedBackup?> pick() => files.pickBackup();

  /// Validates a picked file completely and returns what it holds. Nothing is
  /// stored.
  BackupPreview preview(PickedBackup picked) => codec.decode(picked.bytes);

  /// Replaces all data with the preview's. First the current data is saved to
  /// the private vault; if that fails, nothing is replaced. The replacement is
  /// one transaction. Returns the name of the safety copy.
  Future<String> replaceWith(BackupPreview preview) async {
    final name = 'forja-previo-${_stamp(_clock(), seconds: true)}.json';
    try {
      await vault.save(name, _text(repository.snapshot));
    } catch (_) {
      throw const BackupFailure(
        BackupProblem.invalid,
        'No se pudo guardar el respaldo previo, así que no se cambió nada.',
      );
    }
    await repository.replaceAll(preview.snapshot);
    return name;
  }

  /// Removes every stored record and the safety copies, in one transaction
  /// for the database. The app returns to its first-run state.
  Future<void> deleteEverything() async {
    await repository.replaceAll(AppSnapshot());
    await vault.deleteAll();
  }
}
