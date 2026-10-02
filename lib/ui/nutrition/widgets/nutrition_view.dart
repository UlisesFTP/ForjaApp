import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/models.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/nutrition_view_model.dart';
import 'food_form.dart';
import 'goals_sheet.dart';
import 'recipes_sheet.dart';

String gramsText(double v) =>
    v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);

class NutritionView extends StatelessWidget {
  const NutritionView({super.key, required this.vm});
  final NutritionViewModel vm;

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) {
      final entries = vm.entries;
      return ResponsivePage(
        header: const PageHeading(
          'NUTRICIÓN',
          subtitle: 'Un registro sencillo de tu día.',
        ),
        // The day's total and actions beside what was logged.
        primary: [
          Row(
            children: [
              IconButton(
                tooltip: 'Día anterior',
                onPressed: () => vm.shiftDays(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  vm.isToday
                      ? 'Hoy · ${shortDate(vm.selectedDate)}'
                      : friendlyDate(vm.selectedDate),
                  key: const ValueKey('nutrition-date'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Día siguiente',
                onPressed: () => vm.shiftDays(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          if (!vm.isToday)
            Align(
              child: TextButton(
                onPressed: () => vm.selectDate(vm.today),
                child: const Text('Volver a hoy'),
              ),
            ),
          const SizedBox(height: 8),
          _summary(context),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey('add-food'),
                onPressed: () => showFoodForm(context, vm),
                icon: const Icon(Icons.add),
                label: const Text('Añadir alimento'),
              ),
              OutlinedButton(
                key: const ValueKey('open-recipes'),
                onPressed: () => showRecipes(context, vm),
                child: const Text('Recetas'),
              ),
              OutlinedButton(
                key: const ValueKey('open-goals'),
                onPressed: () => showGoals(context, vm),
                child: const Text('Objetivos'),
              ),
            ],
          ),
          if (vm.favorites.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Favoritos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final f in vm.favorites)
                  InputChip(
                    key: ValueKey('fav-${f.id}'),
                    label: Text('${f.name} · ${f.calories} kcal'),
                    tooltip: 'Añadir ${f.name}',
                    onPressed: vm.busy ? null : () => vm.logFavorite(f),
                    onDeleted: vm.busy ? null : () => vm.removeFavorite(f),
                    deleteButtonTooltipMessage: 'Quitar ${f.name} de favoritos',
                  ),
              ],
            ),
          ],
        ],
        secondary: [
          const SizedBox(height: 24),
          Text(
            vm.isToday ? 'Hoy' : 'Registro del día',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Todavía no has registrado alimentos este día.'),
            ),
          for (final entry in entries) _entryTile(context, entry),
          const SizedBox(height: 16),
          const Text(
            'Las calorías y los macros los introduces tú; la app no tiene base de alimentos ni escaneo, ni calcula una dieta. Lo que no registras no se cuenta como 0.',
          ),
        ],
      );
    },
  );

  Widget _summary(BuildContext context) {
    final goals = vm.goals, kcal = vm.calories, entries = vm.entries;
    final macros = [
      ('Proteína', vm.protein, goals.proteinG),
      ('Carbohidratos', vm.carbs, goals.carbsG),
      ('Grasa', vm.fat, goals.fatG),
    ];
    return SurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.isToday ? 'CALORÍAS REGISTRADAS HOY' : 'CALORÍAS REGISTRADAS',
            style: const TextStyle(
              color: ForjaColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          Semantics(
            label: entries.isEmpty ? 'Sin registros' : '$kcal kilocalorías',
            excludeSemantics: true,
            child: Text(
              entries.isEmpty ? 'Sin registros' : '$kcal',
              key: const ValueKey('kcal-total'),
              style: const TextStyle(
                fontFamily: 'Barlow Condensed',
                fontWeight: FontWeight.w700,
                fontSize: 56,
                color: ForjaColors.ink,
              ),
            ),
          ),
          Text(
            entries.isEmpty
                ? 'Nada registrado todavía'
                : 'kcal · ${entries.length} ${entries.length == 1 ? 'entrada' : 'entradas'}',
            style: const TextStyle(color: ForjaColors.ink),
          ),
          if (goals.kcal != null && entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                key: const ValueKey('goal-kcal'),
                'Objetivo ${goals.kcal} kcal · registradas $kcal de ${goals.kcal}',
                style: const TextStyle(
                  color: ForjaColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          for (final (label, total, goal) in macros)
            if (total.grams != null || goal != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  total.grams == null
                      ? '$label: sin datos${goal == null ? '' : ' · objetivo ${gramsText(goal)} g'}'
                      : '$label: ${gramsText(total.grams!)} g${total.partial ? ' (de ${total.known} de ${total.of} alimentos con dato)' : ''}${goal == null ? '' : ' · objetivo ${gramsText(goal)} g'}',
                  style: const TextStyle(color: ForjaColors.ink),
                ),
              ),
        ],
      ),
    );
  }

  String _detail(FoodEntry e) {
    final parts = [
      '${e.calories} kcal',
      if (e.portion != null)
        '${gramsText(e.portion!)}${e.unit == null ? '' : ' ${e.unit}'}',
      if (e.proteinG != null) 'P ${gramsText(e.proteinG!)} g',
      if (e.carbsG != null) 'C ${gramsText(e.carbsG!)} g',
      if (e.fatG != null) 'G ${gramsText(e.fatG!)} g',
      if (e.caloriesSource == CaloriesSource.macros)
        'kcal calculadas desde macros',
      if (e.caloriesSource == CaloriesSource.recipe) 'de una receta',
    ];
    return parts.join(' · ');
  }

  Widget _entryTile(BuildContext context, FoodEntry entry) => ListTile(
    key: ValueKey('entry-${entry.id}'),
    contentPadding: EdgeInsets.zero,
    title: Text(entry.name),
    subtitle: Text(_detail(entry)),
    onTap: () => showFoodForm(context, vm, entry: entry),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Editar ${entry.name}',
          onPressed: vm.busy
              ? null
              : () => showFoodForm(context, vm, entry: entry),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Eliminar ${entry.name}',
          onPressed: vm.busy ? null : () => vm.remove(entry),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    ),
  );
}
