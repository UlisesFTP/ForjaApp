import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/meal_estimate.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'ai_gateway_test.dart' show FakeClient;

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

const _good = {
  'title': 'Tacos al pastor',
  'items': [
    {
      'name': 'Taco al pastor',
      'grams': 180,
      'kcal': 400,
      'proteinG': 20,
      'carbsG': 40,
      'fatG': 16,
    },
    {
      'name': 'Refresco',
      'grams': 355,
      'kcal': 140,
      'proteinG': 0,
      'carbsG': 35,
      'fatG': 0,
    },
  ],
  'totalKcal': 540,
  'confidence': 'medium',
  'assumptions': ['Dos tacos medianos'],
  'question': null,
};

void main() {
  group('an estimate is checked before it can fill the form (F17)', () {
    test('a good answer, even wrapped in text or fences', () {
      final e = MealEstimate.parse('```json\n${jsonEncode(_good)}\n```');
      expect(e.title, 'Tacos al pastor');
      expect(e.totalKcal, 540);
      expect(e.proteinG, 20, reason: 'summed from the items');
      expect(e.carbsG, 75);
      expect(e.fatG, 16);
      expect(e.confidence, EstimateConfidence.medium);
      expect(e.assumptions, ['Dos tacos medianos']);
      expect(e.warnings, isEmpty);
    });

    test('a total that does not add up is recomputed and said', () {
      final e = MealEstimate.parse(jsonEncode({..._good, 'totalKcal': 900}));
      expect(e.totalKcal, 540);
      expect(e.warnings.single, contains('suma'));
      // A small rounding difference is kept.
      expect(
        MealEstimate.parse(jsonEncode({..._good, 'totalKcal': 545})).totalKcal,
        545,
      );
    });

    test('macros far from the calories are flagged', () {
      final e = MealEstimate.parse(
        jsonEncode({..._good, 'proteinG': 100, 'carbsG': 100, 'fatG': 100}),
      );
      expect(e.warnings.single, contains('no cuadran'));
    });

    test('broken or impossible answers are refused', () {
      for (final bad in [
        'no es json',
        '[]',
        jsonEncode({..._good, 'title': ''}),
        jsonEncode({..._good, 'items': []}),
        jsonEncode({
          ..._good,
          'items': [
            {'name': 'x', 'kcal': 9000},
          ],
        }),
        jsonEncode({
          ..._good,
          'items': List.filled(13, {'name': 'x', 'kcal': 10}),
        }),
      ]) {
        expect(
          () => MealEstimate.parse(bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });

    test('text is cleaned: control characters out, lengths limited', () {
      final e = MealEstimate.parse(
        jsonEncode({
          ..._good,
          'title': 'Tacos\u0000 ${'x' * 200}',
          'assumptions': ['a\nb', 7, ''],
        }),
      );
      expect(e.title.length, lessThanOrEqualTo(80));
      expect(e.title, isNot(contains('\u0000')));
      expect(e.assumptions, ['a b']);
    });
  });

  group('Describir comida (IA) in the food form', () {
    Future<AppDependencies> start(
      WidgetTester tester,
      FakeClient client,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 3000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        aiClient: client,
        secrets: MemorySecretStore()..key = 'sk-test-key-0000000000',
        aiSettings: MemoryAiSettingsStore(),
        clock: () => DateTime(2026, 10, 2, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(390, 3000)),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.nutrition);
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('hidden while the assistant is off', (tester) async {
      await start(tester, FakeClient(failOnCall: true));
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('food-describe')), findsNothing);
    });

    testWidgets('only the text goes; the values fill the form; saving stores '
        'an estimate', (tester) async {
      final client = FakeClient(answer: jsonEncode(_good));
      final d = await start(tester, client);
      await d.ai.accept({DataCategory.nutrition});
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('food-describe')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Asistente externo (IA)'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('meal-text')),
        '2 tacos al pastor y un refresco',
      );
      await tester.tap(find.byKey(const ValueKey('meal-estimate')));
      await tester.pumpAndSettle();
      final sent = client.requests.single;
      expect(sent.maxTokens, 600);
      final user = jsonDecode(sent.messages.last.content!) as Map;
      expect(user, {
        'descripcion_userText': '2 tacos al pastor y un refresco',
        'fecha': '2026-10-02',
      });
      expect(find.textContaining('540 kcal estimadas'), findsOneWidget);
      expect(d.nutrition.entries, isEmpty, reason: 'nothing saved yet');
      await tester.tap(find.byKey(const ValueKey('meal-use')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('food-kcal')))
            .controller!
            .text,
        '540',
      );
      expect(
        find.textContaining('Estimadas por el asistente (IA)'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      final saved = d.nutrition.entries.single;
      expect(saved.name, 'Tacos al pastor');
      expect(saved.calories, 540);
      expect(saved.caloriesSource, CaloriesSource.estimated);
      expect(saved.proteinG, 20);
      expect(find.textContaining('kcal estimadas (IA)'), findsOneWidget);
    });

    testWidgets('an unreadable answer is asked once more, then left to the '
        'person', (tester) async {
      final client = FakeClient(answer: 'Lo siento, no puedo');
      final d = await start(tester, client);
      await d.ai.accept({DataCategory.nutrition});
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('food-describe')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('meal-text')), 'pan');
      await tester.tap(find.byKey(const ValueKey('meal-estimate')));
      await tester.pumpAndSettle();
      expect(client.requests, hasLength(2));
      expect(find.textContaining('Puedes escribirlo a mano'), findsWidgets);
      expect(find.byKey(const ValueKey('meal-use')), findsNothing);
    });
  });
}
