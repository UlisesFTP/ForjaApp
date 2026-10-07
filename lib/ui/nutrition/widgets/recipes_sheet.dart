import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/nutrition_view_model.dart';
import 'food_form.dart' show parseOptional;
import 'nutrition_view.dart' show gramsText;
import '../../core/tone_buttons.dart';

Future<void> showRecipes(BuildContext context, NutritionViewModel vm) =>
    showForjaSheet<void>(context, title: 'Recetas', child: _RecipesPanel(vm));

Future<void> showRecipeEditor(
  BuildContext context,
  NutritionViewModel vm, {
  Recipe? recipe,
}) => showForjaSheet<void>(
  context,
  title: recipe == null ? 'Nueva receta' : 'Editar receta',
  child: RecipeEditor(vm: vm, recipe: recipe),
);

class _RecipesPanel extends StatefulWidget {
  const _RecipesPanel(this.vm);
  final NutritionViewModel vm;
  @override
  State<_RecipesPanel> createState() => _RecipesPanelState();
}

class _RecipesPanelState extends State<_RecipesPanel> {
  String? tag, withoutAllergen;

  NutritionViewModel get vm => widget.vm;

  Future<void> _log(Recipe r) async {
    final servings = TextEditingController(text: '1');
    final kcal = TextEditingController();
    final needsKcal = r.caloriesPerServing == null;
    final result = await showDialog<(double, int?)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir ${r.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('recipe-servings'),
                controller: servings,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Porciones que comes',
                ),
              ),
              if (needsKcal) ...[
                const SizedBox(height: 8),
                const Text(
                  'Algún ingrediente no tiene calorías: indica las de lo que comes.',
                ),
                TextField(
                  key: const ValueKey('recipe-kcal'),
                  controller: kcal,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Calorías (kcal)',
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('recipe-log'),
            onPressed: () {
              final s = parseOptional(servings.text).value;
              if (s == null) return;
              Navigator.pop(context, (s, int.tryParse(kcal.text.trim())));
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
    servings.dispose();
    kcal.dispose();
    if (result != null) {
      final saved = await vm.logRecipe(r, result.$1, kcalOverride: result.$2);
      if (saved && mounted) Navigator.pop(context);
    }
  }

  Future<void> _delete(Recipe r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar ${r.name}?'),
        content: const Text(
          'Lo que ya registraste con esta receta se conserva tal como estaba.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: toneStyle(ActionTone.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const ToneLabel(Icons.delete_outline, 'Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) await vm.deleteRecipe(r);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: vm,
    builder: (context, _) {
      final list = vm.filterRecipes(tag: tag, withoutAllergen: withoutAllergen);
      final hidden = withoutAllergen == null ? 0 : vm.undeclared(tag: tag);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const ValueKey('new-recipe'),
            onPressed: () => showRecipeEditor(context, vm),
            icon: const Icon(Icons.add),
            label: const Text('Nueva receta'),
          ),
          if (vm.allTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Preferencia'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final t in vm.allTags)
                  FilterChip(
                    label: Text(t),
                    selected: tag == t,
                    onSelected: (v) => setState(() => tag = v ? t : null),
                  ),
              ],
            ),
          ],
          if (vm.allAllergens.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Sin el alérgeno declarado'),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final a in vm.allAllergens)
                  FilterChip(
                    label: Text('sin $a'),
                    selected: withoutAllergen == a,
                    onSelected: (v) =>
                        setState(() => withoutAllergen = v ? a : null),
                  ),
              ],
            ),
            if (hidden > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  withoutAllergen == null
                      ? ''
                      : '$hidden receta${hidden == 1 ? '' : 's'} sin alérgenos declarados no se muestra${hidden == 1 ? '' : 'n'}: no se da por segura.',
                  key: const ValueKey('undeclared-note'),
                  style: const TextStyle(color: ForjaColors.muted),
                ),
              ),
          ],
          const SizedBox(height: 12),
          if (list.isEmpty) const Text('No hay recetas con estos filtros.'),
          for (final r in list) _tile(context, r),
          const SizedBox(height: 8),
          const Text(
            'Las etiquetas y alérgenos los declaras tú. "Sin declarar" no significa que no haya alérgenos, y la app no garantiza seguridad clínica.',
            style: TextStyle(color: ForjaColors.muted),
          ),
        ],
      );
    },
  );

  Widget _tile(BuildContext context, Recipe r) {
    final per = r.caloriesPerServing;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: Theme.of(context).textTheme.titleMedium),
          Text(
            '${gramsText(r.servings)} ${r.servings == 1 ? 'porción' : 'porciones'} · ${per == null ? 'calorías: sin dato' : '$per kcal por porción'}',
          ),
          if (r.tags.isNotEmpty) Text('Etiquetas: ${r.tags.join(', ')}'),
          Text(
            r.allergens == null
                ? 'Alérgenos: sin declarar'
                : r.allergens!.isEmpty
                ? 'Alérgenos: ninguno declarado'
                : 'Alérgenos: ${r.allergens!.join(', ')}',
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                key: ValueKey('log-${r.id}'),
                onPressed: vm.busy ? null : () => _log(r),
                child: const Text('Añadir al registro'),
              ),
              IconButton(
                tooltip: 'Editar ${r.name}',
                onPressed: () => showRecipeEditor(context, vm, recipe: r),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Eliminar ${r.name}',
                style: toneIconStyle(ActionTone.danger),
                onPressed: vm.busy ? null : () => _delete(r),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientControllers {
  _IngredientControllers([Ingredient? i])
    : name = TextEditingController(text: i?.name ?? ''),
      quantity = TextEditingController(text: _t(i?.quantity)),
      unit = TextEditingController(text: i?.unit ?? ''),
      kcal = TextEditingController(
        text: i?.calories == null ? '' : '${i!.calories}',
      ),
      protein = TextEditingController(text: _t(i?.proteinG)),
      carbs = TextEditingController(text: _t(i?.carbsG)),
      fat = TextEditingController(text: _t(i?.fatG));
  final TextEditingController name, quantity, unit, kcal, protein, carbs, fat;
  static String _t(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());
  void dispose() {
    for (final c in [name, quantity, unit, kcal, protein, carbs, fat]) {
      c.dispose();
    }
  }
}

/// Create or edit a recipe. Ingredient numbers are optional: a recipe with a
/// missing value shows "sin dato" instead of a smaller total.
class RecipeEditor extends StatefulWidget {
  const RecipeEditor({super.key, required this.vm, this.recipe});
  final NutritionViewModel vm;
  final Recipe? recipe;
  @override
  State<RecipeEditor> createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, servings, notes, tags, allergens;
  late final List<_IngredientControllers> rows;
  late bool declareAllergens;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    name = TextEditingController(text: r?.name ?? '');
    servings = TextEditingController(
      text: r == null ? '1' : gramsText(r.servings),
    );
    notes = TextEditingController(text: r?.notes ?? '');
    tags = TextEditingController(text: r?.tags.join(', ') ?? '');
    allergens = TextEditingController(text: r?.allergens?.join(', ') ?? '');
    declareAllergens = r?.allergens != null;
    rows = [
      for (final i in r?.ingredients ?? const <Ingredient>[])
        _IngredientControllers(i),
      if (r == null) _IngredientControllers(),
    ];
  }

  @override
  void dispose() {
    for (final c in [name, servings, notes, tags, allergens]) {
      c.dispose();
    }
    for (final r in rows) {
      r.dispose();
    }
    super.dispose();
  }

  List<String> _split(String text) => [
    for (final part in text.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  List<Ingredient> _ingredients() => [
    for (final r in rows)
      if (r.name.text.trim().isNotEmpty)
        Ingredient(
          name: r.name.text.trim(),
          quantity: parseOptional(r.quantity.text).value,
          unit: r.unit.text.trim().isEmpty ? null : r.unit.text.trim(),
          calories: int.tryParse(r.kcal.text.trim()),
          proteinG: parseOptional(r.protein.text).value,
          carbsG: parseOptional(r.carbs.text).value,
          fatG: parseOptional(r.fat.text).value,
        ),
  ];

  Recipe _build() => Recipe(
    id: widget.recipe?.id ?? widget.vm.newId(),
    name: name.text.trim(),
    servings: parseOptional(servings.text).value ?? 0,
    ingredients: _ingredients(),
    createdAt: widget.recipe?.createdAt ?? DateTime.now().toUtc(),
    notes: notes.text.trim(),
    tags: _split(tags.text),
    allergens: declareAllergens ? _split(allergens.text) : null,
  );

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    if (await widget.vm.saveRecipe(_build()) && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _build();
    final total = preview.totalCalories;
    return AnimatedBuilder(
      animation: widget.vm,
      builder: (context, _) => Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const ValueKey('recipe-name'),
              controller: name,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Nombre de la receta',
              ),
              validator: (t) =>
                  (t ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
            ),
            TextFormField(
              key: const ValueKey('recipe-yield'),
              controller: servings,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Porciones que rinde',
              ),
              onChanged: (_) => setState(() {}),
              validator: (t) {
                final v = parseOptional(t ?? '').value;
                return v == null || v <= 0 || v > 1000 ? 'Mayor que 0' : null;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Ingredientes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            for (var i = 0; i < rows.length; i++) _row(i),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey('add-ingredient'),
                onPressed: rows.length >= 50
                    ? null
                    : () => setState(() => rows.add(_IngredientControllers())),
                icon: const Icon(Icons.add),
                label: const Text('Añadir ingrediente'),
              ),
            ),
            SurfaceCard(
              child: Text(
                key: const ValueKey('recipe-total'),
                total == null
                    ? 'Total: sin dato (falta alguna caloría)'
                    : 'Total: $total kcal · ${preview.caloriesPerServing} kcal por porción',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tags,
              decoration: const InputDecoration(
                labelText: 'Etiquetas (separadas por comas)',
                helperText: 'Por ejemplo: vegetariana, rápida',
              ),
            ),
            SwitchListTile(
              key: const ValueKey('declare-allergens'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Declarar alérgenos'),
              subtitle: const Text('Apagado = sin declarar (no es "ninguno")'),
              value: declareAllergens,
              onChanged: (v) => setState(() => declareAllergens = v),
            ),
            if (declareAllergens)
              TextField(
                key: const ValueKey('recipe-allergens'),
                controller: allergens,
                decoration: const InputDecoration(
                  labelText: 'Alérgenos (separados por comas)',
                  helperText: 'Déjalo vacío si declaras que no hay ninguno',
                ),
              ),
            TextField(
              controller: notes,
              minLines: 2,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(labelText: 'Notas (opcional)'),
            ),
            FilledButton(
              key: const ValueKey('recipe-save'),
              style: toneStyle(ActionTone.confirm),
              onPressed: widget.vm.busy ? null : _save,
              child: ToneLabel(
                Icons.save_outlined,
                widget.vm.busy ? 'Guardando…' : 'Guardar receta',
              ),
            ),
            if (widget.vm.error != null)
              Semantics(liveRegion: true, child: Text(widget.vm.error!)),
          ],
        ),
      ),
    );
  }

  Widget _row(int i) {
    final r = rows[i];
    Widget f(
      String key,
      TextEditingController c,
      String label,
      double w, {
      bool number = false,
      bool digits = false,
    }) => SizedBox(
      width: w,
      child: TextField(
        key: ValueKey('$key-$i'),
        controller: c,
        keyboardType: number || digits
            ? TextInputType.numberWithOptions(decimal: number)
            : TextInputType.text,
        inputFormatters: digits
            ? [FilteringTextInputFormatter.digitsOnly]
            : number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
            : null,
        decoration: InputDecoration(labelText: label),
        onChanged: (_) => setState(() {}),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          f('ing-name', r.name, 'Ingrediente', 180),
          f('ing-qty', r.quantity, 'Cantidad', 120, number: true),
          f('ing-unit', r.unit, 'Unidad', 100),
          f('ing-kcal', r.kcal, 'kcal', 80, digits: true),
          f('ing-p', r.protein, 'P (g)', 80, number: true),
          f('ing-c', r.carbs, 'C (g)', 80, number: true),
          f('ing-f', r.fat, 'G (g)', 80, number: true),
          IconButton(
            tooltip: 'Quitar ingrediente ${i + 1}',
            onPressed: rows.length <= 1
                ? null
                : () => setState(() => rows.removeAt(i).dispose()),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
