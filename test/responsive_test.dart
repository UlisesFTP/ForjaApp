import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/core/droplet_navigation.dart';
import 'package:forja_app/ui/core/responsive.dart';
import 'package:forja_app/ui/core/widgets.dart';
import 'package:forja_app/ui/nutrition/widgets/food_form.dart';
import 'package:forja_app/ui/settings/widgets/data_sheet.dart';
import 'package:forja_app/ui/today/widgets/sets_sheet.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// A screen: logical size and text scale.
typedef Screen = ({String name, double width, double height, double text});

Screen _s(String name, double width, double height, [double text = 1]) =>
    (name: name, width: width, height: height, text: text);

/// Phones and tablets, upright and sideways, at normal and large text.
final screens = <Screen>[
  // Phones, portrait.
  _s('phone 320×568', 320, 568),
  _s('phone 320×568 text 200%', 320, 568, 2),
  _s('phone 360×640', 360, 640),
  _s('phone 390×844', 390, 844),
  _s('phone 412×915', 412, 915),
  _s('phone 430×932 text 130%', 430, 932, 1.3),
  // Phones, landscape.
  _s('phone landscape 568×320', 568, 320),
  _s('phone landscape 640×360', 640, 360),
  _s('phone landscape 640×360 text 200%', 640, 360, 2),
  _s('phone landscape 844×390', 844, 390),
  _s('phone landscape 844×390 text 200%', 844, 390, 2),
  _s('phone landscape 915×412', 915, 412),
  _s('phone landscape 932×430 text 130%', 932, 430, 1.3),
  // Tablets, portrait.
  _s('tablet 600×960', 600, 960),
  _s('tablet 768×1024', 768, 1024),
  _s('tablet 768×1024 text 200%', 768, 1024, 2),
  _s('tablet 800×1280', 800, 1280),
  _s('tablet 834×1194', 834, 1194),
  // Tablets, landscape.
  _s('tablet landscape 960×600', 960, 600),
  _s('tablet landscape 1024×768', 1024, 768),
  _s('tablet landscape 1024×768 text 200%', 1024, 768, 2),
  _s('tablet landscape 1194×834', 1194, 834),
  _s('tablet landscape 1280×800', 1280, 800),
  _s('tablet landscape 1366×1024', 1366, 1024),
  _s('tablet landscape 1366×1024 text 130%', 1366, 1024, 1.3),
];

const _twoColumnPages = {
  AppPage.today,
  AppPage.plan,
  AppPage.progress,
  AppPage.cardio,
  AppPage.nutrition,
};

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

  Future<AppDependencies> start(WidgetTester tester, Screen screen) async {
    final size = Size(screen.width, screen.height);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      clock: () => DateTime(2026, 9, 29, 9),
    );
    addTearDown(() => unawaited(d.dispose()));
    await d.repository.saveProfile(
      const UserProfile(
        onboarded: true,
        weightKg: 70,
        lastReview: '2026-08-01',
      ),
    );
    await d.repository.addSet(
      DateTime(2026, 9, 29),
      'squat',
      const SetEntry(weightKg: 60, reps: 8, rir: 2),
    );
    for (final (id, name) in [
      ('a', 'Avena con leche y plátano en rodajas'),
      ('b', 'Pollo con arroz'),
    ]) {
      await d.repository.addFood(
        FoodEntry(id: id, dateKey: '2026-09-29', name: name, calories: 400),
      );
    }
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(screen.text),
        ),
        child: ForjaApp(dependencies: d, offerOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();
    return d;
  }

  /// Nothing visible may reach past the side of the screen (no sideways page
  /// scroll, no clipped text), except inside a horizontal scroller such as
  /// the week strip.
  void expectInsideScreen(WidgetTester tester, Screen screen, String where) {
    for (final element in find.byType(RichText).evaluate()) {
      final box = element.renderObject! as RenderBox;
      if (!box.hasSize || !box.attached) continue;
      final horizontal = element.findAncestorWidgetOfExactType<Scrollable>();
      if (horizontal != null && horizontal.axisDirection.name == 'right') {
        continue;
      }
      final rect = box.localToGlobal(Offset.zero) & box.size;
      expect(
        rect.left >= -0.5 && rect.right <= screen.width + 0.5,
        isTrue,
        reason:
            '$where: text ${(element.widget as RichText).text.toPlainText()} at $rect',
      );
    }
  }

  for (final screen in screens) {
    testWidgets('${screen.name}: every page lays out without overflow', (
      tester,
    ) async {
      final d = await start(tester, screen);
      final rail = screen.width > screen.height;
      expect(find.byType(DropletRail), rail ? findsOneWidget : findsNothing);
      expect(
        find.byType(DropletNavigation),
        rail ? findsNothing : findsOneWidget,
      );
      final factor = screen.text.clamp(1.0, 1.6);
      for (final page in AppPage.values) {
        d.shell.open(page);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${page.name} threw');
        expectInsideScreen(tester, screen, page.name);
        if (_twoColumnPages.contains(page)) {
          final width = tester.getSize(find.byType(IndexedStack)).width;
          expect(
            find.byKey(const ValueKey('two-columns')),
            width >= Breakpoints.twoColumns * factor
                ? findsOneWidget
                : findsNothing,
            reason: '${page.name} at $width px of content',
          );
        }
      }
    });
  }

  group('navigation', () {
    testWidgets('portrait keeps the bottom bar; it is centred on a tablet', (
      tester,
    ) async {
      await start(tester, _s('tablet', 834, 1194));
      final bar = tester.getRect(find.byType(DropletNavigation));
      expect(bar.width, lessThanOrEqualTo(640));
      expect(bar.center.dx, closeTo(834 / 2, 0.5));
      expect(bar.bottom, closeTo(1194, 0.5));
    });

    for (final screen in [
      _s('568×320', 568, 320),
      _s('640×360', 640, 360),
      _s('844×390', 844, 390),
      _s('1024×768', 1024, 768),
    ]) {
      testWidgets('landscape ${screen.name}: the rail shows all five items '
          'without scrolling and switches pages', (tester) async {
        final d = await start(tester, screen);
        expect(
          find.descendant(
            of: find.byType(DropletRail),
            matching: find.byType(Scrollable),
          ),
          findsNothing,
        );
        for (final (i, label) in navLabels.indexed) {
          final rect = tester.getRect(
            find.descendant(
              of: find.byType(DropletRail),
              matching: find.text(label),
            ),
          );
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(screen.height));
          await tester.tap(
            find.descendant(
              of: find.byType(DropletRail),
              matching: find.text(label),
            ),
          );
          await tester.pumpAndSettle();
          expect(d.shell.navIndex, i);
        }
      });
    }

    testWidgets('rail items say which page they open and which is current', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        final d = await start(tester, _s('844×390', 844, 390));
        d.shell.open(AppPage.progress);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(
            find.descendant(
              of: find.byType(DropletRail),
              matching: find.bySemanticsLabel('Progreso'),
            ),
          ),
          isSemantics(
            label: 'Progreso',
            isButton: true,
            isSelected: true,
            hasTapAction: true,
          ),
        );
        expect(
          tester.getSemantics(
            find.descendant(
              of: find.byType(DropletRail),
              matching: find.bySemanticsLabel('Plan'),
            ),
          ),
          isSemantics(label: 'Plan', isButton: true, isSelected: false),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('landscape with a camera cutout on the side: the rail keeps '
        'clear of it and the content does not add it again (seen on a '
        'phone: every list tile was shifted)', (tester) async {
      const size = Size(844, 390);
      const cutout = EdgeInsets.only(left: 40);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
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
          data: const MediaQueryData(
            size: size,
            padding: cutout,
            viewPadding: cutout,
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      // The painted rail starts after the cutout.
      expect(
        tester
            .getRect(
              find
                  .descendant(
                    of: find.byType(DropletRail),
                    matching: find.byType(CustomPaint),
                  )
                  .first,
            )
            .left,
        greaterThanOrEqualTo(40),
      );
      d.shell.open(AppPage.plan);
      await tester.pumpAndSettle();
      final title = tester.getRect(find.text('Lunes 28 sep'));
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Lunes 28 sep'),
              matching: find.byType(SurfaceCard),
            )
            .first,
      );
      // The tile's own 16 px, not 16 + the cutout.
      expect(title.left - card.left, closeTo(16, 1));
    });

    testWidgets('large text on a short landscape screen: the rail scrolls '
        'rather than overlapping its items', (tester) async {
      await start(tester, _s('640×360 text 200%', 640, 360, 2));
      expect(tester.takeException(), isNull);
      final rects = [
        for (final label in navLabels)
          tester.getRect(
            find.descendant(
              of: find.byType(DropletRail),
              matching: find.text(label),
            ),
          ),
      ];
      for (var i = 1; i < rects.length; i++) {
        expect(rects[i].top, greaterThanOrEqualTo(rects[i - 1].bottom));
      }
    });

    testWidgets('reduced motion: the rail moves the drop at once', (
      tester,
    ) async {
      final size = const Size(844, 390);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
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
          data: const MediaQueryData(
            size: Size(844, 390),
            disableAnimations: true,
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(DropletRail),
          matching: find.text('Plan'),
        ),
      );
      // One frame later the selected icon already sits in the drop, beside
      // its label, instead of travelling there.
      await tester.pump();
      expect(d.shell.navIndex, 1);
      Finder inRail(Finder f) =>
          find.descendant(of: find.byType(DropletRail), matching: f);
      final icon = tester.getCenter(inRail(find.byIcon(navIcons[1])));
      final label = tester.getCenter(inRail(find.text('Plan')));
      expect(icon.dx, greaterThan(label.dx + 30));
    });
  });

  group('panels and pages on wide screens', () {
    for (final screen in [
      _s('phone landscape', 844, 390),
      _s('small phone landscape', 640, 360),
      _s('tablet', 1024, 768),
      _s('tablet text 200%', 768, 1024, 2),
    ]) {
      testWidgets('${screen.name}: sets, food and data panels open cleanly', (
        tester,
      ) async {
        final d = await start(tester, screen);
        final context = tester.element(find.byType(IndexedStack));
        Finder sheetMaterial() => find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Material),
            )
            .first;
        Future<void> check(String name, Future<void> Function() open) async {
          unawaited(open());
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: name);
          expect(
            tester.getSize(sheetMaterial()).width,
            lessThanOrEqualTo(600),
            reason: name,
          );
          expectInsideScreen(tester, screen, name);
          Navigator.of(context).pop();
          await tester.pumpAndSettle();
        }

        await check(
          'sets',
          () => showSets(context, d.today, 'squat', progression: d.progression),
        );
        await check('food form', () => showFoodForm(context, d.nutrition));
        await check('data', () => showData(context, d.data));
      });
    }

    testWidgets('two columns: each section stays its own screen-reader item '
        '(found on a phone: a whole column was one block)', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        final d = await start(tester, _s('tablet', 1024, 768));
        d.shell.open(AppPage.plan);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('two-columns')), findsOneWidget);
        final plan = tester.getSemantics(find.text('Plan de ejemplo'));
        final week = tester.getSemantics(find.text('28 sep — 4 oct'));
        expect(plan.id, isNot(week.id));
        expect(plan.label, isNot(contains('28 sep')));
      } finally {
        handle.dispose();
      }
    });

    testWidgets('tablet: the exercise library uses several columns', (
      tester,
    ) async {
      final d = await start(tester, _s('tablet', 1366, 1024));
      d.shell.open(AppPage.exercises);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('grid-3')), findsOneWidget);
    });

    testWidgets('phone: the library stays one column', (tester) async {
      final d = await start(tester, _s('phone', 390, 844));
      d.shell.open(AppPage.exercises);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('grid-2')), findsNothing);
      expect(find.byKey(const ValueKey('grid-3')), findsNothing);
    });

    testWidgets('tablet: Más is one centred column, not stretched', (
      tester,
    ) async {
      final d = await start(tester, _s('tablet', 1024, 768));
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      final page = tester.getRect(find.byType(IndexedStack));
      // The settings card is at most the readable width, and centred.
      final card = tester.getRect(
        find
            .ancestor(
              of: find.text('Datos y privacidad'),
              matching: find.byType(SurfaceCard),
            )
            .first,
      );
      expect(card.width, lessThanOrEqualTo(Breakpoints.readable + 0.5));
      expect(card.center.dx, closeTo(page.center.dx, 1));
    });

    testWidgets('tablet: Hoy puts the summary beside the exercises', (
      tester,
    ) async {
      await start(tester, _s('tablet', 1024, 768));
      final title = tester.getRect(find.text('Pierna & fuerza'));
      final first = tester.getRect(find.text('Sentadilla con barra'));
      expect(first.left, greaterThan(title.right));
      expect(first.top, lessThan(title.bottom + 40));
      // The finish button stays with the exercises.
      final finish = tester.getRect(
        find.byKey(const ValueKey('finish-session')),
      );
      expect(finish.left, greaterThanOrEqualTo(first.left - 60));
    });

    testWidgets('phone 390×844: Hoy is unchanged — three cards and finish '
        'above the bar without scrolling', (tester) async {
      await start(tester, _s('phone', 390, 844));
      final bar = tester.getRect(find.byType(DropletNavigation));
      final finish = tester.getRect(
        find.byKey(const ValueKey('finish-session')),
      );
      expect(finish.bottom, lessThanOrEqualTo(bar.top));
      expect(find.byKey(const ValueKey('two-columns')), findsNothing);
    });

    for (final screen in [_s('844×390', 844, 390), _s('1024×768', 1024, 768)]) {
      testWidgets('${screen.name}: Hoy and the rail meet the target and '
          'label guidelines', (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await start(tester, screen);
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          handle.dispose();
        }
      });
    }
  });
}
