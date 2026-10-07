import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/coach_view_model.dart';
import 'profile_inputs.dart';

Future<void> showOnboarding(BuildContext context, CoachViewModel vm) =>
    showForjaSheet<void>(
      context,
      title: 'Vamos a conocerte',
      child: OnboardingFlow(vm: vm),
    );

/// Short steps. Each answer is saved as it is given so the flow can be
/// resumed, and it can be skipped for the example plan at any point.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.vm});
  final CoachViewModel vm;
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final form = GlobalKey<FormState>();
  late UserProfile answers;
  late int step;
  late TextEditingController weight, age;
  @override
  void initState() {
    super.initState();
    answers = widget.vm.profile;
    step = answers.setupStep.clamp(0, CoachViewModel.steps - 1);
    weight = TextEditingController(
      text: answers.weightKg == null ? '' : weightLabel(answers.weightKg!),
    );
    age = TextEditingController(text: answers.age?.toString() ?? '');
  }

  @override
  void dispose() {
    weight.dispose();
    age.dispose();
    super.dispose();
  }

  bool get _last => step == CoachViewModel.steps - 1;
  bool get _canContinue => step != 2 || answers.trainingDays.length == 3;

  Future<void> _next() async {
    if (_last) {
      if (!form.currentState!.validate()) return;
      final done = answers.copyWith(
        weightKg: () => parseOptionalWeight(weight.text),
        age: () => parseOptionalAge(age.text),
      );
      if (await widget.vm.finishOnboarding(done) && mounted) {
        Navigator.pop(context);
      }
      return;
    }
    if (await widget.vm.saveProgress(answers, step + 1) && mounted) {
      setState(() => step++);
    }
  }

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final busy = widget.vm.busy;
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Paso ${step + 1} de ${CoachViewModel.steps}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: (step + 1) / CoachViewModel.steps,
              semanticsLabel: 'Progreso del perfil',
            ),
            const SizedBox(height: 16),
            ..._content(context, busy),
            const SizedBox(height: 20),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: busy ? null : () => setState(() => step--),
                      child: const Text('Atrás'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: busy || !_canContinue ? null : _next,
                    child: Text(
                      busy
                          ? 'Guardando…'
                          : _last
                          ? 'Terminar y crear mi plan'
                          : 'Siguiente',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (await widget.vm.skipSetup() && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: const Text('Saltar por ahora'),
            ),
            Text(
              'Si saltas, empiezas sin plan: puedes crear tu rutina en Plan cuando quieras. No se pide ningún permiso del teléfono.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.vm.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(widget.vm.error!),
                ),
              ),
          ],
        ),
      );
    },
  );

  List<Widget> _content(BuildContext context, bool busy) {
    final title = Theme.of(context).textTheme.titleMedium;
    Widget choice<T>(Map<T, String> labels, T value, ValueChanged<T> onTap) =>
        Column(
          children: [
            for (final entry in labels.entries)
              Semantics(
                selected: entry.key == value,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 52,
                  title: Text(entry.value),
                  trailing: Icon(
                    entry.key == value
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: busy ? null : () => onTap(entry.key),
                ),
              ),
          ],
        );
    return switch (step) {
      0 => [
        Text('¿Cuánta experiencia tienes entrenando?', style: title),
        choice(experienceLabels, answers.experience, (v) {
          setState(() => answers = answers.copyWith(experience: v));
        }),
      ],
      1 => [
        Text('¿Cuál es tu objetivo principal?', style: title),
        choice(goalLabels, answers.goal, (v) {
          setState(() => answers = answers.copyWith(goal: v));
        }),
      ],
      2 => [
        Text('¿Qué tres días entrenas?', style: title),
        const SizedBox(height: 8),
        TrainingDaysPicker(
          selected: answers.trainingDays,
          enabled: !busy,
          onChanged: (days) =>
              setState(() => answers = answers.copyWith(trainingDays: days)),
        ),
      ],
      3 => [
        Text('¿Con qué equipo cuentas?', style: title),
        const SizedBox(height: 8),
        EquipmentPicker(
          selected: answers.equipment,
          enabled: !busy,
          onChanged: (set) =>
              setState(() => answers = answers.copyWith(equipment: set)),
        ),
        const SizedBox(height: 8),
        const Text('El peso corporal siempre está disponible.'),
      ],
      4 => [
        Text('¿Cuánto tiempo tienes por sesión?', style: title),
        const SizedBox(height: 8),
        SessionMinutesPicker(
          minutes: answers.sessionMinutes,
          enabled: !busy,
          onChanged: (m) =>
              setState(() => answers = answers.copyWith(sessionMinutes: m)),
        ),
      ],
      5 => [
        Text('¿Cómo sueles sentirte de energía?', style: title),
        choice(energyLabels, answers.energy, (v) {
          setState(() => answers = answers.copyWith(energy: v));
        }),
      ],
      _ => [
        Text('Datos opcionales', style: title),
        const SizedBox(height: 8),
        const Text(
          'El peso solo se usa para estimar las calorías del cardio. Si lo dejas vacío, el cardio registrará la duración sin calorías. Ninguno de estos datos decide tus cargas.',
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Peso corporal (opcional)',
            suffixText: 'kg',
          ),
          validator: optionalWeightError,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: age,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad (opcional)',
            suffixText: 'años',
          ),
          validator: optionalAgeError,
        ),
      ],
    };
  }
}
