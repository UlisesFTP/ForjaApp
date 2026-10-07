import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/cardio_math.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/cardio_view_model.dart';
import '../../core/tone_buttons.dart';

class CardioView extends StatelessWidget {
  const CardioView({super.key, required this.vm});
  final CardioViewModel vm;
  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) {
      final s = vm.session;
      final kcal = vm.calories;
      return ResponsivePage(
        header: const PageHeading('CARDIO', subtitle: 'Un paso más.'),
        // The stopwatch and its controls beside the history.
        primary: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: CardioActivity.values
                .map(
                  (activity) => ChoiceChip(
                    label: Text(cardioLabels[activity]!),
                    selected: (s?.activity ?? vm.activity) == activity,
                    onSelected: vm.active ? null : (_) => vm.select(activity),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            key: const ValueKey('cardio-intensity'),
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final i in CardioIntensity.values)
                ChoiceChip(
                  label: Text(cardioIntensityLabels[i]!),
                  selected: (s?.current?.intensity ?? vm.intensity) == i,
                  onSelected: vm.busy ? null : (_) => vm.setIntensity(i),
                ),
            ],
          ),
          if (!vm.active) ...[
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('cardio-target'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Objetivo en minutos (opcional)',
              ),
              onChanged: (text) => vm.setTarget(
                text.isEmpty ? null : (int.tryParse(text)?.clamp(1, 600)),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SurfaceCard(
            light: true,
            child: Column(
              children: [
                Text(
                  cardioLabels[s?.activity ?? vm.activity]!.toUpperCase(),
                  style: const TextStyle(
                    color: ForjaColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Tiempo: ${vm.display}',
                  excludeSemantics: true,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      vm.display,
                      key: const ValueKey('cardio-time'),
                      style: const TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontWeight: FontWeight.w700,
                        fontSize: 64,
                        color: ForjaColors.ink,
                      ),
                    ),
                  ),
                ),
                if (vm.remaining != null)
                  Text(
                    vm.remaining == Duration.zero
                        ? 'Objetivo alcanzado'
                        : 'Faltan ${CardioMath.clock(vm.remaining!)} para el objetivo',
                    style: const TextStyle(color: ForjaColors.ink),
                  ),
                const SizedBox(height: 10),
                Text(
                  !vm.active
                      ? 'Sin sesión en curso'
                      : kcal == null
                      ? 'Sin estimación de calorías'
                      : '≈ ${kcal.round()} kcal',
                  key: const ValueKey('cardio-kcal'),
                  style: const TextStyle(
                    fontSize: 24,
                    color: ForjaColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  vm.active && kcal == null
                      ? 'Falta tu peso corporal en el perfil cuando empezó algún tramo. Se registra solo la duración.'
                      : vm.weightKg == null
                      ? 'Añade tu peso corporal en tu perfil para estimar calorías. Se registra solo la duración.'
                      : 'Peso usado al empezar cada tramo; editar tu perfil no cambia sesiones terminadas.',
                  style: const TextStyle(color: ForjaColors.ink),
                ),
              ],
            ),
          ),
          if (vm.coherence != CardioCoherence.ok) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: SurfaceCard(
                child: Text(
                  vm.coherence == CardioCoherence.clockBehind
                      ? 'El reloj del teléfono retrocedió mientras la sesión estaba abierta. Al finalizar tendrás que indicar la duración real.'
                      : 'Esta sesión lleva más de 12 horas abierta. Al finalizar confirma la duración real.',
                  key: const ValueKey('cardio-incoherent'),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (!vm.active)
            FilledButton.icon(
              key: const ValueKey('cardio-start'),
              style: toneStyle(ActionTone.confirm),
              onPressed: vm.busy ? null : vm.start,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Iniciar'),
            )
          else ...[
            FilledButton.icon(
              key: const ValueKey('cardio-toggle'),
              onPressed: vm.busy ? null : (vm.running ? vm.pause : vm.resume),
              icon: Icon(vm.running ? Icons.pause : Icons.play_arrow),
              label: Text(vm.running ? 'Pausar' : 'Continuar'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              key: const ValueKey('cardio-finish'),
              onPressed: vm.busy ? null : () => _finish(context),
              child: const Text('Finalizar'),
            ),
            TextButton(
              key: const ValueKey('cardio-discard'),
              style: toneStyle(ActionTone.danger),
              onPressed: vm.busy ? null : () => _discard(context),
              child: const ToneLabel(Icons.delete_outline, 'Descartar sesión'),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'El tiempo se calcula con marcas de hora, no contando segundos: sigue correcto si cambias de pestaña, bloqueas la pantalla o cierras la app, y la sesión se recupera al volver. La app no se ejecuta en segundo plano. Las calorías son aproximadas (tabla MET $cardioMetTableVersion, sin revisión de fuente todavía).',
          ),
        ],
        secondary: [
          const SizedBox(height: 24),
          Text('Historial', style: Theme.of(context).textTheme.titleLarge),
          if (vm.history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Tus sesiones de cardio terminadas aparecerán aquí.'),
            ),
          for (final h in vm.history) _historyTile(h),
        ],
      );
    },
  );

  Widget _historyTile(CardioSession h) {
    final kcal = vm.caloriesOf(h);
    final duration = h.duration(h.finishedAt ?? h.startedAt);
    return ExpansionTile(
      key: ValueKey('cardio-${h.id}'),
      tilePadding: EdgeInsets.zero,
      title: Text(
        '${cardioLabels[h.activity]} · ${CardioMath.clock(duration)}',
      ),
      subtitle: Text(
        '${friendlyDate(h.startedAt.toLocal())} · ${kcal == null ? 'kcal no disponibles' : '≈ ${kcal.round()} kcal'}${h.durationCorrected ? ' · duración corregida' : ''}',
      ),
      children: [
        for (final seg in h.segments)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text(
              '${cardioIntensityLabels[seg.intensity]} · ${CardioMath.clock(seg.duration(h.finishedAt ?? h.startedAt))}',
            ),
            subtitle: Text(
              seg.weightKg == null
                  ? 'Sin peso registrado'
                  : 'Peso ${weightLabel(seg.weightKg!)} kg',
            ),
          ),
        if (h.feedback != null)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text('Al terminar: ${feelingLabels[h.feedback]}'),
          ),
        if (h.note.isNotEmpty)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text(h.note),
          ),
      ],
    );
  }

  Future<void> _finish(BuildContext context) => showForjaSheet<void>(
    context,
    title: 'Finalizar cardio',
    child: _FinishForm(vm: vm),
  );

  Future<void> _discard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Descartar la sesión?'),
        content: const Text(
          'Se perderá el tiempo de esta sesión y no se guardará en el historial.',
        ),
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
    if (confirmed == true) await vm.discard();
  }
}

class _FinishForm extends StatefulWidget {
  const _FinishForm({required this.vm});
  final CardioViewModel vm;
  @override
  State<_FinishForm> createState() => _FinishFormState();
}

class _FinishFormState extends State<_FinishForm> {
  final minutes = TextEditingController();
  final note = TextEditingController();
  Feeling? feeling;
  String? problem;

  @override
  void dispose() {
    minutes.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    Duration? corrected;
    if (minutes.text.trim().isNotEmpty) {
      final m = int.tryParse(minutes.text.trim());
      if (m == null || m < 0 || m > 1440) {
        setState(() => problem = 'Minutos: 0–1440');
        return;
      }
      corrected = Duration(minutes: m);
    } else if (widget.vm.coherence != CardioCoherence.ok) {
      setState(() => problem = 'Indica la duración real en minutos.');
      return;
    }
    setState(() => problem = null);
    if (await widget.vm.finish(
          correctedDuration: corrected,
          feedback: feeling,
          note: note.text.trim(),
        ) &&
        mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final needs = vm.coherence != CardioCoherence.ok;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tiempo registrado: ${vm.display}'),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('cardio-corrected'),
          controller: minutes,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: needs
                ? 'Duración real (obligatoria)'
                : 'Corregir duración (opcional)',
            suffixText: 'min',
            errorText: problem,
            helperText: needs
                ? 'El reloj del teléfono no es coherente con la sesión.'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        const Text('¿Cómo te sentiste? (opcional)'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final f in Feeling.values)
              ChoiceChip(
                label: Text(feelingLabels[f]!),
                selected: feeling == f,
                onSelected: (selected) =>
                    setState(() => feeling = selected ? f : null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: note,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Nota (opcional)'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('cardio-save'),
          style: toneStyle(ActionTone.confirm),
          onPressed: vm.busy ? null : _save,
          child: ToneLabel(
            Icons.save_outlined,
            vm.busy ? 'Guardando…' : 'Guardar sesión',
          ),
        ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    );
  }
}
