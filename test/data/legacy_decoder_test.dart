import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/legacy/legacy_snapshot_v1_decoder.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';

import '../support/legacy_fixture.dart';

LegacyDecodeResult decodeEdited(void Function(Map<String, dynamic> json) edit) {
  final json = legacyFixtureJson();
  edit(json);
  return catalogDecoder().decode(jsonEncode(json));
}

List<String> issuesOf(LegacyDecodeResult result) =>
    (result as LegacyInvalid).issues;

Map<String, dynamic> map(Object? value) => value as Map<String, dynamic>;

void main() {
  test('the full fixture decodes without losing or inventing a field', () {
    final result = catalogDecoder().decode(legacyFixtureRaw());
    final decoded = result as LegacyDecoded;
    // Re-encoding with the 0.1 `toJson` must give back the original content.
    expect(
      canonicalJson(decoded.snapshot.legacyJson()),
      canonicalJson(legacyFixtureJson()),
    );
    expect(decoded.repairs, isEmpty);
    final s = decoded.snapshot;
    expect(s.sessions, hasLength(5));
    expect(s.overrides['2026-09-29'], isNull);
    expect(s.overrides.containsKey('2026-09-29'), isTrue);
    expect(s.sessions['2026-09-29']!.exercises.first.exerciseId, 'rdl');
    expect(s.sessions['2026-10-01']!.exercises.first.weightKg, 67.25);
    expect(s.sessions['2026-10-01']!.feeling, Feeling.energetic);
    expect(s.food.last.name, 'Café con leche ☕');
  });
  test('whole numbers written as integers are accepted as doubles', () {
    final result = decodeEdited((json) {
      map(map(json['sessions'])['2026-10-01'])['exercises'][1]['weightKg'] = 10;
      map(json['profile'])['weightKg'] = 82;
    });
    final snapshot = (result as LegacyDecoded).snapshot;
    expect(snapshot.sessions['2026-10-01']!.exercises[1].weightKg, 10.0);
    expect(snapshot.profile.weightKg, 82.0);
  });
  test('a newer schema version is reported, not guessed', () {
    expect(
      catalogDecoder().decode('{"schemaVersion": 99}'),
      isA<LegacyNewerVersion>(),
    );
  });
  test('malformed text is reported as invalid JSON', () {
    for (final raw in ['', '{"schemaVersion": 1, ', 'no es json']) {
      expect(issuesOf(catalogDecoder().decode(raw)), [r'$: JSON no válido']);
    }
    expect(issuesOf(catalogDecoder().decode('[]')), [
      r'$: se esperaba un objeto',
    ]);
  });
  group('rejects, with the path of each problem', () {
    final cases = <String, (void Function(Map<String, dynamic>), String)>{
      'missing version': (
        (j) => j.remove('schemaVersion'),
        'schemaVersion: debe ser 1',
      ),
      'version as text': (
        (j) => j['schemaVersion'] = '1',
        'schemaVersion: debe ser 1',
      ),
      'unknown routine': (
        (j) => map(map(j['sessions'])['2026-10-01'])['routineId'] = 'yoga',
        'sessions[2026-10-01].routineId: referencia desconocida',
      ),
      'unknown exercise': (
        (j) => map(
          map(j['sessions'])['2026-09-29'],
        )['exercises'][0]['exerciseId'] = 'nope',
        'sessions[2026-09-29].exercises[0].exerciseId: referencia desconocida',
      ),
      'repeated exercise': (
        (j) => map(
          map(j['sessions'])['2026-09-29'],
        )['exercises'][2]['exerciseId'] = 'rdl',
        'sessions[2026-09-29].exercises[2].exerciseId: ejercicio repetido en la sesión',
      ),
      'weight too high': (
        (j) =>
            map(map(j['sessions'])['2026-09-29'])['exercises'][1]['weightKg'] =
                5000,
        'sessions[2026-09-29].exercises[1].weightKg: fuera de rango',
      ),
      'negative weight': (
        (j) =>
            map(map(j['sessions'])['2026-09-29'])['exercises'][1]['weightKg'] =
                -1,
        'sessions[2026-09-29].exercises[1].weightKg: fuera de rango',
      ),
      'weight as text': (
        (j) =>
            map(map(j['sessions'])['2026-09-29'])['exercises'][1]['weightKg'] =
                '52',
        'sessions[2026-09-29].exercises[1].weightKg: se esperaba un número',
      ),
      'completed as number': (
        (j) =>
            map(map(j['sessions'])['2026-09-29'])['exercises'][1]['completed'] =
                1,
        'sessions[2026-09-29].exercises[1].completed: se esperaba verdadero o falso',
      ),
      'unknown status': (
        (j) => map(map(j['sessions'])['2026-09-29'])['status'] = 'paused',
        'sessions[2026-09-29].status: valor no reconocido',
      ),
      'unknown feeling': (
        (j) => map(map(j['sessions'])['2026-10-01'])['feeling'] = 'happy',
        'sessions[2026-10-01].feeling: valor no reconocido',
      ),
      'key does not match its date': (
        (j) => map(map(j['sessions'])['2026-09-29'])['dateKey'] = '2026-09-28',
        'sessions[2026-09-29].dateKey: no coincide con su clave',
      ),
      'impossible date as key': (
        (j) {
          final sessions = map(j['sessions']);
          sessions['2026-02-31'] = sessions.remove('2026-09-29');
        },
        'sessions[#4]: fecha no válida',
      ),
      'session is not an object': (
        (j) => map(j['sessions'])['2026-09-29'] = 'x',
        'sessions[2026-09-29]: se esperaba un objeto',
      ),
      'age too low': (
        (j) => map(j['profile'])['age'] = 13,
        'profile.age: fuera de rango',
      ),
      'body weight too low': (
        (j) => map(j['profile'])['weightKg'] = 24.9,
        'profile.weightKg: fuera de rango',
      ),
      'unknown experience': (
        (j) => map(j['profile'])['experience'] = 'elite',
        'profile.experience: valor no reconocido',
      ),
      'bad review date': (
        (j) => map(j['profile'])['lastReview'] = '2026-13-01',
        'profile.lastReview: fecha no válida',
      ),
      'reminder hour out of range': (
        (j) => map(j['reminder'])['hour'] = 24,
        'reminder.hour: fuera de rango',
      ),
      'reminder minute as decimal': (
        (j) => map(j['reminder'])['minute'] = 30.5,
        'reminder.minute: se esperaba un entero',
      ),
      'override to unknown routine': (
        (j) => map(j['overrides'])['2026-09-30'] = 'yoga',
        'overrides[2026-09-30]: referencia desconocida',
      ),
      'check-in with unknown feeling': (
        (j) => map(map(j['checkIns'])['2026-09-29'])['feeling'] = 'meh',
        'checkIns[2026-09-29].feeling: valor no reconocido',
      ),
      'food without calories': (
        (j) => j['food'][0]['calories'] = 0,
        'food[0].calories: fuera de rango',
      ),
      'food calories too high': (
        (j) => j['food'][1]['calories'] = 5001,
        'food[1].calories: fuera de rango',
      ),
      'food with blank name': (
        (j) => j['food'][2]['name'] = '   ',
        'food[2].name: vacío',
      ),
      'food without id': (
        (j) => j['food'][0].remove('id'),
        'food[0].id: se esperaba texto',
      ),
      'missing section': (
        (j) => j.remove('checkIns'),
        'checkIns: se esperaba un objeto',
      ),
      'food is not a list': (
        (j) => j['food'] = {},
        'food: se esperaba una lista',
      ),
    };
    cases.forEach((name, spec) {
      test(name, () {
        final result = decodeEdited(spec.$1);
        expect(issuesOf(result), contains(spec.$2));
      });
    });
  });
  test('problems never repeat personal content', () {
    final result = decodeEdited((json) {
      map(json['profile'])['age'] = 3;
      map(json['sessions'])['2026-09-29'] = 'x';
      json['food'][1]['calories'] = 0;
      json['food'][2]['name'] = '';
    });
    final text = issuesOf(result).join('\n');
    for (final secret in ['Hombro', 'Dormí', 'Pollo', 'Café']) {
      expect(text, isNot(contains(secret)));
    }
  });
  test('duplicate food ids are kept and given a stable new id', () {
    final result = decodeEdited((json) {
      json['food'][1]['id'] = json['food'][0]['id'];
      json['food'].add(Map<String, dynamic>.from(json['food'][0] as Map));
    });
    final decoded = result as LegacyDecoded;
    final ids = decoded.snapshot.food.map((f) => f.id).toList();
    expect(ids, hasLength(4));
    expect(ids.toSet(), hasLength(4));
    expect(ids.first, '1759143600000001');
    expect(ids[1], '1759143600000001#2');
    expect(ids[3], '1759143600000001#3');
    expect(decoded.repairs, ['food-id-reassigned', 'food-id-reassigned']);
    expect(decoded.snapshot.food[1].name, 'Pollo con arroz y ensalada');
  });
  test('a long list of problems is capped and counted', () {
    final result = decodeEdited((json) {
      json['food'] = [
        for (var i = 0; i < 30; i++)
          {'id': 'f$i', 'dateKey': '2026-09-29', 'name': 'x', 'calories': 0},
      ];
    });
    final issues = issuesOf(result);
    expect(issues, hasLength(21));
    expect(issues.last, '…y 10 más');
  });
}
