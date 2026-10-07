import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/plan_view_model.dart';
import '../../core/tone_buttons.dart';

class PlanView extends StatelessWidget {
  const PlanView({
    super.key,
    required this.vm,
    required this.onDate,
    required this.onEdit,
    this.onReview,
  });
  final PlanViewModel vm;
  final ValueChanged<DateTime> onDate;
  final VoidCallback onEdit;

  /// Opens the minicoach's review of the plan (F16).
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) => ResponsivePage(
      header: const PageHeading(
        'TU PLAN',
        subtitle: 'Tus días de entrenamiento y tu descanso.',
      ),
      // The plan in use and its draft beside the week.
      primary: [
        _ActivePlan(vm: vm, onEdit: onEdit, onReview: onReview),
        if (vm.draft != null) _DraftCard(vm: vm, onEdit: onEdit),
      ],
      secondary: [
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              tooltip: 'Semana anterior',
              onPressed: () => vm.changeWeek(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${shortDate(vm.week.first)} — ${shortDate(vm.week.last)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Semana siguiente',
              onPressed: () => vm.changeWeek(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...vm.week.map((date) {
          final routine = vm.routineOn(date), status = vm.statusOn(date);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              padding: EdgeInsets.zero,
              light: routine != null,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  friendlyDate(date),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: routine != null ? ForjaColors.ink : ForjaColors.text,
                  ),
                ),
                subtitle: Text(
                  routine == null
                      ? 'Descanso${status == null ? '' : ' · ${sessionLabels[status]}'}'
                      : '${routine.name} · ${status == null ? 'Programada' : sessionLabels[status]}',
                  style: TextStyle(
                    color: routine != null
                        ? ForjaColors.ink
                        : ForjaColors.muted,
                  ),
                ),
                trailing: Icon(
                  routine != null
                      ? Icons.arrow_forward
                      : Icons.nights_stay_outlined,
                  color: routine != null ? ForjaColors.ink : ForjaColors.muted,
                ),
                onTap: () => onDate(date),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        const Text(
          'Si faltas o dejas ejercicios pendientes, registra el resultado en Hoy para moverlos al próximo descanso disponible.',
        ),
        if (vm.versions.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Versiones aceptadas (${vm.versions.length})'),
            children: [
              for (final p in vm.versions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name),
                  subtitle: Text(
                    'Desde ${friendlyDate(parseDateKey(p.effectiveFrom!))} · ${p.routines.map((r) => r.name).join(', ')}',
                  ),
                ),
            ],
          ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    ),
  );
}

class _ActivePlan extends StatelessWidget {
  const _ActivePlan({required this.vm, required this.onEdit, this.onReview});
  final PlanViewModel vm;
  final VoidCallback onEdit;
  final VoidCallback? onReview;
  @override
  Widget build(BuildContext context) {
    final plan = vm.activePlan;
    final example = plan.source == PlanSource.example;
    final none = plan.source == PlanSource.none;
    final upcoming = vm.upcoming;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            none
                ? upcoming?.name ?? 'Aún no tienes un plan'
                : example
                ? 'Plan de ejemplo'
                : plan.name,
            key: const ValueKey('active-plan-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            none && upcoming != null
                ? 'Empieza el ${friendlyDate(parseDateKey(upcoming.effectiveFrom!))}. Hasta entonces no hay entrenamientos programados.'
                : none
                ? 'Crea tu rutina con tus días y tus ejercicios, o genera una desde tu perfil. FORJA no trae una rutina de ejemplo.'
                : example
                ? 'Es una plantilla fija de tres días, no un plan hecho para ti. Edítalo o genera uno desde tu perfil; los pesos son ejemplos, no cargas prescritas.'
                : 'En uso desde ${friendlyDate(parseDateKey(plan.effectiveFrom!))}.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('plan-edit'),
                onPressed: vm.busy ? null : onEdit,
                icon: Icon(
                  none && upcoming == null ? Icons.add : Icons.edit_outlined,
                ),
                label: Text(
                  none && upcoming == null ? 'Crear mi plan' : 'Editar plan',
                ),
              ),
              OutlinedButton.icon(
                onPressed: vm.busy ? null : vm.generateFromProfile,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Generar desde mi perfil'),
              ),
              if (onReview != null)
                OutlinedButton.icon(
                  key: const ValueKey('plan-review'),
                  onPressed: onReview,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Revisión del plan'),
                ),
            ],
          ),
          if (vm.proposal != null && !vm.proposal!.ok)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(vm.proposal!.failure!),
              ),
            ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.vm, required this.onEdit});
  final PlanViewModel vm;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    final draft = vm.draft!;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SurfaceCard(
        light: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Borrador pendiente',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: ForjaColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              '${draft.name} · ${draft.routines.map((r) => r.name).join(', ')}. No se usa hasta que lo aceptes.',
            ),
            if (vm.proposal?.draft?.id == draft.id)
              for (final note in vm.proposal!.notes)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(note),
                ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: vm.busy ? null : onEdit,
                  child: const Text('Revisar borrador'),
                ),
                TextButton(
                  onPressed: vm.busy ? null : vm.discardDraft,
                  style: toneStyle(ActionTone.danger),
                  child: const ToneLabel(Icons.delete_outline, 'Descartar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
