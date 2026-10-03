import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// Regression (seen in the 320 px captures, 2026-10-02): a one-word page
/// title wider than the line broke inside the word ("EJERCICI/OS"). Now its
/// size goes down just enough to keep the word whole.
void main() {
  for (final (page, title) in [
    (AppPage.exercises, 'EJERCICIOS'),
    (AppPage.plan, 'TU PLAN'),
    (AppPage.more, 'A TU RITMO'),
  ]) {
    testWidgets('"$title" never breaks inside a word at 320 px and 200 %', (
      tester,
    ) async {
      const size = Size(320, 1200);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 10, 2, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(size: size, textScaler: TextScaler.linear(2)),
          child: SizedBox(),
        ),
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(2),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(page);
      await tester.pumpAndSettle();
      final finder = find.text(title);
      final text = tester.widget<Text>(finder);
      final box = tester.getRect(finder);
      // Each word, laid out alone with the rendered style, fits the width
      // the title was given.
      for (final word in title.split(' ')) {
        final painter = TextPainter(
          text: TextSpan(text: word, style: text.style),
          textScaler: const TextScaler.linear(2),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        expect(painter.width, lessThanOrEqualTo(box.width + 0.5), reason: word);
        painter.dispose();
      }
      expect(tester.takeException(), isNull);
    });
  }
}
