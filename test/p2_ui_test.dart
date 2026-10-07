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
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class FakeLauncher implements TutorialLauncher {
  FakeLauncher({this.works = true});
  bool works;
  final opened = <Uri>[];
  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return works;
  }
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

  Future<AppDependencies> start(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
    bool onboarding = false,
    AppSnapshot? snapshot,
    FakeLauncher? launcher,
  }) async {
    // Interaction tests use a tall screen so lazily built lists are fully
    // built; the 320 px / 200% layout tests keep a real phone height.
    final height = width < 390 || scale > 1 ? 844.0 : 2800.0;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(snapshot),
      launcher: launcher ?? FakeLauncher(),
      clock: () => DateTime(2026, 10, 1),
    );
    addTearDown(() => unawaited(d.dispose()));
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, height),
          textScaler: TextScaler.linear(scale),
        ),
        child: ForjaApp(dependencies: d, offerOnboarding: onboarding),
      ),
    );
    await tester.pumpAndSettle();
    return d;
  }

  // Lists build lazily: scroll the visible page (or sheet) until it exists.
  // Scrolls so that some match can actually be tapped. Text also appears in
  // pages behind a modal sheet, so the first match is not always the right one.
  Future<void> reveal(WidgetTester tester, Finder target) async {
    if (target.evaluate().isEmpty) {
      // Not built yet: scroll the top page until it is.
      await tester.scrollUntilVisible(
        target,
        300,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .last,
      );
    }
    final matches = target.evaluate().length;
    for (var m = 0; m < matches; m++) {
      await tester.ensureVisible(target.at(m));
      await tester.pump();
      if (target.at(m).hitTestable().evaluate().isNotEmpty) return;
    }
  }

  Future<void> tapText(
    WidgetTester tester,
    String text, {
    bool settle = true,
  }) async {
    await reveal(tester, find.text(text));
    await tester.tap(find.text(text).hitTestable().first);
    if (settle) await tester.pumpAndSettle();
  }

  Future<void> tapBy(WidgetTester tester, Finder finder) async {
    await reveal(tester, finder);
    await tester.tap(finder.hitTestable().first);
    await tester.pumpAndSettle();
  }

  group('onboarding', () {
    testWidgets(
      'opens on first run, in short steps, and creates a draft at the end',
      (tester) async {
        final d = await start(tester, onboarding: true);
        expect(find.text('Paso 1 de 7'), findsOneWidget);
        expect(
          find.text('¿Cuánta experiencia tienes entrenando?'),
          findsOneWidget,
        );
        await tapText(tester, 'Principiante');
        await tapText(tester, 'Siguiente');
        expect(find.text('Paso 2 de 7'), findsOneWidget);
        await tapText(tester, 'Ganar músculo');
        await tapText(tester, 'Siguiente');
        // Days: exactly three are required before continuing.
        expect(find.text('Paso 3 de 7'), findsOneWidget);
        FilledButton next() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Siguiente'),
        );
        // The usual Tuesday/Thursday/Saturday start selected; clear them.
        for (final day in ['Martes', 'Jueves', 'Sábado']) {
          await tapText(tester, day);
        }
        expect(find.textContaining('Elige 3 días más'), findsOneWidget);
        expect(next().onPressed, isNull);
        await tapText(tester, 'Lunes');
        await tapText(tester, 'Miércoles');
        expect(find.textContaining('Elige 1 día más'), findsOneWidget);
        expect(next().onPressed, isNull);
        await tapText(tester, 'Viernes');
        expect(
          find.text('Tres días elegidos. El resto son de descanso.'),
          findsOneWidget,
        );
        expect(next().onPressed, isNotNull);
        // A fourth day cannot be added.
        await tapText(tester, 'Domingo');
        expect(d.coach.profile.trainingDays.length, 3);
        await tapText(tester, 'Siguiente');
        // Equipment: body weight is always on.
        expect(find.text('Paso 4 de 7'), findsOneWidget);
        expect(
          find.text('El peso corporal siempre está disponible.'),
          findsOneWidget,
        );
        await tapText(tester, 'Mancuernas');
        await tapText(tester, 'Siguiente');
        await tapText(tester, '45 min');
        await tapText(tester, 'Siguiente');
        await tapText(tester, 'Siguiente'); // energy keeps its default
        expect(find.text('Paso 7 de 7'), findsOneWidget);
        expect(find.text('Terminar y crear mi plan'), findsOneWidget);
        await tapText(tester, 'Terminar y crear mi plan');
        expect(
          find.text('Paso 7 de 7'),
          findsNothing,
          reason: 'the sheet closed',
        );
        final p = d.coach.profile;
        expect(
          [p.onboarded, p.experience, p.goal, p.sessionMinutes],
          [true, Experience.beginner, TrainingGoal.muscle, 45],
        );
        expect(p.trainingDays, [1, 3, 5]);
        // Everything starts selected; tapping "Mancuernas" cleared it.
        expect(p.equipment, isNot(contains(Equipment.dumbbell)));
        expect(p.equipment, contains(Equipment.barbell));
        expect(p.weightKg, isNull);
        expect(d.repository.draft!.routines.length, 3);
        expect(
          d.repository.planFor(DateTime(2026, 10, 1)).source,
          PlanSource.example,
        );
        d.shell.open(AppPage.plan);
        await tester.pumpAndSettle();
        expect(find.text('Borrador pendiente'), findsOneWidget);
      },
    );
    // D45: skipping no longer gives a plan; it says how to create one.
    testWidgets('can be skipped without a plan, and says so', (tester) async {
      final d = await start(tester, onboarding: true);
      expect(
        find.textContaining('No se pide ningún permiso del teléfono'),
        findsOneWidget,
      );
      await tapText(tester, 'Saltar por ahora');
      expect(find.text('Paso 1 de 7'), findsNothing);
      expect(d.coach.needsOnboarding, isFalse);
      expect(d.coach.usingExample, isTrue);
      expect(d.repository.draft, isNull);
      // From the profile it can be completed later.
      await tester.tap(find.byTooltip('Mi perfil y minicoach'));
      await tester.pumpAndSettle();
      expect(find.text('Completa tu perfil'), findsOneWidget);
      expect(
        find.textContaining('Aún no completaste tu perfil'),
        findsOneWidget,
      );
    });
    testWidgets('is not offered again after skipping', (tester) async {
      final d = await start(
        tester,
        onboarding: true,
        snapshot: AppSnapshot(profile: const UserProfile(skippedSetup: true)),
      );
      expect(d.coach.needsOnboarding, isFalse);
      expect(find.text('Paso 1 de 7'), findsNothing);
    });
    testWidgets('resumes where it was left', (tester) async {
      await start(
        tester,
        onboarding: true,
        snapshot: AppSnapshot(
          profile: const UserProfile(
            experience: Experience.advanced,
            setupStep: 3,
          ),
        ),
      );
      expect(find.text('Paso 4 de 7'), findsOneWidget);
      expect(find.text('¿Con qué equipo cuentas?'), findsOneWidget);
      await tapText(tester, 'Atrás');
      expect(find.text('Paso 3 de 7'), findsOneWidget);
    });
    testWidgets('optional body data: empty is fine, bad values are explained', (
      tester,
    ) async {
      final d = await start(
        tester,
        onboarding: true,
        snapshot: AppSnapshot(profile: const UserProfile(setupStep: 6)),
      );
      expect(find.text('Paso 7 de 7'), findsOneWidget);
      expect(
        find.textContaining(
          'Si lo dejas vacío, el cardio registrará la duración',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Peso corporal (opcional)'),
        '10',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Edad (opcional)'),
        '5',
      );
      await tapText(tester, 'Terminar y crear mi plan');
      expect(
        find.textContaining(
          'Introduce un peso entre 25 y 300 kg, o déjalo vacío',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Introduce una edad entre 14 y 100 años, o déjala vacía',
        ),
        findsOneWidget,
      );
      expect(d.coach.profile.onboarded, isFalse);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Peso corporal (opcional)'),
        '82,5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Edad (opcional)'),
        '',
      );
      await tapText(tester, 'Terminar y crear mi plan');
      expect(d.coach.profile.weightKg, 82.5);
      expect(d.coach.profile.age, isNull);
    });
    testWidgets('every step fits 320 px at 200% text', (tester) async {
      await start(tester, width: 320, scale: 2, onboarding: true);
      for (var step = 1; step <= 6; step++) {
        expect(find.text('Paso $step de 7'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'step $step');
        await tapText(tester, 'Siguiente');
      }
      expect(find.text('Paso 7 de 7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('controls meet the 48 px target and the title is a header', (
      tester,
    ) async {
      await start(tester, onboarding: true);
      for (final label in ['Siguiente', 'Saltar por ahora']) {
        final box = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        );
        expect(
          tester.getSize(box).height,
          greaterThanOrEqualTo(48),
          reason: label,
        );
      }
      expect(
        find.ancestor(
          of: find.text('Paso 1 de 7'),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.header == true,
          ),
        ),
        findsOneWidget,
      );
    });
  });
  group('profile form', () {
    testWidgets(
      'validates optional data, needs three days, and proposes a draft',
      (tester) async {
        final d = await start(
          tester,
          snapshot: AppSnapshot(
            profile: const UserProfile(onboarded: true, weightKg: 70, age: 30),
          ),
        );
        await tester.tap(find.byTooltip('Mi perfil y minicoach'));
        await tester.pumpAndSettle();
        expect(find.text('Tu minicoach'), findsOneWidget);
        expect(
          find.textContaining('Cambiar tu perfil propone un borrador de plan'),
          findsOneWidget,
        );
        // Only two days: saving is disabled.
        await tapText(tester, 'Martes');
        expect(find.textContaining('Elige 1 día más'), findsOneWidget);
        FilledButton save() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Guardar y proponer plan'),
        );
        await reveal(tester, find.text('Guardar y proponer plan'));
        expect(save().onPressed, isNull);
        await tapText(tester, 'Lunes');
        await reveal(tester, find.text('Guardar y proponer plan'));
        expect(save().onPressed, isNotNull);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Peso corporal (opcional)'),
          '999',
        );
        await tapText(tester, 'Guardar y proponer plan');
        expect(
          find.textContaining('Introduce un peso entre 25 y 300 kg'),
          findsOneWidget,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Peso corporal (opcional)'),
          '',
        );
        await tapText(tester, 'Guardar y proponer plan');
        expect(
          d.coach.profile.weightKg,
          isNull,
          reason: 'cleared means unknown',
        );
        expect(d.coach.profile.trainingDays, [1, 4, 6]);
        expect(d.repository.draft, isNotNull);
        expect(d.repository.profileHistory.single.reason, ProfileChange.edit);
      },
    );
    testWidgets('shows the history of answers', (tester) async {
      final d = await start(
        tester,
        snapshot: AppSnapshot(profile: const UserProfile(onboarded: true)),
      );
      await d.coach.saveEdit(
        d.coach.profile.copyWith(goal: TrainingGoal.fitness),
      );
      await tester.tap(find.byTooltip('Mi perfil y minicoach'));
      await tester.pumpAndSettle();
      await tapText(tester, 'Historial de respuestas (1)');
      await reveal(tester, find.text('Edición'));
      expect(find.text('Edición'), findsOneWidget);
      expect(find.textContaining('Mejorar condición'), findsWidgets);
    });
    testWidgets('fits 320 px at 200% text', (tester) async {
      await start(
        tester,
        width: 320,
        scale: 2,
        snapshot: AppSnapshot(profile: const UserProfile(onboarded: true)),
      );
      await tester.tap(find.byTooltip('Mi perfil y minicoach'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('Guardar y proponer plan'));
      expect(tester.takeException(), isNull);
    });
  });
  group('plan screen and editor', () {
    Future<AppDependencies> onPlan(
      WidgetTester tester, {
      double width = 390,
      double scale = 1,
    }) async {
      final d = await start(
        tester,
        width: width,
        scale: scale,
        snapshot: AppSnapshot(
          profile: const UserProfile(
            onboarded: true,
            experience: Experience.intermediate,
            trainingDays: [
              DateTime.tuesday,
              DateTime.thursday,
              DateTime.saturday,
            ],
          ),
        ),
      );
      d.shell.open(AppPage.plan);
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('names the example plan honestly', (tester) async {
      await onPlan(tester);
      expect(find.text('Plan de ejemplo'), findsOneWidget);
      expect(find.textContaining('no un plan hecho para ti'), findsOneWidget);
      expect(find.text('Editar plan'), findsOneWidget);
      expect(find.text('Generar desde mi perfil'), findsOneWidget);
    });
    testWidgets(
      'generate, review, edit, accept: the plan changes only from the chosen date',
      (tester) async {
        final d = await onPlan(tester);
        await tapText(tester, 'Generar desde mi perfil');
        expect(find.text('Borrador pendiente'), findsOneWidget);
        expect(
          find.textContaining('no una prescripción personalizada'),
          findsOneWidget,
        );
        expect(
          d.repository.planFor(DateTime(2026, 10, 1)).source,
          PlanSource.example,
        );
        await tapText(tester, 'Revisar borrador');
        expect(
          find.textContaining('no afecta a tus sesiones ya registradas'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const ValueKey('plan-name')),
          'Mi plan de prueba',
        );
        await tester.pump();
        await tapText(tester, 'Guardar borrador');
        expect(d.repository.draft!.name, 'Mi plan de prueba');
        // The button now reads "Borrador guardado" (the snack bar says it too).
        await reveal(
          tester,
          find.widgetWithText(OutlinedButton, 'Borrador guardado'),
        );
        expect(
          tester
              .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Borrador guardado'),
              )
              .onPressed,
          isNull,
        );
        // Edit the first exercise's prescription.
        final first = d.repository.draft!.days.first.routine.exercises.first;
        await tapBy(
          tester,
          find.byTooltip('Opciones de ${exerciseFor(first.exerciseId).name}'),
        );
        await tapText(tester, 'Editar series y reps');
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Series'),
          '5',
        );
        await tapText(tester, 'Guardar en el borrador');
        await reveal(tester, find.text('Guardar borrador'));
        expect(
          find.text('Guardar borrador'),
          findsOneWidget,
          reason: 'the edit made it dirty again',
        );
        // Accept from today.
        await tapText(tester, 'Aceptar plan');
        expect(find.textContaining('no cambian'), findsOneWidget);
        await tapText(tester, 'Aceptar');
        expect(
          find.text('Editar plan'),
          findsOneWidget,
          reason: 'back on the plan screen',
        );
        final accepted = d.repository.plans.firstWhere(
          (p) => p.status == PlanStatus.accepted,
        );
        expect(accepted.name, 'Mi plan de prueba');
        expect(accepted.routines.first.exercises.first.sets, 5);
        expect(accepted.effectiveFrom, '2026-10-01');
        expect(find.text('Mi plan de prueba'), findsOneWidget);
        expect(find.textContaining('En uso desde'), findsOneWidget);
        await reveal(tester, find.text('Versiones aceptadas (1)'));
        expect(find.text('Versiones aceptadas (1)'), findsOneWidget);
        expect(find.text('Borrador pendiente'), findsNothing);
      },
    );
    testWidgets('leaving with unsaved changes asks first', (tester) async {
      final d = await onPlan(tester);
      await tapText(tester, 'Editar plan');
      await tester.enterText(
        find.byKey(const ValueKey('plan-name')),
        'Cambio sin guardar',
      );
      await tester.pump();
      // System back / gesture goes through the same confirmation.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('¿Salir sin guardar?'), findsOneWidget);
      await tapText(tester, 'Seguir editando');
      expect(find.byKey(const ValueKey('plan-name')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tapText(tester, 'Salir sin guardar');
      expect(find.byKey(const ValueKey('plan-name')), findsNothing);
      expect(
        d.repository.draft!.name,
        'Mi plan',
        reason: 'the unsaved name was dropped',
      );
    });
    testWidgets('leaving without changes does not ask', (tester) async {
      await onPlan(tester);
      await tapText(tester, 'Editar plan');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('¿Salir sin guardar?'), findsNothing);
      expect(find.byKey(const ValueKey('plan-name')), findsNothing);
    });
    testWidgets(
      'editing offers removal and the picker, and flags an invalid plan',
      (tester) async {
        final d = await onPlan(tester);
        await tapText(tester, 'Editar plan');
        for (final id in ['squat', 'rdl', 'press']) {
          await tapBy(
            tester,
            find.byTooltip('Opciones de ${exerciseFor(id).name}'),
          );
          await tapText(tester, 'Quitar');
        }
        await reveal(tester, find.text('Antes de aceptar'));
        expect(find.text('Antes de aceptar'), findsOneWidget);
        expect(
          find.textContaining('añade al menos un ejercicio'),
          findsWidgets,
        );
        await reveal(tester, find.text('Aceptar plan'));
        expect(
          tester
              .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Aceptar plan'),
              )
              .onPressed,
          isNull,
        );
        // Add one back from the picker, searched without accents.
        await tapBy(tester, find.text('Añadir ejercicio').first);
        await tester.enterText(
          find.widgetWithText(TextField, 'Buscar ejercicio o músculo'),
          'sentadilla bulgara',
        );
        await tester.pumpAndSettle();
        await tapText(tester, 'Sentadilla búlgara');
        final remaining = tester
            .widgetList<Text>(find.textContaining('• '))
            .map((t) => t.data)
            .toList();
        expect(
          find.text('Antes de aceptar'),
          findsNothing,
          reason: '$remaining',
        );
        expect(
          d.repository.draft!.days.first.routine.exercises.length,
          3,
          reason: 'not saved yet',
        );
      },
    );
    testWidgets('discarding the draft asks for confirmation', (tester) async {
      final d = await onPlan(tester);
      await tapText(tester, 'Editar plan');
      await tapText(tester, 'Descartar borrador');
      expect(find.text('¿Descartar el borrador?'), findsOneWidget);
      await tapText(tester, 'Cancelar');
      expect(d.repository.draft, isNotNull);
      await tapText(tester, 'Descartar borrador');
      await tapText(tester, 'Descartar');
      expect(d.repository.draft, isNull);
      expect(find.text('Borrador pendiente'), findsNothing);
    });
    testWidgets('Hoy follows the accepted plan', (tester) async {
      final d = await onPlan(tester);
      await d.repository.saveDraft(
        PlanVersion(
          id: 'x-plan',
          status: PlanStatus.draft,
          source: PlanSource.manual,
          name: 'Casa',
          createdAt: DateTime.utc(2026, 10, 1),
          days: [
            for (final (i, w) in [
              DateTime.monday,
              DateTime.thursday,
              DateTime.saturday,
            ].indexed)
              PlanDay(
                w,
                Routine(
                  id: 'x-r$i',
                  name: 'Casa $i',
                  focus: '',
                  warmup: 'Calienta',
                  exercises: [
                    PlanExercise.fromExercise(exerciseFor('pushup'))
                        .copyWith(sets: 4, repsMin: 10, repsMax: 12, rir: 1),
                    PlanExercise.fromExercise(exerciseFor('plank')),
                  ],
                ),
              ),
          ],
        ),
      );
      await d.repository.acceptDraft(DateTime(2026, 10, 1));
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      expect(find.text('Casa 1'), findsOneWidget);
      expect(find.text('Flexiones'), findsOneWidget);
      expect(find.text('4 × 10–12 · RIR 1'), findsOneWidget);
      expect(find.text('3 × 30–45 s · RIR 2'), findsOneWidget);
      // The plan's own prescription is not rewritten by the profile.
      expect(find.textContaining('Plan inicial'), findsNothing);
    });
    testWidgets('the plan screen and editor fit 320 px at 200% text', (
      tester,
    ) async {
      final d = await onPlan(tester, width: 320, scale: 2);
      await tapText(tester, 'Generar desde mi perfil');
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Revisar borrador');
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('Descartar borrador'));
      expect(tester.takeException(), isNull);
      expect(d.repository.draft, isNotNull);
    });
  });
  group('library', () {
    Future<AppDependencies> inLibrary(
      WidgetTester tester, {
      FakeLauncher? launcher,
      AppSnapshot? snapshot,
      double width = 390,
      double scale = 1,
    }) async {
      final d = await start(
        tester,
        launcher: launcher,
        snapshot: snapshot,
        width: width,
        scale: scale,
      );
      d.shell.open(AppPage.exercises);
      await tester.pumpAndSettle();
      return d;
    }

    Future<void> search(WidgetTester tester, String query) async {
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar ejercicio o músculo'),
        query,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('search ignores accents and combines with the filters', (
      tester,
    ) async {
      final d = await inLibrary(tester);
      expect(find.text('${exerciseCatalog.length} ejercicios'), findsOneWidget);
      await search(tester, 'triceps');
      // Muscles count too ("Pecho y tríceps"), so several exercises match.
      expect(
        d.exercises.filtered.map((e) => e.id),
        containsAll(['bench', 'triceps', 'skull', 'benchdip']),
      );
      await reveal(tester, find.text('Extensión de tríceps'));
      expect(find.text('Extensión de tríceps'), findsOneWidget);
      await tapBy(tester, find.widgetWithText(FilterChip, 'Peso corporal'));
      expect(find.text('Fondos en banco'), findsOneWidget);
      expect(find.text('Extensión de tríceps'), findsNothing);
      // Body-weight exercises that train the triceps.
      expect(d.exercises.filtered.map((e) => e.id), ['pushup', 'benchdip']);
      await search(tester, 'zzz');
      expect(find.text('Sin resultados'), findsOneWidget);
      expect(find.text('0 ejercicios'), findsOneWidget);
    });
    testWidgets('"solo mi equipo" follows the profile', (tester) async {
      await inLibrary(
        tester,
        snapshot: AppSnapshot(
          profile: const UserProfile(equipment: {Equipment.dumbbell}),
        ),
      );
      await search(tester, 'press de banca');
      expect(find.text('Press de banca'), findsOneWidget);
      await tapBy(
        tester,
        find.widgetWithText(SwitchListTile, 'Solo mi equipo'),
      );
      expect(find.text('Press de banca con mancuernas'), findsOneWidget);
      expect(find.text('Press de banca'), findsNothing);
      await search(tester, 'flexiones');
      expect(
        find.text('Flexiones'),
        findsOneWidget,
        reason: 'body weight is always available',
      );
    });
    testWidgets(
      'details show equipment, warm-up, technique and compatible alternatives',
      (tester) async {
        await inLibrary(tester);
        await search(tester, 'press de banca');
        await tester.tap(find.text('Press de banca').first);
        await tester.pumpAndSettle();
        expect(find.textContaining('PECHO · BARRA'), findsOneWidget);
        expect(find.text('Calentamiento'), findsOneWidget);
        expect(find.text('Técnica'), findsOneWidget);
        await reveal(tester, find.text('Alternativas con tu equipo'));
        Finder inSheet(String text) => find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(text),
        );
        expect(inSheet('Press de banca con mancuernas'), findsOneWidget);
        expect(inSheet('Flexiones'), findsOneWidget);
        // An alternative opens its own details.
        await tapBy(tester, inSheet('Flexiones'));
        expect(find.textContaining('PECHO · PESO CORPORAL'), findsOneWidget);
      },
    );
    testWidgets(
      'the tutorial is a labelled search, with retry, copy and no false promise',
      (tester) async {
        final launcher = FakeLauncher(works: false);
        await inLibrary(tester, launcher: launcher);
        await search(tester, 'sentadilla con barra');
        await tester.tap(find.text('Sentadilla con barra').first);
        await tester.pumpAndSettle();
        await reveal(
          tester,
          find.textContaining('no es un video seleccionado'),
        );
        expect(
          find.textContaining('no es un video seleccionado'),
          findsOneWidget,
        );
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await tapText(tester, 'Buscar tutorial en YouTube');
        expect(launcher.opened.single.host, 'www.youtube.com');
        expect(launcher.opened.single.path, '/results');
        await reveal(tester, find.text('Reintentar'));
        expect(
          find.text('No se pudo abrir YouTube. Revisa la conexión.'),
          findsOneWidget,
        );
        expect(
          find.text('Buscar en YouTube'),
          findsNothing,
          reason: 'the search already is the fallback',
        );
        await tapText(tester, 'Reintentar');
        expect(launcher.opened, hasLength(2));
        launcher.works = true;
        await tapText(tester, 'Reintentar');
        expect(
          find.text('No se pudo abrir YouTube. Revisa la conexión.'),
          findsNothing,
        );
        launcher.works = false;
        await tapText(tester, 'Buscar tutorial en YouTube');
        await tapText(tester, 'Copiar enlace');
        expect(copied, contains('youtube.com/results'));
        expect(find.text('Enlace copiado'), findsOneWidget);
      },
    );
    testWidgets('the library fits 320 px at 200% text', (tester) async {
      await inLibrary(tester, width: 320, scale: 2);
      expect(tester.takeException(), isNull);
      await search(tester, 'press de banca');
      // At 200% the result is below the fold: scroll until it is built.
      for (
        var i = 0;
        i < 12 && find.text('Press de banca').evaluate().isEmpty;
        i++
      ) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -300));
        await tester.pump();
      }
      await tester.ensureVisible(find.text('Press de banca').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Press de banca').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('PECHO · BARRA'), findsOneWidget);
    });
  });
}
