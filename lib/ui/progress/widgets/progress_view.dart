import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../core/weight_units.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/progress_stats.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/progress_view_model.dart';
import '../view_models/progression_view_model.dart';
import 'progression_card.dart';

const _rangeLabels = {
  StatsRange.week: 'Semana',
  StatsRange.month: 'Mes',
  StatsRange.all: 'Todo',
};

class ProgressView extends StatelessWidget {
  const ProgressView({super.key, required this.vm, required this.progression});
  final ProgressViewModel vm;
  final ProgressionViewModel progression;
  @override
  Widget build(BuildContext context) => VmObserver(
    viewModel: vm,
    builder: (context) {
      final compliance = vm.compliance, volume = vm.volume;
      final unit = vm.unit;
      return ResponsivePage(
        header: const PageHeading(
          'TU PROGRESO',
          subtitle: 'Cada sesión cuenta.',
        ),
        // Summary numbers beside the trends, suggestions and history.
        primary: [
          SegmentedButton<StatsRange>(
            segments: [
              for (final r in StatsRange.values)
                ButtonSegment(value: r, label: Text(_rangeLabels[r]!)),
            ],
            selected: {vm.range},
            onSelectionChanged: (value) => vm.setRange(value.first),
          ),
          const SizedBox(height: 16),
          _complianceCard(context, compliance),
          const SizedBox(height: 16),
          _volumeCard(context, volume, unit),
          const SizedBox(height: 20),
          Text('Constancia', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vm.week.map((date) {
              final done = vm.statusOn(date) == SessionStatus.completed;
              return Semantics(
                label:
                    '${friendlyDate(date)}: ${done ? 'completado' : 'sin sesión completada'}',
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: done ? ForjaColors.paper : ForjaColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        shortWeekdays[date.weekday - 1],
                        style: TextStyle(
                          color: done ? ForjaColors.ink : ForjaColors.text,
                        ),
                      ),
                      Icon(
                        done ? Icons.check : Icons.remove,
                        color: done ? ForjaColors.ink : ForjaColors.muted,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        secondary: [
          const SizedBox(height: 20),
          _trends(context, unit),
          const SizedBox(height: 20),
          Text(
            'Sugerencias de progresión',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: progression,
            builder: (context, _) {
              final all = progression.suggestions;
              if (all.isEmpty) {
                return const Text(
                  'Cuando completes ejercicios con series registradas, aquí verás si procede subir la carga y por qué.',
                );
              }
              return Column(
                children: [
                  for (final s in all)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ProgressionCard(vm: progression, suggestion: s),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Historial', style: Theme.of(context).textTheme.titleLarge),
          if (vm.inRange.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No hay sesiones en este rango.'),
            ),
          ...vm.inRange.map((session) => _session(session, unit)),
        ],
      );
    },
  );

  Widget _complianceCard(BuildContext context, Compliance c) {
    final pct = c.ratio == null ? null : (c.ratio! * 100).round();
    return SurfaceCard(
      light: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CUMPLIMIENTO',
            style: TextStyle(
              color: ForjaColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          Semantics(
            label: c.due == 0
                ? 'Sin sesiones vencidas en este rango'
                : '${c.done} de ${c.due} sesiones completadas, $pct por ciento',
            excludeSemantics: true,
            child: Text(
              c.due == 0
                  ? 'Sin datos'
                  : '${c.fraction}${pct == null ? '' : ' · $pct %'}',
              key: const ValueKey('compliance-value'),
              style: const TextStyle(
                fontFamily: 'Barlow Condensed',
                fontWeight: FontWeight.w700,
                fontSize: 48,
                color: ForjaColors.ink,
              ),
            ),
          ),
          Text(
            'Completas ${c.done} · parciales ${c.partial} · ausencias ${c.missed} · sin registro ${c.unrecorded}${c.moved > 0 ? ' · movidas ${c.moved}' : ''}',
            style: const TextStyle(color: ForjaColors.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            Compliance.policy,
            style: TextStyle(color: ForjaColors.ink, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _volumeCard(
    BuildContext context,
    VolumeStats v,
    WeightUnit unit,
  ) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Volumen externo', style: Theme.of(context).textTheme.titleLarge),
        Text(
          v.hasData
              ? '${weightText(v.kgReps, unit)} ${unit.label}·reps'
              : 'Sin datos suficientes',
          key: const ValueKey('volume-value'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          v.setsTotal == 0
              ? 'Aún no hay series de trabajo registradas en este rango.'
              : '${v.setsCounted} de ${v.setsTotal} series de trabajo tienen carga y repeticiones (${(v.coverage! * 100).round()} %).',
        ),
        const SizedBox(height: 6),
        const Text(
          'Carga × repeticiones de las series de trabajo registradas con peso externo. No incluye calentamiento, peso corporal, tiempo, datos que faltan ni sesiones importadas de la versión 0.1.',
          style: TextStyle(color: ForjaColors.muted, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _trends(BuildContext context, WeightUnit unit) {
    final trends = vm.trends;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evolución por ejercicio',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (trends.isNotEmpty)
              TextButton(
                key: const ValueKey('trend-toggle'),
                onPressed: vm.toggleTable,
                child: Text(vm.asTable ? 'Ver gráfica' : 'Ver como tabla'),
              ),
          ],
        ),
        if (trends.isEmpty)
          const Text(
            'Aún no hay series con carga y repeticiones en este rango.',
          ),
        for (final t in trends)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.exerciseName(t.exerciseId),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (t.best != null)
                    Text(
                      'Mejor marca observada: ${weightText(t.best!.weightKg, unit)} ${unit.label} × ${t.best!.reps} (${shortDate(parseDateKey(t.best!.dateKey))})',
                    ),
                  const SizedBox(height: 8),
                  vm.asTable ? _table(t, unit) : _bars(t, unit),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Monochrome bars of the heaviest set per session, each labelled.
  Widget _bars(ExerciseTrend t, WeightUnit unit) {
    final points = t.points.length > 12
        ? t.points.sublist(t.points.length - 12)
        : t.points;
    final top = points
        .map((p) => p.topWeightKg)
        .reduce((a, b) => a > b ? a : b);
    return Semantics(
      container: true,
      label:
          'Gráfica de la carga más alta por sesión de ${vm.exerciseName(t.exerciseId)}: ${points.map((p) => '${shortDate(parseDateKey(p.dateKey))} ${weightText(p.topWeightKg, unit)} ${unit.label}').join(', ')}',
      child: ExcludeSemantics(
        // Each bar takes its share of the width, but never more than a bar
        // should: with few sessions on a wide card it stays a bar.
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final p in points)
                SizedBox(
                  width: math.min(52.0, constraints.maxWidth / points.length),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weightText(p.topWeightKg, unit),
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        Container(
                          height: top <= 0 ? 2 : 4 + 56 * p.topWeightKg / top,
                          decoration: BoxDecoration(
                            color: ForjaColors.paper,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Text(
                          '${parseDateKey(p.dateKey).day}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ForjaColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _table(ExerciseTrend t, WeightUnit unit) => Table(
    columnWidths: const {
      0: FlexColumnWidth(1.4),
      1: FlexColumnWidth(1),
      2: FlexColumnWidth(1),
      3: FlexColumnWidth(1.3),
    },
    children: [
      TableRow(
        children: [
          for (final h in ['Fecha', 'Carga máx.', 'Reps', 'Carga×reps'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Semantics(
                header: true,
                child: Text(
                  h,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      for (final p in t.points)
        TableRow(
          children: [
            for (final cell in [
              shortDate(parseDateKey(p.dateKey)),
              '${weightText(p.topWeightKg, unit)} ${unit.label}',
              '${p.totalReps}',
              weightText(p.kgReps, unit),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(cell, style: const TextStyle(fontSize: 13)),
              ),
          ],
        ),
    ],
  );

  Widget _session(WorkoutSession session, WeightUnit unit) {
    final sets = session.exercises.fold<int>(
      0,
      (n, e) => n + e.workSets.length,
    );
    return ExpansionTile(
      key: ValueKey('history-${session.dateKey}'),
      tilePadding: EdgeInsets.zero,
      leading: Icon(
        session.status == SessionStatus.completed
            ? Icons.check_circle
            : Icons.history,
      ),
      title: Text(vm.routineName(session.routineId)),
      subtitle: Text(
        '${friendlyDate(parseDateKey(session.dateKey))} · ${sessionLabels[session.status]}',
      ),
      trailing: Text('${session.completedCount}/${session.exercises.length}'),
      children: [
        for (final e in session.exercises)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 16),
            title: Text(vm.exerciseName(e.exerciseId)),
            subtitle: Text(_exerciseLine(e, unit)),
          ),
        if (sets == 0)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text('Sin series registradas en esta sesión.'),
          ),
      ],
    );
  }

  String _exerciseLine(ExerciseLog e, WeightUnit unit) {
    final state = e.completed
        ? 'Completado'
        : e.skipped
        ? 'Omitido: ${e.skipReason ?? ''}'
        : 'Pendiente';
    final done = e.workSets;
    if (done.isEmpty) return state;
    final parts = [
      for (final s in done)
        [
          if (s.weightKg != null)
            '${weightText(s.weightKg!, unit)} ${unit.label}',
          if (s.reps != null) '× ${s.reps}',
        ].join(' ').trim(),
    ].where((p) => p.isNotEmpty).join(', ');
    return '$state · ${done.length} series${parts.isEmpty ? '' : ': $parts'}';
  }
}
