// Frame-time profile of the main screens on a real device (F14 performance).
//
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_test.dart -d <device>
//
// The app runs on an in-memory store with sixty days of history, so the
// phone's own data is never touched. Only a profile/release build gives
// meaningful numbers: debug builds are slower by design.
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:integration_test/integration_test.dart';

class _NoTutorials implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// Collects the engine's own per-frame timings while [action] runs. The
/// timeline of the VM service is not needed, so this works in a plain
/// profile build.
Future<Map<String, Object>> measure(Future<void> Function() action) async {
  final frames = <FrameTiming>[];
  void collect(List<FrameTiming> timings) => frames.addAll(timings);
  SchedulerBinding.instance.addTimingsCallback(collect);
  await action();
  // Timings reach Dart in batches; give the last batch time to arrive.
  await Future<void>.delayed(const Duration(seconds: 1));
  SchedulerBinding.instance.removeTimingsCallback(collect);
  double ms(Duration d) => d.inMicroseconds / 1000;
  double pct(List<double> v, double q) {
    if (v.isEmpty) return 0;
    final sorted = [...v]..sort();
    return sorted[((sorted.length - 1) * q).round()];
  }

  final build = [for (final f in frames) ms(f.buildDuration)];
  final raster = [for (final f in frames) ms(f.rasterDuration)];
  final total = [for (final f in frames) ms(f.totalSpan)];
  // 120 Hz is this phone's refresh rate: a frame has 8.33 ms; two periods
  // (16.7 ms) is the budget most people notice.
  return {
    'frames': frames.length,
    'build_p50_ms': pct(build, .5),
    'build_p90_ms': pct(build, .9),
    'build_p99_ms': pct(build, .99),
    'raster_p50_ms': pct(raster, .5),
    'raster_p90_ms': pct(raster, .9),
    'raster_p99_ms': pct(raster, .99),
    'total_p90_ms': pct(total, .9),
    'total_p99_ms': pct(total, .99),
    'total_worst_ms': total.isEmpty ? 0 : total.reduce((a, b) => a > b ? a : b),
    'over_16_7ms': total.where((t) => t > 16.7).length,
    'over_33_3ms': total.where((t) => t > 33.3).length,
  };
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scrolling the main screens stays within the frame budget', (
    tester,
  ) async {
    final d = await AppDependencies.create(
      store: MemoryForjaStore(),
      launcher: _NoTutorials(),
    );
    addTearDown(d.dispose);
    await d.repository.saveProfile(
      const UserProfile(onboarded: true, weightKg: 72),
      record: ProfileChange.edit,
    );
    // Sixty days of finished sessions so Progreso and the history have work.
    final now = DateTime.now();
    var seeded = 0;
    for (var back = 60; back >= 1; back--) {
      final date = DateTime(now.year, now.month, now.day - back);
      if (d.repository.routineOn(date) == null) continue;
      try {
        final session = d.repository.sessionOn(date)!;
        for (final log in session.exercises) {
          await d.repository.addSet(
            date,
            log.exerciseId,
            SetEntry(weightKg: 40.0 + back / 4, reps: 8, rir: 2),
          );
          await d.repository.toggleExercise(date, log.exerciseId);
        }
        await d.repository.finishSession(date, SessionStatus.completed);
        seeded++;
      } catch (_) {
        // A day that cannot be filled is simply left out of the profile.
      }
    }
    debugPrint('PERF seeded sessions: $seeded');

    await tester.pumpWidget(ForjaApp(dependencies: d, offerOnboarding: false));
    await tester.pumpAndSettle();

    Future<void> scrollBack(Finder list) async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, -500), 2500);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, 500), 2500);
        await tester.pumpAndSettle();
      }
    }

    final report = <String, dynamic>{'seeded_sessions': seeded};
    for (final (tab, key) in const [
      ('Hoy', 'today'),
      ('Plan', 'plan'),
      ('Progreso', 'progress'),
      ('Ejercicios', 'exercises'),
    ]) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      report['scroll_$key'] = await measure(() async {
        await scrollBack(find.byType(Scrollable).first);
      });
    }

    // Tab changes (the navbar animation) are part of the experience too.
    report['tab_changes'] = await measure(() async {
      for (var i = 0; i < 3; i++) {
        for (final tab in const ['Plan', 'Progreso', 'Ejercicios', 'Hoy']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
        }
      }
    });
    // The driver writes this to build/perf/summary.json.
    binding.reportData = report;
    debugPrint('PERF ${jsonEncode(report)}');
  });
}
