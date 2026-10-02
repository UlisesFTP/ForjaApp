import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/core/droplet_navigation.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

// Bold label widths at normal size, close to DM Sans 14: Hoy, Plan,
// Progreso, Ejercicios, Más.
const _labels = [30.0, 32.0, 62.0, 70.0, 31.0];

double _sum(List<double> v) => v.fold(0.0, (a, b) => a + b);

// One line of the 14 px, 1.2 line-height label at the paragraph's own scale.
bool _isOneLine(RenderParagraph p) =>
    p.size.height < p.textScaler.scale(14) * 1.2 * 1.5;

void main() {
  group('how the bottom bar shares its width', () {
    test('items fill the bar exactly and every label fits with its gap', () {
      for (final width in [300.0, 340.0, 370.0, 392.0, 620.0]) {
        for (final scale in [1.0, 1.3, 2.0]) {
          final l = NavBarLayout.compute(
            width: width,
            textScale: scale,
            labelWidths: _labels,
          );
          expect(_sum(l.widths), closeTo(width, 0.001));
          for (var i = 0; i < 5; i++) {
            expect(
              l.widths[i],
              greaterThanOrEqualTo(
                _labels[i] * l.labelScale + NavBarLayout.minGap - 0.001,
              ),
              reason: 'item $i at $width px, text $scale',
            );
          }
        }
      }
    });

    test('labels follow the system text size while it fits, and stop '
        'growing when it would not', () {
      final roomy = NavBarLayout.compute(
        width: 620,
        textScale: 1.3,
        labelWidths: _labels,
      );
      expect(roomy.labelScale, 1.3);
      final tight = NavBarLayout.compute(
        width: 300,
        textScale: 2,
        labelWidths: _labels,
      );
      expect(tight.labelScale, lessThan(2));
      expect(tight.labelScale, greaterThanOrEqualTo(1));
    });

    test('on a typical phone the long labels get the roomier gap, not '
        'just the minimum', () {
      // 375 dp phone: 355 px of bar.
      final l = NavBarLayout.compute(
        width: 355,
        textScale: 1,
        labelWidths: _labels,
      );
      // Between "Progreso" and "Ejercicios": half of each item's slack.
      final gap =
          (l.widths[2] - _labels[2]) / 2 + (l.widths[3] - _labels[3]) / 2;
      expect(gap, greaterThanOrEqualTo(NavBarLayout.preferredGap - 0.001));
    });

    test('with room to spare the items are equal, so icons are evenly '
        'spaced', () {
      final l = NavBarLayout.compute(
        width: 620,
        textScale: 1,
        labelWidths: _labels,
      );
      for (final w in l.widths) {
        expect(w, closeTo(124, 0.001));
      }
    });

    test('on a 360 phone only the long labels grow; the others share the '
        'rest equally', () {
      final l = NavBarLayout.compute(
        width: 340,
        textScale: 1,
        labelWidths: _labels,
      );
      expect(l.widths[0], closeTo(l.widths[1], 0.001));
      expect(l.widths[1], closeTo(l.widths[4], 0.001));
      expect(l.widths[3], greaterThan(l.widths[0]));
      final centres = l.centres;
      expect(centres.first, closeTo(l.widths[0] / 2, 0.001));
      expect(centres.last, closeTo(340 - l.widths[4] / 2, 0.001));
    });
  });

  group('the bottom bar on phones', () {
    setUpAll(() async {
      await (FontLoader(
        'DM Sans',
      )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
      await (FontLoader('Barlow Condensed')
            ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
          .load();
    });

    Future<AppDependencies> start(
      WidgetTester tester,
      double width,
      double height,
      double text,
    ) async {
      final size = Size(width, height);
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
      await d.repository.saveProfile(const UserProfile(onboarded: true));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size, textScaler: TextScaler.linear(text)),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      return d;
    }

    Finder label(String text) => find.descendant(
      of: find.byType(DropletNavigation),
      matching: find.text(text),
    );

    for (final (width, height, text) in [
      (320.0, 568.0, 1.0),
      (320.0, 568.0, 2.0),
      (360.0, 640.0, 1.0),
      (360.0, 640.0, 1.3),
      (390.0, 844.0, 1.0),
      (390.0, 844.0, 2.0),
      (412.0, 915.0, 1.0),
      (600.0, 960.0, 1.0),
    ]) {
      testWidgets(
        '${width.toInt()}×${height.toInt()} text ${(text * 100).round()}%: '
        'labels stay on one line, apart, and every page is reachable',
        (tester) async {
          final d = await start(tester, width, height, text);
          // Selecting each page in turn: the bold label of the selected item
          // must still keep clear of its neighbours.
          for (var selected = 0; selected < 5; selected++) {
            await tester.tap(label(navLabels[selected]));
            await tester.pumpAndSettle();
            expect(d.shell.navIndex, selected);
            final rects = <Rect>[];
            for (final name in navLabels) {
              final paragraph = tester.renderObject<RenderParagraph>(
                find.descendant(
                  of: label(name),
                  matching: find.byType(RichText),
                ),
              );
              expect(
                _isOneLine(paragraph),
                isTrue,
                reason: '"$name" broke into lines',
              );
              rects.add(tester.getRect(label(name)));
            }
            for (var i = 1; i < 5; i++) {
              expect(
                rects[i].left - rects[i - 1].right,
                greaterThanOrEqualTo(6),
                reason: '"${navLabels[i - 1]}" and "${navLabels[i]}" touch',
              );
            }
            final bar = tester.getRect(find.byType(DropletNavigation));
            expect(rects.first.left, greaterThanOrEqualTo(bar.left));
            expect(rects.last.right, lessThanOrEqualTo(bar.right));
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('large text no longer turns the bar into a third of a small '
        'screen (it used to break "Pro-gres-o" over three lines)', (
      tester,
    ) async {
      await start(tester, 320, 568, 2);
      expect(
        tester.getSize(find.byType(DropletNavigation)).height,
        lessThan(568 / 4),
      );
    });

    testWidgets('icons sit over their labels', (tester) async {
      await start(tester, 360, 640, 1);
      for (final (i, name) in navLabels.indexed) {
        if (i == 0) continue; // the selected icon rides in the drop
        final icon = tester.getCenter(
          find.descendant(
            of: find.byType(DropletNavigation),
            matching: find.byIcon(navIcons[i]),
          ),
        );
        expect(icon.dx, closeTo(tester.getCenter(label(name)).dx, 1));
      }
    });

    testWidgets('the rail keeps its labels to 140 % so it does not take '
        'half of a phone turned sideways', (tester) async {
      await start(tester, 844, 390, 2);
      final rail = tester.getSize(
        find
            .descendant(
              of: find.byType(DropletRail),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(rail.width, lessThan(844 * .2));
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.descendant(
            of: find.byType(DropletRail),
            matching: find.text('Ejercicios'),
          ),
          matching: find.byType(RichText),
        ),
      );
      expect(_isOneLine(paragraph), isTrue);
      expect(
        paragraph.textScaler.scale(14) / 14,
        closeTo(DropletRail.maxLabelScale, 0.001),
      );
    });

    testWidgets('pages still open from the bar in Spanish order', (
      tester,
    ) async {
      final d = await start(tester, 390, 844, 1);
      await tester.tap(label('Ejercicios'));
      await tester.pumpAndSettle();
      expect(d.shell.page, AppPage.exercises);
    });
  });
}
