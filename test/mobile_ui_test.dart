import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:ui' show SemanticsAction;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/theme/forja_theme.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/ui/today/widgets/exercise_card.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class FakeLauncher implements TutorialLauncher {
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
  Future<AppDependencies> start(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: FakeLauncher(),
      clock: () => DateTime(2026, 9, 29),
    );
    // dispose() waits for storage to close, which needs real async time.
    // The ViewModels and repository are disposed synchronously; only closing
    // the storage is async, and it needs real time that testWidgets lacks.
    addTearDown(() => unawaited(d.dispose()));
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: Size(width, 844),
          textScaler: TextScaler.linear(scale),
        ),
        child: ForjaApp(dependencies: d, offerOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();
    return d;
  }

  testWidgets('390×844 shows three cards and completion above navigation', (
    tester,
  ) async {
    await start(tester);
    expect(find.byType(ExerciseCard), findsNWidgets(3));
    expect(find.text('Completar sesión').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    final cards = tester.getRect(find.byType(ExerciseCard).last),
        finish = tester.getRect(find.byKey(const ValueKey('finish-session')));
    expect(cards.bottom, lessThanOrEqualTo(finish.top));
    expect(finish.bottom, lessThan(746));
  });
  testWidgets('complete, edit weight, tap reorder and keyboard remain usable', (
    tester,
  ) async {
    final d = await start(tester);
    await tester.tap(find.byKey(const ValueKey('complete-squat')));
    await tester.pumpAndSettle();
    expect(d.today.completed, 1);
    await tester.enterText(find.byKey(const ValueKey('weight-squat')), '52.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(d.today.entries.first.weightKg, 52.5);
    await tester.tap(find.byTooltip('Mover Sentadilla con barra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mover abajo'));
    await tester.pumpAndSettle();
    expect(d.today.entries[1].exerciseId, 'squat');
    // Focused grip/menu exposes directional keyboard movement.
    await tester.tap(find.byTooltip('Mover Sentadilla con barra'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(d.today.entries.first.exerciseId, 'squat');
    await tester.tap(find.byKey(const ValueKey('complete-squat')));
    await tester.pumpAndSettle();
    expect(d.today.completed, 0);
  });
  testWidgets('drag reorders without losing completed state', (tester) async {
    final d = await start(tester);
    await tester.tap(find.byKey(const ValueKey('complete-squat')));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(
      tester.getCenter(find.byTooltip('Mover Sentadilla con barra')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(d.today.entries.first.exerciseId, isNot('squat'));
    expect(
      d.today.entries.firstWhere((e) => e.exerciseId == 'squat').completed,
      true,
    );
  });
  testWidgets('320 px with 200% text has no overflow across every page', (
    tester,
  ) async {
    final d = await start(tester, width: 320, scale: 2);
    for (final page in AppPage.values) {
      d.shell.open(page);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: page.name);
    }
  });
  testWidgets('rest and all-completed states display explicitly', (
    tester,
  ) async {
    final d = await start(tester);
    for (final entry in [...d.today.entries]) {
      await d.today.toggle(entry.exerciseId);
    }
    await d.today.finish(SessionStatus.completed);
    await tester.pumpAndSettle();
    expect(find.text('Sesión completada'), findsWidgets);
    d.today.selectDate(DateTime(2026, 9, 30));
    await tester.pumpAndSettle();
    expect(find.text('Día de descanso'), findsOneWidget);
    expect(find.byType(ExerciseCard), findsNothing);
  });
  testWidgets(
    'details and check-in have visible close and restore opening focus',
    (tester) async {
      await start(tester);
      final details = find.byTooltip('Detalles de Sentadilla con barra');
      final detailIcon = find.descendant(
        of: details,
        matching: find.byIcon(Icons.info_outline),
      );
      final opener = Focus.of(tester.element(detailIcon));
      opener.requestFocus();
      await tester.pump();
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(find.text('Músculos'), findsOneWidget);
      await tester.tap(find.byTooltip('Cerrar Sentadilla con barra'));
      await tester.pumpAndSettle();
      expect(opener.hasFocus, isTrue);
      await tester.tap(find.text('¿Cómo te sientes?'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Cerrar ¿Cómo te sientes?'), findsOneWidget);
      await tester.tap(find.text('Cansado'));
      await tester.tap(find.text('Guardar check-in'));
      await tester.pumpAndSettle();
      expect(find.text('Cansado'), findsOneWidget);
    },
  );
  testWidgets('screen reader can complete and weight has a 44 px target', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      final d = await start(tester);
      final node = tester.getSemantics(
        find.bySemanticsLabel('Completar Sentadilla con barra'),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      tester
          .renderObject(find.byKey(const ValueKey('complete-squat')))
          .owner!
          .semanticsOwner!
          .performAction(node.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(d.today.completed, 1);
      expect(
        tester.getSize(find.byKey(const ValueKey('weight-squat'))).height,
        greaterThanOrEqualTo(44),
      );
    } finally {
      handle.dispose();
    }
  });
  test('monochrome text pairs meet normal-text contrast', () {
    double ratio(Color a, Color b) {
      final values = [a.computeLuminance(), b.computeLuminance()]..sort();
      return (values.last + .05) / (values.first + .05);
    }

    expect(
      ratio(ForjaColors.muted, ForjaColors.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      ratio(ForjaColors.text, ForjaColors.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      ratio(ForjaColors.ink, ForjaColors.paper),
      greaterThanOrEqualTo(4.5),
    );
  });
}
