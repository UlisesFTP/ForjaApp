import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/core/theme/forja_theme.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/streak_rules.dart';
import 'package:forja_app/ui/core/responsive.dart';
import 'package:forja_app/ui/streak/widgets/streak_page.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

// Plan of the rules tests: Monday, Wednesday and Friday.
bool _mwf(DateTime d) => const {1, 3, 5}.contains(d.weekday);

WorkoutSession _s(
  String key,
  SessionStatus status, {
  bool ticked = false,
  bool setDone = false,
}) => WorkoutSession(
  dateKey: key,
  routineId: 'r',
  status: status,
  exercises: [
    ExerciseLog(
      exerciseId: 'squat',
      weightKg: 40,
      completed: ticked,
      sets: [
        if (setDone)
          const SetLog(id: 's1', kind: SetKind.work, number: 1, reps: 5),
      ],
    ),
  ],
);

Streak _streak(
  List<WorkoutSession> sessions, {
  List<Reschedule> moves = const [],
  DateTime? today,
}) => Streak(
  sessions: sessions,
  reschedules: moves,
  planned: _mwf,
  // Wednesday 30 September 2026.
  today: today ?? DateTime(2026, 9, 30, 18),
);

Reschedule _move(String from, String to, {bool undone = false}) => Reschedule(
  id: '$from>$to',
  sourceDate: from,
  targetDate: to,
  kind: RescheduleKind.missed,
  createdAt: DateTime(2026, 9, 1),
  undoneAt: undone ? DateTime(2026, 9, 2) : null,
);

double _lum(Color c) {
  double lin(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _contrast(Color a, Color b) {
  final x = _lum(a), y = _lum(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  group('streak rules (streak-v1)', () {
    test(
      'no sessions: no streak, past days are not judged, today is to do',
      () {
        final s = _streak([]);
        expect(s.current, 0);
        expect(s.best, 0);
        expect(s.dayOn(DateTime(2026, 9, 28)), StreakDay.untracked);
        expect(s.todayState, StreakDay.pending);
      },
    );

    test(
      'rest days do not break the run; each trained planned day adds one',
      () {
        final s = _streak([
          _s('2026-09-21', SessionStatus.completed),
          _s('2026-09-23', SessionStatus.completed),
          _s('2026-09-25', SessionStatus.completed),
          _s('2026-09-28', SessionStatus.completed),
        ]);
        expect(s.dayOn(DateTime(2026, 9, 22)), StreakDay.rest);
        // Today (Wednesday) is still to do: it does not break the run.
        expect(s.todayState, StreakDay.pending);
        expect(s.current, 4);
      },
    );

    test('a planned day that passed without training breaks the run; the '
        'best keeps the longer one', () {
      final s = _streak([
        _s('2026-09-14', SessionStatus.completed),
        _s('2026-09-16', SessionStatus.completed),
        _s('2026-09-18', SessionStatus.completed),
        // 21: nothing saved, after the first session: missed.
        _s('2026-09-23', SessionStatus.completed),
        _s('2026-09-25', SessionStatus.missed),
        _s('2026-09-28', SessionStatus.completed),
        _s('2026-09-30', SessionStatus.completed),
      ]);
      expect(s.dayOn(DateTime(2026, 9, 21)), StreakDay.missed);
      expect(s.dayOn(DateTime(2026, 9, 25)), StreakDay.missed);
      expect(s.current, 2);
      expect(s.best, 3);
    });

    test('flexible: partial sessions and real activity count; an open day '
        'with nothing done does not', () {
      final s = _streak([
        _s('2026-09-21', SessionStatus.partial),
        _s('2026-09-23', SessionStatus.scheduled, ticked: true),
        _s('2026-09-25', SessionStatus.scheduled, setDone: true),
        _s('2026-09-28', SessionStatus.scheduled),
      ]);
      expect(s.dayOn(DateTime(2026, 9, 21)), StreakDay.trained);
      expect(s.dayOn(DateTime(2026, 9, 23)), StreakDay.trained);
      expect(s.dayOn(DateTime(2026, 9, 25)), StreakDay.trained);
      expect(s.dayOn(DateTime(2026, 9, 28)), StreakDay.missed);
      expect(s.current, 0);
      expect(s.best, 3);
    });

    test('a missed day that was moved is neutral and its destination '
        'counts; undoing the move makes it a miss again', () {
      final sessions = [
        _s('2026-09-21', SessionStatus.completed),
        _s('2026-09-23', SessionStatus.missed),
        // Moved to Thursday 24 (a rest day in the plan) and done there.
        _s('2026-09-24', SessionStatus.completed),
        _s('2026-09-25', SessionStatus.completed),
        _s('2026-09-28', SessionStatus.completed),
      ];
      final moved = _streak(
        sessions,
        moves: [_move('2026-09-23', '2026-09-24')],
      );
      expect(moved.dayOn(DateTime(2026, 9, 23)), StreakDay.moved);
      expect(moved.dayOn(DateTime(2026, 9, 24)), StreakDay.trained);
      expect(moved.current, 4);
      final undone = _streak(
        sessions,
        moves: [_move('2026-09-23', '2026-09-24', undone: true)],
      );
      expect(undone.dayOn(DateTime(2026, 9, 23)), StreakDay.missed);
      expect(undone.current, 3);
    });

    test('training today counts at once; future workouts are only planned', () {
      final s = _streak([
        _s('2026-09-28', SessionStatus.completed),
        _s('2026-09-30', SessionStatus.completed),
        _s('2026-10-02', SessionStatus.completed),
      ]);
      expect(s.todayState, StreakDay.trained);
      expect(s.current, 2);
      // A saved future session is not training yet.
      expect(s.dayOn(DateTime(2026, 10, 2)), StreakDay.upcoming);
      expect(s.dayOn(DateTime(2026, 10, 3)), StreakDay.rest);
    });

    test('days before the first saved session are not held against anyone', () {
      // Seen on Saturday 26, before the next planned day.
      final s = _streak([
        _s('2026-09-25', SessionStatus.completed),
      ], today: DateTime(2026, 9, 26));
      expect(s.dayOn(DateTime(2026, 9, 23)), StreakDay.untracked);
      expect(s.current, 1);
    });

    test('a day saved with nothing done (an edited weight) does not start '
        'the count, so it is not the first miss (seen on a phone)', () {
      final s = _streak([
        _s('2026-09-28', SessionStatus.scheduled),
      ], today: DateTime(2026, 9, 29));
      expect(s.trackingStart, isNull);
      expect(s.dayOn(DateTime(2026, 9, 28)), StreakDay.untracked);
      // A day marked as missed does start it.
      final marked = _streak([
        _s('2026-09-28', SessionStatus.missed),
      ], today: DateTime(2026, 9, 29));
      expect(marked.dayOn(DateTime(2026, 9, 28)), StreakDay.missed);
    });

    test('counts per period', () {
      final s = _streak([
        _s('2026-09-21', SessionStatus.completed),
        _s('2026-09-23', SessionStatus.partial),
        _s('2026-09-25', SessionStatus.missed),
      ]);
      final c = s.countIn(DateTime(2026, 9), DateTime(2026, 9, 30));
      expect(c.trained, 2);
      expect(c.missed, 2, reason: 'the 25th and Monday 28 (nothing saved)');
    });
  });

  group('the yearly map layout', () {
    test('one block when the squares are big enough, two halves otherwise', () {
      final wide = HeatMapLayout.fit(width: 900, weeks: 53);
      expect(wide.blocks, 1);
      expect(wide.cell, greaterThanOrEqualTo(HeatMapLayout.minCell));
      final phone = HeatMapLayout.fit(width: 318, weeks: 53);
      expect(phone.blocks, 2);
      expect(phone.cell, greaterThanOrEqualTo(HeatMapLayout.minCell - 1));
      expect(phone.weeksPerBlock * 2, greaterThanOrEqualTo(53));
    });
  });

  test('the orange keeps 3:1 against where it is drawn', () {
    expect(
      _contrast(ForjaColors.flameDeep, ForjaColors.paper),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrast(ForjaColors.flame, ForjaColors.surface),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrast(ForjaColors.flame, ForjaColors.background),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrast(ForjaColors.flameOff, ForjaColors.paper),
      greaterThanOrEqualTo(3),
    );
    expect(
      _contrast(ForjaColors.flameOff, ForjaColors.background),
      greaterThanOrEqualTo(3),
    );
  });

  group('the streak in the app', () {
    setUpAll(() async {
      await (FontLoader(
        'DM Sans',
      )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
      await (FontLoader('Barlow Condensed')
            ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
          .load();
    });

    // Tuesday 29 September 2026; the example plan trains Tue, Thu and Sat.
    final now = DateTime(2026, 9, 29, 9);

    Future<AppDependencies> start(
      WidgetTester tester, {
      Size size = const Size(390, 844),
      double text = 1,
      bool reduced = false,
      bool history = true,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => now,
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.repository.saveProfile(const UserProfile(onboarded: true));
      if (history) {
        // Three weeks back (Tue, Thu, Sat from the 8th): 8 done and one
        // missed day, the 12th.
        for (
          var day = DateTime(2026, 9, 8);
          day.isBefore(DateTime(2026, 9, 29));
          day = nextDay(day)
        ) {
          final session = d.repository.sessionOn(day);
          if (session == null) continue;
          if (day == DateTime(2026, 9, 12)) {
            await d.repository.finishSession(
              day,
              SessionStatus.missed,
              reschedule: false,
            );
            continue;
          }
          for (final log in session.exercises) {
            await d.repository.toggleExercise(day, log.exerciseId);
          }
          await d.repository.finishSession(
            day,
            SessionStatus.completed,
            reschedule: false,
          );
        }
      }
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(text),
            disableAnimations: reduced,
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('the top bar shows the flame and the run; today is still to '
        'do, so the flame waits', (tester) async {
      final d = await start(tester);
      // 15, 17, 19, 22, 24, 26 after the miss on the 12th.
      expect(d.streak.current, 6);
      expect(d.streak.todayState, StreakDay.pending);
      expect(d.streak.lit, isFalse);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('streak-count'))).data,
        '6',
      );
      final handle = tester.ensureSemantics();
      try {
        expect(
          find.bySemanticsLabel(RegExp('Racha: 6 entrenos seguidos')),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('training today lights the flame and adds one', (tester) async {
      final d = await start(tester);
      final before = d.streak.celebrate;
      await d.repository.toggleExercise(
        DateTime(2026, 9, 29),
        d.repository
            .sessionOn(DateTime(2026, 9, 29))!
            .exercises
            .first
            .exerciseId,
      );
      await tester.pumpAndSettle();
      expect(d.streak.current, 7);
      expect(d.streak.lit, isTrue);
      expect(d.streak.celebrate, before + 1, reason: 'the flame celebrates');
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('streak-count'))).data,
        '7',
      );
    });

    testWidgets('the badge opens the month, the year and the table', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('streak-badge')));
      await tester.pumpAndSettle();
      expect(find.byType(StreakPage), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('streak-current'))).data,
        '6',
      );
      expect(find.text('Septiembre 2026'), findsOneWidget);
      expect(find.text('Mejor racha: 6'), findsOneWidget);
      // Trained, missed and pending days read in words.
      final handle = tester.ensureSemantics();
      try {
        expect(
          find.bySemanticsLabel('Martes 15 sep: entrenaste'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Sábado 12 sep: faltaste'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Martes 29 sep: toca entrenar hoy, hoy'),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('streak-month-count')))
            .data,
        '8 entrenos · 1 falta este mes',
      );
      await tester.tap(find.byTooltip('Mes anterior'));
      await tester.pumpAndSettle();
      expect(find.text('Agosto 2026'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('streak-year-table')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('2026 · 8 entrenos'), findsOneWidget);
      await tester.tap(find.byTooltip('Año anterior'));
      await tester.pumpAndSettle();
      expect(find.text('2025 · 0 entrenos'), findsOneWidget);
      expect(d.streak.year, 2025);
    });

    testWidgets('the month starts on Monday with blanks; the year map has '
        'whole weeks', (tester) async {
      final d = await start(tester, history: false);
      // 1 September 2026 is a Tuesday.
      final cells = d.streak.monthCells;
      expect(cells.first, isNull);
      expect(cells[1], DateTime(2026, 9));
      expect(cells.length % 7, 0);
      final weeks = d.streak.yearWeeks;
      expect(weeks.first.first, isNull, reason: '29 Dec 2025 is outside');
      expect(weeks.first[3], DateTime(2026));
      expect(weeks.every((w) => w.length == 7), isTrue);
      expect(weeks.expand((w) => w).whereType<DateTime>().length, 365);
    });

    testWidgets('with no streak, a rest day does not claim the streak goes '
        'on (seen on a phone)', (tester) async {
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        // Wednesday: rest in the example plan.
        clock: () => DateTime(2026, 9, 30, 9),
      );
      addTearDown(() => unawaited(d.dispose()));
      expect(d.streak.todayState, StreakDay.rest);
      expect(
        d.streak.todayMessage,
        'Hoy es descanso. Tu racha empieza con tu próximo entreno.',
      );
    });

    testWidgets('the flame flickers for a moment and then rests; with '
        'reduced motion it does not move', (tester) async {
      await start(tester);
      await tester.tap(find.byKey(const ValueKey('streak-badge')));
      // pumpAndSettle would time out if the flame kept moving.
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: no flicker at all', (tester) async {
      final d = await start(tester, reduced: true);
      await d.repository.toggleExercise(
        DateTime(2026, 9, 29),
        d.repository
            .sessionOn(DateTime(2026, 9, 29))!
            .exercises
            .first
            .exerciseId,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });

    for (final (name, size, text) in [
      ('small phone, text 200%', const Size(320, 568), 2.0),
      ('phone landscape', const Size(844, 390), 1.0),
      ('tablet', const Size(1024, 768), 1.0),
      ('tablet, text 200%', const Size(1024, 768), 2.0),
    ]) {
      testWidgets('$name: the badge and the page lay out cleanly', (
        tester,
      ) async {
        await start(tester, size: size, text: text);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const ValueKey('streak-badge')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final width = tester.getSize(find.byType(StreakPage)).width;
        expect(
          find.byKey(const ValueKey('two-columns')),
          fitsTwoColumns(tester.element(find.byType(StreakPage)), width)
              ? findsOneWidget
              : findsNothing,
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('streak-year-table')),
          300,
          scrollable: find.byType(Scrollable).last,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the page meets the target, label and contrast guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await start(tester);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await tester.tap(find.byKey(const ValueKey('streak-badge')));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        handle.dispose();
      }
    });
  });
}
