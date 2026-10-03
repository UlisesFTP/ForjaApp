import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/nutrition_view_model.dart';
import 'food_form.dart' show parseOptional;

Future<void> showGoals(BuildContext context, NutritionViewModel vm) =>
    showForjaSheet<void>(context, title: 'Objetivos', child: _GoalsForm(vm));

class _GoalsForm extends StatefulWidget {
  const _GoalsForm(this.vm);
  final NutritionViewModel vm;
  @override
  State<_GoalsForm> createState() => _GoalsFormState();
}

class _GoalsFormState extends State<_GoalsForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController kcal, protein, carbs, fat;

  static String _text(num? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    final g = widget.vm.goals;
    kcal = TextEditingController(text: _text(g.kcal));
    protein = TextEditingController(text: _text(g.proteinG));
    carbs = TextEditingController(text: _text(g.carbsG));
    fat = TextEditingController(text: _text(g.fatG));
  }

  @override
  void dispose() {
    for (final c in [kcal, protein, carbs, fat]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _grams(String? t) {
    final p = parseOptional(t ?? '');
    if (!p.ok) return 'Escribe un número';
    final v = p.value;
    return v != null && (v < 0 || v > 1000) ? '0–1000 g' : null;
  }

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    final k = kcal.text.trim();
    final saved = await widget.vm.saveGoals(
      NutritionGoals(
        kcal: k.isEmpty ? null : int.parse(k),
        proteinG: parseOptional(protein.text).value,
        carbsG: parseOptional(carbs.text).value,
        fatG: parseOptional(fat.text).value,
      ),
    );
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.vm,
    builder: (context, _) => Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Opcionales y tuyos: la app no calcula objetivos ni dietas. Sin objetivo, el minicoach solo muestra referencias generales no clínicas. Vacío significa "sin objetivo".',
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('goal-input-kcal'),
            controller: kcal,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Calorías al día (kcal)',
            ),
            validator: (t) {
              final v = int.tryParse((t ?? '').trim());
              if ((t ?? '').trim().isEmpty) return null;
              return v == null || v < 500 || v > 10000
                  ? '500–10000 kcal'
                  : null;
            },
          ),
          const SizedBox(height: 8),
          for (final (key, label, c) in [
            ('goal-input-protein', 'Proteína (g)', protein),
            ('goal-input-carbs', 'Carbohidratos (g)', carbs),
            ('goal-input-fat', 'Grasa (g)', fat),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                key: ValueKey(key),
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(labelText: label),
                validator: _grams,
              ),
            ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('goals-save'),
            onPressed: widget.vm.busy ? null : _save,
            child: Text(widget.vm.busy ? 'Guardando…' : 'Guardar objetivos'),
          ),
          if (widget.vm.error != null)
            Semantics(liveRegion: true, child: Text(widget.vm.error!)),
        ],
      ),
    ),
  );
}
