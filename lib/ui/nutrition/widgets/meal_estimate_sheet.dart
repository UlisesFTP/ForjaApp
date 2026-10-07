import 'package:flutter/material.dart';

import '../../../domain/models/models.dart';
import '../../../domain/services/ai/meal_estimate.dart';
import '../../core/ai_widgets.dart';
import '../../core/widgets.dart';
import '../view_models/meal_estimate_view_model.dart';
import '../view_models/nutrition_view_model.dart';
import '../../core/tone_buttons.dart';

/// "Describir comida (IA)": returns the values to fill the food form with
/// (source `estimated`), or null. It never saves anything.
Future<FoodDraft?> showMealEstimate(
  BuildContext context,
  MealEstimateViewModel vm,
) => showForjaSheet<FoodDraft>(
  context,
  title: 'Describir comida',
  child: _MealEstimate(vm),
);

String _g(double? v) => v == null
    ? '—'
    : '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1).replaceAll('.', ',')} g';

class _MealEstimate extends StatefulWidget {
  const _MealEstimate(this.vm);
  final MealEstimateViewModel vm;
  @override
  State<_MealEstimate> createState() => _MealEstimateState();
}

class _MealEstimateState extends State<_MealEstimate> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  FoodDraft _draft(MealEstimate e) => FoodDraft(
    name: e.title,
    calories: e.totalKcal,
    proteinG: e.proteinG,
    carbsG: e.carbsG,
    fatG: e.fatG,
    source: CaloriesSource.estimated,
  );

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final vm = widget.vm, e = vm.estimate;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AiBadge(detail: vm.provider),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('meal-text'),
            controller: _text,
            maxLines: 4,
            minLines: 2,
            maxLength: MealEstimateViewModel.maxLength,
            enabled: !vm.working,
            decoration: const InputDecoration(
              labelText: 'Qué comiste y cuánto',
              hintText: 'Ej.: 2 tacos al pastor y un refresco de 355 ml',
            ),
          ),
          const Text(
            'Solo se envía este texto a tu proveedor. Revisa los valores antes '
            'de guardar: son una estimación.',
          ),
          const SizedBox(height: 8),
          if (vm.working)
            Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Estimando…')),
                TextButton(
                  key: const ValueKey('meal-stop'),
                  onPressed: vm.stop,
                  child: const Text('Detener'),
                ),
              ],
            )
          else
            FilledButton.icon(
              key: const ValueKey('meal-estimate'),
              onPressed: vm.available
                  ? () => vm.estimateFrom(_text.text)
                  : null,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Estimar'),
            ),
          if (!vm.available)
            const Text(
              'El asistente no está activo: actívalo en Más → Asistente IA.',
            ),
          if (vm.error != null && !vm.working)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(liveRegion: true, child: Text(vm.error!)),
            ),
          if (e != null) ...[
            const SizedBox(height: 12),
            SurfaceCard(
              key: const ValueKey('meal-result'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(e.title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    '${e.totalKcal} kcal estimadas · confianza '
                    '${e.confidence.label}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Proteína ${_g(e.proteinG)} · Carbohidratos '
                    '${_g(e.carbsG)} · Grasa ${_g(e.fatG)}',
                  ),
                  const SizedBox(height: 8),
                  for (final i in e.items)
                    Text(
                      '• ${i.name}'
                      '${i.grams == null ? '' : ' (${_g(i.grams)})'}: '
                      '${i.kcal} kcal',
                    ),
                  if (e.assumptions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Supuestos',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    for (final a in e.assumptions) Text('• $a'),
                  ],
                  if (e.question != null) ...[
                    const SizedBox(height: 8),
                    Text('Pregunta: ${e.question}'),
                  ],
                  for (final w in e.warnings) ...[
                    const SizedBox(height: 8),
                    Text(w),
                  ],
                  if (vm.usage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${vm.usage!.total} tokens',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('meal-use'),
              style: toneStyle(ActionTone.confirm),
              onPressed: () => Navigator.of(context).pop(_draft(e)),
              child: const ToneLabel(Icons.check, 'Usar estos valores'),
            ),
            const Text(
              'Se rellena el formulario; nada se guarda hasta que tú lo '
              'guardes. Si escribes otras calorías, pasan a ser tuyas.',
            ),
          ],
        ],
      );
    },
  );
}
