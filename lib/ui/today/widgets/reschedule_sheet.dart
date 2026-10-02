import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/reschedule_planner.dart';
import '../../core/widgets.dart';
import '../view_models/today_view_model.dart';

/// Shows what "No terminé" / "Falté" would move and where, before anything is
/// saved. The person can accept the suggestion, pick another date, or save
/// the result without moving the pending work.
Future<void> showReschedule(
  BuildContext context,
  TodayViewModel vm,
  SessionStatus status,
) => showForjaSheet<void>(
  context,
  title: status == SessionStatus.missed
      ? 'Registrar ausencia'
      : 'Guardar sesión incompleta',
  child: ReschedulePanel(vm: vm, status: status),
);

class ReschedulePanel extends StatefulWidget {
  const ReschedulePanel({super.key, required this.vm, required this.status});
  final TodayViewModel vm;
  final SessionStatus status;
  @override
  State<ReschedulePanel> createState() => _ReschedulePanelState();
}

class _ReschedulePanelState extends State<ReschedulePanel> {
  // A date picked by hand; null means the suggested one.
  DateTime? chosen;

  TodayViewModel get vm => widget.vm;

  Future<void> _pick(ReschedulePreview preview) async {
    final first = nextDay(preview.source, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: chosen ?? preview.suggested?.date ?? first,
      firstDate: first,
      lastDate: nextDay(preview.source, ReschedulePlanner.manualWindow),
      helpText: 'Elige el día de la sesión',
      // Days with a workout are not offered: nothing is displaced.
      selectableDayPredicate: (day) => vm.moveProblem(day) == null,
    );
    if (picked != null && mounted) setState(() => chosen = dateOnly(picked));
  }

  Future<void> _apply({DateTime? to, bool reschedule = true}) async {
    final saved = await vm.finish(
      widget.status,
      moveTo: to,
      reschedule: reschedule,
    );
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: vm,
    builder: (context, _) {
      final preview = vm.preview(widget.status);
      if (preview == null) {
        return const Text('Esta sesión ya no se puede reprogramar.');
      }
      final target = chosen ?? preview.suggested?.date;
      final warnings = target == null
          ? const <String>[]
          : (chosen != null
                ? vm.moveWarnings(widget.status, target)
                : preview.suggested!.warnings);
      final names = [for (final id in preview.pending) vm.exercise(id).name];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.status == SessionStatus.missed
                ? 'Se moverá la rutina completa:'
                : 'Se moverán solo los pendientes (lo hecho y lo omitido se queda en esta fecha):',
          ),
          const SizedBox(height: 8),
          for (final name in names)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text('• $name'),
            ),
          const SizedBox(height: 12),
          if (target == null)
            const SurfaceCard(
              child: Text(
                'No hay un día libre en las próximas dos semanas. Puedes elegir una fecha a mano o guardar la sesión sin mover los pendientes; quedarán señalados.',
              ),
            )
          else
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chosen == null ? 'Fecha propuesta' : 'Fecha elegida',
                    style: const TextStyle(color: ForjaColors.muted),
                  ),
                  Text(
                    friendlyDate(target),
                    key: const ValueKey('reschedule-target'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  for (final warning in warnings)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(warning)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const Text(
            'No se desplaza ninguna otra sesión. Podrás deshacerlo mientras el nuevo día no haya empezado.',
            style: TextStyle(color: ForjaColors.muted),
          ),
          const SizedBox(height: 16),
          if (target != null)
            FilledButton(
              key: const ValueKey('reschedule-apply'),
              onPressed: vm.busy ? null : () => _apply(to: chosen),
              child: Text(vm.busy ? 'Guardando…' : 'Reprogramar'),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey('reschedule-pick'),
            onPressed: vm.busy ? null : () => _pick(preview),
            child: const Text('Elegir otra fecha'),
          ),
          TextButton(
            key: const ValueKey('reschedule-keep'),
            onPressed: vm.busy ? null : () => _apply(reschedule: false),
            child: const Text('Guardar sin reprogramar'),
          ),
          if (vm.error != null)
            Semantics(liveRegion: true, child: Text(vm.error!)),
        ],
      );
    },
  );
}
