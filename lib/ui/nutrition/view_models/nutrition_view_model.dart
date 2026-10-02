import '../../../core/date_utils.dart';
import '../../../core/ids.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../core/view_model.dart';

/// What the person typed for one food, already parsed. Null is "unknown".
class FoodDraft {
  const FoodDraft({
    required this.name,
    required this.calories,
    this.portion,
    this.unit,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.source = CaloriesSource.manual,
  });
  final String name;
  final int calories;
  final double? portion;
  final String? unit;
  final double? proteinG, carbsG, fatG;
  final CaloriesSource source;
}

/// A total over the entries that have the value, and how many do. Missing
/// values are never counted as zero.
class MacroTotal {
  const MacroTotal(this.grams, this.known, this.of);
  final double? grams;
  final int known, of;
  bool get partial => known > 0 && known < of;
}

class NutritionViewModel extends ViewModel {
  NutritionViewModel(
    this._repository, {
    DateTime Function()? clock,
    IdGenerator? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? randomId {
    selectedDate = dateOnly(_clock());
    watch(_repository);
  }
  final NutritionRepository _repository;
  final DateTime Function() _clock;
  final IdGenerator _newId;
  late DateTime selectedDate;

  DateTime get today => dateOnly(_clock());
  bool get isToday => dateKey(selectedDate) == dateKey(today);
  List<FoodEntry> get entries => _repository.foodOn(selectedDate);
  int get calories => entries.fold(0, (sum, e) => sum + e.calories);
  NutritionGoals get goals => _repository.goals;
  List<FavoriteFood> get favorites => _repository.favorites;
  List<Recipe> get recipes => _repository.recipes;

  void selectDate(DateTime date) {
    selectedDate = dateOnly(date);
    notifyListeners();
  }

  void shiftDays(int days) => selectDate(nextDay(selectedDate, days));

  MacroTotal _total(double? Function(FoodEntry) pick) {
    final list = entries;
    final known = [for (final e in list) ?pick(e)];
    return MacroTotal(
      known.isEmpty ? null : known.fold<double>(0, (a, b) => a + b),
      known.length,
      list.length,
    );
  }

  MacroTotal get protein => _total((e) => e.proteinG);
  MacroTotal get carbs => _total((e) => e.carbsG);
  MacroTotal get fat => _total((e) => e.fatG);

  Future<bool> add(FoodDraft d) => run(
    () => _repository.addFood(_entry(_newId(), d)),
    success: 'Alimento guardado',
  );

  Future<bool> update(FoodEntry original, FoodDraft d) => run(
    () => _repository.updateFood(
      _entry(
        original.id,
        d,
        dateKey: original.dateKey,
        recipeId: original.recipeId,
      ),
    ),
    success: 'Alimento actualizado',
  );

  FoodEntry _entry(
    String id,
    FoodDraft d, {
    String? dateKey,
    String? recipeId,
  }) => FoodEntry(
    id: id,
    dateKey: dateKey ?? _dateKey,
    name: d.name.trim(),
    calories: d.calories,
    portion: d.portion,
    unit: d.unit == null || d.unit!.trim().isEmpty ? null : d.unit!.trim(),
    proteinG: d.proteinG,
    carbsG: d.carbsG,
    fatG: d.fatG,
    caloriesSource: d.source,
    recipeId: recipeId,
  );

  String get _dateKey => dateKey(selectedDate);

  /// Removes an entry and offers to bring it back.
  Future<bool> remove(FoodEntry entry) => run(() async {
    await _repository.removeFood(entry.id);
    announce(
      'Registro eliminado',
      actionLabel: 'Deshacer',
      onAction: () => restore(entry),
    );
  });

  Future<bool> restore(FoodEntry entry) =>
      run(() => _repository.restoreFood(entry), success: 'Registro restaurado');

  // ---- favorites
  Future<bool> saveFavorite(FoodEntry e) => run(
    () => _repository.addFavorite(
      FavoriteFood(
        id: _newId(),
        name: e.name,
        calories: e.calories,
        portion: e.portion,
        unit: e.unit,
        proteinG: e.proteinG,
        carbsG: e.carbsG,
        fatG: e.fatG,
      ),
    ),
    success: 'Guardado en favoritos',
  );

  Future<bool> logFavorite(FavoriteFood f) => run(
    () => _repository.addFood(
      FoodEntry(
        id: _newId(),
        dateKey: _dateKey,
        name: f.name,
        calories: f.calories,
        portion: f.portion,
        unit: f.unit,
        proteinG: f.proteinG,
        carbsG: f.carbsG,
        fatG: f.fatG,
      ),
    ),
    success: '${f.name} añadido',
  );

  Future<bool> removeFavorite(FavoriteFood f) => run(
    () => _repository.removeFavorite(f.id),
    success: 'Favorito eliminado',
  );

  // ---- recipes
  /// Logs [servings] of a recipe as one entry. Calories come from the
  /// ingredients; when one has no calories, [kcalOverride] (typed by the
  /// person) is required: nothing is guessed. Macros are logged only when the
  /// whole recipe has them.
  Future<bool> logRecipe(Recipe recipe, double servings, {int? kcalOverride}) =>
      run(() async {
        if (!servings.isFinite || servings <= 0 || servings > 1000) {
          throw ArgumentError('Las porciones deben ser mayores que 0.');
        }
        final perServing = recipe.caloriesPerServing;
        final calories =
            kcalOverride ??
            (perServing == null ? null : (perServing * servings).round());
        if (calories == null) {
          throw ArgumentError(
            'Esta receta tiene ingredientes sin calorías: indica las calorías de lo que comes.',
          );
        }
        double? share(double? total) =>
            total == null ? null : total / recipe.servings * servings;
        await _repository.addFood(
          FoodEntry(
            id: _newId(),
            dateKey: _dateKey,
            name: recipe.name,
            calories: calories,
            portion: servings,
            unit: servings == 1 ? 'porción' : 'porciones',
            proteinG: share(recipe.totalProteinG),
            carbsG: share(recipe.totalCarbsG),
            fatG: share(recipe.totalFatG),
            caloriesSource: CaloriesSource.recipe,
            recipeId: recipe.id,
          ),
        );
        announce('${recipe.name} añadido');
      });

  String newId() => _newId();

  Future<bool> saveRecipe(Recipe recipe) =>
      run(() => _repository.saveRecipe(recipe), success: 'Receta guardada');
  Future<bool> deleteRecipe(Recipe recipe) => run(
    () => _repository.deleteRecipe(recipe.id),
    success: 'Receta eliminada',
  );

  /// Recipes with a declared [tag] and without a declared [allergen]. A
  /// recipe whose allergens were never declared is not assumed safe: it is
  /// left out when an allergen is excluded, and counted by [undeclared].
  List<Recipe> filterRecipes({String? tag, String? withoutAllergen}) => [
    for (final r in recipes)
      if ((tag == null || r.tags.contains(tag)) &&
          (withoutAllergen == null ||
              (r.allergens != null && !r.allergens!.contains(withoutAllergen))))
        r,
  ];

  int undeclared({String? tag}) => [
    for (final r in recipes)
      if ((tag == null || r.tags.contains(tag)) && r.allergens == null) r,
  ].length;

  List<String> get allTags =>
      ({for (final r in recipes) ...r.tags}.toList()..sort());
  List<String> get allAllergens =>
      ({for (final r in recipes) ...?r.allergens}.toList()..sort());

  Future<bool> saveGoals(NutritionGoals goals) =>
      run(() => _repository.saveGoals(goals), success: 'Objetivos guardados');
}
