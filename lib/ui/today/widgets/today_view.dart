import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/models.dart';
import '../../../domain/models/labels.dart';
import '../../../data/services/tutorial_launcher.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../../exercises/widgets/exercise_details.dart';
import '../view_models/today_view_model.dart';
import 'exercise_card.dart';
import '../../progress/view_models/progression_view_model.dart';
import 'check_in_sheet.dart';
import 'reopen_dialog.dart';
import 'reschedule_sheet.dart';
import 'sets_sheet.dart';

class TodayView extends StatelessWidget {
  const TodayView({
    super.key,
    required this.vm,
    required this.progression,
    required this.launcher,
    required this.onProgress,
    required this.onCoach,
    required this.onCardio,
  });
  final TodayViewModel vm;
  final ProgressionViewModel progression;
  final TutorialLauncher launcher;
  final VoidCallback onProgress, onCoach, onCardio;
  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) => LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final header = _header(width);
        // A rest day is one card: a centred column on any screen.
        if (vm.routine == null) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              header,
              Padding(
                padding: centredPadding(
                  width,
                  maxWidth: Breakpoints.readable,
                  side: 16,
                  top: 10,
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_rest(context), ..._after(context)],
                ),
              ),
            ],
          );
        }
        final padding = centredPadding(width, side: 16, top: 10, bottom: 0);
        // Phones: one column, as always. From two columns of room the
        // session summary and check-in sit beside the exercise list.
        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            header,
            Padding(
              padding: padding,
              child: fitsTwoColumns(context, width)
                  ? TwoColumns(
                      primaryFlex: 2,
                      secondaryFlex: 3,
                      primary: [..._summary(context), ..._after(context)],
                      secondary: _session(context),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ..._summary(context),
                        ..._session(context),
                        ..._after(context),
                      ],
                    ),
            ),
          ],
        );
      },
    ),
  );

  // The paper band with the date and the week; its content stays centred on
  // wide screens while the band itself spans the page.
  Widget _header(double width) => Container(
    decoration: const BoxDecoration(
      color: ForjaColors.paper,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
    ),
    padding: centredPadding(width, side: 16, top: 0, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${vm.isToday ? 'Hoy' : weekdayNames[vm.selectedDate.weekday - 1]} · ${shortDate(vm.selectedDate)}',
                style: const TextStyle(
                  fontFamily: 'Barlow Condensed',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: ForjaColors.ink,
                ),
              ),
            ),
            if (!vm.isToday)
              TextButton(
                onPressed: vm.goToday,
                style: TextButton.styleFrom(foregroundColor: ForjaColors.ink),
                child: const Text('Hoy'),
              ),
            IconButton(
              tooltip: 'Semana anterior',
              onPressed: () => vm.selectDate(nextDay(vm.selectedDate, -7)),
              icon: const Icon(Icons.chevron_left, color: ForjaColors.ink),
            ),
            IconButton(
              tooltip: 'Semana siguiente',
              onPressed: () => vm.selectDate(nextDay(vm.selectedDate, 7)),
              icon: const Icon(Icons.chevron_right, color: ForjaColors.ink),
            ),
          ],
        ),
        _Calendar(vm),
      ],
    ),
  );

  // Routine, counts, warm-up and what the check-in changed.
  List<Widget> _summary(BuildContext context) => [
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vm.routine!.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${vm.entries.length} ejercicios · 45–60 min · ${vm.completed}/${vm.entries.length}${vm.skipped > 0 ? ' · ${vm.skipped} omitido${vm.skipped == 1 ? '' : 's'}' : ''}',
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Calentamiento',
          onPressed: () => showForjaSheet<void>(
            context,
            title: 'Calentamiento',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(vm.routine!.warmup),
                const SizedBox(height: 16),
                const Text(
                  'Empieza con series ligeras. Las indicaciones específicas aparecen en cada ejercicio.',
                ),
                if (vm.recommendation != null) ...[
                  const SizedBox(height: 16),
                  Text(vm.recommendation!),
                ],
              ],
            ),
          ),
          icon: const Icon(Icons.local_fire_department_outlined),
        ),
      ],
    ),
    if (vm.moveInto != null) _movedHere(context),
    if (vm.recommendation != null)
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          vm.recommendation!,
          style: const TextStyle(
            color: ForjaColors.paper,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    if (vm.adjustmentProposed)
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const ValueKey('adjustment-toggle'),
          onPressed: vm.busy
              ? null
              : () => vm.setAdjustment(!vm.adjustmentApplied),
          child: Text(
            vm.adjustmentApplied
                ? 'Quitar el ajuste de intensidad'
                : 'Aplicar el ajuste de intensidad',
          ),
        ),
      ),
    if (vm.injured)
      Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            key: const ValueKey('injury-feedback'),
            onPressed: () => showCheckIn(context, vm),
            child: const Text('Guardar una nota'),
          ),
          if (!vm.finished && vm.hasPending)
            OutlinedButton(
              key: const ValueKey('injury-finish'),
              onPressed: () =>
                  showReschedule(context, vm, SessionStatus.partial),
              child: const Text('Terminar la sesión'),
            ),
        ],
      ),
  ];

  // The exercise list and the button that closes the session.
  List<Widget> _session(BuildContext context) => [
    const SizedBox(height: 8),
    ReorderableListView.builder(
      key: ValueKey(dateKey(vm.selectedDate)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: vm.entries.length,
      onReorderItem: vm.reorder,
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, _) => Transform.scale(
          scale: MediaQuery.disableAnimationsOf(context)
              ? 1
              : 1 + .025 * animation.value,
          child: Material(color: Colors.transparent, child: child),
        ),
      ),
      itemBuilder: (context, index) {
        final log = vm.entries[index], exercise = vm.exercise(log.exerciseId);
        return ExerciseCard(
          key: ValueKey(log.exerciseId),
          exercise: exercise,
          log: log,
          prescription: vm.prescription(log.exerciseId),
          index: index,
          isNext: vm.nextExerciseId == log.exerciseId,
          unit: vm.unit,
          busy: vm.busy,
          canMoveUp: index > 0,
          canMoveDown: index < vm.entries.length - 1,
          onToggle: () => _toggle(context, log.exerciseId),
          onSets: () =>
              showSets(context, vm, log.exerciseId, progression: progression),
          onWeight: (weight) => vm.setWeight(log.exerciseId, weight),
          onMove: (delta) => vm.move(log.exerciseId, delta),
          onDetails: () => showExerciseDetails(context, exercise, launcher),
        );
      },
    ),
    Row(
      children: [
        Expanded(
          child: FilledButton(
            key: const ValueKey('finish-session'),
            onPressed: vm.busy || !vm.allResolved || vm.finished
                ? null
                : () => vm.finish(SessionStatus.completed),
            child: Text(
              vm.session?.status == SessionStatus.completed
                  ? 'Sesión completada'
                  : vm.finished
                  ? 'Sesión parcial guardada'
                  : 'Completar sesión',
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Más opciones de sesión',
          enabled: !vm.busy,
          icon: const Icon(Icons.more_horiz),
          onSelected: (choice) => switch (choice) {
            'reopen' => _reopen(context),
            'partial' => showReschedule(context, vm, SessionStatus.partial),
            _ => showReschedule(context, vm, SessionStatus.missed),
          },
          itemBuilder: (_) => [
            if (vm.finished)
              const PopupMenuItem(
                value: 'reopen',
                child: Text('Reabrir sesión'),
              )
            else ...[
              if (vm.hasPending)
                const PopupMenuItem(
                  value: 'partial',
                  child: Text('No terminé'),
                ),
              const PopupMenuItem(value: 'missed', child: Text('Falté')),
            ],
          ],
        ),
      ],
    ),
  ];

  // How the person feels, and the ways out to progress and the coach.
  List<Widget> _after(BuildContext context) => [
    QuickRow(
      icon: Icons.sentiment_satisfied_alt,
      title: vm.checkIn == null
          ? '¿Cómo te sientes?'
          : feelingLabels[vm.checkIn!.feeling]!,
      onTap: () => showCheckIn(context, vm),
    ),
    if (vm.finished)
      QuickRow(
        icon: Icons.sentiment_satisfied,
        title: vm.afterCheckIn == null
            ? '¿Cómo te sentiste al terminar?'
            : 'Al terminar: ${feelingLabels[vm.afterCheckIn!.feeling]!}',
        onTap: () => showCheckIn(context, vm, phase: CheckInPhase.after),
      ),
    Wrap(
      spacing: 4,
      children: [
        TextButton.icon(
          onPressed: onProgress,
          icon: const Icon(Icons.bar_chart, size: 20),
          label: const Text('Progreso'),
        ),
        TextButton.icon(
          onPressed: onCoach,
          icon: const Icon(Icons.tune, size: 20),
          label: Text(
            vm.reviewDue ? 'Minicoach · revisión disponible' : 'Minicoach',
          ),
        ),
      ],
    ),
  ];

  Widget _rest(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.nights_stay_outlined, size: 32),
        const SizedBox(height: 10),
        Text(
          'Día de descanso',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (vm.session?.status == SessionStatus.partial ||
            vm.session?.status == SessionStatus.missed)
          Text(
            'Sesión anterior: ${sessionLabels[vm.session!.status]}. Los pendientes se reprogramaron.',
          ),
        Text('Siguiente: ${vm.nextRoutine}', textAlign: TextAlign.center),
        if (vm.canUndo(vm.moveFrom)) ...[
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('undo-move-from'),
            onPressed: vm.busy ? null : () => vm.undoMove(vm.moveFrom!.id),
            child: const Text('Deshacer reprogramación'),
          ),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onCardio,
          icon: const Icon(Icons.timer_outlined),
          label: const Text('Abrir cardio'),
        ),
      ],
    ),
  );
  Future<void> _toggle(BuildContext context, String id) async {
    if (vm.finished && !await confirmReopen(context)) return;
    await vm.toggle(id);
  }

  Future<void> _reopen(BuildContext context) async {
    if (await confirmReopen(context)) await vm.reopen();
  }

  // Shown on the day a workout was moved to, while it can still be undone.
  Widget _movedHere(BuildContext context) {
    final move = vm.moveInto!;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Reprogramada desde el ${friendlyDate(parseDateKey(move.sourceDate))}',
            ),
          ),
          if (vm.canUndo(move))
            TextButton(
              key: const ValueKey('undo-move-into'),
              onPressed: vm.busy ? null : () => vm.undoMove(move.id),
              child: const Text('Deshacer'),
            ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar(this.vm);
  final TodayViewModel vm;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final itemWidth =
          (constraints.maxWidth / 7).clamp(48.0, 90.0) *
          (scale > 1.4 ? 1.35 : 1);
      final reduced = MediaQuery.disableAnimationsOf(context);
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        // Days keep a comfortable width; on wide screens the week is centred
        // instead of stretched.
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: vm.week.map((date) {
              final selected = dateKey(date) == dateKey(vm.selectedDate),
                  workout = vm.routineOn(date) != null;
              final done = vm.statusOn(date) == SessionStatus.completed;
              return Semantics(
                container: true,
                onTap: () => vm.selectDate(date),
                button: true,
                selected: selected,
                label:
                    '${friendlyDate(date)}, ${done
                        ? 'completado'
                        : workout
                        ? 'entrenamiento'
                        : 'descanso'}',
                excludeSemantics: true,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: reduced ? 0 : 260),
                  curve: Curves.easeInOut,
                  width: itemWidth,
                  decoration: BoxDecoration(
                    color: selected ? ForjaColors.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => vm.selectDate(date),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            shortWeekdays[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 14,
                              color: selected
                                  ? ForjaColors.paper
                                  : ForjaColors.ink,
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? ForjaColors.paper
                                  : ForjaColors.ink,
                            ),
                          ),
                          Icon(
                            done
                                ? Icons.check
                                : workout
                                ? Icons.circle
                                : Icons.remove,
                            size: 10,
                            color: selected
                                ? ForjaColors.paper
                                : ForjaColors.ink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    },
  );
}
