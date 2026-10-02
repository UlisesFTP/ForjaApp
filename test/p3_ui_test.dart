import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';
import 'package:forja_app/ui/today/widgets/exercise_card.dart';

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

  final tuesday = DateTime(2026, 9, 29);

  Future<AppDependencies> start(
    WidgetTester tester, {
    double width = 390,
    double height = 1800,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      clock: () => DateTime(2026, 9, 29, 9),
    );
    addTearDown(() => unawaited(d.dispose()));
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

  Future<void> openSets(WidgetTester tester, String id, String name) async {
    await tester.tap(find.byTooltip('Series de $name'));
    await tester.pumpAndSettle();
  }

  const squat = 'Sentadilla con barra';

  group('sets panel', () {
    testWidgets('records real sets; empty fields stay "sin registrar"', (
      tester,
    ) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      expect(find.text('Aún no hay series registradas.'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('set-load')), '52,5');
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '8');
      await tester.enterText(find.byKey(const ValueKey('set-rir')), '2');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('52.5 kg · 8 reps · RIR 2'), findsOneWidget);
      // A second set with nothing typed: compliance, never a zero.
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('Sin datos registrados'), findsOneWidget);
      final sets = d.today.logOf('squat').sets;
      expect(sets.map((s) => s.weightKg), [52.5, null]);
      expect(sets.map((s) => s.reps), [8, null]);
      expect(sets.map((s) => s.rir), [2, null]);
      // Fields are cleared for the next set.
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('set-reps')))
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.byTooltip('Cerrar Series · $squat'));
      await tester.pumpAndSettle();
      expect(find.text('Pendiente · 2 series'), findsNothing);
      expect(find.textContaining('2 series'), findsWidgets);
    });

    testWidgets('invalid values are explained and nothing is stored', (
      tester,
    ) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '1000');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('Repeticiones: 0–999'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '8');
      await tester.enterText(find.byKey(const ValueKey('set-rir')), '11');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('RIR: 0–10'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('set-rir')), '');
      await tester.enterText(find.byKey(const ValueKey('set-load')), '9999');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('Carga: 0–2000 kg'), findsOneWidget);
      expect(d.today.logOf('squat').sets, isEmpty);
    });

    testWidgets('a set can be edited and removed', (tester) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '5');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Editar serie 1'));
      await tester.pumpAndSettle();
      expect(find.text('Guardar cambios'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '6');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(d.today.logOf('squat').sets.single.reps, 6);
      await tester.tap(find.byTooltip('Eliminar serie 1'));
      await tester.pumpAndSettle();
      expect(d.today.logOf('squat').sets, isEmpty);
    });

    testWidgets('a warm-up set is kept apart from work sets', (tester) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      await tester.tap(find.text('Calentamiento').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '10');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('Calentamiento 1'), findsOneWidget);
      expect(d.today.logOf('squat').workSets, isEmpty);
    });

    testWidgets('a skipped set is not a done set', (tester) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      await tester.tap(find.byKey(const ValueKey('set-skip')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Molestia');
      await tester.tap(find.text('Omitir').last);
      await tester.pumpAndSettle();
      expect(find.text('Omitida: Molestia'), findsOneWidget);
      expect(d.today.logOf('squat').sets.single.isDone, isFalse);
      expect(d.today.logOf('squat').workSets, isEmpty);
    });

    testWidgets('the panel fits 320 px at 200% text', (tester) async {
      await start(tester, width: 320, scale: 2);
      await openSets(tester, 'squat', squat);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '8');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('8 reps'), findsOneWidget);
    });

    testWidgets('the rest timer starts, pauses, resumes and cancels', (
      tester,
    ) async {
      final d = await start(tester);
      await openSets(tester, 'squat', squat);
      expect(find.textContaining('Descanso sugerido'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rest-start')));
      await tester.pump();
      expect(d.today.rest.isRunning, isTrue);
      expect(find.textContaining('Descanso: '), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rest-toggle')));
      await tester.pump();
      expect(d.today.rest.isPaused, isTrue);
      expect(find.textContaining('en pausa'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('rest-toggle')));
      await tester.pump();
      expect(d.today.rest.isRunning, isTrue);
      await tester.tap(find.byKey(const ValueKey('rest-cancel')));
      await tester.pumpAndSettle();
      expect(d.today.rest.isActive, isFalse);
      expect(find.textContaining('Descanso sugerido'), findsOneWidget);
    });
  });

  group('skipping and finishing', () {
    testWidgets('a skipped exercise needs a reason and finishes partial', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('complete-squat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('complete-press')));
      await tester.pumpAndSettle();
      // Not all resolved yet: the finish button is disabled.
      expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('finish-session')))
            .onPressed,
        isNull,
      );
      await openSets(tester, 'rdl', 'Peso muerto rumano');
      await tester.tap(find.byKey(const ValueKey('exercise-skip')));
      await tester.pumpAndSettle();
      // The confirm button stays disabled until there is a reason.
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Omitir'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Sin equipo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Omitir'));
      await tester.pumpAndSettle();
      expect(find.text('Ejercicio omitido: Sin equipo'), findsOneWidget);
      await tester.tap(find.byTooltip('Cerrar Series · Peso muerto rumano'));
      await tester.pumpAndSettle();
      expect(find.text('Omitido: Sin equipo'), findsOneWidget);
      expect(find.textContaining('1 omitido'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('finish-session')));
      await tester.pumpAndSettle();
      expect(d.today.session!.status, SessionStatus.partial);
      expect(find.text('Sesión parcial guardada'), findsOneWidget);
      expect(
        find.text('Sesión guardada como parcial: hay ejercicios omitidos'),
        findsOneWidget,
      );
      // Nothing was moved: the workout stays on its day.
      expect(d.today.moveFrom, isNull);
      expect(d.today.routine, isNotNull);
    });

    testWidgets('an exercise can be brought back from skipped', (tester) async {
      final d = await start(tester);
      await d.repository.setSkipped(tuesday, 'squat', true, reason: 'dolor');
      await tester.pumpAndSettle();
      await openSets(tester, 'squat', squat);
      await tester.tap(find.byKey(const ValueKey('exercise-unskip')));
      await tester.pumpAndSettle();
      expect(d.today.logOf('squat').skipped, isFalse);
    });
  });

  group('reopening', () {
    Future<AppDependencies> finished(WidgetTester tester) async {
      final d = await start(tester);
      for (final e in [...d.today.entries]) {
        await d.today.toggle(e.exerciseId);
      }
      await d.today.finish(SessionStatus.completed);
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets(
      'unchecking a finished session asks first; cancelling changes nothing',
      (tester) async {
        final d = await finished(tester);
        await tester.tap(find.byKey(const ValueKey('complete-squat')));
        await tester.pumpAndSettle();
        expect(find.text('Reabrir la sesión'), findsOneWidget);
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(d.today.session!.status, SessionStatus.completed);
        expect(d.today.logOf('squat').completed, isTrue);
        expect(d.repository.eventsOn(tuesday), isEmpty);
      },
    );

    testWidgets('confirming reopens, keeps an audit entry and recalculates', (
      tester,
    ) async {
      final d = await finished(tester);
      await tester.tap(find.byKey(const ValueKey('complete-squat')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reabrir y cambiar'));
      await tester.pumpAndSettle();
      expect(d.today.session!.status, SessionStatus.scheduled);
      expect(d.today.logOf('squat').completed, isFalse);
      expect(d.repository.eventsOn(tuesday), hasLength(1));
      expect(find.text('Completar sesión'), findsOneWidget);
    });

    testWidgets('the menu offers "Reabrir sesión" for a finished session', (
      tester,
    ) async {
      final d = await finished(tester);
      await tester.tap(find.byTooltip('Más opciones de sesión'));
      await tester.pumpAndSettle();
      expect(find.text('Falté'), findsNothing);
      await tester.tap(find.text('Reabrir sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reabrir y cambiar'));
      await tester.pumpAndSettle();
      expect(d.today.session!.status, SessionStatus.scheduled);
      expect(d.today.completed, 3, reason: 'nothing recorded is discarded');
    });

    testWidgets('adding a set to a finished session asks before reopening', (
      tester,
    ) async {
      final d = await finished(tester);
      await openSets(tester, 'squat', squat);
      await tester.enterText(find.byKey(const ValueKey('set-reps')), '5');
      await tester.tap(find.byKey(const ValueKey('set-save')));
      await tester.pumpAndSettle();
      expect(find.text('Reabrir la sesión'), findsOneWidget);
      await tester.tap(find.text('Reabrir y cambiar'));
      await tester.pumpAndSettle();
      expect(d.today.logOf('squat').sets, hasLength(1));
      expect(d.repository.eventsOn(tuesday), hasLength(1));
    });

    testWidgets('after-training feeling is separate from the first answer', (
      tester,
    ) async {
      final d = await finished(tester);
      await d.today.saveCheckIn(const CheckIn(feeling: Feeling.tired));
      await tester.pumpAndSettle();
      expect(find.text('¿Cómo te sentiste al terminar?'), findsOneWidget);
      await tester.tap(find.text('¿Cómo te sentiste al terminar?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Con energía'));
      await tester.tap(find.text('Guardar check-in'));
      await tester.pumpAndSettle();
      expect(d.today.checkIn!.feeling, Feeling.tired);
      expect(d.today.afterCheckIn!.feeling, Feeling.energetic);
      expect(find.text('Al terminar: Con energía'), findsOneWidget);
    });
  });

  group('check-in and the lighter session', () {
    testWidgets('tiredness proposes a lighter session that can be reverted', (
      tester,
    ) async {
      final d = await start(tester);
      final planned = d.today.prescription('squat');
      await d.today.saveCheckIn(const CheckIn(feeling: Feeling.tired));
      await tester.pumpAndSettle();
      expect(d.today.adjustmentApplied, isTrue);
      expect(d.today.prescription('squat').rir, 'RIR 3');
      expect(find.text('Quitar el ajuste de intensidad'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('adjustment-toggle')));
      await tester.pumpAndSettle();
      expect(d.repository.adjustmentOn(tuesday), isFalse);
      expect(d.today.adjustmentApplied, isFalse);
      expect(d.today.prescription('squat').sets, planned.sets);
      expect(d.today.prescription('squat').rir, planned.rir);
      expect(find.text('Aplicar el ajuste de intensidad'), findsOneWidget);
      expect(find.textContaining('Ajuste de intensidad quitado'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('adjustment-toggle')));
      await tester.pumpAndSettle();
      expect(d.today.adjustmentApplied, isTrue);
    });

    testWidgets('the adjustment never reaches an exercise already underway', (
      tester,
    ) async {
      final d = await start(tester);
      await d.repository.addSet(tuesday, 'squat', const SetEntry(reps: 5));
      final before = d.today.prescription('squat');
      await d.today.saveCheckIn(const CheckIn(feeling: Feeling.doms));
      await tester.pumpAndSettle();
      expect(d.today.prescription('squat').sets, before.sets);
      expect(d.today.prescription('squat').rir, before.rir);
      // A pending one is adjusted.
      expect(d.today.prescription('rdl').rir, 'RIR 3');
      // What was logged is untouched.
      expect(d.today.logOf('squat').sets.single.reps, 5);
    });

    testWidgets('an injury pauses: no adjustment, only feedback or finishing', (
      tester,
    ) async {
      final d = await start(tester);
      await d.today.saveCheckIn(const CheckIn(feeling: Feeling.injured));
      await tester.pumpAndSettle();
      expect(find.textContaining('pausa la sesión'), findsWidgets);
      expect(find.byKey(const ValueKey('adjustment-toggle')), findsNothing);
      expect(d.today.prescription('squat').rir, 'Pausar');
      expect(find.byKey(const ValueKey('injury-feedback')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('injury-finish')));
      await tester.pumpAndSettle();
      expect(find.text('Guardar sesión incompleta'), findsOneWidget);
    });

    testWidgets('no answer is not "normal": the row asks the question', (
      tester,
    ) async {
      final d = await start(tester);
      expect(d.today.checkIn, isNull);
      expect(find.text('¿Cómo te sientes?'), findsOneWidget);
      expect(find.byKey(const ValueKey('adjustment-toggle')), findsNothing);
    });
  });

  group('rescheduling', () {
    testWidgets(
      'the preview names pending work and the date, then moves it and offers undo',
      (tester) async {
        final d = await start(tester);
        await tester.tap(find.byKey(const ValueKey('complete-squat')));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Más opciones de sesión'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('No terminé'));
        await tester.pumpAndSettle();
        expect(find.text('Guardar sesión incompleta'), findsOneWidget);
        expect(find.text('• Peso muerto rumano'), findsOneWidget);
        expect(find.text('• Sentadilla con barra'), findsNothing);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('reschedule-target')))
              .data,
          'Miércoles 30 sep',
        );
        expect(find.text('Entrenas al día siguiente.'), findsOneWidget);
        // Nothing saved yet.
        expect(d.repository.rescheduleFrom(tuesday), isNull);
        await tester.tap(find.byKey(const ValueKey('reschedule-apply')));
        await tester.pumpAndSettle();
        expect(d.repository.rescheduleFrom(tuesday), isNotNull);
        expect(find.text('Sesión movida al Miércoles 30 sep'), findsOneWidget);
        await tester.tap(find.text('Deshacer'));
        await tester.pumpAndSettle();
        expect(d.repository.rescheduleFrom(tuesday), isNull);
        expect(d.today.routine, isNotNull);
        expect(d.today.completed, 1);
      },
    );

    testWidgets(
      'an absence offers the whole routine; keeping pending moves nothing',
      (tester) async {
        final d = await start(tester);
        await tester.tap(find.byTooltip('Más opciones de sesión'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Falté'));
        await tester.pumpAndSettle();
        expect(find.text('Registrar ausencia'), findsOneWidget);
        expect(find.textContaining('rutina completa'), findsOneWidget);
        expect(find.text('• Sentadilla con barra'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('reschedule-keep')));
        await tester.pumpAndSettle();
        expect(d.today.session!.status, SessionStatus.missed);
        expect(d.repository.rescheduleFrom(tuesday), isNull);
        expect(d.today.routine, isNotNull);
      },
    );

    testWidgets('the destination day says where it came from and can undo', (
      tester,
    ) async {
      final d = await start(tester);
      await d.today.finish(SessionStatus.missed);
      await tester.pumpAndSettle();
      expect(find.text('Día de descanso'), findsOneWidget);
      expect(find.byKey(const ValueKey('undo-move-from')), findsOneWidget);
      d.today.selectDate(DateTime(2026, 9, 30));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Reprogramada desde el Martes 29 sep'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('undo-move-into')));
      await tester.pumpAndSettle();
      expect(d.repository.rescheduleInto(DateTime(2026, 9, 30)), isNull);
      expect(find.text('Día de descanso'), findsOneWidget);
    });

    testWidgets('once the destination is started, undo is no longer offered', (
      tester,
    ) async {
      final d = await start(tester);
      await d.today.finish(SessionStatus.missed);
      d.today.selectDate(DateTime(2026, 9, 30));
      await tester.pumpAndSettle();
      await d.today.toggle('squat');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('undo-move-into')), findsNothing);
      expect(find.textContaining('Reprogramada desde'), findsOneWidget);
    });

    testWidgets('the reschedule sheet fits 320 px at 200% text', (
      tester,
    ) async {
      await start(tester, width: 320, scale: 2);
      await tester.tap(find.byTooltip('Más opciones de sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Falté'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('reschedule-apply')), findsOneWidget);
    });
  });

  group('units', () {
    testWidgets(
      'pounds are shown and typed in lb, and stored in kg unrounded',
      (tester) async {
        final d = await start(tester);
        await d.repository.updateWeight(tuesday, 'squat', 40);
        await d.settings.saveUnit(WeightUnit.lb);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('weight-squat')))
              .controller!
              .text,
          '88.18',
        );
        // Focusing and leaving the field without typing must not rewrite the
        // stored weight with its rounded display.
        await tester.tap(find.byKey(const ValueKey('weight-squat')));
        await tester.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(d.today.logOf('squat').weightKg, 40);
        await tester.enterText(
          find.byKey(const ValueKey('weight-squat')),
          '100',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(d.today.logOf('squat').weightKg, closeTo(45.359237, 1e-9));
        expect(find.text('lb'), findsWidgets);
        await d.settings.saveUnit(WeightUnit.kg);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextField>(find.byKey(const ValueKey('weight-squat')))
              .controller!
              .text,
          '45.36',
        );
        expect(d.today.logOf('squat').weightKg, closeTo(45.359237, 1e-9));
      },
    );

    testWidgets('the unit is chosen in its own sheet and survives', (
      tester,
    ) async {
      final d = await start(tester);
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unidad de peso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Libras (lb)'));
      await tester.pumpAndSettle();
      expect(d.repository.profile.unit, WeightUnit.lb);
      // Changing the unit is not a profile answer: no history entry.
      expect(d.repository.profileHistory, isEmpty);
    });
  });

  testWidgets('390×844 still shows three cards and the finish button', (
    tester,
  ) async {
    await start(tester, height: 844);
    expect(find.byType(ExerciseCard), findsNWidgets(3));
    final cards = tester.getRect(find.byType(ExerciseCard).last);
    final finish = tester.getRect(find.byKey(const ValueKey('finish-session')));
    expect(cards.bottom, lessThanOrEqualTo(finish.top));
    expect(finish.bottom, lessThan(746));
    expect(tester.takeException(), isNull);
  });
}
