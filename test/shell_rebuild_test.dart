import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/exercises/widgets/exercises_view.dart';
import 'package:forja_app/ui/plan/widgets/plan_view.dart';
import 'package:forja_app/ui/progress/widgets/progress_view.dart';
import 'package:forja_app/ui/today/widgets/today_view.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// The shell keeps every page alive in an IndexedStack. Changing tab must not
/// rebuild the pages that are not the one being shown: on a phone the worst
/// frame of a tab change was ≈169 ms (profile build, 120 Hz) and the other
/// six pages were being rebuilt each time.
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

  testWidgets('a tab change rebuilds only the pages involved', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _Launcher(),
      clock: () => DateTime(2026, 9, 29, 9),
    );
    addTearDown(() => unawaited(d.dispose()));
    await d.repository.saveProfile(
      const UserProfile(onboarded: true, weightKg: 70),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: ForjaApp(dependencies: d, offerOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();

    final counts = <Type, int>{};
    final watched = {TodayView, PlanView, ProgressView, ExercisesView};
    final previous = debugOnRebuildDirtyWidget;
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      if (watched.contains(element.widget.runtimeType)) {
        counts.update(
          element.widget.runtimeType,
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = previous);
    debugPrintRebuildDirtyWidgets = false;

    await tester.tap(find.text('Progreso').last);
    await tester.pumpAndSettle();

    // Nothing but the page that is shown may rebuild because the tab moved.
    expect(
      counts[TodayView] ?? 0,
      0,
      reason: 'Hoy was rebuilt only because the tab changed',
    );
    expect(counts[PlanView] ?? 0, 0, reason: 'Plan rebuilt by a tab change');
    expect(
      counts[ExercisesView] ?? 0,
      0,
      reason: 'Ejercicios rebuilt by a tab change',
    );
  });
}
