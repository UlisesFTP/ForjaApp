import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/ui/nutrition/view_models/nutrition_view_model.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

Recipe recipe({
  String id = 'r1',
  double servings = 4,
  List<Ingredient>? ingredients,
  List<String> tags = const [],
  List<String>? allergens,
}) => Recipe(
  id: id,
  name: 'Guiso $id',
  servings: servings,
  createdAt: DateTime.utc(2026, 10, 1),
  tags: tags,
  allergens: allergens,
  ingredients:
      ingredients ??
      const [
        Ingredient(
          name: 'Arroz',
          quantity: 200,
          unit: 'g',
          calories: 720,
          proteinG: 14,
          carbsG: 158,
          fatG: 1.5,
        ),
        Ingredient(
          name: 'Pollo',
          quantity: 300,
          unit: 'g',
          calories: 495,
          proteinG: 93,
          carbsG: 0,
          fatG: 11,
        ),
      ],
);

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

  group('food maths (F12)', () {
    test('kcal from macros is 4·P + 4·C + 9·F, and needs all three', () {
      expect(caloriesFromMacros(30, 50, 10), 4 * 30 + 4 * 50 + 9 * 10);
      expect(caloriesFromMacros(30, null, 10), isNull);
      expect(caloriesFromMacros(null, null, null), isNull);
      expect(
        caloriesFromMacros(0, 0, 0),
        0,
        reason: 'zero is a value, not unknown',
      );
      expect(caloriesFromMacros(12.5, 0.5, 3.3), (50 + 2 + 29.7).round());
    });

    test('a recipe adds up its ingredients and divides by the servings', () {
      final r = recipe();
      expect(r.totalCalories, 1215);
      expect(r.caloriesPerServing, (1215 / 4).round());
      expect(r.totalProteinG, 107);
      expect(r.totalCarbsG, 158);
      expect(r.totalFatG, 12.5);
      // Fractional servings.
      expect(recipe(servings: 2.5).caloriesPerServing, (1215 / 2.5).round());
    });

    test(
      'one ingredient without calories makes the total unknown, not smaller',
      () {
        final r = recipe(
          ingredients: const [
            Ingredient(name: 'Arroz', calories: 720),
            Ingredient(name: 'Sal'),
          ],
        );
        expect(r.totalCalories, isNull);
        expect(r.caloriesPerServing, isNull);
        expect(r.totalProteinG, isNull);
        expect(recipe(ingredients: const []).totalCalories, isNull);
      },
    );

    test('macros are unknown unless every ingredient has them', () {
      final r = recipe(
        ingredients: const [
          Ingredient(name: 'A', calories: 100, proteinG: 5),
          Ingredient(name: 'B', calories: 100),
        ],
      );
      expect(r.totalCalories, 200);
      expect(r.totalProteinG, isNull);
    });

    test('declared allergens are not the same as undeclared', () {
      expect(recipe(allergens: null).allergens, isNull);
      expect(recipe(allergens: const []).allergens, isEmpty);
    });
  });

  group('nutrition persistence (F12)', () {
    late StoreHarness h;
    late Opened db;
    setUp(() async {
      h = await StoreHarness.create();
      db = await h.open();
    });
    tearDown(() => h.dispose());
    Future<Opened> reopen() async {
      await db.close();
      return db = await h.open();
    }

    final day = DateTime(2026, 10, 1);
    FoodEntry food({
      String id = 'f1',
      int calories = 300,
      double? portion,
      String? unit,
      double? protein,
      double? carbs,
      double? fat,
      CaloriesSource source = CaloriesSource.manual,
      String? recipeId,
    }) => FoodEntry(
      id: id,
      dateKey: '2026-10-01',
      name: 'Avena $id',
      calories: calories,
      portion: portion,
      unit: unit,
      proteinG: protein,
      carbsG: carbs,
      fatG: fat,
      caloriesSource: source,
      recipeId: recipeId,
    );

    test(
      'portion and macros are stored; unknown stays null, never 0',
      () async {
        await db.repo.addFood(
          food(
            id: 'a',
            portion: 0.5,
            unit: 'taza',
            protein: 10,
            carbs: null,
            fat: 0,
          ),
        );
        await db.repo.addFood(food(id: 'b'));
        final stored = (await reopen()).repo.foodOn(day);
        final a = stored.firstWhere((e) => e.id == 'a'),
            b = stored.firstWhere((e) => e.id == 'b');
        expect(
          [a.portion, a.unit, a.proteinG, a.carbsG, a.fatG],
          [0.5, 'taza', 10, null, 0],
        );
        expect(
          [b.portion, b.unit, b.proteinG, b.carbsG, b.fatG],
          [null, null, null, null, null],
        );
        expect(b.caloriesSource, CaloriesSource.manual);
        expect(a.hasMacros, isTrue);
        expect(b.hasMacros, isFalse);
      },
    );

    test('calories without macros are a valid entry', () async {
      await db.repo.addFood(food(calories: 250));
      expect(db.repo.foodOn(day).single.calories, 250);
      expect(db.repo.foodOn(day).single.proteinG, isNull);
    });

    test('invalid entries are refused and nothing is stored', () async {
      for (final bad in [
        food(calories: -1),
        food(calories: 5001),
        food(portion: 0),
        food(portion: -2),
        food(portion: double.nan),
        food(unit: 'x' * 13),
        food(protein: -1),
        food(fat: 2001),
        food(carbs: double.infinity),
        FoodEntry(id: 'n', dateKey: '2026-10-01', name: '  ', calories: 10),
        FoodEntry(id: 'n', dateKey: '2026-02-31', name: 'x', calories: 10),
        FoodEntry(id: 'n', dateKey: 'hoy', name: 'x', calories: 10),
        food(source: CaloriesSource.recipe),
      ]) {
        await expectLater(db.repo.addFood(bad), throwsArgumentError);
      }
      expect((await db.counts())['food_entries'], 0);
    });

    test(
      'calories derived from macros must match them: no silent invention',
      () async {
        await expectLater(
          db.repo.addFood(
            food(
              calories: 999,
              protein: 10,
              carbs: 10,
              fat: 10,
              source: CaloriesSource.macros,
            ),
          ),
          throwsArgumentError,
        );
        await expectLater(
          db.repo.addFood(
            food(calories: 100, protein: 10, source: CaloriesSource.macros),
          ),
          throwsArgumentError,
        );
        await db.repo.addFood(
          food(
            calories: 170,
            protein: 10,
            carbs: 10,
            fat: 10,
            source: CaloriesSource.macros,
          ),
        );
        expect(
          (await reopen()).repo.foodOn(day).single.caloriesSource,
          CaloriesSource.macros,
        );
      },
    );

    test(
      'an explicit manual number is kept even when macros disagree',
      () async {
        await db.repo.addFood(
          food(calories: 400, protein: 10, carbs: 10, fat: 10),
        );
        expect((await reopen()).repo.foodOn(day).single.calories, 400);
      },
    );

    test('an edit is one atomic replacement and keeps the position', () async {
      await db.repo.addFood(food(id: 'a'));
      await db.repo.addFood(food(id: 'b'));
      await db.repo.addFood(food(id: 'c'));
      await db.repo.updateFood(
        food(id: 'b', calories: 555, portion: 2, unit: 'g'),
      );
      final stored = (await reopen()).repo.foodOn(day);
      expect(stored.map((e) => e.id), ['a', 'b', 'c']);
      expect(stored[1].calories, 555);
      expect(stored[1].portion, 2);
      await expectLater(
        db.repo.updateFood(food(id: 'zzz')),
        throwsArgumentError,
      );
      await expectLater(
        db.repo.updateFood(food(id: 'a', calories: -3)),
        throwsArgumentError,
      );
      expect(db.repo.foodOn(day).first.calories, 300);
    });

    test('a failed edit changes nothing and a retry succeeds', () async {
      await db.repo.addFood(food(id: 'a'));
      h.fault.arm(
        (sql) => sql.startsWith('UPDATE') && sql.contains('food_entries'),
      );
      await expectLater(
        db.repo.updateFood(food(id: 'a', calories: 111)),
        throwsInjected,
      );
      expect(db.repo.foodOn(day).single.calories, 300);
      h.fault.disarm();
      await db.repo.updateFood(food(id: 'a', calories: 111));
      expect((await reopen()).repo.foodOn(day).single.calories, 111);
    });

    test(
      'moving an entry to another date works and reaches the other day',
      () async {
        await db.repo.addFood(food(id: 'a'));
        await db.repo.updateFood(
          FoodEntry(
            id: 'a',
            dateKey: '2026-10-02',
            name: 'Avena a',
            calories: 300,
          ),
        );
        expect(db.repo.foodOn(day), isEmpty);
        expect(db.repo.foodOn(DateTime(2026, 10, 2)).single.id, 'a');
      },
    );

    test('removing and restoring (undo) brings the entry back once', () async {
      final e = food(id: 'a', portion: 1, unit: 'tazón', protein: 5);
      await db.repo.addFood(e);
      await db.repo.removeFood('a');
      expect(db.repo.foodOn(day), isEmpty);
      await db.repo.restoreFood(e);
      await db.repo.restoreFood(e);
      final stored = (await reopen()).repo.foodOn(day);
      expect(stored, hasLength(1));
      expect(stored.single.unit, 'tazón');
      expect(stored.single.proteinG, 5);
    });

    test('adding the same id twice is refused', () async {
      await db.repo.addFood(food(id: 'a'));
      await expectLater(db.repo.addFood(food(id: 'a')), throwsStateError);
      expect(db.repo.foodOn(day), hasLength(1));
    });

    test(
      'favorites survive restart, keep their order and can be removed',
      () async {
        await db.repo.addFavorite(
          const FavoriteFood(
            id: 'x',
            name: 'Yogur',
            calories: 120,
            portion: 1,
            unit: 'taza',
            proteinG: 8,
          ),
        );
        await db.repo.addFavorite(
          const FavoriteFood(id: 'y', name: 'Café', calories: 5),
        );
        await db.repo.addFavorite(
          const FavoriteFood(id: 'x', name: 'otra', calories: 1),
        );
        final reopened = await reopen();
        expect(reopened.repo.favorites.map((f) => f.id), ['x', 'y']);
        expect(reopened.repo.favorites.first.proteinG, 8);
        expect(reopened.repo.favorites.last.proteinG, isNull);
        await reopened.repo.removeFavorite('x');
        expect((await reopen()).repo.favorites.map((f) => f.id), ['y']);
        await expectLater(
          db.repo.addFavorite(
            const FavoriteFood(id: 'z', name: '', calories: 1),
          ),
          throwsArgumentError,
        );
      },
    );

    test('a recipe is stored whole, edited atomically and deleted with its ingredients', () async {
      await db.repo.saveRecipe(recipe(tags: ['rápida'], allergens: ['gluten']));
      var stored = (await reopen()).repo.recipes.single;
      expect(stored.ingredients.map((i) => i.name), ['Arroz', 'Pollo']);
      expect(stored.totalCalories, 1215);
      expect(stored.tags, ['rápida']);
      expect(stored.allergens, ['gluten']);
      // Replace with fewer ingredients: the old ones are gone.
      await db.repo.saveRecipe(
        recipe(
          ingredients: const [Ingredient(name: 'Pan', calories: 200)],
          allergens: null,
        ),
      );
      stored = (await reopen()).repo.recipes.single;
      expect(stored.ingredients.single.name, 'Pan');
      expect(stored.allergens, isNull, reason: 'undeclared stays undeclared');
      expect(
        (await db.db
                .customSelect('SELECT COUNT(*) AS n FROM recipe_ingredients')
                .getSingle())
            .read<int>('n'),
        1,
      );
      await db.repo.deleteRecipe('r1');
      expect(
        (await db.db
                .customSelect('SELECT COUNT(*) AS n FROM recipe_ingredients')
                .getSingle())
            .read<int>('n'),
        0,
      );
      expect((await reopen()).repo.recipes, isEmpty);
    });

    test('invalid recipes are refused', () async {
      for (final bad in [
        Recipe(
          id: 'a',
          name: '',
          servings: 1,
          createdAt: DateTime.utc(2026),
          ingredients: const [Ingredient(name: 'x')],
        ),
        recipe(servings: 0),
        recipe(servings: -1),
        recipe(servings: double.nan),
        recipe(ingredients: const []),
        recipe(ingredients: const [Ingredient(name: ' ')]),
        recipe(ingredients: const [Ingredient(name: 'x', quantity: 0)]),
        recipe(ingredients: const [Ingredient(name: 'x', calories: -5)]),
        recipe(ingredients: const [Ingredient(name: 'x', proteinG: -1)]),
        recipe(tags: ['x' * 25]),
        recipe(allergens: ['']),
      ]) {
        await expectLater(db.repo.saveRecipe(bad), throwsArgumentError);
      }
      expect(db.repo.recipes, isEmpty);
    });

    test('deleting a recipe never rewrites what was eaten', () async {
      await db.repo.saveRecipe(recipe());
      await db.repo.addFood(
        food(
          id: 'e',
          calories: 304,
          portion: 1,
          unit: 'porción',
          source: CaloriesSource.recipe,
          recipeId: 'r1',
        ),
      );
      await db.repo.deleteRecipe('r1');
      final e = (await reopen()).repo.foodOn(day).single;
      expect(e.calories, 304);
      expect(e.recipeId, 'r1');
    });

    test('goals are optional, validated, stored and clearable', () async {
      expect(db.repo.goals.isEmpty, isTrue);
      await db.repo.saveGoals(const NutritionGoals(kcal: 2200, proteinG: 140));
      var g = (await reopen()).repo.goals;
      expect([g.kcal, g.proteinG, g.carbsG, g.fatG], [2200, 140, null, null]);
      for (final bad in [
        const NutritionGoals(kcal: 100),
        const NutritionGoals(kcal: 20000),
        const NutritionGoals(proteinG: -1),
        const NutritionGoals(fatG: 5000),
        const NutritionGoals(carbsG: double.nan),
      ]) {
        await expectLater(db.repo.saveGoals(bad), throwsArgumentError);
      }
      await db.repo.saveGoals(const NutritionGoals());
      g = (await reopen()).repo.goals;
      expect(g.isEmpty, isTrue);
    });

    test('a failed recipe write leaves the previous recipe intact', () async {
      await db.repo.saveRecipe(recipe());
      h.fault.arm(
        (sql) => sql.startsWith('INSERT') && sql.contains('recipe_ingredients'),
      );
      await expectLater(
        db.repo.saveRecipe(
          recipe(ingredients: const [Ingredient(name: 'Nuevo', calories: 1)]),
        ),
        throwsInjected,
      );
      h.fault.disarm();
      final stored = (await reopen()).repo.recipes.single;
      expect(stored.ingredients.map((i) => i.name), ['Arroz', 'Pollo']);
    });
  });

  group('nutrition view model (F12)', () {
    late AppDependencies d;
    late NutritionViewModel vm;
    var now = DateTime(2026, 10, 1, 12);
    var counter = 0;
    setUp(() async {
      counter = 0;
      d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => now,
      );
      vm = NutritionViewModel(
        d.repository,
        clock: () => now,
        newId: () => 'id${counter++}',
      );
    });
    tearDown(() async {
      vm.dispose();
      await d.dispose();
    });

    test('totals count only what is known and say how much that is', () async {
      await vm.add(const FoodDraft(name: 'A', calories: 200, proteinG: 10));
      await vm.add(const FoodDraft(name: 'B', calories: 300));
      await vm.add(
        const FoodDraft(name: 'C', calories: 100, proteinG: 5.5, fatG: 2),
      );
      expect(vm.calories, 600);
      expect(vm.protein.grams, 15.5);
      expect(vm.protein.known, 2);
      expect(vm.protein.of, 3);
      expect(vm.protein.partial, isTrue);
      expect(vm.carbs.grams, isNull, reason: 'no carbs recorded is not 0 g');
      expect(vm.fat.grams, 2);
    });

    test('an empty day has no total at all', () {
      expect(vm.entries, isEmpty);
      expect(vm.protein.grams, isNull);
      expect(vm.calories, 0);
    });

    test('the day can change and entries stay on their own date', () async {
      await vm.add(const FoodDraft(name: 'Hoy', calories: 100));
      vm.shiftDays(-1);
      expect(vm.isToday, isFalse);
      expect(vm.entries, isEmpty);
      await vm.add(const FoodDraft(name: 'Ayer', calories: 50));
      expect(vm.entries.single.name, 'Ayer');
      expect(vm.entries.single.dateKey, '2026-09-30');
      vm.selectDate(vm.today);
      expect(vm.entries.single.name, 'Hoy');
      // Crossing a month and a year.
      vm.selectDate(DateTime(2026, 12, 31));
      vm.shiftDays(1);
      expect(vm.selectedDate, DateTime(2027, 1, 1));
    });

    test('delete announces an undo that restores the entry', () async {
      await vm.add(const FoodDraft(name: 'A', calories: 100));
      final entry = vm.entries.single;
      await vm.remove(entry);
      expect(vm.entries, isEmpty);
      expect(vm.messageActionLabel, 'Deshacer');
      vm.messageAction!();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(vm.entries.single.name, 'A');
    });

    test('editing keeps the entry date and recipe link', () async {
      await vm.add(const FoodDraft(name: 'A', calories: 100));
      final e = vm.entries.single;
      await vm.update(
        e,
        const FoodDraft(name: ' A2 ', calories: 120, unit: ' g ', portion: 30),
      );
      final u = vm.entries.single;
      expect(
        [u.id, u.name, u.calories, u.unit, u.portion, u.dateKey],
        [e.id, 'A2', 120, 'g', 30, e.dateKey],
      );
    });

    test('a favorite is logged on the selected day', () async {
      await vm.add(const FoodDraft(name: 'Yogur', calories: 120, proteinG: 8));
      await vm.saveFavorite(vm.entries.single);
      vm.shiftDays(-2);
      await vm.logFavorite(vm.favorites.single);
      expect(vm.entries.single.name, 'Yogur');
      expect(vm.entries.single.proteinG, 8);
      expect(vm.entries.single.dateKey, '2026-09-29');
    });

    test(
      'logging a recipe: per-serving kcal, macros share, fractional servings',
      () async {
        final r = recipe();
        await d.repository.saveRecipe(r);
        await vm.logRecipe(r, 1.5);
        final e = vm.entries.single;
        expect(e.calories, ((1215 / 4).round() * 1.5).round());
        expect(e.portion, 1.5);
        expect(e.unit, 'porciones');
        expect(e.proteinG, closeTo(107 / 4 * 1.5, 1e-9));
        expect(e.caloriesSource, CaloriesSource.recipe);
        expect(e.recipeId, 'r1');
      },
    );

    test(
      'a recipe with an unknown ingredient needs the person\'s own calories',
      () async {
        final r = recipe(
          ingredients: const [
            Ingredient(name: 'A', calories: 100),
            Ingredient(name: 'Sal'),
          ],
        );
        expect(await vm.logRecipe(r, 1), isFalse);
        expect(vm.error, contains('sin calorías'));
        expect(vm.entries, isEmpty);
        expect(await vm.logRecipe(r, 1, kcalOverride: 350), isTrue);
        expect(vm.entries.single.calories, 350);
        expect(vm.entries.single.proteinG, isNull);
      },
    );

    test('invalid servings are refused', () async {
      final r = recipe();
      for (final s in [0.0, -1.0, double.nan, 5000.0]) {
        expect(await vm.logRecipe(r, s), isFalse);
      }
      expect(vm.entries, isEmpty);
    });

    test('filters: tags, and allergens that are declared (undeclared is never assumed safe)', () async {
      await d.repository.saveRecipe(
        recipe(id: 'a', tags: ['vegetariana'], allergens: ['gluten']),
      );
      await d.repository.saveRecipe(
        recipe(id: 'b', tags: ['vegetariana'], allergens: []),
      );
      await d.repository.saveRecipe(
        recipe(id: 'c', tags: ['carne'], allergens: null),
      );
      expect(vm.allTags, ['carne', 'vegetariana']);
      expect(vm.allAllergens, ['gluten']);
      expect(vm.filterRecipes(tag: 'vegetariana').map((r) => r.id), ['a', 'b']);
      expect(vm.filterRecipes(withoutAllergen: 'gluten').map((r) => r.id), [
        'b',
      ]);
      expect(vm.undeclared(), 1);
      expect(vm.filterRecipes().map((r) => r.id), ['a', 'b', 'c']);
    });

    test('goals save and absent goals add nothing', () async {
      expect(vm.goals.isEmpty, isTrue);
      await vm.saveGoals(const NutritionGoals(kcal: 2000));
      expect(vm.goals.kcal, 2000);
      expect(await vm.saveGoals(const NutritionGoals(kcal: 1)), isFalse);
      expect(vm.goals.kcal, 2000);
    });
  });

  group('nutrition screens (F12)', () {
    Future<AppDependencies> start(
      WidgetTester tester, {
      double width = 390,
      double scale = 1,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 3000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 10, 1, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 3000),
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.nutrition);
      await tester.pumpAndSettle();
      return d;
    }

    Future<void> addFood(
      WidgetTester tester, {
      required String name,
      String? kcal,
      Map<String, String> more = const {},
    }) async {
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-name')), name);
      if (kcal != null) {
        await tester.enterText(find.byKey(const ValueKey('food-kcal')), kcal);
      }
      if (more.isNotEmpty) {
        await tester.tap(find.text('Porción y macros (opcional)'));
        await tester.pumpAndSettle();
        for (final e in more.entries) {
          await tester.enterText(find.byKey(ValueKey(e.key)), e.value);
        }
      }
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
    }

    testWidgets('empty day says so instead of showing zero', (tester) async {
      await start(tester);
      expect(find.text('Sin registros'), findsOneWidget);
      expect(
        find.text('Todavía no has registrado alimentos este día.'),
        findsOneWidget,
      );
    });

    testWidgets('quick manual entry: name and kcal only', (tester) async {
      final d = await start(tester);
      await addFood(tester, name: 'Tacos', kcal: '450');
      expect(d.nutrition.calories, 450);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('kcal-total'))).data,
        '450',
      );
      expect(find.text('450 kcal'), findsOneWidget);
      expect(
        find.text('Proteína: sin datos'),
        findsNothing,
        reason: 'no macro line without macros or goals',
      );
    });

    testWidgets('invalid kcal is explained and nothing is saved', (
      tester,
    ) async {
      final d = await start(tester);
      await addFood(tester, name: 'Tacos', kcal: '9999');
      expect(find.text('Introduce entre 0 y 5000 kcal'), findsOneWidget);
      expect(d.nutrition.entries, isEmpty);
      await tester.enterText(find.byKey(const ValueKey('food-kcal')), '');
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      expect(find.text('Introduce entre 0 y 5000 kcal'), findsOneWidget);
      // Typing a valid number removes the message at once; it used to stay on
      // screen until the next attempt to save (seen on a phone).
      await tester.enterText(find.byKey(const ValueKey('food-kcal')), '350');
      await tester.pumpAndSettle();
      expect(find.text('Introduce entre 0 y 5000 kcal'), findsNothing);
    });

    testWidgets('portion and macros are shown, with partial coverage', (
      tester,
    ) async {
      final d = await start(tester);
      await addFood(
        tester,
        name: 'Avena',
        kcal: '300',
        more: {
          'food-portion': '0,5',
          'food-unit': 'taza',
          'food-protein': '10',
        },
      );
      await addFood(tester, name: 'Café', kcal: '5');
      expect(d.nutrition.entries.first.portion, 0.5);
      expect(find.textContaining('0.5 taza'), findsOneWidget);
      expect(find.textContaining('P 10 g'), findsOneWidget);
      expect(
        find.text('Proteína: 10 g (de 1 de 2 alimentos con dato)'),
        findsOneWidget,
      );
    });

    testWidgets('kcal can be calculated from macros and then say so', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-name')), 'Pollo');
      await tester.tap(find.text('Porción y macros (opcional)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-protein')), '30');
      await tester.enterText(find.byKey(const ValueKey('food-carbs')), '0');
      await tester.enterText(find.byKey(const ValueKey('food-fat')), '5');
      await tester.tap(find.byKey(const ValueKey('food-from-macros')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('food-kcal')))
            .controller!
            .text,
        '165',
      );
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries.single.caloriesSource, CaloriesSource.macros);
      expect(
        find.textContaining('kcal calculadas desde macros'),
        findsOneWidget,
      );
    });

    testWidgets(
      'typing your own kcal after calculating makes them yours again',
      (tester) async {
        final d = await start(tester);
        await tester.tap(find.byKey(const ValueKey('add-food')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('food-name')),
          'Pollo',
        );
        await tester.tap(find.text('Porción y macros (opcional)'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('food-protein')),
          '30',
        );
        await tester.enterText(find.byKey(const ValueKey('food-carbs')), '0');
        await tester.enterText(find.byKey(const ValueKey('food-fat')), '5');
        await tester.tap(find.byKey(const ValueKey('food-from-macros')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const ValueKey('food-kcal')), '200');
        await tester.tap(find.byKey(const ValueKey('food-save')));
        await tester.pumpAndSettle();
        expect(d.nutrition.entries.single.calories, 200);
        expect(
          d.nutrition.entries.single.caloriesSource,
          CaloriesSource.manual,
        );
      },
    );

    testWidgets('calculating with a missing macro does not invent a number', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Porción y macros (opcional)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-protein')), '30');
      await tester.tap(find.byKey(const ValueKey('food-from-macros')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('food-kcal')))
            .controller!
            .text,
        isEmpty,
      );
    });

    testWidgets('edit, then delete with undo', (tester) async {
      final d = await start(tester);
      await addFood(tester, name: 'Tacos', kcal: '450');
      await tester.tap(find.byTooltip('Editar Tacos'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-kcal')), '500');
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries.single.calories, 500);
      await tester.tap(find.byTooltip('Eliminar Tacos'));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries, isEmpty);
      expect(find.text('Registro eliminado'), findsOneWidget);
      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries.single.calories, 500);
    });

    testWidgets('changing the day shows that day and keeps entries apart', (
      tester,
    ) async {
      final d = await start(tester);
      await addFood(tester, name: 'Hoy', kcal: '100');
      await tester.tap(find.byTooltip('Día anterior'));
      await tester.pumpAndSettle();
      expect(find.text('Hoy'), findsWidgets);
      expect(d.nutrition.entries, isEmpty);
      expect(find.text('Sin registros'), findsOneWidget);
      await tester.tap(find.text('Volver a hoy'));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries.single.name, 'Hoy');
    });

    testWidgets('favorites: save while adding, then one tap logs it', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('add-food')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('food-name')), 'Yogur');
      await tester.enterText(find.byKey(const ValueKey('food-kcal')), '120');
      await tester.tap(find.text('Guardar en favoritos'));
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      expect(d.repository.favorites.single.name, 'Yogur');
      await tester.tap(find.byTooltip('Añadir Yogur'));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries, hasLength(2));
      await tester.tap(find.byTooltip('Quitar Yogur de favoritos'));
      await tester.pumpAndSettle();
      expect(d.repository.favorites, isEmpty);
      expect(d.nutrition.entries, hasLength(2), reason: 'logged entries stay');
    });

    testWidgets(
      'goals: none means no comparison; with a goal the numbers are shown plainly',
      (tester) async {
        final d = await start(tester);
        await addFood(tester, name: 'Tacos', kcal: '450');
        expect(find.byKey(const ValueKey('goal-kcal')), findsNothing);
        await tester.tap(find.byKey(const ValueKey('open-goals')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const ValueKey('goal-input-kcal')),
          '2000',
        );
        await tester.enterText(
          find.byKey(const ValueKey('goal-input-protein')),
          '120',
        );
        await tester.tap(find.byKey(const ValueKey('goals-save')));
        await tester.pumpAndSettle();
        expect(d.repository.goals.kcal, 2000);
        expect(
          find.text('Objetivo 2000 kcal · registradas 450 de 2000'),
          findsOneWidget,
        );
        expect(
          find.text('Proteína: sin datos · objetivo 120 g'),
          findsOneWidget,
        );
      },
    );

    testWidgets('goals are validated', (tester) async {
      await start(tester);
      await tester.tap(find.byKey(const ValueKey('open-goals')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('goal-input-kcal')),
        '100',
      );
      await tester.tap(find.byKey(const ValueKey('goals-save')));
      await tester.pumpAndSettle();
      expect(find.text('500–10000 kcal'), findsOneWidget);
    });

    testWidgets('create a recipe, see its totals, log it, filter it', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('open-recipes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-recipe')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('recipe-name')),
        'Guiso',
      );
      await tester.enterText(find.byKey(const ValueKey('recipe-yield')), '4');
      await tester.enterText(find.byKey(const ValueKey('ing-name-0')), 'Arroz');
      await tester.enterText(find.byKey(const ValueKey('ing-kcal-0')), '720');
      await tester.pump();
      expect(
        find.text('Total: 720 kcal · 180 kcal por porción'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('add-ingredient')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('ing-name-1')), 'Sal');
      await tester.pump();
      expect(
        find.text('Total: sin dato (falta alguna caloría)'),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(const ValueKey('ing-kcal-1')), '0');
      await tester.pump();
      expect(
        find.text('Total: 720 kcal · 180 kcal por porción'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('recipe-save')));
      await tester.pumpAndSettle();
      expect(d.repository.recipes.single.ingredients, hasLength(2));
      expect(find.text('4 porciones · 180 kcal por porción'), findsOneWidget);
      expect(find.text('Alérgenos: sin declarar'), findsOneWidget);
      await tester.tap(find.text('Añadir al registro'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('recipe-log')));
      await tester.pumpAndSettle();
      expect(d.nutrition.entries.single.calories, 180);
      expect(d.nutrition.entries.single.caloriesSource, CaloriesSource.recipe);
    });

    testWidgets('a recipe needs a name, servings and an ingredient', (
      tester,
    ) async {
      final d = await start(tester);
      await tester.tap(find.byKey(const ValueKey('open-recipes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('new-recipe')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('recipe-save')));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un nombre'), findsOneWidget);
      expect(d.repository.recipes, isEmpty);
      await tester.enterText(find.byKey(const ValueKey('recipe-name')), 'X');
      await tester.enterText(find.byKey(const ValueKey('recipe-yield')), '0');
      await tester.tap(find.byKey(const ValueKey('recipe-save')));
      await tester.pumpAndSettle();
      expect(find.text('Mayor que 0'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('recipe-yield')), '2');
      await tester.tap(find.byKey(const ValueKey('recipe-save')));
      await tester.pumpAndSettle();
      expect(d.repository.recipes, isEmpty, reason: 'no ingredient');
      expect(
        find.text('Una receta lleva de 1 a 50 ingredientes.'),
        findsWidgets,
      );
    });

    testWidgets(
      'allergen filter leaves out recipes whose allergens were never declared',
      (tester) async {
        final d = await start(tester);
        await d.repository.saveRecipe(
          recipe(id: 'a', tags: ['vegetariana'], allergens: ['gluten']),
        );
        await d.repository.saveRecipe(recipe(id: 'b', allergens: []));
        await d.repository.saveRecipe(recipe(id: 'c', allergens: null));
        await tester.tap(find.byKey(const ValueKey('open-recipes')));
        await tester.pumpAndSettle();
        expect(find.text('Guiso a'), findsOneWidget);
        expect(find.text('Guiso c'), findsOneWidget);
        await tester.tap(find.text('sin gluten'));
        await tester.pumpAndSettle();
        expect(find.text('Guiso a'), findsNothing);
        expect(find.text('Guiso b'), findsOneWidget);
        expect(find.text('Guiso c'), findsNothing);
        expect(find.textContaining('no se da por segura'), findsOneWidget);
      },
    );

    testWidgets('deleting a recipe asks first and keeps what was logged', (
      tester,
    ) async {
      final d = await start(tester);
      await d.repository.saveRecipe(recipe());
      await d.nutrition.logRecipe(d.repository.recipes.single, 1);
      await tester.tap(find.byKey(const ValueKey('open-recipes')));
      await tester.pumpAndSettle();
      // The logged entry has the same name: the recipe's button is the last.
      await tester.tap(find.byTooltip('Eliminar Guiso r1').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(d.repository.recipes, hasLength(1));
      await tester.tap(find.byTooltip('Eliminar Guiso r1').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      expect(d.repository.recipes, isEmpty);
      expect(d.nutrition.entries, hasLength(1));
    });

    testWidgets('screens fit 320 px at 200% text', (tester) async {
      final d = await start(tester, width: 320, scale: 2);
      await d.repository.saveRecipe(
        recipe(tags: ['vegetariana'], allergens: ['gluten']),
      );
      await addFood(
        tester,
        name: 'Avena',
        kcal: '300',
        more: {'food-protein': '10'},
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('open-recipes')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('new-recipe')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
