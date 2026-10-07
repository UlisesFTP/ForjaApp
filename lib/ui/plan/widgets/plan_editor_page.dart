import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/exercise_library.dart';
import '../../core/widgets.dart';
import '../view_models/plan_editor_view_model.dart';
import '../view_models/plan_view_model.dart';
import '../../core/tone_buttons.dart';

/// Makes sure a draft exists, then opens the editor over it.
Future<void> editPlan(
  BuildContext context,
  PlanViewModel plan,
  PlanEditorViewModel Function() createEditor,
) async {
  if (!await plan.startEditing() || !context.mounted) return;
  final editor = createEditor();
  try {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => PlanEditorPage(vm: editor)));
  } finally {
    editor.dispose();
  }
}

class PlanEditorPage extends StatelessWidget {
  const PlanEditorPage({super.key, required this.vm});
  final PlanEditorViewModel vm;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: vm,
    builder: (context, _) => PopScope(
      canPop: !vm.dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Salir sin guardar?'),
            content: const Text(
              'Tienes cambios sin guardar en este borrador. Si sales, se pierden.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Seguir editando'),
              ),
              FilledButton(
                style: toneStyle(ActionTone.caution),
                onPressed: () => Navigator.pop(context, true),
                child: const ToneLabel(Icons.logout, 'Salir sin guardar'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar plan'),
          backgroundColor: ForjaColors.paper,
          foregroundColor: ForjaColors.ink,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: VmObserver(viewModel: vm, builder: _body),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _body(BuildContext context) {
    final issues = vm.issues;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Estás editando un borrador. Lo que cambies aquí no afecta a tus sesiones ya registradas ni al plan en uso hasta que lo aceptes.',
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const ValueKey('plan-name'),
          initialValue: vm.working.name,
          maxLength: 40,
          decoration: const InputDecoration(labelText: 'Nombre del plan'),
          onChanged: vm.renamePlan,
        ),
        const SizedBox(height: 8),
        for (var day = 0; day < vm.working.days.length; day++)
          _DayCard(vm: vm, day: day),
        if (vm.working.days.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Tu plan aún no tiene días. Añade los días que entrenas y sus '
              'ejercicios.',
            ),
          ),
        if (vm.working.days.length < 7)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              key: const ValueKey('add-day'),
              onPressed: vm.busy ? null : vm.addDay,
              icon: const Icon(Icons.add),
              label: const Text('Añadir día'),
            ),
          ),
        if (issues.isNotEmpty)
          SurfaceCard(
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Antes de aceptar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  for (final issue in issues) Text('• $issue'),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: vm.busy || !vm.dirty ? null : vm.save,
          child: Text(vm.dirty ? 'Guardar borrador' : 'Borrador guardado'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          style: toneStyle(ActionTone.confirm),
          onPressed: vm.busy || issues.isNotEmpty
              ? null
              : () => _accept(context),
          child: const ToneLabel(Icons.check_circle_outline, 'Aceptar plan'),
        ),
        const SizedBox(height: 10),
        TextButton(
          style: toneStyle(ActionTone.danger),
          onPressed: vm.busy ? null : () => _discard(context),
          child: const ToneLabel(Icons.delete_outline, 'Descartar borrador'),
        ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    );
  }

  Future<void> _discard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar el borrador?'),
        content: const Text('El plan en uso no cambia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: toneStyle(ActionTone.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const ToneLabel(Icons.delete_outline, 'Descartar'),
          ),
        ],
      ),
    );
    if (confirmed == true && await vm.discard() && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _accept(BuildContext context) async {
    final options = vm.startOptions;
    var chosen = options.first;
    final from = await showDialog<DateTime>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Aceptar plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Las sesiones ya registradas y las de fechas anteriores no cambian. ¿Desde cuándo aplica?',
              ),
              const SizedBox(height: 8),
              RadioGroup<DateTime>(
                groupValue: chosen,
                onChanged: (value) => setState(() => chosen = value ?? chosen),
                child: Column(
                  children: [
                    for (var i = 0; i < options.length; i++)
                      RadioListTile<DateTime>(
                        contentPadding: EdgeInsets.zero,
                        value: options[i],
                        title: Text(
                          i == 0
                              ? 'Desde hoy · ${friendlyDate(options[i])}'
                              : 'Desde el próximo lunes · ${friendlyDate(options[i])}',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: toneStyle(ActionTone.confirm),
              onPressed: () => Navigator.pop(context, chosen),
              child: const ToneLabel(Icons.check, 'Aceptar'),
            ),
          ],
        ),
      ),
    );
    if (from != null && await vm.accept(from) && context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.vm, required this.day});
  final PlanEditorViewModel vm;
  final int day;

  @override
  Widget build(BuildContext context) {
    final planDay = vm.working.days[day], routine = planDay.routine;
    final used = {for (final d in vm.working.days) d.weekday};
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              key: ValueKey('weekday-$day-${planDay.weekday}'),
              initialValue: planDay.weekday,
              isExpanded: true,
              decoration: InputDecoration(labelText: 'Día ${day + 1}'),
              items: [
                for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                  DropdownMenuItem(
                    value: d,
                    enabled: d == planDay.weekday || !used.contains(d),
                    child: Text(weekdayNames[d - 1]),
                  ),
              ],
              onChanged: (value) {
                if (value != null) vm.setWeekday(day, value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('routine-name-${routine.id}'),
              initialValue: routine.name,
              maxLength: 40,
              decoration: const InputDecoration(
                labelText: 'Nombre de la rutina',
              ),
              onChanged: (value) => vm.renameRoutine(day, value),
            ),
            Text(
              'Unos ${vm.minutes(routine)} min · ${routine.exercises.length} ejercicios',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < routine.exercises.length; i++)
              _ExerciseTile(vm: vm, day: day, index: i),
            if (routine.exercises.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Esta rutina no tiene ejercicios todavía.'),
              ),
            OutlinedButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.add),
              label: const Text('Añadir ejercicio'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: ValueKey('remove-day-${routine.id}'),
                style: toneStyle(ActionTone.danger),
                onPressed: vm.busy ? null : () => vm.removeDay(day),
                child: const ToneLabel(Icons.delete_outline, 'Quitar este día'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) => showForjaSheet<void>(
    context,
    title: 'Añadir ejercicio',
    child: _Picker(vm: vm, day: day),
  );
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.vm,
    required this.day,
    required this.index,
  });
  final PlanEditorViewModel vm;
  final int day, index;

  @override
  Widget build(BuildContext context) {
    final planned = vm.working.days[day].routine.exercises[index];
    final e = vm.exercise(planned.exerciseId);
    final reps = e.loadType == LoadType.time
        ? '${planned.repsMin}–${planned.repsMax} s'
        : '${planned.repsMin}–${planned.repsMax}';
    final count = vm.working.days[day].routine.exercises.length;
    return ListTile(
      key: ValueKey('exercise-$day-${planned.exerciseId}'),
      contentPadding: EdgeInsets.zero,
      isThreeLine: true,
      title: Text(e.name),
      subtitle: Text(
        '${planned.sets} × $reps · RIR ${planned.rir} · descanso ${planned.restSeconds} s'
        '${planned.referenceWeightKg == null ? '' : '\nPeso de ejemplo ${weightLabel(planned.referenceWeightKg!)} kg (no es una carga prescrita)'}',
      ),
      trailing: PopupMenuButton<String>(
        tooltip: 'Opciones de ${e.name}',
        onSelected: (action) async {
          switch (action) {
            case 'edit':
              await showForjaSheet<void>(
                context,
                title: e.name,
                child: _PrescriptionForm(
                  planned: planned,
                  exercise: e,
                  onSave: (value) => vm.updateExercise(day, index, value),
                ),
              );
            case 'up':
              vm.moveExercise(day, index, index - 1);
            case 'down':
              vm.moveExercise(day, index, index + 1);
            case 'swap':
              await showForjaSheet<void>(
                context,
                title: 'Cambiar ${e.name}',
                child: _Alternatives(vm: vm, day: day, index: index),
              );
            case 'remove':
              vm.removeExercise(day, index);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Editar series y reps'),
          ),
          if (index > 0)
            const PopupMenuItem(value: 'up', child: Text('Mover arriba')),
          if (index < count - 1)
            const PopupMenuItem(value: 'down', child: Text('Mover abajo')),
          const PopupMenuItem(
            value: 'swap',
            child: Text('Cambiar por alternativa'),
          ),
          const PopupMenuItem(value: 'remove', child: Text('Quitar')),
        ],
      ),
    );
  }
}

class _Picker extends StatefulWidget {
  const _Picker({required this.vm, required this.day});
  final PlanEditorViewModel vm;
  final int day;
  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  String query = '';
  bool onlyMine = true;
  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final taken = vm.working.days[widget.day].routine.exerciseIds;
    final results = searchExercises(
      vm.catalog,
      query: query,
      equipment: onlyMine ? vm.myEquipment : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Buscar ejercicio o músculo',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Solo mi equipo'),
          value: onlyMine,
          onChanged: (value) => setState(() => onlyMine = value),
        ),
        if (results.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Sin resultados. Prueba con otro músculo o activa todo el equipo.',
            ),
          ),
        for (final e in results)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.name),
            subtitle: Text(
              '${e.group} · ${equipmentLabels[e.equipment]}${taken.contains(e.id) ? ' · ya está en la rutina' : ''}',
            ),
            enabled: !taken.contains(e.id),
            onTap: () {
              vm.addExercise(widget.day, e);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class _Alternatives extends StatelessWidget {
  const _Alternatives({
    required this.vm,
    required this.day,
    required this.index,
  });
  final PlanEditorViewModel vm;
  final int day, index;
  @override
  Widget build(BuildContext context) {
    final options = vm.alternatives(day, index);
    if (options.isEmpty) {
      return const Text(
        'No hay alternativas compatibles con tu equipo para este ejercicio. Puedes quitarlo y añadir otro.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Mismo grupo muscular y tipo de movimiento, con el equipo que tienes. Se usa la prescripción por defecto del nuevo ejercicio.',
        ),
        const SizedBox(height: 8),
        for (final e in options)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(e.name),
            subtitle: Text('${e.muscles} · ${equipmentLabels[e.equipment]}'),
            onTap: () {
              vm.replaceExercise(day, index, e);
              Navigator.pop(context);
            },
          ),
      ],
    );
  }
}

class _PrescriptionForm extends StatefulWidget {
  const _PrescriptionForm({
    required this.planned,
    required this.exercise,
    required this.onSave,
  });
  final PlanExercise planned;
  final Exercise exercise;
  final ValueChanged<PlanExercise> onSave;
  @override
  State<_PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<_PrescriptionForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController sets,
      repsMin,
      repsMax,
      rir,
      rest,
      step,
      weight;
  @override
  void initState() {
    super.initState();
    final p = widget.planned;
    sets = TextEditingController(text: '${p.sets}');
    repsMin = TextEditingController(text: '${p.repsMin}');
    repsMax = TextEditingController(text: '${p.repsMax}');
    rir = TextEditingController(text: '${p.rir}');
    rest = TextEditingController(text: '${p.restSeconds}');
    step = TextEditingController(text: weightLabel(p.incrementKg));
    weight = TextEditingController(
      text: p.referenceWeightKg == null
          ? ''
          : weightLabel(p.referenceWeightKg!),
    );
  }

  @override
  void dispose() {
    for (final c in [sets, repsMin, repsMax, rir, rest, step, weight]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _int(String? text, int min, int max, String what) {
    final value = int.tryParse((text ?? '').trim());
    return value == null || value < min || value > max
        ? '$what: $min–$max'
        : null;
  }

  Widget _field(
    TextEditingController c,
    String label,
    String? Function(String?) validator, {
    bool decimal = false,
    String? suffix,
  }) => TextFormField(
    controller: c,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
      ),
    ],
    decoration: InputDecoration(labelText: label, suffixText: suffix),
    validator: validator,
  );

  @override
  Widget build(BuildContext context) {
    final timed = widget.exercise.loadType == LoadType.time;
    return Form(
      key: form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(sets, 'Series', (t) => _int(t, 1, 10, 'Series')),
          const SizedBox(height: 12),
          _field(
            repsMin,
            timed ? 'Segundos mínimos' : 'Repeticiones mínimas',
            (t) => _int(t, 1, 300, 'Mínimo'),
          ),
          const SizedBox(height: 12),
          _field(repsMax, timed ? 'Segundos máximos' : 'Repeticiones máximas', (
            t,
          ) {
            final error = _int(t, 1, 300, 'Máximo');
            if (error != null) return error;
            return int.parse(t!) < (int.tryParse(repsMin.text) ?? 0)
                ? 'El máximo no puede ser menor que el mínimo'
                : null;
          }),
          const SizedBox(height: 12),
          _field(
            rir,
            'RIR (repeticiones en reserva)',
            (t) => _int(t, 0, 5, 'RIR'),
          ),
          const SizedBox(height: 12),
          _field(
            rest,
            'Descanso',
            (t) => _int(t, 0, 600, 'Descanso'),
            suffix: 's',
          ),
          const SizedBox(height: 12),
          _field(
            step,
            'Incremento de carga',
            (t) {
              final v = double.tryParse((t ?? '').replaceAll(',', '.'));
              return v == null || v < 0 || v > 50
                  ? 'Incremento: 0–50 kg'
                  : null;
            },
            decimal: true,
            suffix: 'kg',
          ),
          const SizedBox(height: 12),
          _field(
            weight,
            'Peso de referencia (opcional)',
            (t) {
              if ((t ?? '').trim().isEmpty) return null;
              final v = double.tryParse(t!.replaceAll(',', '.'));
              return v == null || v < 0 || v > 2000 ? 'Peso: 0–2000 kg' : null;
            },
            decimal: true,
            suffix: 'kg',
          ),
          const SizedBox(height: 6),
          Text(
            'El peso de referencia es solo un punto de partida editable, no una carga prescrita.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              widget.onSave(
                widget.planned.copyWith(
                  sets: int.parse(sets.text),
                  repsMin: int.parse(repsMin.text),
                  repsMax: int.parse(repsMax.text),
                  rir: int.parse(rir.text),
                  restSeconds: int.parse(rest.text),
                  incrementKg: double.parse(step.text.replaceAll(',', '.')),
                  referenceWeightKg: () => weight.text.trim().isEmpty
                      ? null
                      : double.parse(weight.text.replaceAll(',', '.')),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Guardar en el borrador'),
          ),
        ],
      ),
    );
  }
}
