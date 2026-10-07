import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/nutrition_view_model.dart';
import '../../core/tone_buttons.dart';

/// Parses a typed number (comma or dot). Empty is null (unknown); anything
/// else that is not a finite number is an error.
({double? value, bool ok}) parseOptional(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return (value: null, ok: true);
  final v = double.tryParse(t);
  return v == null || !v.isFinite
      ? (value: null, ok: false)
      : (value: v, ok: true);
}

/// What the food form needs from the optional assistant (F17): whether it
/// can be asked now, and a way to ask it. The form never talks to the
/// network itself.
class MealAssist {
  const MealAssist({
    required this.listenable,
    required this.available,
    required this.describe,
  });

  /// Changes when the assistant is turned on or off.
  final Listenable listenable;
  final bool Function() available;

  /// Opens "Describir comida (IA)" and returns the values to fill in.
  final Future<FoodDraft?> Function(BuildContext context) describe;
}

Future<void> showFoodForm(
  BuildContext context,
  NutritionViewModel vm, {
  FoodEntry? entry,
  MealAssist? assist,
  FoodDraft? initial,
}) => showForjaSheet<void>(
  context,
  title: entry == null ? 'Añadir alimento' : 'Editar alimento',
  child: FoodForm(vm: vm, entry: entry, assist: assist, initial: initial),
);

/// Name, calories, optional portion and macros. Calories typed by hand are
/// the person's own number; "Calcular desde macros" fills them in visibly and
/// the entry then says where they came from.
class FoodForm extends StatefulWidget {
  const FoodForm({
    super.key,
    required this.vm,
    this.entry,
    this.assist,
    this.initial,
  });
  final NutritionViewModel vm;
  final FoodEntry? entry;

  /// Values to start a new entry with (an assistant's proposal, F17).
  final FoodDraft? initial;

  /// Offered when adding a food, if the assistant is on.
  final MealAssist? assist;
  @override
  State<FoodForm> createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name,
      calories,
      portion,
      unit,
      protein,
      carbs,
      fat;
  CaloriesSource source = CaloriesSource.manual;
  bool favorite = false;

  static String _text(double? v) => v == null
      ? ''
      : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    name = TextEditingController(text: e?.name ?? '');
    calories = TextEditingController(text: e == null ? '' : '${e.calories}');
    portion = TextEditingController(text: _text(e?.portion));
    unit = TextEditingController(text: e?.unit ?? '');
    protein = TextEditingController(text: _text(e?.proteinG));
    carbs = TextEditingController(text: _text(e?.carbsG));
    fat = TextEditingController(text: _text(e?.fatG));
    source = switch (e?.caloriesSource) {
      CaloriesSource.macros => CaloriesSource.macros,
      CaloriesSource.estimated => CaloriesSource.estimated,
      _ => CaloriesSource.manual,
    };
    final i = widget.initial;
    if (e == null && i != null) {
      name.text = i.name;
      calories.text = '${i.calories}';
      portion.text = _text(i.portion);
      unit.text = i.unit ?? '';
      protein.text = _text(i.proteinG);
      carbs.text = _text(i.carbsG);
      fat.text = _text(i.fatG);
      source = i.source;
      _estimatedKcal = i.calories;
    }
  }

  @override
  void dispose() {
    for (final c in [name, calories, portion, unit, protein, carbs, fat]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _gramsError(String? text) {
    final p = parseOptional(text ?? '');
    if (!p.ok) return 'Escribe un número';
    final v = p.value;
    return v != null && (v < 0 || v > 2000) ? '0–2000 g' : null;
  }

  /// The calories are still the estimate they started as.
  // The calories an estimate came with: kept as an estimate while unchanged.
  late int? _estimatedKcal = widget.entry?.calories;

  bool get _estimateKept =>
      source == CaloriesSource.estimated &&
      calories.text.trim() == '$_estimatedKcal';

  String _number(double? v) =>
      v == null ? '' : (v == v.roundToDouble() ? '${v.toInt()}' : '$v');

  /// Fills the form with the assistant's estimate; nothing is saved.
  Future<void> _describe() async {
    final draft = await widget.assist!.describe(context);
    if (draft == null || !mounted) return;
    setState(() {
      name.text = draft.name;
      calories.text = '${draft.calories}';
      protein.text = _number(draft.proteinG);
      carbs.text = _number(draft.carbsG);
      fat.text = _number(draft.fatG);
      source = CaloriesSource.estimated;
      _estimatedKcal = draft.calories;
    });
  }

  void _fromMacros() {
    final p = parseOptional(protein.text), c = parseOptional(carbs.text);
    final f = parseOptional(fat.text);
    final kcal = p.ok && c.ok && f.ok
        ? caloriesFromMacros(p.value, c.value, f.value)
        : null;
    if (kcal == null) {
      setState(() => form.currentState?.validate());
      widget.vm.announce(
        'Para calcular necesitas proteína, carbohidratos y grasa.',
      );
      return;
    }
    setState(() {
      calories.text = '$kcal';
      source = CaloriesSource.macros;
    });
  }

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    final p = parseOptional(protein.text), c = parseOptional(carbs.text);
    final f = parseOptional(fat.text), q = parseOptional(portion.text);
    final kcal = int.parse(calories.text.trim());
    // Calories edited after being calculated are the person's own again. An
    // estimate stays an estimate while its calories are untouched: editing
    // the name or the portion does not turn it into the person's number
    // (D40).
    final derived = caloriesFromMacros(p.value, c.value, f.value);
    final effective = source == CaloriesSource.macros && derived == kcal
        ? CaloriesSource.macros
        : _estimateKept
        ? CaloriesSource.estimated
        : widget.entry?.caloriesSource == CaloriesSource.recipe
        ? CaloriesSource.recipe
        : CaloriesSource.manual;
    final draft = FoodDraft(
      name: name.text,
      calories: kcal,
      portion: q.value,
      unit: unit.text,
      proteinG: p.value,
      carbsG: c.value,
      fatG: f.value,
      source: effective,
    );
    final saved = widget.entry == null
        ? await widget.vm.add(draft)
        : await widget.vm.update(widget.entry!, draft);
    if (!saved || !mounted) return;
    if (favorite && widget.entry == null) {
      final added = widget.vm.entries.lastOrNull;
      if (added != null) await widget.vm.saveFavorite(added);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.vm,
    builder: (context, _) => Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.assist != null && widget.entry == null)
            ListenableBuilder(
              listenable: widget.assist!.listenable,
              builder: (context, _) => widget.assist!.available()
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OutlinedButton.icon(
                        key: const ValueKey('food-describe'),
                        onPressed: widget.vm.busy ? null : _describe,
                        icon: const Icon(Icons.cloud_outlined),
                        label: const Text('Describir comida (IA)'),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          TextFormField(
            key: const ValueKey('food-name'),
            controller: name,
            maxLength: 80,
            decoration: const InputDecoration(labelText: 'Alimento o comida'),
            validator: (t) =>
                (t ?? '').trim().isEmpty ? 'Escribe un nombre' : null,
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: const ValueKey('food-kcal'),
            controller: calories,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Calorías (kcal)',
              helperText: source == CaloriesSource.macros
                  ? 'Calculadas desde los macros: 4·proteína + 4·carbohidratos + 9·grasa'
                  : _estimateKept
                  ? 'Estimadas por el asistente (IA): si escribes otras, pasan a ser tuyas'
                  : 'Tu número manda: no se cambia solo',
            ),
            onChanged: (_) => setState(() {}),
            // Once the person types, the message follows the value: a valid
            // number must not keep showing the error from the first attempt.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (t) {
              final v = int.tryParse((t ?? '').trim());
              return v == null || v < 0 || v > 5000
                  ? 'Introduce entre 0 y 5000 kcal'
                  : null;
            },
          ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            initiallyExpanded:
                widget.entry != null &&
                (widget.entry!.hasMacros || widget.entry!.portion != null),
            title: const Text('Porción y macros (opcional)'),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _field('food-portion', portion, 'Porción', 130, number: true),
                  _field('food-unit', unit, 'Unidad', 130, maxLength: 12),
                  _field(
                    'food-protein',
                    protein,
                    'Proteína (g)',
                    170,
                    number: true,
                    grams: true,
                  ),
                  _field(
                    'food-carbs',
                    carbs,
                    'Carbohidratos (g)',
                    190,
                    number: true,
                    grams: true,
                  ),
                  _field(
                    'food-fat',
                    fat,
                    'Grasa (g)',
                    170,
                    number: true,
                    grams: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  key: const ValueKey('food-from-macros'),
                  onPressed: _fromMacros,
                  child: const Text('Calcular kcal desde macros'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 8),
                child: Text(
                  'Lo que dejes vacío queda como "sin dato", no como 0 g.',
                ),
              ),
            ],
          ),
          if (widget.entry == null)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text('Guardar en favoritos'),
              value: favorite,
              onChanged: (v) => setState(() => favorite = v ?? false),
            ),
          const SizedBox(height: 8),
          FilledButton(
            key: const ValueKey('food-save'),
            style: toneStyle(ActionTone.confirm),
            onPressed: widget.vm.busy ? null : _save,
            child: ToneLabel(
              Icons.save_outlined,
              widget.vm.busy ? 'Guardando…' : 'Guardar',
            ),
          ),
          if (widget.vm.error != null)
            Semantics(liveRegion: true, child: Text(widget.vm.error!)),
        ],
      ),
    ),
  );

  Widget _field(
    String key,
    TextEditingController controller,
    String label,
    double width, {
    bool number = false,
    bool grams = false,
    int? maxLength,
  }) => SizedBox(
    width: width,
    child: TextFormField(
      key: ValueKey(key),
      controller: controller,
      maxLength: maxLength,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
          : null,
      decoration: InputDecoration(labelText: label, counterText: ''),
      onChanged: (_) {
        if (grams && source == CaloriesSource.macros) {
          setState(() {});
        }
      },
      validator: grams
          ? _gramsError
          : number
          ? (t) {
              final p = parseOptional(t ?? '');
              if (!p.ok) return 'Escribe un número';
              final v = p.value;
              return v != null && (v <= 0 || v > 100000) ? 'Mayor que 0' : null;
            }
          : null,
    ),
  );
}
