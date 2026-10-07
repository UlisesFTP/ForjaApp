import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../core/date_utils.dart';
import '../../domain/expert/model/recommendation.dart' show RuleFamily;
import '../../domain/models/models.dart';
import '../../domain/services/plan_validator.dart';
import '../services/snapshot_diff.dart' show canonicalJson;

/// The backup file format. Version 2 (schema 7, D40) adds the coach's
/// decisions and preferences, the source of a favorite's calories and the
/// `estimated` source; version 1 files are still read.
const backupFormat = 'forja-backup';
const backupVersion = 2;

/// Largest file that is read (20 MiB), checked before anything is parsed.
const backupMaxBytes = 20 * 1024 * 1024;

enum BackupProblem {
  /// Not JSON, or not readable text.
  corrupt,

  /// JSON, but not a FORJA backup.
  notABackup,

  /// Written by a newer version of the format.
  futureVersion,

  /// The checksum does not match: the file was changed or damaged.
  checksum,

  /// The file is larger than [backupMaxBytes].
  tooLarge,

  /// Counts, ranges, references or structure are wrong.
  invalid,
}

class BackupFailure implements Exception {
  const BackupFailure(this.problem, this.message, {this.issues = const []});
  final BackupProblem problem;
  // Written for the person; never contains their data.
  final String message;
  // `path: reason`, without values.
  final List<String> issues;
  @override
  String toString() => 'BackupFailure($problem: $message)';
}

/// What a valid file holds, shown before anything is replaced.
class BackupPreview {
  const BackupPreview({
    required this.createdAt,
    required this.appSchema,
    required this.counts,
    required this.snapshot,
  });
  final DateTime createdAt;
  final int appSchema;
  final Map<String, int> counts;
  final AppSnapshot snapshot;
}

/// Versioned JSON with a SHA-256 checksum. The checksum detects damage or
/// edits; it is not encryption and does not protect the content.
class BackupCodec {
  BackupCodec({required this.isKnownExercise});
  final bool Function(String exerciseId) isKnownExercise;

  /// What a file of [version] counts: version 1 had no coach sections, so
  /// its counts are compared without them.
  static Map<String, int> countsOf(
    AppSnapshot s, {
    int version = backupVersion,
  }) => {
    'sessions': s.sessions.length,
    'exerciseLogs': s.sessions.values.fold(0, (n, x) => n + x.exercises.length),
    'sets': s.sessions.values.fold(
      0,
      (n, x) => n + x.exercises.fold(0, (m, e) => m + e.sets.length),
    ),
    'overrides': s.overrides.length,
    'checkIns': s.checkIns.length + s.afterCheckIns.length,
    'food': s.food.length,
    'favorites': s.favorites.length,
    'recipes': s.recipes.length,
    'plans': s.plans.length,
    'profileHistory': s.profileHistory.length,
    'reschedules': s.reschedules.length,
    'progressionDecisions': s.progressionDecisions.length,
    'reviews': s.reviews.length,
    'cardio': s.cardio.length,
    if (version >= 2) 'coachDecisions': s.coachDecisions.length,
    if (version >= 2) 'coachPreferences': s.coachPreferences.length,
  };

  static String _checksum(Map<String, dynamic> body) =>
      sha256.convert(utf8.encode(canonicalJson(body))).toString();

  /// The file text for [snapshot]. [schema] is the database schema version
  /// (informational).
  static String encode(
    AppSnapshot snapshot, {
    required DateTime createdAt,
    required int schema,
  }) {
    final data = {...snapshot.toJson()}..remove('schemaVersion');
    final body = {
      'version': backupVersion,
      'counts': countsOf(snapshot),
      'data': data,
    };
    return const JsonEncoder.withIndent('  ').convert({
      'format': backupFormat,
      'version': backupVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'appSchema': schema,
      'counts': body['counts'],
      'data': data,
      'checksum': {'algorithm': 'sha256', 'value': _checksum(body)},
    });
  }

  /// Validates everything and returns the preview, or throws a
  /// [BackupFailure]. Nothing is stored here.
  BackupPreview decode(Uint8List bytes) {
    if (bytes.length > backupMaxBytes) {
      throw const BackupFailure(
        BackupProblem.tooLarge,
        'El archivo supera los 20 MiB y no se lee.',
      );
    }
    final Object? root;
    try {
      root = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const BackupFailure(
        BackupProblem.corrupt,
        'El archivo no se puede leer: está dañado o no es una copia de FORJA.',
      );
    }
    if (root is! Map<String, dynamic> || root['format'] != backupFormat) {
      throw const BackupFailure(
        BackupProblem.notABackup,
        'Este archivo no es una copia de seguridad de FORJA.',
      );
    }
    final version = root['version'];
    if (version is! int || version < 1) {
      throw const BackupFailure(
        BackupProblem.invalid,
        'La versión de la copia no es válida.',
      );
    }
    if (version > backupVersion) {
      throw const BackupFailure(
        BackupProblem.futureVersion,
        'La copia viene de una versión más nueva de FORJA. Actualiza la app para importarla.',
      );
    }
    try {
      final data = _map(root['data'], r'$.data');
      final claimed = _map(root['counts'], r'$.counts');
      final sum = _map(root['checksum'], r'$.checksum');
      if (sum['algorithm'] != 'sha256' || sum['value'] is! String) {
        throw const _Issue(r'$.checksum', 'no válido');
      }
      final expected = _checksum({
        'version': version,
        'counts': claimed,
        'data': data,
      });
      if (expected != sum['value']) {
        throw const BackupFailure(
          BackupProblem.checksum,
          'La copia no pasa la comprobación de integridad: se modificó o se dañó. No se importó nada.',
        );
      }
      final snapshot = _snapshot(data, version);
      final counts = countsOf(snapshot, version: version);
      for (final e in counts.entries) {
        if (claimed[e.key] != e.value) {
          throw _Issue('\$.counts.${e.key}', 'no coincide con el contenido');
        }
      }
      final created = _date(root['createdAt'], r'$.createdAt');
      final schema = root['appSchema'];
      return BackupPreview(
        createdAt: created,
        appSchema: schema is int ? schema : 0,
        counts: counts,
        snapshot: snapshot,
      );
    } on _Issue catch (e) {
      throw BackupFailure(
        BackupProblem.invalid,
        'La copia tiene datos que no son válidos. No se importó nada.',
        issues: [e.toString()],
      );
    }
  }

  // ---- decoding helpers: every failure names a path, never a value.
  static Map<String, dynamic> _map(Object? v, String path) =>
      v is Map<String, dynamic>
      ? v
      : throw _Issue(path, 'falta o no es un objeto');
  static List<dynamic> _list(Object? v, String path) =>
      v is List ? v : throw _Issue(path, 'falta o no es una lista');
  static String _str(
    Map<String, dynamic> m,
    String k,
    String path, {
    int max = 5000,
    bool allowEmpty = true,
  }) {
    final v = m[k];
    if (v is! String) throw _Issue('$path.$k', 'falta o no es texto');
    if (v.length > max || (!allowEmpty && v.trim().isEmpty)) {
      throw _Issue('$path.$k', 'longitud no válida');
    }
    return v;
  }

  static String? _strN(
    Map<String, dynamic> m,
    String k,
    String path, {
    int max = 5000,
  }) {
    final v = m[k];
    if (v == null) return null;
    if (v is! String || v.length > max) {
      throw _Issue('$path.$k', 'no es texto válido');
    }
    return v;
  }

  static int _int(
    Map<String, dynamic> m,
    String k,
    String path, {
    int min = -1 << 31,
    int max = 1 << 31,
  }) {
    final v = m[k];
    if (v is! int) throw _Issue('$path.$k', 'falta o no es un entero');
    if (v < min || v > max) throw _Issue('$path.$k', 'fuera de rango');
    return v;
  }

  static int? _intN(
    Map<String, dynamic> m,
    String k,
    String path, {
    int min = -1 << 31,
    int max = 1 << 31,
  }) => m[k] == null ? null : _int(m, k, path, min: min, max: max);

  static double? _dblN(
    Map<String, dynamic> m,
    String k,
    String path, {
    double min = 0,
    double max = 1e9,
  }) {
    final v = m[k];
    if (v == null) return null;
    if (v is! num || !v.toDouble().isFinite) {
      throw _Issue('$path.$k', 'no es un número');
    }
    final d = v.toDouble();
    if (d < min || d > max) throw _Issue('$path.$k', 'fuera de rango');
    return d;
  }

  static double _dbl(
    Map<String, dynamic> m,
    String k,
    String path, {
    double min = 0,
    double max = 1e9,
  }) =>
      _dblN(m, k, path, min: min, max: max) ??
      (throw _Issue('$path.$k', 'falta'));

  static bool _bool(Map<String, dynamic> m, String k, String path) {
    final v = m[k];
    return v is bool
        ? v
        : throw _Issue('$path.$k', 'falta o no es verdadero/falso');
  }

  static T _enum<T extends Enum>(
    List<T> values,
    Map<String, dynamic> m,
    String k,
    String path,
  ) {
    final v = m[k];
    for (final e in values) {
      if (e.name == v) return e;
    }
    throw _Issue('$path.$k', 'valor desconocido');
  }

  static T? _enumN<T extends Enum>(
    List<T> values,
    Map<String, dynamic> m,
    String k,
    String path,
  ) => m[k] == null ? null : _enum(values, m, k, path);

  static DateTime _date(Object? v, String path) {
    if (v is! String) throw _Issue(path, 'falta o no es una fecha');
    final d = DateTime.tryParse(v);
    if (d == null) throw _Issue(path, 'fecha no válida');
    return d.toUtc();
  }

  static DateTime? _dateN(Map<String, dynamic> m, String k, String path) =>
      m[k] == null ? null : _date(m[k], '$path.$k');

  static String _key(Object? v, String path) {
    if (v is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) {
      throw _Issue(path, 'fecha no válida');
    }
    final d = DateTime.tryParse(v);
    if (d == null || dateKey(d) != v) throw _Issue(path, 'fecha no válida');
    return v;
  }

  void _exercise(String id, String path) {
    if (!isKnownExercise(id)) throw _Issue(path, 'ejercicio desconocido');
  }

  static void _unique(Set<String> seen, String id, String path) {
    if (!seen.add(id)) throw _Issue(path, 'identificador repetido');
  }

  AppSnapshot _snapshot(Map<String, dynamic> d, int version) {
    final profileMap = _map(d['profile'], r'$.data.profile');
    final UserProfile profile;
    try {
      profile = UserProfile.fromJson(profileMap);
    } on FormatException {
      throw const _Issue(r'$.data.profile', 'no válido');
    } on TypeError {
      throw const _Issue(r'$.data.profile', 'no válido');
    }
    final w = profile.weightKg, a = profile.age;
    if ((w != null && (w < 25 || w > 300)) ||
        (a != null && (a < 14 || a > 100)) ||
        profile.trainingDays.length != 3 ||
        profile.trainingDays.toSet().length != 3 ||
        profile.trainingDays.any((x) => x < 1 || x > 7) ||
        profile.sessionMinutes < 20 ||
        profile.sessionMinutes > 180) {
      throw const _Issue(r'$.data.profile', 'valores fuera de rango');
    }
    final rem = _map(d['reminder'], r'$.data.reminder');
    final reminder = ReminderSettings(
      enabled: _bool(rem, 'enabled', r'$.data.reminder'),
      hour: _int(rem, 'hour', r'$.data.reminder', min: 0, max: 23),
      minute: _int(rem, 'minute', r'$.data.reminder', min: 0, max: 59),
    );

    final sessions = <String, WorkoutSession>{};
    final setIds = <String>{};
    final sessionMap = _map(d['sessions'], r'$.data.sessions');
    for (final e in sessionMap.entries) {
      final p = '\$.data.sessions.${e.key}';
      _key(e.key, p);
      final m = _map(e.value, p);
      if (_str(m, 'dateKey', p) != e.key) {
        throw _Issue('$p.dateKey', 'no coincide con su clave');
      }
      final logs = <ExerciseLog>[];
      final seen = <String>{};
      for (final (i, raw) in _list(m['exercises'], '$p.exercises').indexed) {
        final lp = '$p.exercises[$i]';
        final lm = _map(raw, lp);
        final id = _str(lm, 'exerciseId', lp, max: 60, allowEmpty: false);
        _exercise(id, '$lp.exerciseId');
        _unique(seen, id, '$lp.exerciseId');
        final completed = _bool(lm, 'completed', lp),
            skipped = _bool(lm, 'skipped', lp);
        if (completed && skipped) {
          throw _Issue(lp, 'completado y omitido a la vez');
        }
        final sets = <SetLog>[];
        for (final (j, sr) in _list(lm['sets'], '$lp.sets').indexed) {
          final sp = '$lp.sets[$j]';
          final sm = _map(sr, sp);
          final sid = _str(sm, 'id', sp, max: 64, allowEmpty: false);
          _unique(setIds, sid, '$sp.id');
          final status = _enum(SetStatus.values, sm, 'status', sp);
          final weight = _dblN(sm, 'weightKg', sp, max: 2000);
          final reps = _intN(sm, 'reps', sp, min: 0, max: 999);
          final rir = _intN(sm, 'rir', sp, min: 0, max: 10);
          if (status == SetStatus.skipped &&
              (weight != null || reps != null || rir != null)) {
            throw _Issue(sp, 'una serie omitida lleva datos');
          }
          sets.add(
            SetLog(
              id: sid,
              kind: _enum(SetKind.values, sm, 'kind', sp),
              number: _int(sm, 'number', sp, min: 1, max: 1000),
              status: status,
              weightKg: weight,
              reps: reps,
              rir: rir,
              skipReason: _strN(sm, 'skipReason', sp, max: 120),
            ),
          );
        }
        if (sets.length > 30) throw _Issue('$lp.sets', 'demasiadas series');
        logs.add(
          ExerciseLog(
            exerciseId: id,
            weightKg: _dbl(lm, 'weightKg', lp, max: 2000),
            completed: completed,
            skipped: skipped,
            skipReason: _strN(lm, 'skipReason', lp, max: 120),
            technique: _enumN(TechniqueRating.values, lm, 'technique', lp),
            sets: sets,
          ),
        );
      }
      sessions[e.key] = WorkoutSession(
        dateKey: e.key,
        routineId: _str(m, 'routineId', p, max: 64, allowEmpty: false),
        exercises: logs,
        status: _enum(SessionStatus.values, m, 'status', p),
        feeling: _enumN(Feeling.values, m, 'feeling', p),
        note: _str(m, 'note', p, max: 2000),
      );
    }

    final overrides = <String, String?>{};
    for (final e in _map(d['overrides'], r'$.data.overrides').entries) {
      _key(e.key, '\$.data.overrides.${e.key}');
      final v = e.value;
      if (v != null && (v is! String || v.isEmpty || v.length > 64)) {
        throw _Issue('\$.data.overrides.${e.key}', 'no válido');
      }
      overrides[e.key] = v as String?;
    }

    Map<String, CheckIn> checkIns(String key) {
      final out = <String, CheckIn>{};
      for (final e in _map(d[key], '\$.data.$key').entries) {
        final p = '\$.data.$key.${e.key}';
        _key(e.key, p);
        final m = _map(e.value, p);
        out[e.key] = CheckIn(
          feeling: _enum(Feeling.values, m, 'feeling', p),
          note: _str(m, 'note', p, max: 2000),
        );
      }
      return out;
    }

    final food = <FoodEntry>[];
    final foodIds = <String>{};
    for (final (i, raw) in _list(d['food'], r'$.data.food').indexed) {
      final p = '\$.data.food[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(foodIds, id, '$p.id');
      final source = _enum(CaloriesSource.values, m, 'caloriesSource', p);
      // Estimates exist from version 2 on.
      if (version < 2 && source == CaloriesSource.estimated) {
        throw _Issue('$p.caloriesSource', 'valor desconocido');
      }
      final entry = FoodEntry(
        id: id,
        dateKey: _key(m['dateKey'], '$p.dateKey'),
        name: _str(m, 'name', p, max: 80, allowEmpty: false),
        calories: _int(m, 'calories', p, min: 0, max: 5000),
        portion: _dblN(m, 'portion', p, max: 100000),
        unit: _strN(m, 'unit', p, max: 12),
        proteinG: _dblN(m, 'proteinG', p, max: 2000),
        carbsG: _dblN(m, 'carbsG', p, max: 2000),
        fatG: _dblN(m, 'fatG', p, max: 2000),
        caloriesSource: source,
        recipeId: _strN(m, 'recipeId', p, max: 64),
      );
      if ((entry.portion ?? 1) <= 0) {
        throw _Issue('$p.portion', 'debe ser mayor que 0');
      }
      if (source == CaloriesSource.macros &&
          entry.calories !=
              caloriesFromMacros(entry.proteinG, entry.carbsG, entry.fatG)) {
        throw _Issue('$p.calories', 'no coincide con los macros');
      }
      if (source == CaloriesSource.recipe && entry.recipeId == null) {
        throw _Issue('$p.recipeId', 'falta');
      }
      food.add(entry);
    }

    final plans = <PlanVersion>[];
    final planIds = <String>{}, routineIds = <String>{};
    for (final (i, raw) in _list(d['plans'], r'$.data.plans').indexed) {
      final p = '\$.data.plans[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(planIds, id, '$p.id');
      final days = <PlanDay>[];
      for (final (j, dr) in _list(m['days'], '$p.days').indexed) {
        final dp = '$p.days[$j]';
        final dm = _map(dr, dp);
        final rm = _map(dm['routine'], '$dp.routine');
        final rp = '$dp.routine';
        final rid = _str(rm, 'id', rp, max: 64, allowEmpty: false);
        _unique(routineIds, rid, '$rp.id');
        final planned = <PlanExercise>[];
        for (final (k, er) in _list(rm['exercises'], '$rp.exercises').indexed) {
          final ep = '$rp.exercises[$k]';
          final em = _map(er, ep);
          final eid = _str(em, 'exerciseId', ep, max: 60, allowEmpty: false);
          _exercise(eid, '$ep.exerciseId');
          planned.add(
            PlanExercise(
              exerciseId: eid,
              sets: _int(em, 'sets', ep, min: 1, max: 20),
              repsMin: _int(em, 'repsMin', ep, min: 1, max: 100),
              repsMax: _int(em, 'repsMax', ep, min: 1, max: 100),
              rir: _int(em, 'rir', ep, min: 0, max: 10),
              restSeconds: _int(em, 'restSeconds', ep, min: 0, max: 3600),
              incrementKg: _dbl(em, 'incrementKg', ep, max: 100),
              referenceWeightKg: _dblN(em, 'referenceWeightKg', ep, max: 2000),
            ),
          );
        }
        days.add(
          PlanDay(
            _int(dm, 'weekday', dp, min: 1, max: 7),
            Routine(
              id: rid,
              name: _str(rm, 'name', rp, max: 80, allowEmpty: false),
              focus: _str(rm, 'focus', rp, max: 200),
              warmup: _str(rm, 'warmup', rp, max: 500),
              exercises: planned,
            ),
          ),
        );
      }
      final plan = PlanVersion(
        id: id,
        status: _enum(PlanStatus.values, m, 'status', p),
        source: _enum(PlanSource.values, m, 'source', p),
        name: _str(m, 'name', p, max: 80, allowEmpty: false),
        createdAt: _date(m['createdAt'], '$p.createdAt'),
        acceptedAt: _dateN(m, 'acceptedAt', p),
        effectiveFrom: m['effectiveFrom'] == null
            ? null
            : _key(m['effectiveFrom'], '$p.effectiveFrom'),
        days: days,
      );
      final issues = PlanValidator.validate(
        plan,
        forAcceptance: plan.status == PlanStatus.accepted,
        isKnown: isKnownExercise,
      );
      if (issues.isNotEmpty) throw _Issue(p, 'plan no válido');
      // The empty plan only exists in code (D45).
      if (plan.source == PlanSource.none) throw _Issue(p, 'plan no válido');
      plans.add(plan);
    }

    final history = <ProfileAnswer>[];
    final historyIds = <String>{};
    for (final (i, raw) in _list(
      d['profileHistory'],
      r'$.data.profileHistory',
    ).indexed) {
      final p = '\$.data.profileHistory[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(historyIds, id, '$p.id');
      final UserProfile answered;
      try {
        answered = UserProfile.fromJson(_map(m['profile'], '$p.profile'));
      } on FormatException {
        throw _Issue('$p.profile', 'no válido');
      } on TypeError {
        throw _Issue('$p.profile', 'no válido');
      }
      history.add(
        ProfileAnswer(
          id: id,
          recordedAt: _date(m['recordedAt'], '$p.recordedAt'),
          reason: _enum(ProfileChange.values, m, 'reason', p),
          profile: answered,
          rulesVersion: _strN(m, 'rulesVersion', p, max: 40),
        ),
      );
    }

    final adjustments = <String, bool>{};
    for (final e in _map(d['adjustments'], r'$.data.adjustments').entries) {
      _key(e.key, '\$.data.adjustments.${e.key}');
      if (e.value is! bool) {
        throw _Issue('\$.data.adjustments.${e.key}', 'no es verdadero/falso');
      }
      adjustments[e.key] = e.value as bool;
    }

    final moves = <Reschedule>[];
    final moveIds = <String>{};
    for (final (i, raw) in _list(
      d['reschedules'],
      r'$.data.reschedules',
    ).indexed) {
      final p = '\$.data.reschedules[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(moveIds, id, '$p.id');
      final source = _key(m['sourceDate'], '$p.sourceDate'),
          target = _key(m['targetDate'], '$p.targetDate');
      if (target.compareTo(source) <= 0) {
        throw _Issue(p, 'el destino debe ser posterior al origen');
      }
      moves.add(
        Reschedule(
          id: id,
          sourceDate: source,
          targetDate: target,
          kind: _enum(RescheduleKind.values, m, 'kind', p),
          createdAt: _date(m['createdAt'], '$p.createdAt'),
          undoneAt: _dateN(m, 'undoneAt', p),
          parentId: _strN(m, 'parentId', p, max: 64),
        ),
      );
    }
    for (final r in moves) {
      if (r.parentId != null && !moveIds.contains(r.parentId)) {
        throw const _Issue(r'$.data.reschedules', 'parentesco desconocido');
      }
    }

    final events = <SessionEvent>[];
    final eventIds = <String>{};
    for (final (i, raw) in _list(
      d['sessionEvents'],
      r'$.data.sessionEvents',
    ).indexed) {
      final p = '\$.data.sessionEvents[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(eventIds, id, '$p.id');
      events.add(
        SessionEvent(
          id: id,
          dateKey: _key(m['dateKey'], '$p.dateKey'),
          kind: _enum(SessionEventKind.values, m, 'kind', p),
          at: _date(m['at'], '$p.at'),
        ),
      );
    }

    final decisions = <ProgressionDecision>[];
    final decisionIds = <String>{}, decisionKeys = <String>{};
    for (final (i, raw) in _list(
      d['progressionDecisions'],
      r'$.data.progressionDecisions',
    ).indexed) {
      final p = '\$.data.progressionDecisions[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(decisionIds, id, '$p.id');
      final exerciseId = _str(m, 'exerciseId', p, max: 60, allowEmpty: false);
      _exercise(exerciseId, '$p.exerciseId');
      final ruleVersion = _str(m, 'ruleVersion', p, max: 40, allowEmpty: false);
      final basedOn = _str(m, 'basedOn', p, max: 12);
      // One decision per exercise and date, under any rules version (D41a).
      _unique(decisionKeys, '$exerciseId|$basedOn', '$p.basedOn');
      decisions.add(
        ProgressionDecision(
          id: id,
          exerciseId: exerciseId,
          ruleVersion: ruleVersion,
          kind: _enum(ProgressionKind.values, m, 'kind', p),
          basedOn: basedOn,
          status: _enum(DecisionStatus.values, m, 'status', p),
          decidedAt: _date(m['decidedAt'], '$p.decidedAt'),
          fromKg: _dblN(m, 'fromKg', p, max: 2000),
          toKg: _dblN(m, 'toKg', p, max: 2000),
        ),
      );
    }

    final reviews = <MonthlyReview>[];
    final reviewIds = <String>{};
    for (final (i, raw) in _list(d['reviews'], r'$.data.reviews').indexed) {
      final p = '\$.data.reviews[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(reviewIds, id, '$p.id');
      reviews.add(
        MonthlyReview(
          id: id,
          reviewedOn: _key(m['reviewedOn'], '$p.reviewedOn'),
          outcome: _enum(ReviewOutcome.values, m, 'outcome', p),
          rulesVersion: _str(m, 'rulesVersion', p, max: 40, allowEmpty: false),
          sessionsDone: _int(m, 'sessionsDone', p, min: 0, max: 100000),
          sessionsDue: _int(m, 'sessionsDue', p, min: 0, max: 100000),
          answers: Map<String, Object?>.from(_map(m['answers'], '$p.answers')),
          proposal: [
            for (final line in _list(m['proposal'], '$p.proposal'))
              line is String
                  ? line
                  : throw _Issue('$p.proposal', 'no es texto'),
          ],
          createdAt: _date(m['createdAt'], '$p.createdAt'),
        ),
      );
    }

    final cardio = <CardioSession>[];
    final cardioIds = <String>{}, segmentIds = <String>{};
    var active = 0;
    for (final (i, raw) in _list(d['cardio'], r'$.data.cardio').indexed) {
      final p = '\$.data.cardio[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(cardioIds, id, '$p.id');
      final segments = <CardioSegment>[];
      for (final (j, sr) in _list(m['segments'], '$p.segments').indexed) {
        final sp = '$p.segments[$j]';
        final sm = _map(sr, sp);
        final sid = _str(sm, 'id', sp, max: 64, allowEmpty: false);
        _unique(segmentIds, sid, '$sp.id');
        segments.add(
          CardioSegment(
            id: sid,
            startedAt: _date(sm['startedAt'], '$sp.startedAt'),
            endedAt: _dateN(sm, 'endedAt', sp),
            intensity: _enum(CardioIntensity.values, sm, 'intensity', sp),
            weightKg: _dblN(sm, 'weightKg', sp, max: 2000),
          ),
        );
      }
      if (segments.isEmpty) {
        throw _Issue('$p.segments', 'una sesión necesita un tramo');
      }
      final status = _enum(CardioStatus.values, m, 'status', p);
      if (status == CardioStatus.active) active++;
      final session = CardioSession(
        id: id,
        activity: _enum(CardioActivity.values, m, 'activity', p),
        startedAt: _date(m['startedAt'], '$p.startedAt'),
        segments: segments,
        targetMinutes: _intN(m, 'targetMinutes', p, min: 1, max: 600),
        status: status,
        finishedAt: _dateN(m, 'finishedAt', p),
        feedback: _enumN(Feeling.values, m, 'feedback', p),
        note: _str(m, 'note', p, max: 500),
        durationCorrected: _bool(m, 'durationCorrected', p),
      );
      // Only the last segment of an active session can be open.
      for (var j = 0; j < segments.length - 1; j++) {
        if (segments[j].endedAt == null) {
          throw _Issue('$p.segments[$j]', 'tramo abierto en medio');
        }
      }
      if (status == CardioStatus.finished && segments.last.endedAt == null) {
        throw _Issue(p, 'sesión terminada con un tramo abierto');
      }
      cardio.add(session);
    }
    if (active > 1) {
      throw const _Issue(r'$.data.cardio', 'más de una sesión activa');
    }

    final favorites = <FavoriteFood>[];
    final favoriteIds = <String>{};
    for (final (i, raw) in _list(d['favorites'], r'$.data.favorites').indexed) {
      final p = '\$.data.favorites[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(favoriteIds, id, '$p.id');
      // Version 1 favorites had no source: they were typed by hand.
      final source = version < 2
          ? CaloriesSource.manual
          : _enum(CaloriesSource.values, m, 'caloriesSource', p);
      if (source == CaloriesSource.recipe) {
        throw _Issue('$p.caloriesSource', 'no válido para un favorito');
      }
      final favorite = FavoriteFood(
        id: id,
        name: _str(m, 'name', p, max: 80, allowEmpty: false),
        calories: _int(m, 'calories', p, min: 0, max: 5000),
        portion: _dblN(m, 'portion', p, max: 100000),
        unit: _strN(m, 'unit', p, max: 12),
        proteinG: _dblN(m, 'proteinG', p, max: 2000),
        carbsG: _dblN(m, 'carbsG', p, max: 2000),
        fatG: _dblN(m, 'fatG', p, max: 2000),
        caloriesSource: source,
      );
      if (source == CaloriesSource.macros &&
          favorite.calories !=
              caloriesFromMacros(
                favorite.proteinG,
                favorite.carbsG,
                favorite.fatG,
              )) {
        throw _Issue('$p.calories', 'no coincide con los macros');
      }
      favorites.add(favorite);
    }

    final coachDecisions = <CoachDecision>[];
    final coachPreferences = <CoachPreference>[];
    if (version >= 2) {
      final ids = <String>{}, accepted = <String>{};
      for (final (i, raw) in _list(
        d['coachDecisions'],
        r'$.data.coachDecisions',
      ).indexed) {
        final p = '\$.data.coachDecisions[$i]';
        final m = _map(raw, p);
        final id = _str(m, 'id', p, max: 64, allowEmpty: false);
        _unique(ids, id, '$p.id');
        final ruleId = _str(m, 'ruleId', p, max: 80, allowEmpty: false);
        final subject = _str(m, 'subject', p, max: 120, allowEmpty: false);
        final anchor = _str(m, 'anchor', p, max: 120);
        final recKey = _str(m, 'recKey', p, max: 330, allowEmpty: false);
        if (recKey != '$ruleId|$subject|$anchor') {
          throw _Issue('$p.recKey', 'no coincide con la regla');
        }
        final status = _enum(CoachDecisionStatus.values, m, 'status', p);
        if (status == CoachDecisionStatus.accepted && !accepted.add(recKey)) {
          throw _Issue('$p.recKey', 'aceptada dos veces');
        }
        coachDecisions.add(
          CoachDecision(
            id: id,
            recKey: recKey,
            ruleId: ruleId,
            kbVersion: _str(m, 'kbVersion', p, max: 40, allowEmpty: false),
            subject: subject,
            anchor: anchor,
            status: status,
            decidedAt: _date(m['decidedAt'], '$p.decidedAt'),
            summary: _str(m, 'summary', p, max: 500),
          ),
        );
      }
      final families = <String>{};
      for (final (i, raw) in _list(
        d['coachPreferences'],
        r'$.data.coachPreferences',
      ).indexed) {
        final p = '\$.data.coachPreferences[$i]';
        final m = _map(raw, p);
        final family = _str(m, 'family', p, max: 40, allowEmpty: false);
        if (!RuleFamily.values.any((f) => f.name == family)) {
          throw _Issue('$p.family', 'valor desconocido');
        }
        _unique(families, family, '$p.family');
        coachPreferences.add(
          CoachPreference(
            family: family,
            muted: _bool(m, 'muted', p),
            updatedAt: _date(m['updatedAt'], '$p.updatedAt'),
          ),
        );
      }
    }

    final recipes = <Recipe>[];
    final recipeIds = <String>{};
    for (final (i, raw) in _list(d['recipes'], r'$.data.recipes').indexed) {
      final p = '\$.data.recipes[$i]';
      final m = _map(raw, p);
      final id = _str(m, 'id', p, max: 64, allowEmpty: false);
      _unique(recipeIds, id, '$p.id');
      final ingredients = <Ingredient>[];
      for (final (j, ir) in _list(m['ingredients'], '$p.ingredients').indexed) {
        final ip = '$p.ingredients[$j]';
        final im = _map(ir, ip);
        ingredients.add(
          Ingredient(
            name: _str(im, 'name', ip, max: 60, allowEmpty: false),
            quantity: _dblN(im, 'quantity', ip, max: 1e6),
            unit: _strN(im, 'unit', ip, max: 12),
            calories: _intN(im, 'calories', ip, min: 0, max: 100000),
            proteinG: _dblN(im, 'proteinG', ip, max: 100000),
            carbsG: _dblN(im, 'carbsG', ip, max: 100000),
            fatG: _dblN(im, 'fatG', ip, max: 100000),
          ),
        );
      }
      if (ingredients.isEmpty || ingredients.length > 50) {
        throw _Issue('$p.ingredients', 'de 1 a 50 ingredientes');
      }
      final servings = _dbl(m, 'servings', p, min: 0.000001, max: 1000);
      List<String> strings(String k) => [
        for (final t in _list(m[k], '$p.$k'))
          t is String && t.trim().isNotEmpty && t.length <= 24
              ? t
              : throw _Issue('$p.$k', 'etiqueta no válida'),
      ];
      recipes.add(
        Recipe(
          id: id,
          name: _str(m, 'name', p, max: 80, allowEmpty: false),
          servings: servings,
          ingredients: ingredients,
          createdAt: _date(m['createdAt'], '$p.createdAt'),
          notes: _str(m, 'notes', p, max: 1000),
          tags: strings('tags'),
          allergens: m['allergens'] == null ? null : strings('allergens'),
        ),
      );
    }

    final g = _map(d['goals'], r'$.data.goals');
    final goals = NutritionGoals(
      kcal: _intN(g, 'kcal', r'$.data.goals', min: 500, max: 10000),
      proteinG: _dblN(g, 'proteinG', r'$.data.goals', max: 1000),
      carbsG: _dblN(g, 'carbsG', r'$.data.goals', max: 1000),
      fatG: _dblN(g, 'fatG', r'$.data.goals', max: 1000),
    );

    return AppSnapshot(
      profile: profile,
      reminder: reminder,
      sessions: sessions,
      overrides: overrides,
      checkIns: checkIns('checkIns'),
      food: food,
      plans: plans,
      profileHistory: history,
      afterCheckIns: checkIns('afterCheckIns'),
      adjustments: adjustments,
      reschedules: moves,
      sessionEvents: events,
      progressionDecisions: decisions,
      reviews: reviews,
      cardio: cardio,
      favorites: favorites,
      recipes: recipes,
      goals: goals,
      coachDecisions: coachDecisions,
      coachPreferences: coachPreferences,
    );
  }
}

/// A validation problem: where, and what, never the value.
class _Issue implements Exception {
  const _Issue(this.path, this.reason);
  final String path, reason;
  @override
  String toString() => '$path: $reason';
}
