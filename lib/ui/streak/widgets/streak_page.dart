import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/services/streak_rules.dart';
import '../../core/responsive.dart';
import '../../core/widgets.dart';
import '../view_models/streak_view_model.dart';
import 'streak_flame.dart';

Future<void> showStreak(BuildContext context, StreakViewModel vm) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => StreakPage(vm: vm)));

const _shortWeekdayLetters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

String _stateLabel(StreakDay day) => switch (day) {
  StreakDay.trained => 'entrenaste',
  StreakDay.missed => 'faltaste',
  StreakDay.moved => 'reprogramado',
  StreakDay.pending => 'toca entrenar hoy',
  StreakDay.upcoming => 'entreno planificado',
  StreakDay.rest => 'descanso',
  StreakDay.untracked => 'sin registro',
};

/// The streak in full: today's state, the month and the year.
class StreakPage extends StatelessWidget {
  const StreakPage({super.key, required this.vm});
  final StreakViewModel vm;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Racha'),
      backgroundColor: ForjaColors.paper,
      foregroundColor: ForjaColors.ink,
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => ResponsivePage(
          header: _Hero(vm: vm),
          primary: [_MonthCard(vm: vm)],
          secondary: [
            const SizedBox(height: 16),
            _YearCard(vm: vm),
            const SizedBox(height: 16),
            _YearTable(vm: vm),
            const SizedBox(height: 16),
            const Text(
              'Cada día de entrenamiento del plan en el que entrenas suma uno: '
              'sesión completa, parcial o con algún ejercicio o serie hecha. '
              'Los descansos no la rompen. Un día planificado que termina sin '
              'entrenar la rompe, salvo que lo hayas reprogramado: entonces '
              'cuenta el día al que lo moviste. Hoy no cuenta en contra hasta '
              'que acabe. Solo se miran los días desde tu primer entreno o '
              'tu primera falta marcada. Reglas ${Streak.version}.',
              style: TextStyle(color: ForjaColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.vm});
  final StreakViewModel vm;

  @override
  Widget build(BuildContext context) {
    final n = vm.current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          StreakFlame(
            size: 72,
            lit: vm.lit,
            play: vm.celebrate,
            playOnStart: vm.lit,
            tappable: true,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: n == 1 ? '1 entreno seguido' : '$n entrenos seguidos',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$n',
                        key: const ValueKey('streak-current'),
                        style: const TextStyle(
                          fontFamily: 'Barlow Condensed',
                          fontWeight: FontWeight.w700,
                          fontSize: 56,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          n == 1 ? 'entreno seguido' : 'entrenos seguidos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    vm.todayMessage,
                    key: const ValueKey('streak-today'),
                  ),
                ),
                Text(
                  'Mejor racha: ${vm.best}',
                  key: const ValueKey('streak-best'),
                  style: const TextStyle(color: ForjaColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.vm});
  final StreakViewModel vm;

  @override
  Widget build(BuildContext context) {
    final month = vm.month;
    final count = vm.monthCount;
    final cells = vm.monthCells;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mes anterior',
                onPressed: () => vm.shiftMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${fullMonthNames[month.month - 1]} ${month.year}',
                  key: const ValueKey('streak-month'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                onPressed: () => vm.shiftMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Row(
              children: [
                for (final d in _shortWeekdayLetters)
                  Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ForjaColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < cells.length; row += 7)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final date in cells.sublist(row, row + 7))
                  Expanded(
                    child: date == null
                        ? const SizedBox.shrink()
                        : _DayCell(
                            date: date,
                            state: vm.dayOn(date),
                            today: dateKey(date) == dateKey(vm.today),
                          ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            '${count.trained} ${count.trained == 1 ? 'entreno' : 'entrenos'}'
            ' · ${count.missed} ${count.missed == 1 ? 'falta' : 'faltas'} este mes',
            key: const ValueKey('streak-month-count'),
          ),
          const SizedBox(height: 8),
          const _MonthLegend(),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.state,
    required this.today,
  });
  final DateTime date;
  final StreakDay state;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      StreakDay.trained => const StreakFlame(size: 16, lit: true),
      StreakDay.pending => const StreakFlame(size: 16, lit: false),
      StreakDay.missed => const Icon(
        Icons.close,
        size: 16,
        color: ForjaColors.muted,
      ),
      StreakDay.moved => const Icon(
        Icons.redo,
        size: 16,
        color: ForjaColors.muted,
      ),
      StreakDay.upcoming => const Icon(
        Icons.circle_outlined,
        size: 10,
        color: ForjaColors.muted,
      ),
      _ => const SizedBox.shrink(),
    };
    // Each day is its own item for screen readers.
    return Semantics(
      container: true,
      label:
          '${friendlyDate(date)}: ${_stateLabel(state)}'
          '${today ? ', hoy' : ''}',
      excludeSemantics: true,
      child: Container(
        key: ValueKey('streak-day-${dateKey(date)}'),
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: today
              ? Border.all(color: ForjaColors.paper, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: state == StreakDay.trained
                    ? ForjaColors.text
                    : ForjaColors.muted,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(height: 20, child: Center(child: icon)),
          ],
        ),
      ),
    );
  }
}

class _MonthLegend extends StatelessWidget {
  const _MonthLegend();

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 14,
    runSpacing: 6,
    children: [
      _LegendItem(StreakFlame(size: 14, lit: true), 'Entrenaste'),
      _LegendItem(
        Icon(Icons.close, size: 14, color: ForjaColors.muted),
        'Faltaste',
      ),
      _LegendItem(
        Icon(Icons.redo, size: 14, color: ForjaColors.muted),
        'Reprogramado',
      ),
      _LegendItem(
        Icon(Icons.circle_outlined, size: 10, color: ForjaColors.muted),
        'Planificado',
      ),
    ],
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.mark, this.label);
  final Widget mark;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: 18, child: Center(child: mark)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: ForjaColors.muted)),
    ],
  );
}

class _YearCard extends StatelessWidget {
  const _YearCard({required this.vm});
  final StreakViewModel vm;

  @override
  Widget build(BuildContext context) {
    final weeks = vm.yearWeeks;
    final states = [
      for (final week in weeks)
        [for (final day in week) day == null ? null : vm.dayOn(day)],
    ];
    final trained = vm.yearTrained;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Año anterior',
                onPressed: () => vm.shiftYear(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${vm.year} · $trained ${trained == 1 ? 'entreno' : 'entrenos'}',
                  key: const ValueKey('streak-year'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Año siguiente',
                onPressed: () => vm.shiftYear(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The map is a picture; the table below says the same in words.
          Semantics(
            label:
                'Mapa del año ${vm.year}: $trained días entrenados. '
                'El detalle por mes está en la tabla siguiente.',
            child: ExcludeSemantics(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final layout = HeatMapLayout.fit(
                    width: constraints.maxWidth,
                    weeks: weeks.length,
                  );
                  return SizedBox(
                    key: ValueKey('streak-heatmap-${layout.blocks}'),
                    width: constraints.maxWidth,
                    height: layout.height,
                    child: CustomPaint(
                      painter: _HeatMapPainter(
                        weeks: weeks,
                        states: states,
                        layout: layout,
                        today: vm.today,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _LegendItem(_Swatch(_SwatchKind.trained), 'Entreno'),
              _LegendItem(_Swatch(_SwatchKind.missed), 'Falta'),
              _LegendItem(_Swatch(_SwatchKind.rest), 'Descanso'),
              _LegendItem(_Swatch(_SwatchKind.upcoming), 'Planificado'),
            ],
          ),
        ],
      ),
    );
  }
}

/// How the yearly map fits a width: one block of weeks, or two (January to
/// June, July to December) when a single block would make the squares too
/// small to see.
class HeatMapLayout {
  const HeatMapLayout._(this.blocks, this.cell, this.weeksPerBlock);

  factory HeatMapLayout.fit({required double width, required int weeks}) {
    final room = width - labelWidth;
    final single = room / weeks - gap;
    if (single >= minCell) {
      return HeatMapLayout._(1, math.min(single, maxCell), weeks);
    }
    final half = (weeks / 2).ceil();
    return HeatMapLayout._(2, math.min(room / half - gap, maxCell), half);
  }

  static const gap = 2.0, labelWidth = 18.0, monthRow = 16.0;
  static const minCell = 9.0, maxCell = 16.0, blockGap = 12.0;

  final int blocks;
  final double cell;
  final int weeksPerBlock;

  double get blockHeight => monthRow + 7 * (cell + gap);
  double get height => blocks * blockHeight + (blocks - 1) * blockGap;
}

class _HeatMapPainter extends CustomPainter {
  _HeatMapPainter({
    required this.weeks,
    required this.states,
    required this.layout,
    required this.today,
  });
  final List<List<DateTime?>> weeks;
  final List<List<StreakDay?>> states;
  final HeatMapLayout layout;
  final DateTime today;

  static const _rest = Color(0xFF2A2A28), _upcoming = Color(0xFF1F1F1E);

  void _label(Canvas canvas, String text, Offset at) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 10,
          color: ForjaColors.muted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at);
    painter.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = layout.cell, step = cell + HeatMapLayout.gap;
    final todayKey = dateKey(today);
    for (var block = 0; block < layout.blocks; block++) {
      final top = block * (layout.blockHeight + HeatMapLayout.blockGap);
      final first = block * layout.weeksPerBlock;
      final last = math.min(first + layout.weeksPerBlock, weeks.length);
      // Monday, Wednesday and Friday, as in most yearly maps.
      for (final (row, letter) in [(0, 'L'), (2, 'X'), (4, 'V')]) {
        _label(
          canvas,
          letter,
          Offset(0, top + HeatMapLayout.monthRow + row * step - 1),
        );
      }
      for (var w = first; w < last; w++) {
        final x = HeatMapLayout.labelWidth + (w - first) * step;
        // Month name above the week that holds its 1st day (and above the
        // first week of each block, so the block says where it starts).
        final days = weeks[w].whereType<DateTime>();
        final named =
            days.where((d) => d.day == 1).firstOrNull ??
            (w == first ? days.firstOrNull : null);
        if (named != null) {
          _label(canvas, monthNames[named.month - 1], Offset(x, top));
        }
        for (var d = 0; d < 7; d++) {
          final day = weeks[w][d], state = states[w][d];
          if (day == null || state == null) continue;
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x,
              top + HeatMapLayout.monthRow + d * step,
              cell,
              cell,
            ),
            const Radius.circular(2),
          );
          switch (state) {
            case StreakDay.trained:
              canvas.drawRRect(rect, Paint()..color = ForjaColors.flame);
            case StreakDay.missed:
              canvas.drawRRect(
                rect.deflate(.6),
                Paint()
                  ..color = ForjaColors.muted
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.2,
              );
            case StreakDay.upcoming || StreakDay.pending:
              canvas.drawRRect(rect, Paint()..color = _upcoming);
              canvas.drawCircle(
                rect.center,
                math.max(1.2, cell * .14),
                Paint()..color = ForjaColors.muted,
              );
            case _:
              canvas.drawRRect(rect, Paint()..color = _rest);
          }
          if (dateKey(day) == todayKey) {
            canvas.drawRRect(
              rect.inflate(1.2),
              Paint()
                ..color = ForjaColors.paper
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatMapPainter old) =>
      old.states != states || old.layout.cell != layout.cell;
}

enum _SwatchKind { trained, missed, rest, upcoming }

/// The squares of the map, for its legend.
class _Swatch extends StatelessWidget {
  const _Swatch(this.kind);
  final _SwatchKind kind;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 12,
    height: 12,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: switch (kind) {
          _SwatchKind.trained => ForjaColors.flame,
          _SwatchKind.missed => Colors.transparent,
          _SwatchKind.rest => const Color(0xFF2A2A28),
          _SwatchKind.upcoming => const Color(0xFF1F1F1E),
        },
        border: kind == _SwatchKind.missed
            ? Border.all(color: ForjaColors.muted, width: 1.2)
            : null,
      ),
      child: kind == _SwatchKind.upcoming
          ? const Center(
              child: SizedBox(
                width: 3,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ForjaColors.muted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )
          : null,
    ),
  );
}

/// The year month by month, in words: the accessible side of the map.
class _YearTable extends StatelessWidget {
  const _YearTable({required this.vm});
  final StreakViewModel vm;

  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontWeight: FontWeight.w700);
    return SurfaceCard(
      child: Table(
        key: const ValueKey('streak-year-table'),
        columnWidths: const {
          0: FlexColumnWidth(1.6),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          TableRow(
            children: [
              for (final h in ['Mes', 'Entrenos', 'Faltas'])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Semantics(header: true, child: Text(h, style: head)),
                ),
            ],
          ),
          for (final m in vm.yearMonths)
            TableRow(
              children: [
                for (final cell in [
                  fullMonthNames[m.month - 1],
                  '${m.trained}',
                  '${m.missed}',
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(cell),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
