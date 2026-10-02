import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/legacy/legacy_snapshot_source.dart';
import 'package:forja_app/data/legacy/legacy_snapshot_v1_decoder.dart';
import 'package:forja_app/data/services/drift_forja_store.dart';
import 'package:forja_app/data/services/local_store_opener.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/models/storage_failure.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../support/legacy_fixture.dart';
import '../support/sqlite_harness.dart';

const source = PreferencesLegacySnapshotSource.storageKey;

// The real preferences backend, backed by memory, as 0.1 left it.
void installLegacy(String? raw) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({source: ?raw});
}

Future<String?> legacyOnDevice() => PreferencesLegacySnapshotSource().readRaw();

class CountingSource implements LegacySnapshotSource {
  CountingSource(this.value, {this.fails = false});
  final String? value;
  bool fails;
  int reads = 0;
  @override
  String get id => source;
  @override
  Future<String?> readRaw() async {
    reads++;
    if (fails) throw StateError('preferences unavailable');
    return value;
  }
}

Matcher rejectedWith(String raw, String issue) => isA<LegacyDataRejected>()
    .having((f) => f.raw, 'raw', raw)
    .having((f) => f.issues, 'issues', contains(issue));

void main() {
  late StoreHarness h;
  setUp(() async {
    h = await StoreHarness.create();
    installLegacy(legacyFixtureRaw());
  });
  tearDown(() => h.dispose());

  LocalStoreOpener opener({LegacySnapshotSource? from, int? maxPages}) =>
      LocalStoreOpener(
        connection: () => h.connection(maxPages: maxPages),
        source: from ?? PreferencesLegacySnapshotSource(),
      );

  // Closes the store, then inspects the file through a fresh handle.
  Future<Opened> inspect(DriftForjaStore store) async {
    await store.close();
    return h.open();
  }

  Future<Map<String, Object?>> marker(Opened o) async {
    final rows = await o.db.customSelect('SELECT * FROM legacy_imports').get();
    return rows.isEmpty ? {} : rows.single.data;
  }

  const empty = {
    'profiles': 0,
    'profile_history': 0,
    'plan_versions': 0,
    'plan_routines': 0,
    'plan_routine_exercises': 0,
    'reminders': 0,
    'workout_sessions': 0,
    'session_exercises': 0,
    'calendar_overrides': 0,
    'check_ins': 0,
    'food_entries': 0,
    'legacy_imports': 0,
    'set_logs': 0,
    'session_events': 0,
    'reschedules': 0,
    'session_adjustments': 0,
    'progression_decisions': 0,
    'monthly_reviews': 0,
    'cardio_sessions': 0,
    'cardio_segments': 0,
    'food_favorites': 0,
    'recipes': 0,
    'recipe_ingredients': 0,
    'nutrition_goals': 0,
  };

  test('imports the full 0.1 snapshot without loss', () async {
    final store = await opener().open();
    final expected =
        (catalogDecoder().decode(legacyFixtureRaw()) as LegacyDecoded).snapshot;
    final stored = await store.load();
    expect(sameSnapshotContent(stored, expected), isTrue);
    // Against the raw original too, not only against our own decoder.
    expect(
      canonicalJson(stored.legacyJson()),
      canonicalJson(legacyFixtureJson()),
    );
    final o = await inspect(store);
    expect(await o.counts(), {
      'profiles': 1,
      'profile_history': 0,
      'plan_versions': 0,
      'plan_routines': 0,
      'plan_routine_exercises': 0,
      'reminders': 1,
      'workout_sessions': 5,
      'session_exercises': 13,
      'calendar_overrides': 4,
      'check_ins': 2,
      'food_entries': 3,
      'legacy_imports': 1,
      // 0.1 had no sets, events, moves or adjustments: none are invented.
      'set_logs': 0,
      'session_events': 0,
      'reschedules': 0,
      'session_adjustments': 0,
      'progression_decisions': 0,
      'monthly_reviews': 0,
      'cardio_sessions': 0,
      'cardio_segments': 0,
      'food_favorites': 0,
      'recipes': 0,
      'recipe_ingredients': 0,
      'nutrition_goals': 0,
    });
    final origins = await o.db
        .customSelect('SELECT DISTINCT origin FROM workout_sessions')
        .get();
    expect(origins.map((r) => r.read<String>('origin')), ['legacySnapshotV1']);
    // 0.1 had no timestamps: unknown stays unknown instead of being invented.
    for (final table in ['workout_sessions', 'check_ins', 'food_entries']) {
      final known = await o.db
          .customSelect(
            'SELECT COUNT(*) AS n FROM $table WHERE created_at IS NOT NULL',
          )
          .getSingle();
      expect(known.read<int>('n'), 0, reason: table);
    }
    final m = await marker(o);
    expect(m['source'], source);
    expect(m['status'], 'imported');
    expect(
      [m['session_count'], m['override_count'], m['check_in_count']],
      [5, 4, 2],
    );
    expect(m['food_count'], 3);
    expect(m['notes'], '');
    // The original is only ever read.
    expect(await legacyOnDevice(), legacyFixtureRaw());
  });
  test('a second start does not import again and keeps stable ids', () async {
    Future<List<String>> sessionIds(Opened o) async {
      final rows = await o.db
          .customSelect('SELECT id FROM workout_sessions ORDER BY date_key')
          .get();
      return rows.map((r) => r.read<String>('id')).toList();
    }

    var o = await inspect(await opener().open());
    final ids = await sessionIds(o), counts = await o.counts();
    await o.close();
    o = await inspect(await opener().open());
    expect(await sessionIds(o), ids);
    expect(await o.counts(), counts);
    expect(ids.toSet(), hasLength(5));
  });
  test('two imports at once store the data exactly once', () async {
    final o = await h.open();
    final snapshot =
        (catalogDecoder().decode(legacyFixtureRaw()) as LegacyDecoded).snapshot;
    // The second call finds the first one's marker inside its transaction.
    await Future.wait([
      o.store.importLegacy(source, snapshot),
      o.store.importLegacy(source, snapshot),
    ]);
    expect(sameSnapshotContent(await o.store.load(), snapshot), isTrue);
    expect((await o.counts())['workout_sessions'], 5);
    expect((await o.counts())['legacy_imports'], 1);
  });
  group('a failure during the import', () {
    for (final (name, failing) in [
      ('while inserting data', 'food_entries'),
      ('when writing the marker', 'legacy_imports'),
    ]) {
      test(
        '$name leaves no rows and no marker, and a retry succeeds',
        () async {
          h.fault.arm(
            (sql) => sql.startsWith('INSERT') && sql.contains(failing),
          );
          await expectLater(
            opener().open(),
            throwsA(isA<StorageUnavailable>()),
          );
          expect(h.fault.hits, greaterThan(0));
          h.fault.disarm();
          var o = await h.open();
          expect(await o.counts(), empty);
          await o.close();
          expect(await legacyOnDevice(), legacyFixtureRaw());
          o = await inspect(await opener().open());
          expect((await o.counts())['workout_sessions'], 5);
          expect((await marker(o))['status'], 'imported');
        },
      );
    }
  });
  test('a full disk during the import rolls everything back', () async {
    final big = jsonEncode(
      AppSnapshot(
        // What 0.1 wrote for a profile nobody had saved yet.
        profile: const UserProfile(weightKg: 70, age: 28),
        food: [
          for (var i = 0; i < 1500; i++)
            FoodEntry(
              id: 'f$i',
              dateKey: '2026-09-29',
              name: 'Comida $i ${'x' * 150}',
              calories: 100,
            ),
        ],
      ).legacyJson(),
    );
    installLegacy(big);
    // Create the schema first, then cap the file just above its size.
    var o = await h.open();
    final pages = (await o.db.customSelect('PRAGMA page_count').getSingle())
        .read<int>('page_count');
    await o.close();
    await expectLater(
      opener(maxPages: pages + 3).open(),
      throwsA(isA<StorageUnavailable>()),
    );
    o = await h.open();
    expect(await o.counts(), empty);
    await o.close();
    // With room again, the same data imports.
    o = await inspect(await opener().open());
    expect((await o.counts())['food_entries'], 1500);
    expect((await marker(o))['status'], 'imported');
  });
  group('data that cannot be imported', () {
    final cases = <String, (String, String)>{
      'corrupt text': ('{"schemaVersion": 1, ', r'$: JSON no válido'),
      'unknown references': (
        legacyFixtureRaw().replaceFirst(
          '"routineId": "legs"',
          '"routineId": "yoga"',
        ),
        'sessions[2026-09-29].routineId: referencia desconocida',
      ),
      'impossible dates': (
        legacyFixtureRaw().replaceFirst('"2026-10-03": {', '"2026-02-31": {'),
        'sessions[#3]: fecha no válida',
      ),
    };
    cases.forEach((name, spec) {
      test(
        '$name is refused, nothing is written and the original stays',
        () async {
          installLegacy(spec.$1);
          await expectLater(
            opener().open(),
            throwsA(rejectedWith(spec.$1, spec.$2)),
          );
          // Asking again gives the same answer: it is not silently skipped.
          await expectLater(
            opener().open(),
            throwsA(isA<LegacyDataRejected>()),
          );
          final o = await h.open();
          expect(await o.counts(), empty);
          expect(await legacyOnDevice(), spec.$1);
        },
      );
    });
    test('a snapshot from a newer version is reported untouched', () async {
      const raw = '{"schemaVersion": 99}';
      installLegacy(raw);
      await expectLater(
        opener().open(),
        throwsA(isA<LegacyFutureVersion>().having((f) => f.raw, 'raw', raw)),
      );
      final o = await h.open();
      expect(await o.counts(), empty);
      expect(await legacyOnDevice(), raw);
    });
  });
  test(
    'continuing without importing marks the source and keeps the original',
    () async {
      const raw = '{"schemaVersion": 1, ';
      installLegacy(raw);
      await expectLater(opener().open(), throwsA(isA<LegacyDataRejected>()));
      final store = await opener().open(skipLegacyImport: true);
      expect(sameSnapshotContent(await store.load(), AppSnapshot()), isTrue);
      var o = await inspect(store);
      expect((await marker(o))['status'], 'skipped');
      expect(await legacyOnDevice(), raw);
      await o.close();
      // Later starts neither fail nor import: the choice was made.
      o = await inspect(await opener().open());
      expect(await o.counts(), {...empty, 'legacy_imports': 1});
    },
  );
  test('without legacy data the source is marked and not read again', () async {
    final none = CountingSource(null);
    var o = await inspect(await opener(from: none).open());
    expect((await marker(o))['status'], 'absent');
    await o.close();
    o = await inspect(await opener(from: none).open());
    expect(none.reads, 1);
    expect((await marker(o))['status'], 'absent');
  });
  test(
    'a failed read is not "no data": nothing is marked and a retry imports',
    () async {
      final flaky = CountingSource(legacyFixtureRaw(), fails: true);
      await expectLater(
        opener(from: flaky).open(),
        throwsA(isA<StorageUnavailable>()),
      );
      var o = await h.open();
      expect(await o.counts(), empty);
      await o.close();
      flaky.fails = false;
      o = await inspect(await opener(from: flaky).open());
      expect((await o.counts())['workout_sessions'], 5);
    },
  );
  test(
    'repaired duplicate food ids are recorded as a code, not as content',
    () async {
      final json = legacyFixtureJson();
      json['food'][1]['id'] = json['food'][0]['id'];
      installLegacy(jsonEncode(json));
      final o = await inspect(await opener().open());
      expect((await marker(o))['notes'], 'food-id-reassigned');
      expect((await o.counts())['food_entries'], 3);
    },
  );
}
