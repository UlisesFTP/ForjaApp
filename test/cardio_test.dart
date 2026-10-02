import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/cardio_math.dart';
import 'package:forja_app/ui/cardio/view_models/cardio_view_model.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

DateTime t(int h, [int m = 0, int s = 0]) => DateTime.utc(2026, 10, 1, h, m, s);

CardioSegment seg(
  String id,
  DateTime start,
  DateTime? end, {
  CardioIntensity intensity = CardioIntensity.moderate,
  double? kg = 70,
}) => CardioSegment(
  id: id,
  startedAt: start,
  endedAt: end,
  intensity: intensity,
  weightKg: kg,
);

CardioSession session(
  List<CardioSegment> segments, {
  CardioActivity activity = CardioActivity.walk,
}) => CardioSession(
  id: 's',
  activity: activity,
  startedAt: segments.first.startedAt,
  segments: segments,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // The real fonts: the fallback is wider and would hide real layouts.
    await (FontLoader(
      'DM Sans',
    )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
    await (FontLoader('Barlow Condensed')
          ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
        .load();
  });
  group('cardio math (F10)', () {
    test('kcal ≈ MET × kg × hours, from the versioned table', () {
      // Walking, moderate, 70 kg, 30 minutes: 3.5 × 70 × 0.5.
      final s = session([seg('a', t(9, 0), t(9, 30))]);
      expect(CardioMath.kcal(s, t(10, 0)), closeTo(122.5, 1e-9));
      expect(
        CardioMath.met(CardioActivity.walk, CardioIntensity.moderate),
        3.5,
      );
      expect(cardioMetTableVersion, 'met-v1');
    });

    test('every activity has a rising MET for low, moderate and high', () {
      for (final a in CardioActivity.values) {
        final low = CardioMath.met(a, CardioIntensity.low);
        final mid = CardioMath.met(a, CardioIntensity.moderate);
        final high = CardioMath.met(a, CardioIntensity.high);
        expect(low, lessThan(mid));
        expect(mid, lessThan(high));
      }
    });

    test('each segment uses its own intensity and weight', () {
      final s = session([
        seg('a', t(9, 0), t(9, 30), kg: 70),
        seg('b', t(9, 40), t(10, 10), intensity: CardioIntensity.high, kg: 68),
      ]);
      final expected = 3.5 * 70 * .5 + 4.8 * 68 * .5;
      expect(CardioMath.kcal(s, t(11, 0)), closeTo(expected, 1e-9));
    });

    test('an unknown weight gives no estimate, never a guess', () {
      final s = session([
        seg('a', t(9, 0), t(9, 30), kg: 70),
        seg('b', t(9, 40), t(10, 10), kg: null),
      ]);
      expect(CardioMath.kcal(s, t(11, 0)), isNull);
      // A weightless segment with no time does not spoil it.
      final empty = session([
        seg('a', t(9, 0), t(9, 30)),
        seg('b', t(9, 40), t(9, 40), kg: null),
      ]);
      expect(CardioMath.kcal(empty, t(11, 0)), isNotNull);
    });

    test('a running segment counts up to now', () {
      final s = session([seg('a', t(9, 0), null)]);
      expect(s.duration(t(9, 45)), const Duration(minutes: 45));
      expect(CardioMath.kcal(s, t(10, 0)), closeTo(3.5 * 70, 1e-9));
    });

    test('segments never give negative time', () {
      final s = session([seg('a', t(9, 30), t(9, 0))]);
      expect(s.duration(t(10)), Duration.zero);
    });

    test(
      'coherence: clock behind, implausible length, and the normal case',
      () {
        expect(
          CardioMath.coherence(session([seg('a', t(9), t(10))]), t(11)),
          CardioCoherence.ok,
        );
        expect(
          CardioMath.coherence(session([seg('a', t(9, 30), t(9))]), t(11)),
          CardioCoherence.clockBehind,
        );
        // Started "in the future": the clock was set back.
        expect(
          CardioMath.coherence(session([seg('a', t(12), null)]), t(9)),
          CardioCoherence.clockBehind,
        );
        // A small skew is tolerated.
        expect(
          CardioMath.coherence(session([seg('a', t(9, 1), null)]), t(9)),
          CardioCoherence.ok,
        );
        expect(
          CardioMath.coherence(
            session([seg('a', t(0), null)]),
            t(0).add(const Duration(hours: 13)),
          ),
          CardioCoherence.implausible,
        );
        expect(
          CardioMath.needsCorrection(session([seg('a', t(9), null)]), t(10)),
          isFalse,
        );
      },
    );

    test('clock text', () {
      expect(CardioMath.clock(const Duration(seconds: 3725)), '01:02:05');
      expect(CardioMath.clock(Duration.zero), '00:00:00');
    });
  });

  group('cardio persistence (F10)', () {
    late StoreHarness h;
    late Opened db;
    setUp(() async {
      h = await StoreHarness.create();
      db = await h.open(clock: () => t(8));
    });
    tearDown(() => h.dispose());
    Future<Opened> reopen() async {
      await db.close();
      return db = await h.open(clock: () => t(8));
    }

    Future<void> start([CardioIntensity i = CardioIntensity.moderate]) =>
        db.repo.startCardio(
          activity: CardioActivity.bicycle,
          intensity: i,
          at: t(9),
          targetMinutes: 45,
        );

    test('an active session survives a restart with its timestamps', () async {
      await db.repo.saveProfile(const UserProfile(weightKg: 72));
      await start();
      await db.repo.pauseCardio(t(9, 20));
      await db.repo.resumeCardio(t(9, 30), intensity: CardioIntensity.high);
      final reopened = await reopen();
      final s = reopened.repo.activeCardio!;
      expect(s.activity, CardioActivity.bicycle);
      expect(s.targetMinutes, 45);
      expect(s.running, isTrue);
      expect(s.segments, hasLength(2));
      expect(s.segments.first.endedAt, t(9, 20));
      expect(s.segments.last.endedAt, isNull);
      expect(s.segments.last.intensity, CardioIntensity.high);
      expect(s.segments.map((x) => x.weightKg), [72, 72]);
      // 20 minutes before the pause plus what has run since resuming.
      expect(s.duration(t(9, 45)), const Duration(minutes: 35));
    });

    test('a long pause adds no time', () async {
      await start();
      await db.repo.pauseCardio(t(9, 10));
      final reopened = await reopen();
      expect(reopened.repo.activeCardio!.paused, isTrue);
      expect(
        reopened.repo.activeCardio!.duration(t(23)),
        const Duration(minutes: 10),
      );
      await reopened.repo.resumeCardio(t(22));
      expect(
        reopened.repo.activeCardio!.duration(t(22, 5)),
        const Duration(minutes: 15),
      );
    });

    test('only one session can be active', () async {
      await start();
      await expectLater(start(), throwsStateError);
      expect(db.repo.cardioHistory, isEmpty);
      expect((await db.counts())['cardio_sessions'], 1);
    });

    test('finishing saves once; pressing again does nothing', () async {
      await db.repo.saveProfile(const UserProfile(weightKg: 70));
      await start(CardioIntensity.low);
      final id = db.repo.activeCardio!.id;
      await db.repo.finishCardio(
        id,
        t(9, 30),
        feedback: Feeling.energetic,
        note: ' buen ritmo ',
      );
      final counts = await db.counts();
      await db.repo.finishCardio(id, t(9, 59), note: 'otra');
      expect(await db.counts(), counts);
      final saved = (await reopen()).repo.cardioHistory.single;
      expect(saved.status, CardioStatus.finished);
      expect(saved.duration(t(23)), const Duration(minutes: 30));
      expect(saved.finishedAt, t(9, 30));
      expect(saved.feedback, Feeling.energetic);
      expect(saved.note, 'buen ritmo');
      expect(db.repo.activeCardio, isNull);
      expect(CardioMath.kcal(saved, t(23)), closeTo(5.0 * 70 * .5, 1e-9));
    });

    test('later profile edits never change a finished session', () async {
      await db.repo.saveProfile(const UserProfile(weightKg: 70));
      await start();
      final id = db.repo.activeCardio!.id;
      await db.repo.finishCardio(id, t(10));
      final before = CardioMath.kcal(db.repo.cardioHistory.single, t(23));
      await db.repo.saveProfile(const UserProfile(weightKg: 100));
      expect(CardioMath.kcal(db.repo.cardioHistory.single, t(23)), before);
      expect(db.repo.cardioHistory.single.segments.single.weightKg, 70);
    });

    test('a session without a body weight records time but no kcal', () async {
      await start();
      await db.repo.finishCardio(db.repo.activeCardio!.id, t(9, 20));
      final saved = db.repo.cardioHistory.single;
      expect(saved.segments.single.weightKg, isNull);
      expect(saved.duration(t(23)), const Duration(minutes: 20));
      expect(CardioMath.kcal(saved, t(23)), isNull);
    });

    test('segmented intensity: changing it splits the time', () async {
      await db.repo.saveProfile(const UserProfile(weightKg: 70));
      await start();
      await db.repo.changeCardioIntensity(t(9, 10), CardioIntensity.high);
      // The same intensity again is not a new segment.
      await db.repo.changeCardioIntensity(t(9, 11), CardioIntensity.high);
      await db.repo.finishCardio(db.repo.activeCardio!.id, t(9, 30));
      final saved = (await reopen()).repo.cardioHistory.single;
      expect(saved.segments, hasLength(2));
      expect(saved.segments.map((s) => s.intensity), [
        CardioIntensity.moderate,
        CardioIntensity.high,
      ]);
      expect(saved.segments.map((s) => s.duration(t(23)).inMinutes), [10, 20]);
      expect(
        CardioMath.kcal(saved, t(23)),
        closeTo(7.0 * 70 * 10 / 60 + 10.0 * 70 * 20 / 60, 1e-9),
      );
    });

    test(
      'changing intensity while paused is refused by the repository',
      () async {
        await start();
        await db.repo.pauseCardio(t(9, 10));
        await expectLater(
          db.repo.changeCardioIntensity(t(9, 20), CardioIntensity.high),
          throwsStateError,
        );
      },
    );

    test(
      'a clock set back is detected and finishing needs the real duration',
      () async {
        await start();
        // 08:30 is before the 09:00 start.
        await expectLater(db.repo.pauseCardio(t(8, 30)), throwsStateError);
        final id = db.repo.activeCardio!.id;
        await expectLater(db.repo.finishCardio(id, t(8, 30)), throwsStateError);
        expect(
          db.repo.activeCardio!.running,
          isTrue,
          reason: 'nothing was lost',
        );
        await db.repo.finishCardio(
          id,
          t(8, 30),
          correctedDuration: const Duration(minutes: 25),
        );
        final saved = db.repo.cardioHistory.single;
        expect(saved.duration(t(23)), const Duration(minutes: 25));
        expect(saved.durationCorrected, isTrue);
        expect(
          (await reopen()).repo.cardioHistory.single.durationCorrected,
          isTrue,
        );
      },
    );

    test('correcting after a pause keeps the earlier time and fixes the last segment', () async {
      await start();
      await db.repo.pauseCardio(t(9, 20));
      await db.repo.resumeCardio(t(9, 30));
      final id = db.repo.activeCardio!.id;
      await expectLater(
        db.repo.finishCardio(
          id,
          t(15),
          correctedDuration: const Duration(minutes: 10),
        ),
        throwsArgumentError,
        reason: 'less than the 20 minutes already recorded',
      );
      await db.repo.finishCardio(
        id,
        t(15),
        correctedDuration: const Duration(minutes: 50),
      );
      final saved = db.repo.cardioHistory.single;
      expect(saved.duration(t(23)), const Duration(minutes: 50));
      expect(saved.segments.first.duration(t(23)), const Duration(minutes: 20));
      expect(saved.segments.last.duration(t(23)), const Duration(minutes: 30));
    });

    test('invalid inputs are refused', () async {
      for (final minutes in [0, 601, -5]) {
        await expectLater(
          db.repo.startCardio(
            activity: CardioActivity.walk,
            intensity: CardioIntensity.low,
            at: t(9),
            targetMinutes: minutes,
          ),
          throwsArgumentError,
        );
      }
      await start();
      final id = db.repo.activeCardio!.id;
      await expectLater(
        db.repo.finishCardio(
          id,
          t(10),
          correctedDuration: const Duration(hours: 25),
        ),
        throwsArgumentError,
      );
      await expectLater(
        db.repo.finishCardio(id, t(10), note: 'x' * 501),
        throwsArgumentError,
      );
      await expectLater(
        db.repo.finishCardio('nope', t(10)),
        throwsArgumentError,
      );
    });

    test('discarding removes the session and its segments, once', () async {
      await start();
      await db.repo.pauseCardio(t(9, 10));
      final id = db.repo.activeCardio!.id;
      await db.repo.discardCardio(id);
      expect(db.repo.activeCardio, isNull);
      final counts = await db.counts();
      expect(counts['cardio_sessions'], 0);
      expect(
        (await db.db
                .customSelect('SELECT COUNT(*) AS n FROM cardio_segments')
                .getSingle())
            .read<int>('n'),
        0,
      );
      await db.repo.discardCardio(id);
      // A finished session cannot be discarded.
      await start();
      final id2 = db.repo.activeCardio!.id;
      await db.repo.finishCardio(id2, t(10));
      await expectLater(db.repo.discardCardio(id2), throwsStateError);
      expect(db.repo.cardioHistory, hasLength(1));
    });

    test('a failed write changes nothing and a retry succeeds', () async {
      await start();
      final before = await db.counts();
      h.fault.arm(
        (sql) => sql.startsWith('UPDATE') && sql.contains('cardio_segments'),
      );
      await expectLater(db.repo.pauseCardio(t(9, 10)), throwsInjected);
      expect(db.repo.activeCardio!.running, isTrue);
      expect(await db.counts(), before);
      h.fault.disarm();
      await db.repo.pauseCardio(t(9, 10));
      expect((await reopen()).repo.activeCardio!.paused, isTrue);
    });

    test('concurrent commands are applied in order', () async {
      await start();
      final id = db.repo.activeCardio!.id;
      await Future.wait([
        db.repo.pauseCardio(t(9, 10)),
        db.repo.resumeCardio(t(9, 20)),
        db.repo.finishCardio(id, t(9, 40)),
        db.repo.finishCardio(id, t(9, 50)),
      ]);
      final saved = (await reopen()).repo.cardioHistory.single;
      expect(saved.duration(t(23)), const Duration(minutes: 30));
      expect(saved.finishedAt, t(9, 40));
    });

    test('history is newest first', () async {
      for (var i = 0; i < 3; i++) {
        await db.repo.startCardio(
          activity: CardioActivity.values[i],
          intensity: CardioIntensity.low,
          at: t(9 + i),
        );
        await db.repo.finishCardio(db.repo.activeCardio!.id, t(9 + i, 10));
      }
      expect((await reopen()).repo.cardioHistory.map((s) => s.activity), [
        CardioActivity.values[2],
        CardioActivity.values[1],
        CardioActivity.values[0],
      ]);
    });
  });

  group('cardio view model (F10)', () {
    late StoreHarness h;
    late Opened db;
    var wall = t(9);
    var mono = Duration.zero;
    setUp(() async {
      h = await StoreHarness.create();
      db = await h.open();
      wall = t(9);
      mono = Duration.zero;
    });
    tearDown(() => h.dispose());

    CardioViewModel make({Duration tick = const Duration(days: 1)}) =>
        CardioViewModel(
          db.repo,
          db.repo,
          clock: () => wall,
          monotonic: () => mono,
          tick: tick,
        );

    void advance(Duration d) {
      wall = wall.add(d);
      mono += d;
    }

    test('the time comes from timestamps, not from ticks', () async {
      final vm = make();
      addTearDown(vm.dispose);
      await db.repo.saveProfile(const UserProfile(weightKg: 70));
      await vm.start();
      // The ticker (one day) never fired; the display is still right.
      advance(const Duration(minutes: 7, seconds: 3));
      expect(vm.display, '00:07:03');
      expect(vm.calories, closeTo(3.5 * 70 * (7 * 60 + 3) / 3600, 1e-9));
      await vm.pause();
      advance(const Duration(hours: 3));
      expect(vm.display, '00:07:03', reason: 'paused time does not count');
      await vm.resume();
      advance(const Duration(minutes: 1));
      expect(vm.display, '00:08:03');
    });

    test(
      'a phone clock change while the app runs does not alter the session',
      () async {
        final vm = make();
        addTearDown(vm.dispose);
        await vm.start();
        advance(const Duration(minutes: 10));
        // The user (or the network) moves the wall clock back two hours.
        wall = wall.subtract(const Duration(hours: 2));
        expect(vm.display, '00:10:00');
        advance(const Duration(minutes: 5));
        expect(vm.display, '00:15:00');
        await vm.finish();
        final saved = db.repo.cardioHistory.single;
        expect(saved.duration(wall), const Duration(minutes: 15));
      },
    );

    test(
      'after a restart the session is rebuilt from the stored start',
      () async {
        final first = make();
        await first.start();
        advance(const Duration(minutes: 20));
        first.dispose();
        // A new process: new view model, new monotonic base, same stored data.
        mono = Duration.zero;
        final vm = make();
        addTearDown(vm.dispose);
        expect(vm.running, isTrue);
        expect(vm.display, '00:20:00');
        advance(const Duration(minutes: 5));
        expect(vm.display, '00:25:00');
        expect(vm.coherence, CardioCoherence.ok);
      },
    );

    test('after a restart a clock that went back is flagged', () async {
      final first = make();
      await first.start();
      advance(const Duration(minutes: 20));
      first.dispose();
      wall = t(7); // two hours before the start
      final vm = make();
      addTearDown(vm.dispose);
      expect(vm.coherence, CardioCoherence.clockBehind);
      expect(vm.display, '00:00:00');
      await vm.finish();
      expect(vm.error, contains('reloj'));
      expect(db.repo.activeCardio, isNotNull, reason: 'nothing was lost');
      expect(
        await vm.finish(correctedDuration: const Duration(minutes: 30)),
        isTrue,
      );
      expect(
        db.repo.cardioHistory.single.duration(t(23)),
        const Duration(minutes: 30),
      );
    });

    test('a session open for more than 12 hours asks to confirm', () async {
      final first = make();
      await first.start();
      first.dispose();
      wall = t(9).add(const Duration(hours: 13));
      final vm = make();
      addTearDown(vm.dispose);
      expect(vm.coherence, CardioCoherence.implausible);
    });

    test('the optional target counts down and stops at zero', () async {
      final vm = make();
      addTearDown(vm.dispose);
      vm.setTarget(10);
      await vm.start();
      advance(const Duration(minutes: 4));
      expect(vm.remaining, const Duration(minutes: 6));
      advance(const Duration(minutes: 30));
      expect(vm.remaining, Duration.zero);
    });

    test('double taps are absorbed: one session, one save', () async {
      final vm = make();
      addTearDown(vm.dispose);
      final first = vm.start();
      final second = vm.start();
      expect(await first, isTrue);
      expect(await second, isFalse);
      expect((await db.counts())['cardio_sessions'], 1);
      advance(const Duration(minutes: 5));
      final a = vm.finish();
      final b = vm.finish();
      await Future.wait([a, b]);
      expect(db.repo.cardioHistory, hasLength(1));
    });

    test('the periodic timer only refreshes the screen', () async {
      final vm = make(tick: const Duration(milliseconds: 5));
      addTearDown(vm.dispose);
      var refreshes = 0;
      vm.addListener(() => refreshes++);
      await vm.start();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(refreshes, greaterThan(1));
      // Time did not move: ticks add nothing.
      expect(vm.display, '00:00:00');
      await vm.pause();
      final after = refreshes;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(refreshes, after, reason: 'no ticking while paused');
    });
  });

  group('cardio screen (F10)', () {
    Future<AppDependencies> start(
      WidgetTester tester, {
      double width = 390,
      double scale = 1,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 2400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime.now(),
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.repository.saveProfile(const UserProfile(weightKg: 70));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 2400),
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.cardio);
      await tester.pumpAndSettle();
      return d;
    }

    // A running session keeps a periodic refresh timer; the test framework
    // wants no timer left when the body ends, so tests pause at the end.
    Future<void> stop(WidgetTester tester, AppDependencies d) async {
      if (d.cardio.running) await d.cardio.pause();
      await tester.pump();
    }

    testWidgets(
      'start, change intensity, pause, continue and finish with feedback',
      (tester) async {
        final d = await start(tester);
        expect(find.text('Sin sesión en curso'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('cardio-start')));
        await tester.pump();
        expect(d.cardio.running, isTrue);
        await tester.tap(find.text('Intensa'));
        await tester.pump();
        expect(d.cardio.session!.segments, hasLength(2));
        await tester.tap(find.byKey(const ValueKey('cardio-toggle')));
        await tester.pump();
        expect(d.cardio.paused, isTrue);
        expect(find.text('Continuar'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('cardio-toggle')));
        await tester.pump();
        expect(d.cardio.running, isTrue);
        await tester.tap(find.byKey(const ValueKey('cardio-finish')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Con energía'));
        await tester.tap(find.byKey(const ValueKey('cardio-save')));
        await tester.pumpAndSettle();
        expect(d.cardio.active, isFalse);
        final saved = d.repository.cardioHistory.single;
        expect(saved.feedback, Feeling.energetic);
        expect(saved.segments.length, greaterThanOrEqualTo(3));
        expect(find.text('Sesión de cardio guardada'), findsOneWidget);
        expect(find.textContaining('Caminata ·'), findsOneWidget);
      },
    );

    testWidgets('discarding asks first and cancelling keeps the session', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('cardio-start')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('cardio-discard')));
      await tester.pumpAndSettle();
      expect(find.text('¿Descartar la sesión?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(d.cardio.active, isTrue);
      await tester.tap(find.byKey(const ValueKey('cardio-discard')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();
      expect(d.cardio.active, isFalse);
      expect(d.repository.cardioHistory, isEmpty);
    });

    testWidgets('the optional target is shown while running', (tester) async {
      final d = await start(tester);
      await tester.enterText(find.byKey(const ValueKey('cardio-target')), '30');
      await tester.tap(find.byKey(const ValueKey('cardio-start')));
      await tester.pump();
      expect(d.cardio.session!.targetMinutes, 30);
      expect(find.textContaining('para el objetivo'), findsOneWidget);
      await stop(tester, d);
    });

    testWidgets(
      'no weight: time is kept and kcal are explained as unavailable',
      (tester) async {
        final d = await start(tester);
        await d.repository.saveProfile(const UserProfile());
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('cardio-start')));
        await tester.pump();
        expect(find.text('Sin estimación de calorías'), findsOneWidget);
        expect(
          find.textContaining('Se registra solo la duración'),
          findsOneWidget,
        );
        expect(d.cardio.calories, isNull);
        await stop(tester, d);
      },
    );

    testWidgets('a restart restores the running session on screen', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('cardio-start')));
      await tester.pump();
      expect(find.text('Pausar'), findsOneWidget);
      // The page shows what is stored; leaving and coming back keeps it.
      d.shell.open(AppPage.today);
      await tester.pump();
      d.shell.open(AppPage.cardio);
      await tester.pump();
      expect(find.text('Pausar'), findsOneWidget);
      expect(d.cardio.running, isTrue);
      await stop(tester, d);
    });

    testWidgets('fits 320 px at 200% text, idle, running and finishing', (
      tester,
    ) async {
      final d = await start(tester, width: 320, scale: 2);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('cardio-start')));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('cardio-finish')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('cardio-save')), findsOneWidget);
      expect(d.cardio.active, isTrue);
      await stop(tester, d);
    });
  });
}
