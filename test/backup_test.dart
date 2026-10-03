import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/backup/backup_codec.dart';
import 'package:forja_app/data/database/tables.dart' show LegacyImportStatus;
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/backup_service.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'support/fake_notifications.dart';
import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

class FakeBackupFiles implements BackupFiles {
  final List<(String, Uint8List)> saved = [];
  bool cancelSave = false;
  PickedBackup? next;
  Object? pickError;
  int picks = 0;
  @override
  Future<bool> saveCopy({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (cancelSave) return false;
    saved.add((fileName, bytes));
    return true;
  }

  @override
  Future<PickedBackup?> pickBackup() async {
    picks++;
    if (pickError != null) throw pickError!;
    return next;
  }
}

class MemoryVault implements BackupVault {
  final Map<String, String> files = {};
  bool failSave = false;
  @override
  Future<String> save(String name, String content) async {
    if (failSave) throw const FileSystemException('disco lleno');
    files[name] = content;
    return name;
  }

  @override
  Future<void> deleteAll() async => files.clear();
  @override
  Future<List<String>> names() async => files.keys.toList()..sort();
}

BackupCodec codec() {
  final known = {for (final e in exerciseCatalog) e.id};
  return BackupCodec(isKnownExercise: known.contains);
}

Uint8List bytes(String text) => Uint8List.fromList(utf8.encode(text));

/// Recomputes the checksum of an edited backup, so a test can reach the
/// checks that come after it.
String resign(Map<String, dynamic> file) {
  final body = {
    'version': file['version'],
    'counts': file['counts'],
    'data': file['data'],
  };
  file['checksum'] = {
    'algorithm': 'sha256',
    'value': sha256.convert(utf8.encode(canonicalJson(body))).toString(),
  };
  return jsonEncode(file);
}

Map<String, dynamic> parse(String text) =>
    jsonDecode(text) as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'DM Sans',
    )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
    await (FontLoader('Barlow Condensed')
          ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
        .load();
  });

  final now = DateTime.utc(2026, 10, 1, 15, 30);
  final tuesday = DateTime(2026, 9, 29);

  /// A database with a bit of everything, written through the real commands.
  Future<Opened> richDatabase(
    StoreHarness h, {
    String note = 'Hombro izquierdo sensible',
  }) async {
    final o = await h.open(clock: () => now);
    final r = o.repo;
    await r.saveProfile(
      UserProfile(
        weightKg: 72.5,
        age: 33,
        onboarded: true,
        note: note,
        unit: WeightUnit.lb,
        lastReview: '2026-09-01',
      ),
      record: ProfileChange.edit,
    );
    await r.saveReminder(
      const ReminderSettings(enabled: true, hour: 7, minute: 15),
    );
    await r.addSet(
      tuesday,
      'squat',
      const SetEntry(weightKg: 52.5, reps: 8, rir: 2),
    );
    await r.addSet(
      tuesday,
      'squat',
      const SetEntry(kind: SetKind.warmup, weightKg: 20, reps: 10),
    );
    await r.addSet(tuesday, 'squat', const SetEntry());
    await r.setTechnique(tuesday, 'squat', TechniqueRating.solid);
    await r.setSkipped(tuesday, 'rdl', true, reason: 'sin barra');
    await r.toggleExercise(tuesday, 'press');
    await r.saveCheckIn(tuesday, CheckIn(feeling: Feeling.tired, note: note));
    await r.saveCheckIn(
      tuesday,
      const CheckIn(feeling: Feeling.normal),
      phase: CheckInPhase.after,
    );
    await r.setAdjustment(tuesday, false);
    await r.finishSession(DateTime(2026, 10, 1), SessionStatus.missed);
    await r.reopenSession(tuesday).then((_) {}, onError: (_) {});
    await r.addFood(
      FoodEntry(
        id: 'f1',
        dateKey: '2026-09-29',
        name: 'Avena',
        calories: 300,
        portion: 0.5,
        unit: 'taza',
        proteinG: 10,
        fatG: 0,
      ),
    );
    await r.addFavorite(
      const FavoriteFood(id: 'v1', name: 'Yogur', calories: 120),
    );
    await r.saveRecipe(
      Recipe(
        id: 'q1',
        name: 'Guiso',
        servings: 2.5,
        createdAt: now,
        tags: const ['rápida'],
        allergens: const [],
        ingredients: const [
          Ingredient(name: 'Arroz', quantity: 100, unit: 'g', calories: 360),
        ],
      ),
    );
    await r.saveGoals(const NutritionGoals(kcal: 2200, proteinG: 140));
    await r.startCardio(
      activity: CardioActivity.bicycle,
      intensity: CardioIntensity.low,
      at: now,
    );
    await r.changeCardioIntensity(
      now.add(const Duration(minutes: 10)),
      CardioIntensity.high,
    );
    await r.finishCardio(
      r.activeCardio!.id,
      now.add(const Duration(minutes: 30)),
      feedback: Feeling.energetic,
    );
    await r.decideProgression(
      exerciseId: 'squat',
      kind: ProgressionKind.increase,
      basedOn: '2026-09-29',
      ruleVersion: 'prog-v1',
      status: DecisionStatus.accepted,
      fromKg: 60,
      toKg: 62.5,
    );
    await r.completeReview(
      MonthlyReview(
        id: 'rv1',
        reviewedOn: '2026-10-01',
        outcome: ReviewOutcome.rejected,
        rulesVersion: 'review-v1',
        sessionsDone: 2,
        sessionsDue: 3,
        answers: const {'pain': false},
        proposal: const ['sin cambios'],
        createdAt: now,
      ),
    );
    return o;
  }

  group('backup format (F13)', () {
    late StoreHarness h;
    setUp(() async => h = await StoreHarness.create());
    tearDown(() => h.dispose());

    test('a full snapshot goes out and comes back identical', () async {
      final o = await richDatabase(h);
      final text = BackupCodec.encode(
        o.repo.snapshot,
        createdAt: now,
        schema: 6,
      );
      final preview = codec().decode(bytes(text));
      expect(
        sameSnapshotContent(preview.snapshot, o.repo.snapshot),
        isTrue,
        reason: firstDifference(
          preview.snapshot.toJson(),
          o.repo.snapshot.toJson(),
        ),
      );
      expect(preview.createdAt, now);
      expect(preview.appSchema, 6);
      // The restored snapshot has real content on every collection.
      final c = preview.counts;
      expect(c['sessions'], greaterThan(0));
      expect(c['sets'], 3);
      expect(c['cardio'], 1);
      expect(c['food'], 1);
      expect(c['recipes'], 1);
      expect(c['reviews'], 1);
      expect(c['progressionDecisions'], 1);
    });

    test('the file has a version, counts, a checksum and no platform details', () async {
      final o = await richDatabase(h);
      final file = parse(
        BackupCodec.encode(o.repo.snapshot, createdAt: now, schema: 6),
      );
      expect(file['format'], 'forja-backup');
      // Version 2 since schema 7 (D40).
      expect(file['version'], 2);
      expect((file['checksum'] as Map)['algorithm'], 'sha256');
      expect(((file['checksum'] as Map)['value'] as String).length, 64);
      expect(file['counts'], isA<Map>());
      final text = jsonEncode(file);
      // No native notification ids, paths or caches; ids and dates are stable.
      expect(text, isNot(contains('/data/')));
      expect(text, isNot(contains('C:\\')));
      expect(text, isNot(contains('notificationId')));
      expect(text, contains('"2026-09-29"'));
    });

    test(
      'weights keep their kilograms unrounded and units are a preference only',
      () async {
        final o = await h.open(clock: () => now);
        const odd = 22.679618500000002;
        await o.repo.addSet(
          tuesday,
          'squat',
          const SetEntry(weightKg: odd, reps: 5),
        );
        await o.repo.saveProfile(const UserProfile(unit: WeightUnit.lb));
        final restored = codec().decode(
          bytes(BackupCodec.encode(o.repo.snapshot, createdAt: now, schema: 6)),
        );
        expect(
          restored
              .snapshot
              .sessions['2026-09-29']!
              .exercises
              .first
              .sets
              .single
              .weightKg,
          odd,
        );
        expect(restored.snapshot.profile.unit, WeightUnit.lb);
      },
    );

    test(
      'a file written with another key order or indentation is still valid',
      () async {
        final o = await richDatabase(h);
        final text = BackupCodec.encode(
          o.repo.snapshot,
          createdAt: now,
          schema: 6,
        );
        final compact = jsonEncode(canonicalSorted(parse(text)));
        final preview = codec().decode(bytes(compact));
        expect(sameSnapshotContent(preview.snapshot, o.repo.snapshot), isTrue);
      },
    );

    test('an empty database exports and imports', () async {
      final o = await h.open(clock: () => now);
      final preview = codec().decode(
        bytes(BackupCodec.encode(o.repo.snapshot, createdAt: now, schema: 6)),
      );
      expect(sameSnapshotContent(preview.snapshot, AppSnapshot()), isTrue);
      expect(preview.counts.values.every((n) => n == 0), isTrue);
    });
  });

  group('backup refusals (F13)', () {
    late StoreHarness h;
    late String good;
    setUp(() async {
      h = await StoreHarness.create();
      final o = await richDatabase(h);
      good = BackupCodec.encode(o.repo.snapshot, createdAt: now, schema: 6);
    });
    tearDown(() => h.dispose());

    BackupFailure refuse(Uint8List data) {
      try {
        codec().decode(data);
      } on BackupFailure catch (e) {
        return e;
      }
      fail('The file was accepted.');
    }

    BackupProblem problem(String text) => refuse(bytes(text)).problem;

    test('text that is not JSON, or not a FORJA file', () {
      expect(problem('esto no es json'), BackupProblem.corrupt);
      expect(problem(''), BackupProblem.corrupt);
      expect(problem('{"a":'), BackupProblem.corrupt);
      expect(
        refuse(Uint8List.fromList([0xff, 0xfe, 0xfd])).problem,
        BackupProblem.corrupt,
      );
      expect(problem('[1,2,3]'), BackupProblem.notABackup);
      expect(problem('{"format":"otra"}'), BackupProblem.notABackup);
      // The 0.1 prototype snapshot is not a backup.
      expect(
        problem('{"schemaVersion":1,"profile":{}}'),
        BackupProblem.notABackup,
      );
    });

    test(
      'a newer version is refused with an update message; invalid versions too',
      () {
        final f = parse(good)..['version'] = backupVersion + 1;
        final e = refuse(bytes(jsonEncode(f)));
        expect(e.problem, BackupProblem.futureVersion);
        expect(e.message, contains('Actualiza'));
        expect(
          problem(jsonEncode(parse(good)..['version'] = 0)),
          BackupProblem.invalid,
        );
        expect(
          problem(jsonEncode(parse(good)..['version'] = '1')),
          BackupProblem.invalid,
        );
      },
    );

    test('too large is refused before parsing', () {
      final huge = Uint8List(backupMaxBytes + 1);
      expect(refuse(huge).problem, BackupProblem.tooLarge);
      // Exactly the limit is read (and then fails as corrupt, not as large).
      expect(
        refuse(Uint8List(backupMaxBytes)).problem,
        isNot(BackupProblem.tooLarge),
      );
    });

    test('any edit to the content is caught by the checksum', () {
      final f = parse(good);
      (f['data'] as Map)['profile']['age'] = 99;
      final e = refuse(bytes(jsonEncode(f)));
      expect(e.problem, BackupProblem.checksum);
      expect(e.message, contains('No se importó nada'));
      // A single changed character in the raw text.
      final tampered = good.replaceFirst('Avena', 'Avenb');
      expect(problem(tampered), BackupProblem.checksum);
      // Changed counts, changed checksum, missing checksum.
      final c = parse(good);
      (c['counts'] as Map)['sessions'] = 99;
      expect(refuse(bytes(jsonEncode(c))).problem, BackupProblem.checksum);
      final k = parse(good);
      (k['checksum'] as Map)['value'] = 'a' * 64;
      expect(refuse(bytes(jsonEncode(k))).problem, BackupProblem.checksum);
      final m = parse(good)..remove('checksum');
      expect(refuse(bytes(jsonEncode(m))).problem, BackupProblem.invalid);
    });

    // From here the checksum is valid, so the structure checks are reached.
    void expectInvalid(
      String name,
      void Function(Map<String, dynamic> data) edit, {
      String? path,
    }) {
      test('structure: $name', () {
        final f = parse(good);
        edit(f['data'] as Map<String, dynamic>);
        final e = refuse(bytes(resign(f)));
        expect(e.problem, BackupProblem.invalid, reason: name);
        expect(e.message, contains('No se importó nada'));
        if (path != null) {
          expect(e.issues.single, contains(path), reason: e.issues.join());
        }
      });
    }

    expectInvalid(
      'a collection is missing',
      (d) => d.remove('sessions'),
      path: r'$.data.sessions',
    );
    expectInvalid(
      'a number where a list belongs',
      (d) => d['food'] = 5,
      path: r'$.data.food',
    );
    expectInvalid(
      'an unknown enum value',
      (d) => d['cardio'][0]['activity'] = 'nadar',
      path: 'activity',
    );
    expectInvalid(
      'an impossible date',
      (d) => d['food'][0]['dateKey'] = '2026-02-31',
      path: 'dateKey',
    );
    expectInvalid(
      'a malformed date',
      (d) => d['food'][0]['dateKey'] = 'hoy',
      path: 'dateKey',
    );
    expectInvalid('a session whose key differs from its date', (d) {
      final s = d['sessions'] as Map<String, dynamic>;
      s['2026-09-29']['dateKey'] = '2026-09-30';
    }, path: 'dateKey');
    expectInvalid('an unknown exercise', (d) {
      (d['sessions'] as Map)['2026-09-29']['exercises'][0]['exerciseId'] =
          'inventado';
    }, path: 'exerciseId');
    expectInvalid('a repeated exercise in a session', (d) {
      final list = (d['sessions'] as Map)['2026-09-29']['exercises'] as List;
      list[1]['exerciseId'] = list[0]['exerciseId'];
    }, path: 'exerciseId');
    expectInvalid('a repeated set id', (d) {
      final sets =
          (d['sessions'] as Map)['2026-09-29']['exercises'][0]['sets'] as List;
      sets[1]['id'] = sets[0]['id'];
    }, path: 'id');
    expectInvalid('reps out of range', (d) {
      (d['sessions'] as Map)['2026-09-29']['exercises'][0]['sets'][0]['reps'] =
          5000;
    }, path: 'reps');
    expectInvalid('RIR out of range', (d) {
      (d['sessions'] as Map)['2026-09-29']['exercises'][0]['sets'][0]['rir'] =
          11;
    }, path: 'rir');
    expectInvalid('a negative weight', (d) {
      (d['sessions']
              as Map)['2026-09-29']['exercises'][0]['sets'][0]['weightKg'] =
          -3;
    }, path: 'weightKg');
    expectInvalid(
      'calories out of range',
      (d) => d['food'][0]['calories'] = 99999,
      path: 'calories',
    );
    expectInvalid('a repeated food id', (d) {
      final food = d['food'] as List;
      food.add(Map<String, dynamic>.from(food[0] as Map));
    }, path: 'id');
    expectInvalid('macros that do not add up to the stated calories', (d) {
      d['food'][0]['caloriesSource'] = 'macros';
    }, path: 'calories');
    expectInvalid(
      'a body weight out of range',
      (d) => d['profile']['weightKg'] = 5,
      path: 'profile',
    );
    expectInvalid(
      'a wrong-typed profile field',
      (d) => d['profile']['onboarded'] = 'sí',
      path: 'profile',
    );
    expectInvalid(
      'a reminder hour out of range',
      (d) => d['reminder']['hour'] = 30,
      path: 'hour',
    );
    expectInvalid('a move that goes backwards in time', (d) {
      final m = (d['reschedules'] as List)[0] as Map;
      m['targetDate'] = '2020-01-01';
    }, path: 'reschedules');
    expectInvalid('two active cardio sessions', (d) {
      final c = d['cardio'] as List;
      final copy = jsonDecode(jsonEncode(c[0])) as Map<String, dynamic>;
      copy['id'] = 'otra';
      copy['status'] = 'active';
      (copy['segments'] as List)[0]['id'] = 'seg-nuevo';
      (copy['segments'] as List)[0]['endedAt'] = null;
      (c[0] as Map)['status'] = 'active';
      (c[0] as Map)['segments'][(c[0] as Map)['segments'].length -
              1]['endedAt'] =
          null;
      c.add(copy);
    }, path: 'cardio');
    expectInvalid(
      'a recipe with no ingredients',
      (d) => d['recipes'][0]['ingredients'] = [],
      path: 'ingredients',
    );
    expectInvalid(
      'a recipe with zero servings',
      (d) => d['recipes'][0]['servings'] = 0,
      path: 'servings',
    );
    expectInvalid(
      'a goal out of range',
      (d) => d['goals']['kcal'] = 50,
      path: 'kcal',
    );
    expectInvalid('a repeated progression decision', (d) {
      final list = d['progressionDecisions'] as List;
      final copy = Map<String, dynamic>.from(list[0] as Map)..['id'] = 'otro';
      list.add(copy);
    }, path: 'basedOn');

    test('counts that do not match the content are refused', () {
      final f = parse(good);
      (f['counts'] as Map)['food'] = 7;
      final e = refuse(bytes(resign(f)));
      expect(e.problem, BackupProblem.invalid);
      expect(e.issues.single, contains('counts.food'));
    });

    test('refusals never repeat what the person wrote', () {
      final f = parse(good);
      ((f['data'] as Map)['sessions']
              as Map)['2026-09-29']['exercises'][0]['exerciseId'] =
          'inventado';
      final e = refuse(bytes(resign(f)));
      final all = '${e.message} ${e.issues.join(' ')}';
      for (final secret in [
        'Hombro izquierdo sensible',
        'inventado',
        'Avena',
        'sin barra',
      ]) {
        expect(all, isNot(contains(secret)));
      }
    });
  });

  group('restoring into SQLite (F13)', () {
    late StoreHarness h;
    setUp(() async => h = await StoreHarness.create());
    tearDown(() => h.dispose());

    test(
      'replace swaps everything, survives a restart and leaves nothing behind',
      () async {
        final source = await StoreHarness.create();
        addTearDown(source.dispose);
        final from = await richDatabase(source, note: 'nota del teléfono A');
        final snapshot = from.repo.snapshot;
        // The target phone has different data.
        final target = await h.open(clock: () => now);
        await target.repo.addFood(
          FoodEntry(
            id: 'otro',
            dateKey: '2026-09-30',
            name: 'Pan',
            calories: 90,
          ),
        );
        await target.repo.addSet(
          DateTime(2026, 10, 1),
          'bench',
          const SetEntry(reps: 9),
        );
        await target.repo.replaceAll(snapshot);
        expect(sameSnapshotContent(target.repo.snapshot, snapshot), isTrue);
        await target.close();
        final reopened = await h.open(clock: () => now);
        expect(
          sameSnapshotContent(reopened.repo.snapshot, snapshot),
          isTrue,
          reason: firstDifference(
            reopened.repo.snapshot.toJson(),
            snapshot.toJson(),
          ),
        );
        expect(
          reopened.repo.foodOn(DateTime(2026, 9, 30)),
          isEmpty,
          reason: 'old food is gone',
        );
        expect(await reopened.counts(), await from.counts());
        expect(
          await reopened.db.customSelect('PRAGMA foreign_key_check').get(),
          isEmpty,
        );
        expect(
          (await reopened.db.customSelect('PRAGMA integrity_check').getSingle())
              .read<String>('integrity_check'),
          'ok',
        );
      },
    );

    test(
      'a failure in the middle leaves the old data exactly as it was',
      () async {
        final source = await StoreHarness.create();
        addTearDown(source.dispose);
        final snapshot = (await richDatabase(source)).repo.snapshot;
        final target = await h.open(clock: () => now);
        await target.repo.addFood(
          FoodEntry(id: 'a', dateKey: '2026-09-30', name: 'Pan', calories: 90),
        );
        await target.repo.saveGoals(const NutritionGoals(kcal: 1800));
        final before = target.repo.snapshot;
        final counts = await target.counts();
        for (final failing in [
          'recipe_ingredients',
          'cardio_segments',
          'set_logs',
          'food_entries',
        ]) {
          h.fault.arm(
            (sql) => sql.startsWith('INSERT') && sql.contains(failing),
          );
          await expectLater(
            target.repo.replaceAll(snapshot),
            throwsInjected,
            reason: failing,
          );
          h.fault.disarm();
          expect(
            identical(target.repo.snapshot, before),
            isTrue,
            reason: 'memory unchanged: $failing',
          );
          expect(
            await target.counts(),
            counts,
            reason: 'rows unchanged: $failing',
          );
        }
        // A failing commit at the very end rolls back too.
        h.fault.failCommit = true;
        await expectLater(target.repo.replaceAll(snapshot), throwsInjected);
        h.fault.disarm();
        expect(await target.counts(), counts);
        await target.close();
        final reopened = await h.open(clock: () => now);
        expect(sameSnapshotContent(reopened.repo.snapshot, before), isTrue);
        // And it still works afterwards.
        await reopened.repo.replaceAll(snapshot);
        expect(sameSnapshotContent(reopened.repo.snapshot, snapshot), isTrue);
      },
    );

    test('a full disk during the replacement changes nothing', () async {
      // A snapshot far bigger than the space the file may grow to.
      final big = AppSnapshot(
        food: [
          for (var i = 0; i < 600; i++)
            FoodEntry(
              id: 'b$i',
              dateKey: '2026-09-30',
              name: 'x' * 80,
              calories: 1,
            ),
        ],
      );
      final target = await h.open(clock: () => now);
      await target.repo.addFood(
        FoodEntry(id: 'a', dateKey: '2026-09-30', name: 'Pan', calories: 90),
      );
      final pages =
          (await target.db.customSelect('PRAGMA page_count').getSingle())
              .read<int>('page_count');
      await target.db.customStatement('PRAGMA max_page_count = $pages');
      final before = target.repo.snapshot;
      await expectLater(target.repo.replaceAll(big), throwsA(anything));
      expect(identical(target.repo.snapshot, before), isTrue);
      await target.db.customStatement('PRAGMA max_page_count = 1000000');
      expect(target.repo.foodOn(DateTime(2026, 9, 30)).single.id, 'a');
      await target.close();
      final reopened = await h.open(clock: () => now);
      expect(reopened.repo.foodOn(DateTime(2026, 9, 30)).single.id, 'a');
    });

    test('writes queued before a restore finish first, and later ones apply on top', () async {
      final source = await StoreHarness.create();
      addTearDown(source.dispose);
      final snapshot = (await richDatabase(source)).repo.snapshot;
      final target = await h.open(clock: () => now);
      final early = target.repo.addFood(
        FoodEntry(id: 'early', dateKey: '2026-09-30', name: 'A', calories: 1),
      );
      final restore = target.repo.replaceAll(snapshot);
      final late = target.repo.addFood(
        FoodEntry(id: 'late', dateKey: '2026-09-30', name: 'B', calories: 2),
      );
      await Future.wait([early, restore, late]);
      final ids = target.repo
          .foodOn(DateTime(2026, 9, 30))
          .map((e) => e.id)
          .toList();
      expect(ids, [
        'late',
      ], reason: 'the restore removed "early"; "late" came after it');
      await target.close();
      final reopened = await h.open(clock: () => now);
      expect(reopened.repo.foodOn(DateTime(2026, 9, 30)).map((e) => e.id), [
        'late',
      ]);
    });

    test(
      'deleting everything empties every table but keeps the 0.1 import marker',
      () async {
        final o = await richDatabase(h);
        await o.store.markLegacy(
          'forja_flutter_snapshot_v1',
          LegacyImportStatus.imported,
        );
        await o.repo.replaceAll(AppSnapshot());
        final counts = await o.counts();
        for (final e in counts.entries) {
          if (e.key == 'legacy_imports') {
            expect(
              e.value,
              1,
              reason: 'the marker stays so 0.1 data is not imported again',
            );
          } else if (e.key == 'profiles' || e.key == 'reminders') {
            expect(e.value, lessThanOrEqualTo(1), reason: e.key);
          } else {
            expect(e.value, 0, reason: e.key);
          }
        }
        final reopened = await (() async {
          await o.close();
          return h.open(clock: () => now);
        })();
        expect(
          sameSnapshotContent(reopened.repo.snapshot, AppSnapshot()),
          isTrue,
        );
        expect(reopened.repo.profile.onboarded, isFalse);
      },
    );

    test('a snapshot restored from a file is the same one a second database stores', () async {
      // Round trip across "two phones": export from one, import into another.
      final source = await StoreHarness.create();
      addTearDown(source.dispose);
      final a = await richDatabase(source);
      final text = BackupCodec.encode(
        a.repo.snapshot,
        createdAt: now,
        schema: 6,
      );
      final b = await h.open(clock: () => now);
      await b.repo.replaceAll(codec().decode(bytes(text)).snapshot);
      final again = BackupCodec.encode(
        b.repo.snapshot,
        createdAt: now,
        schema: 6,
      );
      expect(parse(again)['data'], parse(text)['data']);
      expect(
        (parse(again)['checksum'] as Map)['value'],
        (parse(text)['checksum'] as Map)['value'],
      );
    });
  });

  group('backup service (F13)', () {
    late StoreHarness h;
    late Opened o;
    late FakeBackupFiles files;
    late MemoryVault vault;
    late BackupService service;
    setUp(() async {
      h = await StoreHarness.create();
      o = await richDatabase(h);
      files = FakeBackupFiles();
      vault = MemoryVault();
      service = BackupService(
        repository: o.repo,
        codec: codec(),
        vault: vault,
        files: files,
        schema: 6,
        clock: () => now,
      );
    });
    tearDown(() => h.dispose());

    test('export writes one valid file where the person chose, named with the date', () async {
      expect(await service.exportCopy(), isTrue);
      final (name, data) = files.saved.single;
      // The person's own clock, not UTC: a copy made in the evening must not
      // carry tomorrow's date (seen on a phone at UTC-6, 18:15 → "…1002-0015").
      final l = now.toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      expect(
        name,
        'forja-respaldo-${l.year}${two(l.month)}${two(l.day)}-'
        '${two(l.hour)}${two(l.minute)}.json',
      );
      final preview = codec().decode(data);
      expect(sameSnapshotContent(preview.snapshot, o.repo.snapshot), isTrue);
    });

    test('cancelling the destination exports nothing', () async {
      files.cancelSave = true;
      expect(await service.exportCopy(), isFalse);
      expect(files.saved, isEmpty);
      expect(vault.files, isEmpty);
    });

    test('importing saves a safety copy first, then replaces', () async {
      final other = await StoreHarness.create();
      addTearDown(other.dispose);
      final src = await other.open(clock: () => now);
      await src.repo.addFood(
        FoodEntry(id: 'z', dateKey: '2026-09-30', name: 'Pan', calories: 90),
      );
      files.next = PickedBackup(
        'copia.json',
        bytes(BackupCodec.encode(src.repo.snapshot, createdAt: now, schema: 6)),
      );
      final before = o.repo.snapshot;
      final picked = (await service.pick())!;
      final preview = service.preview(picked);
      expect(preview.counts['food'], 1);
      // Preview changed nothing.
      expect(identical(o.repo.snapshot, before), isTrue);
      final name = await service.replaceWith(preview);
      expect(name, 'forja-previo-20261001-153000.json');
      expect(sameSnapshotContent(o.repo.snapshot, src.repo.snapshot), isTrue);
      // The safety copy holds what was there before and can be restored.
      final safety = codec().decode(bytes(vault.files[name]!));
      expect(sameSnapshotContent(safety.snapshot, before), isTrue);
      await o.repo.replaceAll(safety.snapshot);
      expect(sameSnapshotContent(o.repo.snapshot, before), isTrue);
    });

    test('if the safety copy cannot be saved, nothing is replaced', () async {
      vault.failSave = true;
      final other = AppSnapshot(
        food: [
          FoodEntry(id: 'z', dateKey: '2026-09-30', name: 'Pan', calories: 90),
        ],
      );
      final preview = codec().decode(
        bytes(BackupCodec.encode(other, createdAt: now, schema: 6)),
      );
      final before = o.repo.snapshot;
      await expectLater(
        service.replaceWith(preview),
        throwsA(
          isA<BackupFailure>().having(
            (e) => e.message,
            'message',
            contains('respaldo previo'),
          ),
        ),
      );
      expect(identical(o.repo.snapshot, before), isTrue);
    });

    test(
      'a failure after the preview leaves the data and keeps the safety copy',
      () async {
        final preview = codec().decode(
          bytes(BackupCodec.encode(AppSnapshot(), createdAt: now, schema: 6)),
        );
        final before = o.repo.snapshot;
        h.fault.arm((sql) => sql.startsWith('DELETE FROM profiles'));
        await expectLater(service.replaceWith(preview), throwsInjected);
        h.fault.disarm();
        expect(identical(o.repo.snapshot, before), isTrue);
        expect(vault.files, hasLength(1));
        // The same preview can be applied after the problem is gone.
        await service.replaceWith(preview);
        expect(sameSnapshotContent(o.repo.snapshot, AppSnapshot()), isTrue);
      },
    );

    test('a file over the limit never reaches the parser', () async {
      files.pickError = const BackupFailure(BackupProblem.tooLarge, 'grande');
      await expectLater(service.pick(), throwsA(isA<BackupFailure>()));
    });

    test('deleting everything clears the data and the safety copies', () async {
      await vault.save('forja-previo-20260101-000000.json', '{}');
      await service.deleteEverything();
      expect(sameSnapshotContent(o.repo.snapshot, AppSnapshot()), isTrue);
      expect(vault.files, isEmpty);
      await o.close();
      final reopened = await h.open(clock: () => now);
      expect(reopened.repo.profile.onboarded, isFalse);
      expect(reopened.repo.foodOn(DateTime(2026, 9, 29)), isEmpty);
    });
  });

  group('private safety copies (F13)', () {
    late Directory dir;
    setUp(
      () async => dir = await Directory.systemTemp.createTemp('forja_vault_'),
    );
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test(
      'copies are written atomically, only the last three are kept',
      () async {
        final vault = FileBackupVault(directory: dir);
        for (var i = 1; i <= 5; i++) {
          final path = await vault.save(
            'forja-previo-2026100$i-120000.json',
            '{"n":$i}',
          );
          expect(await File(path).readAsString(), '{"n":$i}');
        }
        expect(await vault.names(), [
          'forja-previo-20261003-120000.json',
          'forja-previo-20261004-120000.json',
          'forja-previo-20261005-120000.json',
        ]);
        expect(
          dir.listSync().whereType<File>().any((f) => f.path.endsWith('.tmp')),
          isFalse,
        );
      },
    );

    test('only files of its own shape are ever touched', () async {
      final vault = FileBackupVault(directory: dir);
      final foreign = File('${dir.path}/notas-importantes.json')
        ..writeAsStringSync('mío');
      final lookalike = File('${dir.path}/forja-previo-x.json')
        ..writeAsStringSync('mío');
      for (var i = 1; i <= 5; i++) {
        await vault.save('forja-previo-2026100$i-120000.json', '{}');
      }
      await vault.deleteAll();
      expect(await vault.names(), isEmpty);
      expect(foreign.existsSync(), isTrue);
      expect(lookalike.existsSync(), isTrue);
    });

    test('names that could escape the folder are refused', () async {
      final vault = FileBackupVault(directory: dir);
      for (final bad in [
        '../x.json',
        'forja-previo-1.json',
        'a/forja-previo-20261001-120000.json',
        '',
      ]) {
        await expectLater(
          vault.save(bad, '{}'),
          throwsArgumentError,
          reason: bad,
        );
      }
      expect(dir.listSync(), isEmpty);
    });
  });

  group('data screen (F13)', () {
    late FakeBackupFiles files;
    late MemoryVault vault;
    late FakeNotificationService notifications;

    Future<AppDependencies> start(
      WidgetTester tester, {
      double width = 390,
      double scale = 1,
      bool withData = true,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 3200);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      files = FakeBackupFiles();
      vault = MemoryVault();
      notifications = FakeNotificationService();
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 9, 30, 12),
        notifications: notifications,
        backupFiles: files,
        backupVault: vault,
      );
      addTearDown(() => unawaited(d.dispose()));
      if (withData) {
        await d.repository.saveProfile(
          const UserProfile(onboarded: true, weightKg: 70),
          record: ProfileChange.edit,
        );
        await d.repository.saveReminder(
          const ReminderSettings(enabled: true, hour: 7),
        );
        await d.repository.addFood(
          FoodEntry(
            id: 'f',
            dateKey: '2026-09-30',
            name: 'Avena',
            calories: 300,
          ),
        );
        await d.repository.addSet(tuesday, 'squat', const SetEntry(reps: 5));
      }
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 3200),
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Datos y privacidad'));
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('the privacy text says what stays and what does not', (
      tester,
    ) async {
      await start(tester);
      expect(find.textContaining('no envía nada por Internet'), findsOneWidget);
      expect(find.textContaining('no está cifrada'), findsOneWidget);
      expect(
        find.textContaining('el código de comprobación detecta daños'),
        findsOneWidget,
      );
    });

    testWidgets('export warns first and then saves where the person picks', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.byKey(const ValueKey('export-copy')));
      await tester.pumpAndSettle();
      expect(find.textContaining('sin cifrar'), findsOneWidget);
      expect(files.saved, isEmpty, reason: 'nothing before the person agrees');
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(files.saved, isEmpty);
      await tester.tap(find.byKey(const ValueKey('export-copy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('export-continue')));
      await tester.pumpAndSettle();
      expect(files.saved, hasLength(1));
      expect(find.text('Copia guardada'), findsOneWidget);
      // Written inside the panel too: on a phone the snackbar sits under the
      // open sheet, so this is what the person actually sees.
      expect(find.byKey(const ValueKey('export-notice')), findsOneWidget);
      expect(find.textContaining('se guardó en el destino'), findsOneWidget);
    });

    testWidgets('cancelling the destination says so and saves nothing', (
      tester,
    ) async {
      await start(tester);
      files.cancelSave = true;
      await tester.tap(find.byKey(const ValueKey('export-copy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('export-continue')));
      await tester.pumpAndSettle();
      expect(files.saved, isEmpty);
      expect(find.text('Exportación cancelada'), findsOneWidget);
    });

    testWidgets(
      'import: pick, see the preview, confirm, and the data is replaced',
      (tester) async {
        final d = await start(tester);
        final other = AppSnapshot(
          profile: const UserProfile(onboarded: true, weightKg: 88),
          food: [
            FoodEntry(
              id: 'n1',
              dateKey: '2026-09-29',
              name: 'Tacos',
              calories: 450,
            ),
            FoodEntry(id: 'n2', dateKey: '2026-09-29', name: 'Té', calories: 2),
          ],
        );
        files.next = PickedBackup(
          'mi-copia.json',
          bytes(BackupCodec.encode(other, createdAt: now, schema: 6)),
        );
        await tester.tap(find.byKey(const ValueKey('import-copy')));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('import-preview')), findsOneWidget);
        expect(find.text('mi-copia.json'), findsOneWidget);
        expect(find.text('2 alimentos'), findsOneWidget);
        expect(
          find.textContaining('Se reemplazarán TODOS tus datos actuales'),
          findsOneWidget,
        );
        // Still nothing replaced.
        expect(d.repository.profile.weightKg, 70);
        await tester.tap(find.byKey(const ValueKey('import-confirm')));
        await tester.pumpAndSettle();
        expect(d.repository.profile.weightKg, 88);
        expect(d.repository.foodOn(DateTime(2026, 9, 29)).map((e) => e.name), [
          'Tacos',
          'Té',
        ]);
        expect(
          vault.files,
          hasLength(1),
          reason: 'the previous data was saved first',
        );
        expect(find.byKey(const ValueKey('import-preview')), findsNothing);
        // The result is written in the panel (the snackbar is under the sheet).
        expect(find.byKey(const ValueKey('import-notice')), findsOneWidget);
        expect(find.textContaining('se reemplazaron'), findsOneWidget);
        // The imported reminder setting is "off"; the old schedule is cancelled.
        await tester.pump();
        expect(notifications.scheduled, isEmpty);
      },
    );

    testWidgets('the preview counts in the singular when there is one', (
      tester,
    ) async {
      await start(tester);
      final one = AppSnapshot(
        profile: const UserProfile(onboarded: true, weightKg: 88),
        food: [
          FoodEntry(id: 'n1', dateKey: '2026-09-29', name: 'Té', calories: 2),
        ],
      );
      files.next = PickedBackup(
        'uno.json',
        bytes(BackupCodec.encode(one, createdAt: now, schema: 6)),
      );
      await tester.tap(find.byKey(const ValueKey('import-copy')));
      await tester.pumpAndSettle();
      expect(find.text('1 alimento'), findsOneWidget);
      expect(find.text('1 alimentos'), findsNothing);
    });

    testWidgets('cancelling at the preview keeps everything', (tester) async {
      final d = await start(tester);
      files.next = PickedBackup(
        'c.json',
        bytes(BackupCodec.encode(AppSnapshot(), createdAt: now, schema: 6)),
      );
      await tester.tap(find.byKey(const ValueKey('import-copy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('import-cancel')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('import-preview')), findsNothing);
      expect(d.repository.profile.onboarded, isTrue);
      expect(vault.files, isEmpty);
    });

    testWidgets(
      'a damaged file is refused with a clear message and changes nothing',
      (tester) async {
        final d = await start(tester);
        final text = BackupCodec.encode(
          AppSnapshot(),
          createdAt: now,
          schema: 6,
        );
        files.next = PickedBackup(
          'roto.json',
          bytes(text.replaceFirst('"counts"', '"counts" ')..toString()),
        );
        // Edit the content so the checksum no longer matches.
        final f = parse(text);
        (f['data'] as Map)['profile']['age'] = 40;
        files.next = PickedBackup('roto.json', bytes(jsonEncode(f)));
        await tester.tap(find.byKey(const ValueKey('import-copy')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('comprobación de integridad'),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('import-confirm')), findsNothing);
        expect(d.repository.profile.weightKg, 70);
        expect(vault.files, isEmpty);
      },
    );

    testWidgets(
      'files that are not backups, are newer or not JSON are refused',
      (tester) async {
        await start(tester);
        for (final (text, expected) in [
          ('hola', 'dañado'),
          ('{"format":"x"}', 'no es una copia de seguridad'),
          ('{"format":"forja-backup","version":9}', 'más nueva'),
        ]) {
          files.next = PickedBackup('x.json', bytes(text));
          await tester.tap(find.byKey(const ValueKey('import-copy')));
          await tester.pumpAndSettle();
          expect(find.textContaining(expected), findsOneWidget, reason: text);
        }
      },
    );

    testWidgets('picking a file and cancelling the dialog does nothing', (
      tester,
    ) async {
      await start(tester);
      files.next = null;
      await tester.tap(find.byKey(const ValueKey('import-copy')));
      await tester.pumpAndSettle();
      expect(files.picks, 1);
      expect(find.byKey(const ValueKey('import-preview')), findsNothing);
      expect(find.byKey(const ValueKey('import-refusal')), findsNothing);
    });

    testWidgets(
      'delete needs the typed word, then clears data, reminders and copies, and starts over',
      (tester) async {
        final d = await start(tester);
        await d.reminders.start();
        await d.reminders.reconcile();
        expect(notifications.scheduled, isNotEmpty);
        await vault.save('forja-previo-20260101-000000.json', '{}');
        await tester.tap(find.byKey(const ValueKey('delete-all')));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('delete-confirm')),
              )
              .onPressed,
          isNull,
        );
        await tester.enterText(
          find.byKey(const ValueKey('delete-confirm-text')),
          'borrar',
        );
        await tester.pump();
        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('delete-confirm')),
              )
              .onPressed,
          isNull,
        );
        await tester.enterText(
          find.byKey(const ValueKey('delete-confirm-text')),
          'BORRAR',
        );
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('delete-confirm')));
        await tester.pumpAndSettle();
        expect(
          sameSnapshotContent(d.repository.snapshot, AppSnapshot()),
          isTrue,
        );
        expect(vault.files, isEmpty);
        expect(
          notifications.scheduled,
          isEmpty,
          reason: 'real jobs were cancelled',
        );
        // Back to first run: the onboarding opens.
        expect(d.coach.needsOnboarding, isTrue);
        // The first-run sheet is open on top of the app.
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(find.byKey(const ValueKey('delete-confirm')), findsNothing);
      },
    );

    testWidgets('cancelling the delete dialog keeps the data', (tester) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('delete-all')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(d.repository.profile.onboarded, isTrue);
      expect(d.repository.foodOn(DateTime(2026, 9, 30)), isNotEmpty);
    });

    testWidgets('the screen fits 320 px at 200% text, with a preview open', (
      tester,
    ) async {
      await start(tester, width: 320, scale: 2);
      expect(tester.takeException(), isNull);
      files.next = PickedBackup(
        'c.json',
        bytes(
          BackupCodec.encode(
            AppSnapshot(
              food: [
                FoodEntry(
                  id: 'n1',
                  dateKey: '2026-09-29',
                  name: 'Tacos',
                  calories: 450,
                ),
              ],
            ),
            createdAt: now,
            schema: 6,
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('import-copy')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('import-preview')), findsOneWidget);
    });
  });
}

/// The same JSON with keys in sorted order (a different layout of the file).
Object? canonicalSorted(Object? v) => switch (v) {
  Map() => {
    for (final k in (v.keys.cast<String>().toList()..sort()))
      k: canonicalSorted(v[k]),
  },
  List() => v.map(canonicalSorted).toList(),
  _ => v,
};

String firstDifference(Object? a, Object? b, [String path = r'$']) {
  if (a is Map && b is Map) {
    for (final key in {...a.keys, ...b.keys}) {
      final d = firstDifference(a[key], b[key], '$path.$key');
      if (d.isNotEmpty) return d;
    }
    return '';
  }
  if (a is List && b is List) {
    for (var i = 0; i < (a.length > b.length ? a.length : b.length); i++) {
      final d = firstDifference(
        i < a.length ? a[i] : '<none>',
        i < b.length ? b[i] : '<none>',
        '$path[$i]',
      );
      if (d.isNotEmpty) return d;
    }
    return '';
  }
  return a == b ? '' : '$path: $a vs $b';
}
