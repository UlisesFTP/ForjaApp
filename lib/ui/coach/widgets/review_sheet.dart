import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/review_service.dart';
import '../../core/widgets.dart';
import '../view_models/review_view_model.dart';
import 'profile_inputs.dart';
import '../../core/tone_buttons.dart';

const _difficultyLabels = {
  ReviewDifficulty.easy: 'Fácil',
  ReviewDifficulty.right: 'Adecuada',
  ReviewDifficulty.hard: 'Difícil',
};

Future<void> showReview(BuildContext context, ReviewViewModel vm) {
  vm.begin();
  return showForjaSheet<void>(
    context,
    title: 'Revisión mensual',
    child: ReviewPanel(vm: vm),
  );
}

/// Two steps: answer, then read the proposal and decide. Both decisions are
/// explicit; closing the sheet saves nothing.
class ReviewPanel extends StatelessWidget {
  const ReviewPanel({super.key, required this.vm});
  final ReviewViewModel vm;

  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) => vm.proposal == null
        ? _questions(context)
        : _proposal(context, vm.proposal!),
  );

  Widget _questions(BuildContext context) {
    final m = vm.month, a = vm.answers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'El último mes',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                m.due == 0
                    ? 'Sin sesiones vencidas todavía.'
                    : 'Cumplimiento: ${m.done}/${m.due}.',
              ),
              if (m.fatigueDays > 0 || m.injuryDays > 0)
                Text(
                  'Días con cansancio o DOMS: ${m.fatigueDays} · con lesión: ${m.injuryDays}.',
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Responde con calma; esto no es un diagnóstico. Las reglas son locales y no usan Internet.',
        ),
        const SizedBox(height: 16),
        const Text('Energía habitual'),
        const SizedBox(height: 6),
        SegmentedButton<Energy>(
          key: const ValueKey('review-energy'),
          segments: [
            for (final e in Energy.values)
              ButtonSegment(value: e, label: Text(energyLabels[e]!)),
          ],
          selected: {a.energy},
          onSelectionChanged: (v) => vm.answer(_with(a, energy: v.first)),
        ),
        SwitchListTile(
          key: const ValueKey('review-pain'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Dolor o molestias que limitan'),
          value: a.pain,
          onChanged: (v) => vm.answer(_with(a, pain: v)),
        ),
        const Text('¿Cómo te resultó el plan?'),
        const SizedBox(height: 6),
        SegmentedButton<ReviewDifficulty>(
          key: const ValueKey('review-difficulty'),
          segments: [
            for (final d in ReviewDifficulty.values)
              ButtonSegment(value: d, label: Text(_difficultyLabels[d]!)),
          ],
          selected: {a.difficulty},
          onSelectionChanged: (v) => vm.answer(_with(a, difficulty: v.first)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TrainingGoal>(
          key: const ValueKey('review-goal'),
          initialValue: a.goal,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Objetivo'),
          items: [
            for (final g in TrainingGoal.values)
              DropdownMenuItem(value: g, child: Text(goalLabels[g]!)),
          ],
          onChanged: (v) {
            if (v != null) vm.answer(_with(a, goal: v));
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Días de entrenamiento',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TrainingDaysPicker(
          selected: a.trainingDays,
          enabled: !vm.busy,
          onChanged: (next) => vm.answer(_with(a, days: next)),
        ),
        const SizedBox(height: 16),
        Text('Equipo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        EquipmentPicker(
          selected: a.equipment,
          enabled: !vm.busy,
          onChanged: (next) => vm.answer(_with(a, equipment: next)),
        ),
        const SizedBox(height: 16),
        Text(
          'Tiempo por sesión',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SessionMinutesPicker(
          minutes: a.sessionMinutes,
          enabled: !vm.busy,
          onChanged: (next) => vm.answer(_with(a, minutes: next)),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const ValueKey('review-propose'),
          onPressed: vm.busy || a.trainingDays.length != 3 ? null : vm.propose,
          child: const Text('Ver propuesta'),
        ),
        const SizedBox(height: 8),
        TextButton(
          key: const ValueKey('review-postpone'),
          style: toneStyle(ActionTone.caution),
          onPressed: vm.busy
              ? null
              : () async {
                  if (await vm.postpone() && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: ToneLabel(
            Icons.snooze,
            'Posponer ${ReviewService.snoozeDays} días',
          ),
        ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    );
  }

  ReviewAnswers _with(
    ReviewAnswers a, {
    Energy? energy,
    bool? pain,
    ReviewDifficulty? difficulty,
    TrainingGoal? goal,
    Set<Equipment>? equipment,
    List<int>? days,
    int? minutes,
  }) => ReviewAnswers(
    energy: energy ?? a.energy,
    pain: pain ?? a.pain,
    difficulty: difficulty ?? a.difficulty,
    goal: goal ?? a.goal,
    equipment: equipment ?? a.equipment,
    trainingDays: days ?? a.trainingDays,
    sessionMinutes: minutes ?? a.sessionMinutes,
  );

  Widget _proposal(BuildContext context, ReviewProposal p) {
    final failure = vm.failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Propuesta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 8),
        for (final note in p.notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $note'),
          ),
        const SizedBox(height: 8),
        if (vm.changesPlan && vm.comparison.isNotEmpty) ...[
          Text(
            'Plan actual → propuesto',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          for (final line in vm.comparison) Text(line),
          const SizedBox(height: 6),
          const Text(
            'Se guarda como borrador en Plan. Solo empezará a aplicarse desde la fecha que elijas allí; tus sesiones pasadas y las ya empezadas no cambian.',
            style: TextStyle(color: ForjaColors.muted),
          ),
        ] else if (vm.keepsManualDraft)
          const Text(
            'Ya tienes un borrador editado a mano; no se reemplaza. Tus respuestas se guardan en el perfil.',
          )
        else
          const Text('El plan no cambia con estas respuestas.'),
        if (failure != null) ...[
          const SizedBox(height: 8),
          Text(failure, style: const TextStyle(color: ForjaColors.paper)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey('review-accept'),
          style: toneStyle(ActionTone.confirm),
          onPressed: vm.busy || (vm.changesPlan && failure != null)
              ? null
              : () async {
                  if (await vm.accept() && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: ToneLabel(
            Icons.check_circle_outline,
            vm.busy ? 'Guardando…' : 'Aceptar propuesta',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const ValueKey('review-reject'),
          style: toneStyle(ActionTone.caution),
          onPressed: vm.busy
              ? null
              : () async {
                  if (await vm.reject() && context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: const ToneLabel(Icons.close, 'Rechazar: no cambiar nada'),
        ),
        TextButton(
          key: const ValueKey('review-back'),
          onPressed: vm.busy ? null : () => vm.answer(vm.answers),
          child: const Text('Volver a mis respuestas'),
        ),
        if (vm.error != null)
          Semantics(liveRegion: true, child: Text(vm.error!)),
      ],
    );
  }
}

/// The review history of the profile, newest first.
class ReviewHistory extends StatelessWidget {
  const ReviewHistory({super.key, required this.vm});
  final ReviewViewModel vm;
  @override
  Widget build(BuildContext context) {
    if (vm.history.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('Revisiones (${vm.history.length})'),
      children: [
        for (final r in vm.history.reversed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${shortDate(parseDateKey(r.reviewedOn))} · ${r.outcome == ReviewOutcome.accepted ? 'Aceptada' : 'Rechazada'}',
            ),
            subtitle: Text(
              'Cumplimiento ${r.sessionsDone}/${r.sessionsDue} · reglas ${r.rulesVersion}',
            ),
          ),
      ],
    );
  }
}
