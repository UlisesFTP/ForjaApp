import 'dart:convert';

import '../../domain/models/models.dart';

sealed class LegacyDecodeResult {
  const LegacyDecodeResult();
}

class LegacyDecoded extends LegacyDecodeResult {
  const LegacyDecoded(this.snapshot, this.repairs);
  final AppSnapshot snapshot;
  // Codes of values fixed on the way in; they never carry personal content.
  final List<String> repairs;
}

class LegacyInvalid extends LegacyDecodeResult {
  const LegacyInvalid(this.issues);
  final List<String> issues;
}

class LegacyNewerVersion extends LegacyDecodeResult {
  const LegacyNewerVersion();
}

/// Strict reader of the 0.1 snapshot. The model `fromJson` factories fall
/// back to defaults; this one reports every problem instead, because an
/// import must never invent or drop data. Accepts anything 0.1 could write.
class LegacySnapshotV1Decoder {
  LegacySnapshotV1Decoder({
    required this.routineIds,
    required this.exerciseIds,
  });
  final Set<String> routineIds, exerciseIds;

  LegacyDecodeResult decode(String raw) {
    final Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return const LegacyInvalid([r'$: JSON no válido']);
    }
    if (json is! Map) return const LegacyInvalid([r'$: se esperaba un objeto']);
    final version = json['schemaVersion'];
    if (version is int && version > 1) return const LegacyNewerVersion();
    final reader = _Reader(routineIds, exerciseIds);
    final snapshot = reader.snapshot(json);
    return reader.hasIssues
        ? LegacyInvalid(reader.report)
        : LegacyDecoded(snapshot, reader.repairs);
  }
}

// Each reader returns a best-effort value and records problems; the result is
// discarded when any were recorded.
class _Reader {
  _Reader(this.routineIds, this.exerciseIds);
  static const _maxIssues = 20;
  static final _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
  final Set<String> routineIds, exerciseIds;
  final repairs = <String>[];
  final _issues = <String>[];
  var _dropped = 0;

  bool get hasIssues => _issues.isNotEmpty;
  List<String> get report => [..._issues, if (_dropped > 0) '…y $_dropped más'];

  void _issue(String path, String reason) {
    if (_issues.length < _maxIssues) {
      _issues.add('$path: $reason');
    } else {
      _dropped++;
    }
  }

  AppSnapshot snapshot(Map json) {
    if (json['schemaVersion'] != 1) _issue('schemaVersion', 'debe ser 1');
    return AppSnapshot(
      profile: _profile(json['profile']),
      reminder: _reminder(json['reminder']),
      sessions: _sessions(json['sessions']),
      overrides: _overrides(json['overrides']),
      checkIns: _checkIns(json['checkIns']),
      food: _food(json['food']),
    );
  }

  UserProfile _profile(Object? value) {
    const path = 'profile';
    final m = _object(value, path);
    if (m == null) return const UserProfile();
    final last = m['lastReview'];
    final weight = _number(m['weightKg'], '$path.weightKg', 25, 300);
    final age = _integer(m['age'], '$path.age', 14, 100);
    final onboarded = _flag(m['onboarded'], '$path.onboarded') ?? false;
    // 0.1 prefilled 70 kg / 28 years in the form; before the profile was
    // saved those were its defaults, not something the person answered.
    if (!onboarded && (weight != null || age != null)) {
      repairs.add('profile-defaults-cleared');
    }
    return UserProfile(
      experience:
          _choice(Experience.values, m['experience'], '$path.experience') ??
          Experience.intermediate,
      goal:
          _choice(TrainingGoal.values, m['goal'], '$path.goal') ??
          TrainingGoal.strength,
      weightKg: onboarded ? weight : null,
      age: onboarded ? age : null,
      energy:
          _choice(Energy.values, m['energy'], '$path.energy') ?? Energy.normal,
      note: _text(m['note'], '$path.note') ?? '',
      onboarded: onboarded,
      lastReview: last == null ? null : _date(last, '$path.lastReview'),
    );
  }

  ReminderSettings _reminder(Object? value) {
    const path = 'reminder';
    final m = _object(value, path);
    if (m == null) return const ReminderSettings();
    return ReminderSettings(
      enabled: _flag(m['enabled'], '$path.enabled') ?? false,
      hour: _integer(m['hour'], '$path.hour', 0, 23) ?? 18,
      minute: _integer(m['minute'], '$path.minute', 0, 59) ?? 0,
    );
  }

  Map<String, WorkoutSession> _sessions(Object? value) {
    final m = _object(value, 'sessions');
    final result = <String, WorkoutSession>{};
    if (m == null) return result;
    var index = 0;
    for (final entry in m.entries) {
      final key = _date(entry.key, 'sessions[#${index++}]');
      if (key == null) continue;
      final path = 'sessions[$key]';
      final s = _object(entry.value, path);
      if (s == null) continue;
      final dateKey = _date(s['dateKey'], '$path.dateKey');
      if (dateKey != null && dateKey != key) {
        _issue('$path.dateKey', 'no coincide con su clave');
      }
      final feeling = s['feeling'];
      result[key] = WorkoutSession(
        dateKey: key,
        routineId:
            _reference(s['routineId'], '$path.routineId', routineIds) ?? '',
        exercises: _logs(s['exercises'], '$path.exercises'),
        status:
            _choice(SessionStatus.values, s['status'], '$path.status') ??
            SessionStatus.scheduled,
        feeling: feeling == null
            ? null
            : _choice(Feeling.values, feeling, '$path.feeling'),
        note: _text(s['note'], '$path.note') ?? '',
      );
    }
    return result;
  }

  List<ExerciseLog> _logs(Object? value, String path) {
    final list = _array(value, path);
    final logs = <ExerciseLog>[];
    if (list == null) return logs;
    final seen = <String>{};
    for (var i = 0; i < list.length; i++) {
      final at = '$path[$i]';
      final m = _object(list[i], at);
      if (m == null) continue;
      final id = _reference(m['exerciseId'], '$at.exerciseId', exerciseIds);
      if (id != null && !seen.add(id)) {
        _issue('$at.exerciseId', 'ejercicio repetido en la sesión');
      }
      final weight = _number(m['weightKg'], '$at.weightKg', 0, 2000);
      final done = _flag(m['completed'], '$at.completed');
      if (id != null && weight != null && done != null) {
        logs.add(
          ExerciseLog(exerciseId: id, weightKg: weight, completed: done),
        );
      }
    }
    return logs;
  }

  Map<String, String?> _overrides(Object? value) {
    final m = _object(value, 'overrides');
    final result = <String, String?>{};
    if (m == null) return result;
    var index = 0;
    for (final entry in m.entries) {
      final key = _date(entry.key, 'overrides[#${index++}]');
      if (key == null) continue;
      // Null is an explicit rest day.
      result[key] = entry.value == null
          ? null
          : _reference(entry.value, 'overrides[$key]', routineIds);
    }
    return result;
  }

  Map<String, CheckIn> _checkIns(Object? value) {
    final m = _object(value, 'checkIns');
    final result = <String, CheckIn>{};
    if (m == null) return result;
    var index = 0;
    for (final entry in m.entries) {
      final key = _date(entry.key, 'checkIns[#${index++}]');
      if (key == null) continue;
      final path = 'checkIns[$key]';
      final c = _object(entry.value, path);
      if (c == null) continue;
      result[key] = CheckIn(
        feeling:
            _choice(Feeling.values, c['feeling'], '$path.feeling') ??
            Feeling.normal,
        note: _text(c['note'], '$path.note') ?? '',
      );
    }
    return result;
  }

  List<FoodEntry> _food(Object? value) {
    final list = _array(value, 'food');
    final food = <FoodEntry>[];
    if (list == null) return food;
    final seen = <String>{};
    for (var i = 0; i < list.length; i++) {
      final path = 'food[$i]';
      final m = _object(list[i], path);
      if (m == null) continue;
      final id = _text(m['id'], '$path.id');
      final name = _text(m['name'], '$path.name');
      final dateKey = _date(m['dateKey'], '$path.dateKey');
      final calories = _integer(m['calories'], '$path.calories', 1, 5000);
      if (id != null && id.isEmpty) _issue('$path.id', 'vacío');
      if (name != null && name.trim().isEmpty) _issue('$path.name', 'vacío');
      if (id == null ||
          id.isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          dateKey == null ||
          calories == null) {
        continue;
      }
      // Ids come from a microsecond clock, so a repeat is practically
      // impossible; keep both entries instead of dropping one.
      var unique = id, attempt = 1;
      while (!seen.add(unique)) {
        unique = '$id#${++attempt}';
      }
      if (attempt > 1) repairs.add('food-id-reassigned');
      food.add(
        FoodEntry(id: unique, dateKey: dateKey, name: name, calories: calories),
      );
    }
    return food;
  }

  Map<String, dynamic>? _object(Object? value, String path) {
    if (value is Map) return Map<String, dynamic>.from(value);
    _issue(path, 'se esperaba un objeto');
    return null;
  }

  List<dynamic>? _array(Object? value, String path) {
    if (value is List) return value;
    _issue(path, 'se esperaba una lista');
    return null;
  }

  String? _text(Object? value, String path) {
    if (value is String) return value;
    _issue(path, 'se esperaba texto');
    return null;
  }

  bool? _flag(Object? value, String path) {
    if (value is bool) return value;
    _issue(path, 'se esperaba verdadero o falso');
    return null;
  }

  int? _integer(Object? value, String path, int min, int max) {
    if (value is! int) {
      _issue(path, 'se esperaba un entero');
      return null;
    }
    if (value < min || value > max) {
      _issue(path, 'fuera de rango');
      return null;
    }
    return value;
  }

  // Any JSON number: 0.1 on the web wrote whole values like 52.0 as 52.
  double? _number(Object? value, String path, double min, double max) {
    if (value is! num || !value.isFinite) {
      _issue(path, 'se esperaba un número');
      return null;
    }
    if (value < min || value > max) {
      _issue(path, 'fuera de rango');
      return null;
    }
    return value.toDouble();
  }

  E? _choice<E extends Enum>(List<E> values, Object? value, String path) {
    if (value is String) {
      for (final candidate in values) {
        if (candidate.name == value) return candidate;
      }
    }
    _issue(path, 'valor no reconocido');
    return null;
  }

  String? _reference(Object? value, String path, Set<String> valid) {
    if (value is String && valid.contains(value)) return value;
    _issue(path, 'referencia desconocida');
    return null;
  }

  // `DateTime.parse` rolls impossible dates forward ("2026-02-31" becomes
  // March), so check that the date survives a round trip.
  String? _date(Object? value, String path) {
    final match = value is String ? _datePattern.firstMatch(value) : null;
    if (match != null) {
      final year = int.parse(match[1]!), month = int.parse(match[2]!);
      final day = int.parse(match[3]!), date = DateTime.utc(year, month, day);
      if (date.year == year && date.month == month && date.day == day) {
        return value as String;
      }
    }
    _issue(path, 'fecha no válida');
    return null;
  }
}
