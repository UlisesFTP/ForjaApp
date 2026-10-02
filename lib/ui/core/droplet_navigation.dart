import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/forja_theme.dart';

const navLabels = ['Hoy', 'Plan', 'Progreso', 'Ejercicios', 'Más'];
const navIcons = [
  Icons.home_outlined,
  Icons.calendar_month_outlined,
  Icons.bar_chart_rounded,
  Icons.fitness_center,
  Icons.more_horiz,
];

const _labelStyle = TextStyle(
  fontFamily: 'DM Sans',
  fontSize: 14,
  fontWeight: FontWeight.w700,
  height: 1.2,
);

/// Size of [label] in the (bold, widest) navigation style at [scaler].
Size _labelSize(String label, TextScaler scaler) {
  final painter = TextPainter(
    text: TextSpan(text: label, style: _labelStyle),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
    maxLines: 1,
  )..layout();
  final size = painter.size;
  painter.dispose();
  return size;
}

/// How the five items share the bottom bar. Pure, so it is tested on its own.
///
/// Items start equal; one whose label (plus [minGap]) does not fit its share
/// takes what it needs and the rest share the remainder, so "Progreso" and
/// "Ejercicios" no longer touch while the icons stay nearly evenly spaced.
/// Labels are always one line: they grow with the system text size
/// as far as they fit with [minGap] between them (screen readers still get the
/// full label), instead of breaking mid-word ("Progres/o") on small phones.
class NavBarLayout {
  const NavBarLayout._(this.labelScale, this.widths);

  factory NavBarLayout.compute({
    required double width,
    required double textScale,
    required List<double> labelWidths,
  }) {
    final n = labelWidths.length;
    final base = labelWidths.fold(0.0, (a, b) => a + b);
    final fit = (width - minGap * n) / base;
    final scale = math.min(textScale, fit);
    final labels = [for (final w in labelWidths) w * scale];
    // Labels breathe up to [preferredGap] apart when there is room, and no
    // less than [minGap] when there is not.
    final gap = ((width - labels.fold(0.0, (a, b) => a + b)) / n).clamp(
      minGap,
      preferredGap,
    );
    final needs = [for (final l in labels) l + gap];
    // Equal shares first; an item whose label needs more takes it, and the
    // others share what is left. Icons stay as evenly spaced as the labels
    // allow.
    final widths = List.filled(n, 0.0);
    final fixed = <int>{};
    var remaining = width;
    while (fixed.length < n) {
      final free = [
        for (var i = 0; i < n; i++)
          if (!fixed.contains(i)) i,
      ];
      final share = remaining / free.length;
      final over = [
        for (final i in free)
          if (needs[i] > share) i,
      ];
      if (over.isEmpty) {
        for (final i in free) {
          widths[i] = share;
        }
        remaining = 0;
        break;
      }
      for (final i in over) {
        widths[i] = needs[i];
        remaining -= needs[i];
        fixed.add(i);
      }
    }
    // Only when every item needed more than its share: spread the rest.
    if (remaining > 0) {
      for (var i = 0; i < n; i++) {
        widths[i] += remaining / n;
      }
    }
    return NavBarLayout._(scale, widths);
  }

  /// The least space between two labels.
  static const minGap = 12.0;

  /// The space between labels when the bar has room for it.
  static const preferredGap = 18.0;

  /// Text scale the labels are drawn at (the system's, while it fits).
  final double labelScale;

  /// Width of each item, left to right; they add up to the bar's width.
  final List<double> widths;

  /// Horizontal centre of each item.
  List<double> get centres {
    final result = <double>[];
    var left = 0.0;
    for (final w in widths) {
      result.add(left + w / 2);
      left += w;
    }
    return result;
  }
}

/// The moving notch is part of the bar's path, not a black overlay or shadow.
class DropletNavigation extends StatelessWidget {
  const DropletNavigation({
    super.key,
    required this.index,
    required this.onSelected,
  });
  final int index;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final userScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final base = [
      for (final label in navLabels)
        _labelSize(label, TextScaler.noScaling).width,
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = NavBarLayout.compute(
              width: constraints.maxWidth,
              textScale: userScale,
              labelWidths: base,
            );
            final labelScaler = TextScaler.linear(layout.labelScale);
            final labelHeight = _labelSize('Hoy', labelScaler).height;
            final height = math.max(
              98.0 + math.max(0.0, layout.labelScale - 1) * 22,
              70 + labelHeight,
            );
            final centres = layout.centres;
            return TweenAnimationBuilder<double>(
              tween: Tween(end: index.toDouble()),
              duration: Duration(milliseconds: reduced ? 0 : 460),
              curve: Curves.easeInOutCubic,
              builder: (context, position, _) => SizedBox(
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _NavPainter(position, centres),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          5,
                          (i) => SizedBox(
                            width: layout.widths[i],
                            child: Semantics(
                              container: true,
                              onTap: () => onSelected(i),
                              selected: i == index,
                              button: true,
                              label: navLabels[i],
                              excludeSemantics: true,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => onSelected(i),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: AnimatedSlide(
                                          duration: Duration(
                                            milliseconds: reduced ? 0 : 280,
                                          ),
                                          offset: Offset(
                                            0,
                                            i == index ? -.34 : .24,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: Icon(
                                            navIcons[i],
                                            size: 25,
                                            color: i == index
                                                ? ForjaColors.ink
                                                : ForjaColors.muted,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      navLabels[i],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      textScaler: labelScaler,
                                      style: TextStyle(
                                        fontFamily: 'DM Sans',
                                        fontSize: 14,
                                        height: 1.2,
                                        fontWeight: i == index
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: i == index
                                            ? ForjaColors.paper
                                            : ForjaColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The same droplet standing on its side, used when the screen is wider than
/// tall: the notch is on the right edge of the rail and the drop leans into
/// the content at the selected item. Same colours, curves and animation as
/// the bottom bar (decision of the person, 2026-10-02).
class DropletRail extends StatelessWidget {
  const DropletRail({super.key, required this.index, required this.onSelected});
  final int index;
  final ValueChanged<int> onSelected;

  // The drop leans this far past the body edge; the rail keeps room for it.
  static const _overhang = 33.0;
  // Kept small so all five items fit the shortest phone turned sideways
  // (320 px of height) without scrolling at normal text size.
  static const _endPadding = 12.0;
  static const _iconSize = 25.0;
  static const _labelGap = 4.0;

  /// The largest text scale of the rail labels.
  static const maxLabelScale = 1.4;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    // Labels follow the system text size up to [maxLabelScale]: past that
    // the rail would take half of a phone turned sideways. Screen readers
    // still get the full label.
    final scaler = TextScaler.linear(
      math.min(MediaQuery.textScalerOf(context).scale(14) / 14, maxLabelScale),
    );
    var labelWidth = 0.0, labelHeight = 0.0;
    for (final label in navLabels) {
      final size = _labelSize(label, scaler);
      labelWidth = math.max(labelWidth, size.width);
      labelHeight = math.max(labelHeight, size.height);
    }
    // Wide enough for the longest label without it reaching the notch.
    final body = math.max(88.0, labelWidth + 28);
    final block = _iconSize + _labelGap + labelHeight;
    final minItem = block + 8;
    return SafeArea(
      right: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final length = math.max(
              constraints.maxHeight,
              minItem * 5 + _endPadding * 2,
            );
            // On a tall rail (a tablet) the items stay close together and
            // the group is centred, instead of spreading over the height.
            final item = math.min(
              (length - _endPadding * 2) / 5,
              math.max(minItem, 92.0),
            );
            final start = (length - item * 5) / 2;
            final blockTop = (item - block) / 2;
            final iconCentre = blockTop + _iconSize / 2;
            final rail = TweenAnimationBuilder<double>(
              tween: Tween(end: index.toDouble()),
              duration: Duration(milliseconds: reduced ? 0 : 460),
              curve: Curves.easeInOutCubic,
              builder: (context, position, _) => SizedBox(
                width: body + _overhang,
                height: length,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RailPainter(
                          position: position,
                          body: body,
                          item: item,
                          start: start,
                          iconCentre: iconCentre,
                        ),
                      ),
                    ),
                    for (var i = 0; i < 5; i++)
                      Positioned(
                        left: 0,
                        width: body + _overhang,
                        top: start + item * i,
                        height: item,
                        child: Semantics(
                          container: true,
                          onTap: () => onSelected(i),
                          selected: i == index,
                          button: true,
                          label: navLabels[i],
                          excludeSemantics: true,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => onSelected(i),
                            child: Stack(
                              children: [
                                AnimatedPositioned(
                                  duration: Duration(
                                    milliseconds: reduced ? 0 : 280,
                                  ),
                                  curve: Curves.easeOutCubic,
                                  // Selected: inside the drop; otherwise
                                  // centred over its label.
                                  left:
                                      (i == index ? body + 2 : body / 2) -
                                      _iconSize / 2,
                                  top: blockTop,
                                  child: Icon(
                                    navIcons[i],
                                    size: _iconSize,
                                    color: i == index
                                        ? ForjaColors.ink
                                        : ForjaColors.muted,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  width: body,
                                  top: blockTop + _iconSize + _labelGap,
                                  child: Text(
                                    navLabels[i],
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    textScaler: scaler,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      height: 1.2,
                                      fontWeight: i == index
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: i == index
                                          ? ForjaColors.paper
                                          : ForjaColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
            // Very short screens with large text: the rail scrolls rather
            // than squeezing its items.
            return length > constraints.maxHeight
                ? SingleChildScrollView(child: rail)
                : rail;
          },
        ),
      ),
    );
  }
}

/// [_NavPainter] turned on its side: horizontal (x, y) becomes
/// (edge + 25 − y, x), so the notch cuts into the right edge.
class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.position,
    required this.body,
    required this.item,
    required this.start,
    required this.iconCentre,
  });
  final double position, body, item, start, iconCentre;

  @override
  void paint(Canvas canvas, Size size) {
    final e = body, length = size.height;
    final c = start + item * position + iconCentre;
    final half = math.min(37.0, item * .47);
    final top = c - half, bottom = c + half;
    const r = 20.0;
    // Near an end the right-hand corner tightens so the notch never runs
    // into it.
    final rTop = top.clamp(4.0, r), rBottom = (length - bottom).clamp(4.0, r);
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(e - rTop, 0)
      ..quadraticBezierTo(e, 0, e, rTop)
      ..lineTo(e, top)
      ..cubicTo(e, top + 13, e - 34, top + 9, e - 34, c)
      ..cubicTo(e - 34, bottom - 9, e, bottom - 13, e, bottom)
      ..lineTo(e, length - rBottom)
      ..quadraticBezierTo(e, length, e - rBottom, length)
      ..lineTo(r, length)
      ..quadraticBezierTo(0, length, 0, length - r)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = ForjaColors.surface);
    final edges = Path()
      ..moveTo(e - 1, top + 2)
      ..cubicTo(e - 1, top + 10, e - 9, top + 11, e - 18, top + 17)
      ..moveTo(e - 18, bottom - 17)
      ..cubicTo(e - 9, bottom - 11, e - 1, bottom - 10, e - 1, bottom - 2);
    canvas.drawPath(
      edges,
      Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    final drop = Path()
      ..moveTo(e - 30, c)
      ..cubicTo(e - 24, c - 5, e - 23, c - 28, e - 2, c - 28)
      ..cubicTo(e + 32, c - 28, e + 32, c + 28, e - 2, c + 28)
      ..cubicTo(e - 23, c + 28, e - 24, c + 5, e - 30, c)
      ..close();
    canvas.drawPath(drop, Paint()..color = ForjaColors.paper);
    canvas.drawPath(
      drop,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      oldDelegate.position != position ||
      oldDelegate.body != body ||
      oldDelegate.item != item ||
      oldDelegate.iconCentre != iconCentre;
}

class _NavPainter extends CustomPainter {
  _NavPainter(this.position, this.centres);
  final double position;
  // Centre of each item: items are as wide as their labels need.
  final List<double> centres;
  @override
  void paint(Canvas canvas, Size size) {
    final from = position.floor().clamp(0, centres.length - 1);
    final to = position.ceil().clamp(0, centres.length - 1);
    final x = centres[from] + (centres[to] - centres[from]) * (position - from);
    // The notch narrows near an end so it never runs past the bar's corner.
    final half = math.min(
      math.min(37.0, size.width / 5 * .47),
      math.max(16.0, math.min(x - 2, size.width - x - 2)),
    );
    const y = 25.0, r = 20.0;
    final left = x - half, right = x + half;
    final path = Path()
      ..moveTo(r, y)
      ..lineTo(left, y)
      ..cubicTo(left + 13, y, left + 9, 59, x, 59)
      ..cubicTo(right - 9, 59, right - 13, y, right, y)
      ..lineTo(size.width - r, y)
      ..quadraticBezierTo(size.width, y, size.width, y + r)
      ..lineTo(size.width, size.height - r)
      ..quadraticBezierTo(size.width, size.height, size.width - r, size.height)
      ..lineTo(r, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - r)
      ..lineTo(0, y + r)
      ..quadraticBezierTo(0, y, r, y)
      ..close();
    canvas.drawPath(path, Paint()..color = ForjaColors.surface);
    // Only two short, diffused highlights on the notch shoulders.
    final edges = Path()
      ..moveTo(left + 2, y + 1)
      ..cubicTo(left + 10, y + 1, left + 11, 34, left + 17, 43)
      ..moveTo(right - 17, 43)
      ..cubicTo(right - 11, 34, right - 10, y + 1, right - 2, y + 1);
    canvas.drawPath(
      edges,
      Paint()
        ..color = const Color(0x33FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
    );
    final drop = Path()
      ..moveTo(x, 55)
      ..cubicTo(x - 5, 49, x - 28, 48, x - 28, 27)
      ..cubicTo(x - 28, -7, x + 28, -7, x + 28, 27)
      ..cubicTo(x + 28, 48, x + 5, 49, x, 55)
      ..close();
    canvas.drawPath(drop, Paint()..color = ForjaColors.paper);
    canvas.drawPath(
      drop,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_NavPainter oldDelegate) =>
      oldDelegate.position != position ||
      !listEquals(oldDelegate.centres, centres);
}
