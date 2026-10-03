import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/backup/backup_codec.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/snapshot_diff.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'support/sqlite_harness.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

BackupCodec _codec() {
  final known = {for (final e in exerciseCatalog) e.id};
  return BackupCodec(isKnownExercise: known.contains);
}

Uint8List _bytes(String text) => Uint8List.fromList(utf8.encode(text));

String _resign(Map<String, dynamic> file) {
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

/// The same file written as a version 1 backup would have been: no coach
/// sections, no source on favorites.
String _asVersion1(String v2) {
  final file = jsonDecode(v2) as Map<String, dynamic>;
  file['version'] = 1;
  final data = file['data'] as Map<String, dynamic>;
  data.remove('coachDecisions');
  data.remove('coachPreferences');
  for (final f in data['favorites'] as List) {
    (f as Map).remove('caloriesSource');
  }
  final counts = file['counts'] as Map<String, dynamic>;
  counts.remove('coachDecisions');
  counts.remove('coachPreferences');
  return _resign(file);
}

const _estimate = FoodEntry(
  id: 'e1',
  dateKey: '2026-10-01',
  name: 'Tacos al pastor',
  calories: 540,
  proteinG: 28,
  caloriesSource: CaloriesSource.estimated,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 10, 1, 15);

  group('coach decisions (F16, D40)', () {
    late StoreHarness h;
    setUp(() async => h = await StoreHarness.create());
    tearDown(() => h.dispose());

    test('accepting is final; "Ahora no" can repeat; unknown rules are '
        'refused', () async {
      final o = await h.open(clock: () => now);
      final r = o.repo;
      Future<void> decide(
        CoachDecisionStatus status, {
        String ruleId = 'progression.prog',
      }) => r.decideCoach(
        ruleId: ruleId,
        subject: 'squat',
        anchor: '2026-09-29',
        kbVersion: 'expert-v1',
        status: status,
        summary: 'Sentadilla: subir la carga',
      );
      await decide(CoachDecisionStatus.dismissed);
      await decide(CoachDecisionStatus.dismissed);
      await decide(CoachDecisionStatus.accepted);
      await decide(CoachDecisionStatus.accepted);
      await decide(CoachDecisionStatus.dismissed);
      expect(r.coachDecisions.map((d) => d.status), [
        CoachDecisionStatus.dismissed,
        CoachDecisionStatus.dismissed,
        CoachDecisionStatus.accepted,
      ]);
      expect(
        r.coachDecisions.first.recKey,
        'progression.prog|squat|2026-09-29',
      );
      await expectLater(
        decide(CoachDecisionStatus.accepted, ruleId: 'nope.nope'),
        throwsArgumentError,
      );
      // Two acceptances at once still record one.
      await Future.wait([
        r.decideCoach(
          ruleId: 'plan.low-volume',
          subject: 'volume',
          anchor: 'p',
          kbVersion: 'expert-v1',
          status: CoachDecisionStatus.accepted,
        ),
        r.decideCoach(
          ruleId: 'plan.low-volume',
          subject: 'volume',
          anchor: 'p',
          kbVersion: 'expert-v1',
          status: CoachDecisionStatus.accepted,
        ),
      ]);
      expect(
        r.coachDecisions.where((d) => d.ruleId == 'plan.low-volume'),
        hasLength(1),
      );
      await r.setCoachMuted('nutrition', true);
      await r.setCoachMuted('nutrition', true);
      await r.setCoachMuted('cardio', false);
      await expectLater(r.setCoachMuted('nope', true), throwsArgumentError);
      expect(r.coachPreferences.map((p) => (p.family, p.muted)), [
        ('nutrition', true),
      ]);
      await r.setCoachMuted('nutrition', false);
      expect(r.coachPreferences.single.muted, isFalse);

      // Everything survives closing and reopening the database.
      final before = r.snapshot;
      await o.close();
      final again = await h.open(clock: () => now);
      expect(sameSnapshotContent(again.repo.snapshot, before), isTrue);
      expect(again.repo.coachDecisions, hasLength(4));
    });

    test('the log only grows', () {
      final decision = CoachDecision(
        id: 'a',
        recKey: 'plan.frequency|frequency|p',
        ruleId: 'plan.frequency',
        kbVersion: 'expert-v1',
        subject: 'frequency',
        anchor: 'p',
        status: CoachDecisionStatus.dismissed,
        decidedAt: now,
      );
      final one = AppSnapshot(coachDecisions: [decision]);
      expect(() => diffSnapshots(one, AppSnapshot()), throwsStateError);
      final changes = diffSnapshots(
        AppSnapshot(),
        AppSnapshot(
          coachDecisions: [decision],
          coachPreferences: [
            CoachPreference(family: 'cardio', muted: true, updatedAt: now),
          ],
        ),
      );
      expect(changes.coachDecisions, [decision]);
      expect(changes.coachPreferences, hasLength(1));
      expect(changes.isEmpty, isFalse);
    });

    test('memory and SQLite agree after random coach decisions', () async {
      // Drawn outside the closures that run against each store.
      final random = Random(7);
      final steps = [
        for (var i = 0; i < 40; i++)
          (
            random.nextInt(4),
            ['progression.prog', 'plan.frequency', 'cardio.who-week'][random
                .nextInt(3)],
            'subject${random.nextInt(3)}',
            ['nutrition', 'cardio', 'plan'][random.nextInt(3)],
            random.nextBool(),
          ),
      ];
      final o = await h.open(clock: () => now);
      final memory = await AppDependencies.create(
        store: MemoryForjaStore(),
        clock: () => now,
      );
      for (final repo in [o.repo, memory.repository]) {
        for (final (kind, rule, subject, family, flag) in steps) {
          if (kind < 3) {
            await repo.decideCoach(
              ruleId: rule,
              subject: subject,
              anchor: 'a',
              kbVersion: 'expert-v1',
              status: kind == 0
                  ? CoachDecisionStatus.accepted
                  : CoachDecisionStatus.dismissed,
            );
          } else {
            await repo.setCoachMuted(family, flag);
          }
        }
      }
      String shape(AppSnapshot s) => jsonEncode([
        for (final d in s.coachDecisions) [d.recKey, d.status.name],
        for (final p in s.coachPreferences) [p.family, p.muted],
      ]);
      expect(shape(memory.repository.snapshot), shape(o.repo.snapshot));
      final reopened = await h.open(clock: () => now);
      expect(shape(reopened.repo.snapshot), shape(o.repo.snapshot));
      unawaited(memory.dispose());
    });
  });

  group('backup version 2 (D40)', () {
    late StoreHarness h;
    setUp(() async => h = await StoreHarness.create());
    tearDown(() => h.dispose());

    Future<AppSnapshot> withCoachData(Opened o) async {
      final r = o.repo;
      await r.addFood(_estimate);
      await r.addFavorite(
        const FavoriteFood(
          id: 'fv',
          name: 'Tacos al pastor',
          calories: 540,
          caloriesSource: CaloriesSource.estimated,
        ),
      );
      await r.addFavorite(
        const FavoriteFood(id: 'fm', name: 'Yogur', calories: 120),
      );
      await r.decideCoach(
        ruleId: 'nutrition.protein-reference',
        subject: 'protein',
        anchor: '80.0',
        kbVersion: 'expert-v1',
        status: CoachDecisionStatus.dismissed,
        summary: 'Referencia general de proteína',
      );
      await r.setCoachMuted('cardio', true);
      return r.snapshot;
    }

    test(
      'estimates, favorites and coach decisions go out and come back',
      () async {
        final o = await h.open(clock: () => now);
        final snapshot = await withCoachData(o);
        final text = BackupCodec.encode(snapshot, createdAt: now, schema: 7);
        final file = jsonDecode(text) as Map<String, dynamic>;
        expect(file['version'], 2);
        expect((file['counts'] as Map)['coachDecisions'], 1);
        expect((file['counts'] as Map)['coachPreferences'], 1);
        final preview = _codec().decode(_bytes(text));
        expect(sameSnapshotContent(preview.snapshot, snapshot), isTrue);
        // Restored into another database, read back the same.
        final other = await StoreHarness.create();
        addTearDown(other.dispose);
        final target = await other.open(clock: () => now);
        await target.repo.replaceAll(preview.snapshot);
        expect(sameSnapshotContent(target.repo.snapshot, snapshot), isTrue);
        await target.close();
        final reopened = await other.open(clock: () => now);
        expect(
          reopened.repo.favorites.first.caloriesSource,
          CaloriesSource.estimated,
        );
        expect(
          reopened.repo.foodOn(DateTime(2026, 10, 1)).single.caloriesSource,
          CaloriesSource.estimated,
        );
        // Deleting everything empties the coach tables too.
        await reopened.repo.replaceAll(AppSnapshot());
        for (final table in ['coach_decisions', 'coach_preferences']) {
          final n = await reopened.db
              .customSelect('SELECT COUNT(*) AS n FROM $table')
              .getSingle();
          expect(n.read<int>('n'), 0, reason: table);
        }
      },
    );

    test('a version 1 file is still read: no coach data, favorites typed by '
        'hand', () async {
      final o = await h.open(clock: () => now);
      final r = o.repo;
      await r.addFavorite(
        const FavoriteFood(id: 'fm', name: 'Yogur', calories: 120),
      );
      await r.addFood(
        const FoodEntry(
          id: 'f',
          dateKey: '2026-10-01',
          name: 'Pan',
          calories: 80,
        ),
      );
      final v1 = _asVersion1(
        BackupCodec.encode(r.snapshot, createdAt: now, schema: 6),
      );
      final preview = _codec().decode(_bytes(v1));
      expect(preview.snapshot.coachDecisions, isEmpty);
      expect(preview.snapshot.coachPreferences, isEmpty);
      expect(
        preview.snapshot.favorites.single.caloriesSource,
        CaloriesSource.manual,
      );
      expect(preview.counts.containsKey('coachDecisions'), isFalse);
      expect(sameSnapshotContent(preview.snapshot, r.snapshot), isTrue);
    });

    test('estimates did not exist in version 1; a broken coach log is '
        'refused', () async {
      final o = await h.open(clock: () => now);
      final snapshot = await withCoachData(o);
      final v2 = BackupCodec.encode(snapshot, createdAt: now, schema: 7);
      BackupProblem problem(String text) {
        try {
          _codec().decode(_bytes(text));
        } on BackupFailure catch (e) {
          return e.problem;
        }
        fail('accepted');
      }

      expect(problem(_asVersion1(v2)), BackupProblem.invalid);

      Map<String, dynamic> edit() => jsonDecode(v2) as Map<String, dynamic>;
      final twice = edit();
      final log = (twice['data'] as Map)['coachDecisions'] as List;
      final accepted = {
        ...(log.single as Map<String, dynamic>),
        'status': 'accepted',
      };
      log
        ..clear()
        ..addAll([
          accepted,
          {...accepted, 'id': 'other'},
        ]);
      (twice['counts'] as Map)['coachDecisions'] = 2;
      expect(problem(_resign(twice)), BackupProblem.invalid);

      final wrongKey = edit();
      ((wrongKey['data'] as Map)['coachDecisions'] as List).single['recKey'] =
          'otra|cosa|x';
      expect(problem(_resign(wrongKey)), BackupProblem.invalid);

      final family = edit();
      ((family['data'] as Map)['coachPreferences'] as List).single['family'] =
          'magia';
      expect(problem(_resign(family)), BackupProblem.invalid);

      final missing = edit();
      (missing['data'] as Map).remove('coachDecisions');
      expect(problem(_resign(missing)), BackupProblem.invalid);

      final future = edit()..['version'] = 3;
      expect(problem(_resign(future)), BackupProblem.futureVersion);
    });
  });

  group('an estimate stays an estimate (D40)', () {
    Future<AppDependencies> start(WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 3000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 10, 1, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.repository.addFood(_estimate);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 3000)),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.nutrition);
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('editing the name keeps it; typing other kcal makes it the '
        'person\'s own', (tester) async {
      final d = await start(tester);
      expect(find.textContaining('kcal estimadas (IA)'), findsOneWidget);
      await tester.tap(find.byTooltip('Editar Tacos al pastor'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Estimadas por el asistente (IA)'),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(const ValueKey('food-name')), 'Tacos');
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      final kept = d.nutrition.entries.single;
      expect(kept.name, 'Tacos');
      expect(kept.caloriesSource, CaloriesSource.estimated);

      await tester.tap(find.byTooltip('Editar Tacos'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-kcal')), '600');
      await tester.pump();
      expect(find.textContaining('Tu número manda'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      final own = d.nutrition.entries.single;
      expect(own.calories, 600);
      expect(own.caloriesSource, CaloriesSource.manual);
    });

    testWidgets('a favorite keeps the source and logging it carries it', (
      tester,
    ) async {
      final d = await start(tester);
      expect(
        await d.nutrition.saveFavorite(d.nutrition.entries.single),
        isTrue,
      );
      final favorite = d.nutrition.favorites.single;
      expect(favorite.caloriesSource, CaloriesSource.estimated);
      expect(await d.nutrition.logFavorite(favorite), isTrue);
      expect(
        d.nutrition.entries.map((e) => e.caloriesSource),
        everyElement(CaloriesSource.estimated),
      );
    });
  });
}
