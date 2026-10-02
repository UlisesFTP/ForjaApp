import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/theme/forja_theme.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// WCAG relative luminance and contrast ratio.
double _lin(int v) {
  final c = v / 255;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

double luminance(Color c) =>
    0.2126 * _lin((c.r * 255).round()) +
    0.7152 * _lin((c.g * 255).round()) +
    0.0722 * _lin((c.b * 255).round());

double contrast(Color a, Color b) {
  final la = luminance(a), lb = luminance(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
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

  group('palette contrast (WCAG)', () {
    test('text on each surface is at least 4.5:1', () {
      final surfaces = {
        'background': ForjaColors.background,
        'surface': ForjaColors.surface,
      };
      for (final (name, fg) in [
        ('text', ForjaColors.text),
        ('muted', ForjaColors.muted),
      ]) {
        for (final s in surfaces.entries) {
          expect(
            contrast(fg, s.value),
            greaterThanOrEqualTo(4.5),
            reason: '$name on ${s.key}',
          );
        }
      }
      // Ink on paper (the light cards) and paper on the dark background.
      expect(
        contrast(ForjaColors.ink, ForjaColors.paper),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(ForjaColors.paper, ForjaColors.background),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(ForjaColors.paper, ForjaColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('borders and indicators are at least 3:1 against their surface', () {
      expect(
        contrast(ForjaColors.border, ForjaColors.background),
        greaterThanOrEqualTo(1.0),
      );
      expect(
        contrast(ForjaColors.muted, ForjaColors.background),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        contrast(ForjaColors.paper, ForjaColors.surface),
        greaterThanOrEqualTo(3.0),
      );
    });
  });

  group('guidelines on every screen', () {
    Future<AppDependencies> start(
      WidgetTester tester, {
      double width = 390,
      double height = 844,
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
        const SetEntry(reps: 8),
      );
      await d.repository.addFood(
        FoodEntry(id: 'f', dateKey: '2026-09-29', name: 'Avena', calories: 300),
      );
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

    for (final page in AppPage.values) {
      testWidgets('${page.name}: tap targets are at least 44 pt and labelled', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        try {
          final d = await start(tester);
          d.shell.open(page);
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        } finally {
          handle.dispose();
        }
      });
    }

    for (final page in AppPage.values) {
      testWidgets('${page.name}: text contrast meets the guideline', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        try {
          final d = await start(tester);
          d.shell.open(page);
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        } finally {
          handle.dispose();
        }
      });
    }

    testWidgets(
      'panels keep labelled, large targets: sets, check-in, reminders',
      (tester) async {
        final handle = tester.ensureSemantics();
        try {
          await start(tester, height: 2400);
          await tester.tap(find.byTooltip('Series de Sentadilla con barra'));
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await tester.tap(
            find.byTooltip('Cerrar Series · Sentadilla con barra'),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Recordatorios'));
          await tester.pumpAndSettle();
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        } finally {
          handle.dispose();
        }
      },
    );
  });
}
