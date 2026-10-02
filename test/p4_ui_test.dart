import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/progress_stats.dart';
import 'package:forja_app/domain/services/review_service.dart';
import 'package:forja_app/ui/progress/widgets/progress_view.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

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

  // Thursday 1 October 2026.
  final today = DateTime(2026, 10, 1, 9);
  final planned = PlanExercise.fromExercise(exerciseFor('squat'));
  final tue1 = DateTime(2026, 9, 22), tue2 = DateTime(2026, 9, 29);

  Future<AppDependencies> start(
    WidgetTester tester, {
    double width = 390,
    double height = 2400,
    double scale = 1,
    UserProfile? profile,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      clock: () => today,
    );
    addTearDown(() => unawaited(d.dispose()));
    if (profile != null) await d.repository.saveProfile(profile);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(scale),
        ),
        child: ForjaApp(dependencies: d, offerOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();
    return d;
  }

  // A full, eligible squat session.
  Future<void> squatDay(
    AppDependencies d,
    DateTime date, {
    int? reps,
    int? rir,
    double kg = 60,
    TechniqueRating? technique = TechniqueRating.solid,
  }) async {
    for (var i = 0; i < planned.sets; i++) {
      await d.repository.addSet(
        date,
        'squat',
        SetEntry(
          weightKg: kg,
          reps: reps ?? planned.repsMax,
          rir: rir ?? planned.rir,
        ),
      );
    }
    await d.repository.setTechnique(date, 'squat', technique);
    await d.repository.toggleExercise(date, 'squat');
  }

  Future<void> finishDay(AppDependencies d, DateTime date) async {
    for (final e in d.repository.sessionOn(date)!.exercises) {
      if (!e.completed) await d.repository.toggleExercise(date, e.exerciseId);
    }
    await d.repository.finishSession(date, SessionStatus.completed);
  }

  Future<void> openProgress(WidgetTester tester, AppDependencies d) async {
    d.shell.open(AppPage.progress);
    await tester.pumpAndSettle();
  }

  group('statistics (F09)', () {
    testWidgets('with no records: "sin datos", never a zero', (tester) async {
      final d = await start(tester);
      await openProgress(tester, d);
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('compliance-value')))
            .data,
        'Sin datos',
      );
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('volume-value'))).data,
        'Sin datos suficientes',
      );
      expect(
        find.text('Aún no hay series con carga y repeticiones en este rango.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('trend-toggle')), findsNothing);
      expect(find.text('No hay sesiones en este rango.'), findsOneWidget);
    });

    testWidgets('compliance shows numerator, denominator and the policy', (
      tester,
    ) async {
      final d = await start(tester);
      await finishDay(d, tue1);
      await finishDay(d, tue2);
      await openProgress(tester, d);
      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();
      // Planned and already due after the first record: Tue 22, Thu 24,
      // Sat 26, Tue 29; Thu 1 Oct is today (still open) and is not due.
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('compliance-value')))
            .data,
        '2/4 · 50 %',
      );
      expect(find.textContaining('sin registro 2'), findsOneWidget);
      expect(
        find.textContaining('una sesión movida cuenta una sola vez'),
        findsOneWidget,
      );
    });

    testWidgets('a moved session is counted once, at its new date', (
      tester,
    ) async {
      final d = await start(tester);
      await finishDay(d, tue1);
      await d.repository.finishSession(tue2, SessionStatus.missed);
      final target = d.repository.rescheduleFrom(tue2)!.targetDate;
      await finishDay(d, DateTime.parse(target));
      await openProgress(tester, d);
      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();
      expect(find.textContaining('movidas 1'), findsOneWidget);
      expect(find.textContaining('ausencias 0'), findsOneWidget);
    });

    testWidgets(
      'volume sums kg × reps of recorded sets and shows the coverage',
      (tester) async {
        final d = await start(tester);
        await d.repository.addSet(
          tue2,
          'squat',
          const SetEntry(weightKg: 60, reps: 8),
        );
        await d.repository.addSet(
          tue2,
          'squat',
          const SetEntry(weightKg: 60, reps: 6),
        );
        await d.repository.addSet(tue2, 'squat', const SetEntry(weightKg: 60));
        await d.repository.addSet(
          tue2,
          'squat',
          const SetEntry(kind: SetKind.warmup, weightKg: 20, reps: 10),
        );
        await openProgress(tester, d);
        await tester.tap(find.text('Todo'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('volume-value'))).data,
          '840 kg·reps',
        );
        expect(
          find.text(
            '2 de 3 series de trabajo tienen carga y repeticiones (67 %).',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('evolution has a chart and an equivalent table', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        final d = await start(tester);
        await squatDay(d, tue1, kg: 57.5, reps: 7);
        await squatDay(d, tue2, kg: 60);
        await openProgress(tester, d);
        await tester.tap(find.text('Todo'));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(
            RegExp('Gráfica de la carga más alta por sesión'),
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('Mejor marca observada: 60 kg'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const ValueKey('trend-toggle')));
        await tester.pumpAndSettle();
        expect(find.text('Carga máx.'), findsOneWidget);
        expect(find.text('57.5 kg'), findsOneWidget);
        expect(find.text('60 kg'), findsWidgets);
        await tester.tap(find.byKey(const ValueKey('trend-toggle')));
        await tester.pumpAndSettle();
        expect(find.text('Carga máx.'), findsNothing);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('history lists each exercise with its recorded sets', (
      tester,
    ) async {
      final d = await start(tester);
      await d.repository.addSet(
        tue2,
        'squat',
        const SetEntry(weightKg: 60, reps: 8),
      );
      await d.repository.setSkipped(tue2, 'rdl', true, reason: 'sin barra');
      await openProgress(tester, d);
      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('history-2026-09-29')));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 series: 60 kg × 8'), findsOneWidget);
      expect(find.text('Omitido: sin barra'), findsOneWidget);
    });

    testWidgets('range filter limits the history', (tester) async {
      final d = await start(tester);
      await finishDay(d, DateTime(2026, 8, 11));
      await finishDay(d, tue2);
      await openProgress(tester, d);
      await tester.tap(find.text('Todo'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('history-2026-08-11')), findsOneWidget);
      await tester.tap(find.text('Mes'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('history-2026-08-11')), findsNothing);
      expect(
        find.byKey(const ValueKey('history-2026-09-29')),
        findsNothing,
        reason: 'September is not October',
      );
    });

    testWidgets('the page fits 320 px at 200% text with data', (tester) async {
      final d = await start(tester, width: 320, height: 6000, scale: 2);
      await squatDay(d, tue1);
      await squatDay(d, tue2);
      await openProgress(tester, d);
      d.progress.setRange(StatsRange.all);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The list is lazy: scroll until the toggle is built.
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('trend-toggle')),
        300,
        scrollable: find.descendant(
          of: find.byType(ProgressView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('trend-toggle')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('progression suggestions (F08)', () {
    testWidgets(
      'two eligible sessions suggest an increase with its explanation',
      (tester) async {
        final d = await start(tester);
        await squatDay(d, tue1);
        await squatDay(d, tue2);
        await openProgress(tester, d);
        expect(find.text('Sugerencia: subir la carga'), findsOneWidget);
        expect(find.textContaining('Sugerencia: subir'), findsWidgets);
        expect(find.textContaining('22 sep y 29 sep'), findsOneWidget);
        expect(find.byKey(const ValueKey('accept-squat')), findsOneWidget);
        // Nothing was applied by showing it.
        expect(d.repository.workingWeight('squat'), isNull);
        expect(d.repository.progressionDecisions, isEmpty);
      },
    );

    testWidgets(
      'accepting records it once, applies to future sessions and keeps the past',
      (tester) async {
        final d = await start(tester);
        await squatDay(d, tue1);
        await squatDay(d, tue2);
        await openProgress(tester, d);
        await tester.ensureVisible(find.byKey(const ValueKey('accept-squat')));
        await tester.tap(find.byKey(const ValueKey('accept-squat')));
        await tester.pumpAndSettle();
        expect(d.repository.workingWeight('squat'), 60 + planned.incrementKg);
        expect(find.byKey(const ValueKey('accept-squat')), findsNothing);
        expect(find.textContaining('Aceptaste este aumento'), findsOneWidget);
        // A second acceptance (even through the repository) changes nothing.
        await d.repository.decideProgression(
          exerciseId: 'squat',
          kind: ProgressionKind.increase,
          basedOn: '2026-09-29',
          ruleVersion: 'prog-v1',
          status: DecisionStatus.accepted,
          fromKg: 60,
          toKg: 99,
        );
        expect(d.repository.progressionDecisions, hasLength(1));
        expect(d.repository.workingWeight('squat'), 60 + planned.incrementKg);
        // Past sessions are untouched; a session that does not exist yet starts
        // from the accepted load.
        expect(
          d.repository.sessionOn(tue2)!.exercises.first.weightKg,
          planned.referenceWeightKg ?? 0,
        );
        expect(
          d.repository
              .sessionOn(DateTime(2026, 10, 6))!
              .exercises
              .first
              .weightKg,
          60 + planned.incrementKg,
        );
      },
    );

    testWidgets('rejecting records it and changes nothing', (tester) async {
      final d = await start(tester);
      await squatDay(d, tue1);
      await squatDay(d, tue2);
      await openProgress(tester, d);
      await tester.ensureVisible(find.byKey(const ValueKey('reject-squat')));
      await tester.tap(find.byKey(const ValueKey('reject-squat')));
      await tester.pumpAndSettle();
      expect(d.repository.workingWeight('squat'), isNull);
      expect(
        d.repository.progressionDecisions.single.status,
        DecisionStatus.rejected,
      );
      expect(find.textContaining('Rechazaste esta sugerencia'), findsOneWidget);
    });

    testWidgets('an injury or soreness explains why no increase is offered', (
      tester,
    ) async {
      final d = await start(tester);
      await squatDay(d, tue1);
      await squatDay(d, tue2);
      await d.repository.saveCheckIn(
        tue2,
        const CheckIn(feeling: Feeling.doms),
      );
      await openProgress(tester, d);
      expect(find.text('Sin aumento por ahora'), findsOneWidget);
      expect(find.textContaining('DOMS registrados'), findsOneWidget);
      expect(find.byKey(const ValueKey('accept-squat')), findsNothing);
    });

    testWidgets('missing data is listed instead of guessed', (tester) async {
      final d = await start(tester);
      await d.repository.toggleExercise(tue1, 'squat');
      await d.repository.toggleExercise(tue2, 'squat');
      await openProgress(tester, d);
      expect(find.text('Mantener la carga'), findsOneWidget);
      expect(find.text('Datos que faltan:'), findsOneWidget);
      expect(find.byKey(const ValueKey('accept-squat')), findsNothing);
    });

    testWidgets(
      'the explanation says how it is computed and that it never applies itself',
      (tester) async {
        final d = await start(tester);
        await squatDay(d, tue1);
        await squatDay(d, tue2);
        await openProgress(tester, d);
        await tester.ensureVisible(find.text('Cómo se calcula'));
        await tester.tap(find.text('Cómo se calcula'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Nunca se aplica sola'), findsOneWidget);
        expect(find.textContaining('prog-v1'), findsOneWidget);
      },
    );

    testWidgets('the sets panel records technique and shows the suggestion', (
      tester,
    ) async {
      final d = await start(tester);
      await squatDay(d, tue1);
      await squatDay(d, tue2);
      d.today.selectDate(tue2);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Series de Sentadilla con barra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inestable'));
      await tester.pumpAndSettle();
      expect(
        d.repository.sessionOn(tue2)!.exercises.first.technique,
        TechniqueRating.unstable,
      );
      expect(find.text('Sin aumento por ahora'), findsWidgets);
      // Tapping the selected one again clears it: unknown, not "solid".
      await tester.tap(find.text('Inestable'));
      await tester.pumpAndSettle();
      expect(d.repository.sessionOn(tue2)!.exercises.first.technique, isNull);
    });

    testWidgets(
      'an actionable suggestion opens expanded in the panel and can be accepted there',
      (tester) async {
        final d = await start(tester);
        await squatDay(d, tue1);
        await squatDay(d, tue2);
        d.today.selectDate(tue2);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Series de Sentadilla con barra'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('accept-squat')));
        await tester.tap(find.byKey(const ValueKey('accept-squat')));
        await tester.pumpAndSettle();
        expect(d.repository.workingWeight('squat'), 60 + planned.incrementKg);
      },
    );
  });

  group('monthly review (F07)', () {
    const answered = UserProfile(
      onboarded: true,
      lastReview: '2026-08-01',
      goal: TrainingGoal.strength,
    );

    Future<void> openReview(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Mi perfil y minicoach'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('review-open')));
      await tester.pumpAndSettle();
    }

    testWidgets('a due review is offered discreetly and never blocks Hoy', (
      tester,
    ) async {
      final d = await start(tester, profile: answered);
      expect(find.text('Minicoach · revisión disponible'), findsOneWidget);
      expect(find.text('Completar sesión'), findsOneWidget);
      expect(d.review.due, isTrue);
    });

    testWidgets('not due before 30 days, and a new profile is not asked', (
      tester,
    ) async {
      await start(
        tester,
        profile: answered.copyWith(lastReview: () => '2026-09-20'),
      );
      expect(find.text('Minicoach'), findsOneWidget);
      expect(find.textContaining('revisión disponible'), findsNothing);
    });

    testWidgets('rejecting changes nothing and is recorded', (tester) async {
      final d = await start(tester, profile: answered);
      await openReview(tester);
      await tester.tap(find.byKey(const ValueKey('review-propose')));
      await tester.pumpAndSettle();
      expect(find.text('Propuesta'), findsOneWidget);
      expect(
        find.textContaining('pocos entrenamientos vencidos'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('review-reject')));
      await tester.pumpAndSettle();
      expect(d.repository.reviews.single.outcome, ReviewOutcome.rejected);
      expect(d.repository.profile.lastReview, '2026-10-01');
      expect(d.repository.profile.goal, TrainingGoal.strength);
      expect(d.repository.draft, isNull);
      expect(d.review.due, isFalse);
      expect(find.text('Minicoach'), findsOneWidget);
    });

    testWidgets(
      'accepting applies the answers and leaves a draft plan to review',
      (tester) async {
        final d = await start(tester, profile: answered);
        await openReview(tester);
        // Change the goal; the plan is built from it.
        await tester.tap(find.byKey(const ValueKey('review-goal')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Ganar músculo').last);
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('review-propose')),
        );
        await tester.tap(find.byKey(const ValueKey('review-propose')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Cambios en tu perfil: objetivo'),
          findsOneWidget,
        );
        expect(find.text('Plan actual → propuesto'), findsOneWidget);
        await tester.ensureVisible(find.byKey(const ValueKey('review-accept')));
        await tester.tap(find.byKey(const ValueKey('review-accept')));
        await tester.pumpAndSettle();
        final review = d.repository.reviews.single;
        expect(review.outcome, ReviewOutcome.accepted);
        expect(review.rulesVersion, reviewRulesVersion);
        expect(d.repository.profile.goal, TrainingGoal.muscle);
        expect(d.repository.draft, isNotNull);
        expect(d.repository.profileHistory.last.reason, ProfileChange.review);
        // The plan in use is the same until the draft is accepted in Plan.
        expect(d.repository.planFor(today).source, PlanSource.example);
      },
    );

    testWidgets(
      'pain or soreness: nothing in the proposal asks for more load',
      (tester) async {
        await start(tester, profile: answered);
        await openReview(tester);
        await tester.tap(find.byKey(const ValueKey('review-pain')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.byKey(const ValueKey('review-propose')),
        );
        await tester.tap(find.byKey(const ValueKey('review-propose')));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('no se propone ningún aumento'),
          findsWidgets,
        );
      },
    );

    testWidgets('postponing hides it for seven days', (tester) async {
      final d = await start(tester, profile: answered);
      await openReview(tester);
      await tester.ensureVisible(find.byKey(const ValueKey('review-postpone')));
      await tester.tap(find.byKey(const ValueKey('review-postpone')));
      await tester.pumpAndSettle();
      expect(d.repository.profile.reviewSnoozeUntil, '2026-10-08');
      expect(d.review.due, isFalse);
      expect(find.text('Minicoach'), findsOneWidget);
      expect(d.repository.reviews, isEmpty);
    });

    testWidgets('the review history lists decisions with their rules version', (
      tester,
    ) async {
      final d = await start(tester, profile: answered);
      await openReview(tester);
      await tester.tap(find.byKey(const ValueKey('review-propose')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('review-reject')));
      await tester.tap(find.byKey(const ValueKey('review-reject')));
      await tester.pumpAndSettle();
      // The coach sheet is still open under the closed review.
      await tester.ensureVisible(find.textContaining('Revisiones (1)'));
      await tester.tap(find.textContaining('Revisiones (1)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 oct · Rechazada'), findsOneWidget);
      expect(find.textContaining('reglas review-v1'), findsOneWidget);
      expect(d.repository.reviews, hasLength(1));
    });

    testWidgets('both steps fit 320 px at 200% text', (tester) async {
      await start(tester, width: 320, scale: 2, profile: answered);
      await openReview(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('review-propose')));
      await tester.tap(find.byKey(const ValueKey('review-propose')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('review-accept')), findsOneWidget);
    });
  });
}
