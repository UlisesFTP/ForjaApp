import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../view_models/coach_view_model.dart';
import '../view_models/review_view_model.dart';
import 'review_sheet.dart';
import 'onboarding_sheet.dart';
import 'profile_inputs.dart';

/// First run (or after skipping the setup from the start): the guided steps.
/// Otherwise: the profile as an editable form.
Future<void> showCoach(
  BuildContext context,
  CoachViewModel vm, {
  ReviewViewModel? review,
}) => vm.needsOnboarding
    ? showOnboarding(context, vm)
    : showForjaSheet<void>(
        context,
        title: vm.profile.onboarded ? 'Tu minicoach' : 'Completa tu perfil',
        child: CoachForm(vm: vm, review: review),
      );

const _reasonLabels = {
  ProfileChange.onboarding: 'Primer perfil',
  ProfileChange.skipped: 'Saltó el perfil',
  ProfileChange.edit: 'Edición',
  ProfileChange.review: 'Revisión',
  ProfileChange.reviewRejected: 'Revisión rechazada',
};

class CoachForm extends StatefulWidget {
  const CoachForm({super.key, required this.vm, this.review});
  final CoachViewModel vm;
  final ReviewViewModel? review;
  @override
  State<CoachForm> createState() => _CoachFormState();
}

class _CoachFormState extends State<CoachForm> {
  final form = GlobalKey<FormState>();
  late Experience experience;
  late TrainingGoal goal;
  late Energy energy;
  late Set<Equipment> equipment;
  late List<int> days;
  late int minutes;
  late TextEditingController weight, age, note;
  @override
  void initState() {
    super.initState();
    final p = widget.vm.profile;
    experience = p.experience;
    goal = p.goal;
    energy = p.energy;
    equipment = {...p.equipment};
    days = [...p.trainingDays];
    minutes = p.sessionMinutes;
    weight = TextEditingController(
      text: p.weightKg == null ? '' : weightLabel(p.weightKg!),
    );
    age = TextEditingController(text: p.age?.toString() ?? '');
    note = TextEditingController(text: p.note);
  }

  @override
  void dispose() {
    weight.dispose();
    age.dispose();
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: widget.vm,
    builder: (context) {
      final busy = widget.vm.busy;
      final p = widget.vm.profile;
      return Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.vm.usingExample)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SurfaceCard(
                  child: Text(
                    'Aún no completaste tu perfil. Al guardarlo se crea un borrador de plan para que lo revises; también puedes crear tu rutina en Plan.',
                  ),
                ),
              ),
            if (widget.review != null && p.onboarded)
              _reviewEntry(context, widget.review!),
            const Text(
              'Cambiar tu perfil propone un borrador de plan; no borra tus sesiones ni cambia el plan que usas hasta que lo aceptes.',
            ),
            if (p.lastReview != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Última revisión: ${shortDate(parseDateKey(p.lastReview!))}',
                ),
              ),
            const SizedBox(height: 20),
            _select<Experience>(
              'Experiencia',
              experience,
              experienceLabels,
              (value) => setState(() => experience = value),
            ),
            const SizedBox(height: 16),
            _select<TrainingGoal>(
              'Objetivo',
              goal,
              goalLabels,
              (value) => setState(() => goal = value),
            ),
            const SizedBox(height: 20),
            Text(
              'Días de entrenamiento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TrainingDaysPicker(
              selected: days,
              enabled: !busy,
              onChanged: (next) => setState(() => days = next),
            ),
            const SizedBox(height: 20),
            Text('Equipo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            EquipmentPicker(
              selected: equipment,
              enabled: !busy,
              onChanged: (next) => setState(() => equipment = next),
            ),
            const SizedBox(height: 20),
            Text(
              'Tiempo por sesión',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SessionMinutesPicker(
              minutes: minutes,
              enabled: !busy,
              onChanged: (next) => setState(() => minutes = next),
            ),
            const SizedBox(height: 20),
            _select<Energy>(
              'Energía habitual',
              energy,
              energyLabels,
              (value) => setState(() => energy = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Peso corporal (opcional)',
                suffixText: 'kg',
                helperText: 'Para estimar calorías de cardio y la referencia general de proteína',
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
            const SizedBox(height: 16),
            TextField(
              controller: note,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Progreso o comentario (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy || days.length != 3
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      final saved = await widget.vm.saveEdit(
                        p.copyWith(
                          experience: experience,
                          goal: goal,
                          energy: energy,
                          equipment: equipment,
                          trainingDays: days,
                          sessionMinutes: minutes,
                          weightKg: () => parseOptionalWeight(weight.text),
                          age: () => parseOptionalAge(age.text),
                          note: note.text.trim(),
                        ),
                      );
                      if (saved && context.mounted) Navigator.pop(context);
                    },
              child: Text(busy ? 'Guardando…' : 'Guardar y proponer plan'),
            ),
            const SizedBox(height: 10),
            Text(
              'El minicoach usa reglas locales y explicables: no es un diagnóstico ni una IA. El asistente IA es opcional y externo (Más → Asistente IA).',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.vm.history.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Historial de respuestas (${widget.vm.history.length})',
                ),
                children: [
                  for (final answer in widget.vm.history.reversed)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(_reasonLabels[answer.reason]!),
                      subtitle: Text(
                        '${shortDate(answer.recordedAt.toLocal())} · ${experienceLabels[answer.profile.experience]} · ${goalLabels[answer.profile.goal]}',
                      ),
                    ),
                ],
              ),
            if (widget.vm.error != null)
              Semantics(liveRegion: true, child: Text(widget.vm.error!)),
          ],
        ),
      );
    },
  );

  // Discreet: a card, never a blocking dialog.
  Widget _reviewEntry(BuildContext context, ReviewViewModel review) {
    final status = review.status;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              status.due ? 'Revisión mensual disponible' : 'Revisión mensual',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              status.due
                  ? 'Han pasado ${status.daysSince ?? 'varios'} días desde la última. Comparamos tu mes con tu plan y propones cambios que tú aceptas o rechazas.'
                  : status.snoozedUntil != null
                  ? 'Pospuesta hasta el ${shortDate(parseDateKey(status.snoozedUntil!))}.'
                  : 'Se ofrece cada 30 días; puedes hacerla antes si quieres.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                key: const ValueKey('review-open'),
                onPressed: () => showReview(context, review),
                child: Text(status.due ? 'Hacer la revisión' : 'Revisar ahora'),
              ),
            ),
            ReviewHistory(vm: review),
          ],
        ),
      ),
    );
  }

  Widget _select<T>(
    String label,
    T value,
    Map<T, String> labels,
    ValueChanged<T> onChanged,
  ) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: labels.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: widget.vm.busy
        ? null
        : (value) {
            if (value != null) onChanged(value);
          },
  );
}
