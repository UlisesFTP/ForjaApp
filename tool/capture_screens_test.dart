// Visual review aid, not part of `flutter test`: renders every main screen at
// phone, landscape and tablet sizes and writes PNGs to build/screens/.
//
//   flutter test tool/capture_screens_test.dart
//
// Optional: --dart-define=SIZES=390x844,1024x768 to limit the sizes.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/ai/ai_client.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// A local stand-in for the provider, so the chat can be pictured offline:
/// it proposes a meal, then answers.
class _DemoClient implements AiChatClient {
  var _calls = 0;
  @override
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  }) async {
    _calls++;
    final propose = _calls.isOdd && request.tools.isNotEmpty;
    return AiResponse(
      message: AiMessage(
        role: AiRole.assistant,
        content: propose
            ? null
            : 'Dos tacos al pastor rondan las 540 kcal. Te dejo la propuesta '
                  'para que la revises antes de guardarla.',
        toolCalls: propose
            ? const [
                AiToolCall(
                  id: 'c1',
                  name: 'propose_food_entry',
                  arguments: '{"name":"Tacos al pastor","kcal":540,"proteinG":28,"confidence":"medium"}',
                ),
              ]
            : const [],
      ),
      usage: const AiUsage(prompt: 900, completion: 60),
      model: 'mimo-v2.6-flash',
      latency: const Duration(milliseconds: 1800),
    );
  }
}

const _defaultSizes = [
  '390x844',
  '320x568@2',
  '844x390',
  '600x960',
  '768x1024',
  '1024x768',
  '1366x1024',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final (family, asset) in [
      ('DM Sans', 'assets/fonts/DMSans.ttf'),
      ('Barlow Condensed', 'assets/fonts/BarlowCondensed-Bold.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
    }
  });

  const requested = String.fromEnvironment('SIZES');
  final sizes = requested.isEmpty ? _defaultSizes : requested.split(',');

  for (final spec in sizes) {
    testWidgets('capture $spec', (tester) async {
      final parts = spec.split('@');
      final dims = parts.first.split('x').map(double.parse).toList();
      final scale = parts.length > 1 ? double.parse(parts[1]) : 1.0;
      final size = Size(dims[0], dims[1]);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 9, 29, 9),
        aiClient: _DemoClient(),
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.repository.saveProfile(
        const UserProfile(onboarded: true, weightKg: 72),
      );
      await d.repository.addSet(
        DateTime(2026, 9, 29),
        'squat',
        const SetEntry(weightKg: 60, reps: 8, rir: 2),
      );
      for (final (id, name, kcal) in [
        ('a', 'Avena con leche', 350),
        ('b', 'Pollo con arroz', 620),
      ]) {
        await d.repository.addFood(
          FoodEntry(id: id, dateKey: '2026-09-29', name: name, calories: kcal),
        );
      }

      // Eight weeks of training for the streak: all done, except one missed
      // day and one partial session.
      for (
        var day = DateTime(2026, 8, 3);
        day.isBefore(DateTime(2026, 9, 29));
        day = DateTime(day.year, day.month, day.day + 1)
      ) {
        final session = d.repository.sessionOn(day);
        if (session == null) continue;
        try {
          if (day == DateTime(2026, 8, 20)) {
            await d.repository.finishSession(
              day,
              SessionStatus.missed,
              reschedule: false,
            );
            continue;
          }
          final partial = day == DateTime(2026, 9, 10);
          for (final log in session.exercises.take(
            partial ? 1 : session.exercises.length,
          )) {
            await d.repository.toggleExercise(day, log.exerciseId);
          }
          await d.repository.finishSession(
            day,
            partial ? SessionStatus.partial : SessionStatus.completed,
            reschedule: false,
          );
        } catch (_) {
          // A day the repository refuses is simply left out.
        }
      }

      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
            ),
            child: ForjaApp(dependencies: d, offerOnboarding: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> closeSheet() async {
        final close = find.byIcon(Icons.close);
        if (close.evaluate().isNotEmpty) {
          await tester.tap(close.last, warnIfMissed: false);
        } else if (find.byType(BottomSheet).evaluate().isNotEmpty) {
          Navigator.of(tester.element(find.byType(BottomSheet).last)).pop();
        }
        await tester.pumpAndSettle();
      }

      Future<void> shot(String name) async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await render.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final dir = Directory('build/screens')..createSync(recursive: true);
          File('${dir.path}/$spec-$name.png'.replaceAll('@', '_x'))
              .writeAsBytesSync(data!.buffer.asUint8List());
          image.dispose();
        });
      }

      for (final page in AppPage.values) {
        d.shell.open(page);
        await tester.pumpAndSettle();
        await shot('${page.index}-${page.name}');
      }
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('streak-badge')));
      await tester.pumpAndSettle();
      await shot('streak-1');
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -700));
      await tester.pumpAndSettle();
      await shot('streak-2');
      Navigator.of(tester.element(find.text('Racha'))).pop();
      await tester.pumpAndSettle();
      final sets = find.byTooltip('Series de Sentadilla con barra');
      if (sets.evaluate().isNotEmpty) {
        await tester.ensureVisible(sets);
        await tester.tap(sets);
        await tester.pumpAndSettle();
        await shot('sheet-sets');
        await closeSheet();
        await tester.pumpAndSettle();
      }

      // The minicoach page (F16).
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('Minicoach').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Minicoach').first);
      await tester.pumpAndSettle();
      await shot('coach-1');
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
      await tester.pumpAndSettle();
      await shot('coach-2');
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await tester.pumpAndSettle();

      // The assistant's sheet (F17).
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('more-ai')));
      await tester.pumpAndSettle();
      await shot('ai-sheet');
      await closeSheet();
      await tester.pumpAndSettle();

      // The chat, with the local demo client.
      await d.ai.saveKey('sk-demo-0000000000000000');
      await d.ai.accept({...DataCategory.values});
      await d.ai.setCapabilities(const AiCapabilities(tools: true));
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.textContaining('Minicoach').first);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Minicoach').first);
      await tester.pumpAndSettle();
      final ask = find.byKey(const ValueKey('coach-ask-ai'));
      await tester.scrollUntilVisible(
        ask,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(ask);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('chat-input')),
        'Comí 2 tacos al pastor',
      );
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pumpAndSettle();
      await shot('chat');
    });
  }
}
