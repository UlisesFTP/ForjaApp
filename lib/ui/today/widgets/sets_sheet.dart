import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/elapsed_timer.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../core/weight_units.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../../progress/view_models/progression_view_model.dart';
import '../../progress/widgets/progression_card.dart';
import '../view_models/today_view_model.dart';
import 'reopen_dialog.dart';
import '../../core/tone_buttons.dart';

/// The detail panel of one exercise: real sets (warm-up and work), skipping
/// and the optional rest countdown. Hoy itself stays compact.
Future<void> showSets(
  BuildContext context,
  TodayViewModel vm,
  String exerciseId, {
  ProgressionViewModel? progression,
}) => showForjaSheet<void>(
  context,
  title: 'Series · ${vm.exercise(exerciseId).name}',
  child: SetsPanel(vm: vm, exerciseId: exerciseId, progression: progression),
);

/// "52.5 kg · 8 reps · RIR 2". Whatever was not recorded says so, instead of
/// showing a zero.
String setSummary(SetLog set, WeightUnit unit) {
  if (!set.isDone) {
    final reason = set.skipReason;
    return reason == null ? 'Omitida' : 'Omitida: $reason';
  }
  final parts = [
    if (set.weightKg != null)
      '${weightText(set.weightKg!, unit)} ${unit.label}',
    if (set.reps != null) '${set.reps} reps',
    if (set.rir != null) 'RIR ${set.rir}',
  ];
  return parts.isEmpty ? 'Sin datos registrados' : parts.join(' · ');
}

class SetsPanel extends StatefulWidget {
  const SetsPanel({
    super.key,
    required this.vm,
    required this.exerciseId,
    this.progression,
  });
  final TodayViewModel vm;
  final String exerciseId;
  final ProgressionViewModel? progression;
  @override
  State<SetsPanel> createState() => _SetsPanelState();
}

class _SetsPanelState extends State<SetsPanel> {
  final load = TextEditingController();
  final reps = TextEditingController();
  final rir = TextEditingController();
  SetKind kind = SetKind.work;
  String? editing;
  String? problem;
  Timer? ticker;

  TodayViewModel get vm => widget.vm;
  String get id => widget.exerciseId;

  @override
  void initState() {
    super.initState();
    if (vm.rest.isRunning) _tick();
  }

  @override
  void dispose() {
    ticker?.cancel();
    load.dispose();
    reps.dispose();
    rir.dispose();
    super.dispose();
  }

  // The countdown is recomputed from timestamps on every tick, so a pause in
  // the ticks (screen off, background) never loses time.
  void _tick() {
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!vm.rest.isRunning) ticker?.cancel();
    });
  }

  void _clear() {
    load.clear();
    reps.clear();
    rir.clear();
    editing = null;
    kind = SetKind.work;
    problem = null;
  }

  void _edit(SetLog set) => setState(() {
    editing = set.id;
    kind = set.kind;
    problem = null;
    load.text = set.weightKg == null ? '' : weightText(set.weightKg!, vm.unit);
    reps.text = set.reps?.toString() ?? '';
    rir.text = set.rir?.toString() ?? '';
  });

  // Empty means "not recorded"; anything typed must be valid.
  SetEntry? _entry() {
    double? kg;
    int? r, e;
    if (load.text.trim().isNotEmpty) {
      kg = parseWeightKg(load.text, vm.unit);
      if (kg == null || kg < 0 || kg > 2000) {
        problem = 'Carga: 0–${weightText(2000, vm.unit)} ${vm.unit.label}';
        return null;
      }
    }
    if (reps.text.trim().isNotEmpty) {
      r = int.tryParse(reps.text.trim());
      if (r == null || r < 0 || r > 999) {
        problem = 'Repeticiones: 0–999';
        return null;
      }
    }
    if (rir.text.trim().isNotEmpty) {
      e = int.tryParse(rir.text.trim());
      if (e == null || e < 0 || e > 10) {
        problem = 'RIR: 0–10';
        return null;
      }
    }
    return SetEntry(kind: kind, weightKg: kg, reps: r, rir: e);
  }

  Future<bool> _allowed() async => !vm.finished || await confirmReopen(context);

  Future<void> _save() async {
    final entry = _entry();
    if (entry == null) {
      setState(() {});
      return;
    }
    if (!await _allowed()) return;
    final target = editing;
    final saved = target == null
        ? await vm.addSet(id, entry)
        : await vm.updateSet(id, target, entry);
    if (saved && mounted) setState(_clear);
  }

  Future<void> _skipSet() async {
    final reason = await askSkipReason(
      context,
      title: 'Omitir serie',
      required: false,
    );
    if (reason == null || !mounted || !await _allowed()) return;
    final saved = await vm.addSet(
      id,
      SetEntry(
        kind: kind,
        status: SetStatus.skipped,
        skipReason: reason.isEmpty ? null : reason,
      ),
    );
    if (saved && mounted) setState(_clear);
  }

  Future<void> _remove(SetLog set) async {
    if (!await _allowed()) return;
    if (await vm.removeSet(id, set.id) && editing == set.id && mounted) {
      setState(_clear);
    }
  }

  Future<void> _skipExercise() async {
    final reason = await askSkipReason(context, title: 'Omitir ejercicio');
    if (reason == null || !mounted || !await _allowed()) return;
    await vm.skip(id, reason);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: vm,
    builder: (context, _) {
      final log = vm.logOf(id);
      final p = vm.prescription(id);
      final unit = vm.unit;
      final last = log.sets.where((s) => s.weightKg != null).lastOrNull;
      final hint = last?.weightKg ?? log.weightKg;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Plan: ${p.sets} × ${p.reps} · ${p.rir}',
            style: const TextStyle(color: ForjaColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            'Anota solo lo que quieras: carga, repeticiones y esfuerzo son opcionales. Lo que dejes vacío queda como "sin registrar".',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (log.sets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aún no hay series registradas.'),
            ),
          for (final set in log.sets)
            Semantics(
              container: true,
              child: ListTile(
                key: ValueKey('set-${set.id}'),
                contentPadding: EdgeInsets.zero,
                minTileHeight: 48,
                selected: editing == set.id,
                title: Text(
                  '${set.kind == SetKind.warmup ? 'Calentamiento' : 'Serie'} ${set.number}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(setSummary(set, unit)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Editar serie ${set.number}',
                      onPressed: vm.busy ? null : () => _edit(set),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Eliminar serie ${set.number}',
                      style: toneIconStyle(ActionTone.danger),
                      onPressed: vm.busy ? null : () => _remove(set),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(),
          if (log.skipped)
            _skippedBlock(log)
          else ...[
            SegmentedButton<SetKind>(
              segments: const [
                ButtonSegment(value: SetKind.work, label: Text('Trabajo')),
                ButtonSegment(
                  value: SetKind.warmup,
                  label: Text('Calentamiento'),
                ),
              ],
              selected: {kind},
              onSelectionChanged: vm.busy
                  ? null
                  : (value) => setState(() => kind = value.first),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _field(
                  'set-load',
                  load,
                  'Carga (${unit.label})',
                  hint: weightText(hint, unit),
                  decimal: true,
                ),
                _field('set-reps', reps, 'Reps'),
                _field('set-rir', rir, 'RIR (0–10)'),
              ],
            ),
            if (problem != null)
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    problem!,
                    style: const TextStyle(color: ForjaColors.paper),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('set-save'),
                    style: toneStyle(ActionTone.confirm),
                    onPressed: vm.busy ? null : _save,
                    child: ToneLabel(
                      Icons.save_outlined,
                      editing == null ? 'Guardar serie' : 'Guardar cambios',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (editing == null)
                  // Both buttons share the row, so large text wraps inside
                  // them instead of overflowing.
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('set-skip'),
                      style: toneStyle(ActionTone.caution),
                      onPressed: vm.busy ? null : _skipSet,
                      child: const ToneLabel(Icons.skip_next, 'Omitir serie'),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => setState(_clear),
                    child: const Text('Cancelar'),
                  ),
              ],
            ),
          ],
          if (!log.skipped) ...[
            const SizedBox(height: 12),
            _techniqueBlock(log),
          ],
          const SizedBox(height: 16),
          _restBlock(),
          if (widget.progression != null) ...[
            const SizedBox(height: 8),
            _progressionBlock(widget.progression!),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('sheet-complete'),
                style: log.completed ? null : toneStyle(ActionTone.confirm),
                onPressed: vm.busy || log.skipped
                    ? null
                    : () async {
                        if (!await _allowed()) return;
                        await vm.toggle(id);
                      },
                icon: Icon(
                  log.completed ? Icons.undo : Icons.check_circle_outline,
                ),
                label: Text(
                  log.completed
                      ? 'Marcar como pendiente'
                      : 'Marcar ejercicio completado',
                ),
              ),
              if (!log.skipped && !log.completed)
                TextButton(
                  key: const ValueKey('exercise-skip'),
                  style: toneStyle(ActionTone.caution),
                  onPressed: vm.busy ? null : _skipExercise,
                  child: const ToneLabel(Icons.skip_next, 'Omitir ejercicio'),
                ),
            ],
          ),
          if (vm.error != null)
            Semantics(liveRegion: true, child: Text(vm.error!)),
        ],
      );
    },
  );

  // Optional self-assessment: progression needs it said, never assumed.
  Widget _techniqueBlock(ExerciseLog log) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Técnica de este ejercicio (opcional)'),
      const SizedBox(height: 6),
      SegmentedButton<TechniqueRating>(
        key: const ValueKey('technique'),
        emptySelectionAllowed: true,
        segments: const [
          ButtonSegment(value: TechniqueRating.solid, label: Text('Sólida')),
          ButtonSegment(
            value: TechniqueRating.unstable,
            label: Text('Inestable'),
          ),
        ],
        selected: {?log.technique},
        onSelectionChanged: vm.busy
            ? null
            : (value) => vm.setTechnique(id, value.firstOrNull),
      ),
    ],
  );

  Widget _progressionBlock(ProgressionViewModel progression) =>
      ListenableBuilder(
        listenable: progression,
        builder: (context, _) {
          final s = progression.suggestion(id);
          return ExpansionTile(
            key: ValueKey('progression-${s.kind.name}'),
            tilePadding: EdgeInsets.zero,
            initiallyExpanded: s.actionable,
            title: Text(progressionTitles[s.kind]!),
            children: [
              ProgressionCard(vm: progression, suggestion: s, showName: false),
            ],
          );
        },
      );

  Widget _skippedBlock(ExerciseLog log) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Ejercicio omitido: ${log.skipReason ?? ''}'),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('exercise-unskip'),
        onPressed: vm.busy
            ? null
            : () async {
                if (!await _allowed()) return;
                await vm.unskip(id);
              },
        child: const Text('Volver a pendiente'),
      ),
    ],
  );

  Widget _field(
    String key,
    TextEditingController controller,
    String label, {
    String? hint,
    bool decimal = false,
  }) => SizedBox(
    width: 132,
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(decimal ? r'[0-9.,]' : r'[0-9]'),
        ),
      ],
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );

  // The optional rest countdown, recomputed from timestamps.
  Widget _restBlock() {
    final timer = vm.rest, seconds = vm.restSeconds(id);
    final Widget status;
    if (!timer.isActive) {
      status = Text(
        'Descanso sugerido: ${clockText(Duration(seconds: seconds))}',
      );
    } else if (timer.isDone) {
      status = const Text('Descanso terminado');
    } else {
      status = Text(
        'Descanso: ${clockText(timer.remaining)}${timer.isPaused ? ' (en pausa)' : ''}',
      );
    }
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Semantics(liveRegion: timer.isDone, child: status),
          ),
          if (!timer.isActive)
            TextButton(
              key: const ValueKey('rest-start'),
              onPressed: () {
                setState(() => timer.start(seconds));
                _tick();
              },
              child: const Text('Iniciar'),
            )
          else ...[
            if (!timer.isDone)
              TextButton(
                key: const ValueKey('rest-toggle'),
                onPressed: () {
                  setState(timer.isRunning ? timer.pause : timer.resume);
                  if (timer.isRunning) _tick();
                },
                child: Text(timer.isRunning ? 'Pausar' : 'Reanudar'),
              ),
            TextButton(
              key: const ValueKey('rest-cancel'),
              onPressed: () => setState(timer.cancel),
              child: Text(timer.isDone ? 'Cerrar' : 'Cancelar'),
            ),
          ],
        ],
      ),
    );
  }
}
