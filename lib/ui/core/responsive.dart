import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Layout decisions taken from the space a page actually gets, in logical
/// pixels. Phones in portrait keep the single column they always had.
abstract final class Breakpoints {
  /// From this width (at normal text size) two columns fit side by side. A
  /// phone turned sideways gets them beside the rail; larger text needs more
  /// room, see [fitsTwoColumns].
  static const twoColumns = 640.0;

  /// Content stops growing here; wider screens get side margins instead of
  /// lines too long to read.
  static const maxContent = 1200.0;

  /// A single column of text, settings or forms stops growing here.
  static const readable = 680.0;

  /// Space between columns.
  static const gutter = 24.0;
}

/// Whether [width] holds two columns at the current text size: the threshold
/// grows with the text (up to 1.6 times at 160 % and above), so large text
/// keeps a single, readable column instead of two cramped ones.
bool fitsTwoColumns(BuildContext context, double width) {
  final factor = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
    1.0,
    1.6,
  );
  return width >= Breakpoints.twoColumns * factor;
}

/// The side rail replaces the bottom bar when the screen is wider than tall
/// (a phone turned sideways, a tablet in landscape), so the content keeps
/// its height. In portrait the bottom bar stays, on phones and tablets.
bool useNavigationRail(Size size) => size.width > size.height;

/// Padding that keeps at most [maxWidth] of content centred in [width], with
/// at least [side] on each side.
EdgeInsets centredPadding(
  double width, {
  double maxWidth = Breakpoints.maxContent,
  double side = 20,
  double top = 20,
  double bottom = 20,
}) {
  final horizontal = math.max(side, (width - maxWidth) / 2);
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}

/// A scrolling page made of sections.
///
/// Narrower than [Breakpoints.twoColumns]: one column, exactly as on a phone
/// (header, then [primary], then [secondary]). Wider: the header spans the
/// page and [primary] and [secondary] sit side by side, read left column
/// first. Without [secondary] the single column is centred at [maxWidth].
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    this.header,
    required this.primary,
    this.secondary = const [],
    this.maxWidth = Breakpoints.maxContent,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
  });
  final Widget? header;
  final List<Widget> primary, secondary;
  final double maxWidth;
  final int primaryFlex, secondaryFlex;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final twoColumns = secondary.isNotEmpty && fitsTwoColumns(context, width);
      if (!twoColumns) {
        return ListView(
          padding: centredPadding(
            width,
            maxWidth: secondary.isEmpty ? maxWidth : Breakpoints.maxContent,
          ),
          children: [?header, ...primary, ...secondary],
        );
      }
      return ListView(
        padding: centredPadding(width, maxWidth: maxWidth),
        children: [
          ?header,
          TwoColumns(
            primaryFlex: primaryFlex,
            secondaryFlex: secondaryFlex,
            primary: primary,
            secondary: secondary,
          ),
        ],
      );
    },
  );
}

/// Two top-aligned columns of sections; the left one is read first.
class TwoColumns extends StatelessWidget {
  const TwoColumns({
    super.key = const ValueKey('two-columns'),
    required this.primary,
    required this.secondary,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
  });
  final List<Widget> primary, secondary;
  final int primaryFlex, secondaryFlex;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: primaryFlex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final s in primary) _Section(s)],
        ),
      ),
      const SizedBox(width: Breakpoints.gutter),
      Expanded(
        flex: secondaryFlex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final s in secondary) _Section(s)],
        ),
      ),
    ],
  );
}

/// Each section is its own node for screen readers, as it was as an item of
/// the phone's list; otherwise a whole column would be read as one block.
class _Section extends StatelessWidget {
  const _Section(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      Semantics(container: true, child: child);
}

/// Cards in as many columns as fit at [minItemWidth] each (up to
/// [maxColumns]); one column on a phone. Cards in a row share its height.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 320,
    this.maxColumns = 3,
    this.spacing = 12,
  });
  final List<Widget> children;
  final double minItemWidth, spacing;
  final int maxColumns;

  static int columnsFor(
    double width, {
    double minItemWidth = 320,
    double spacing = 12,
    int maxColumns = 3,
  }) => ((width + spacing) / (minItemWidth + spacing)).floor().clamp(
    1,
    maxColumns,
  );

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = columnsFor(
        constraints.maxWidth,
        minItemWidth: minItemWidth,
        spacing: spacing,
        maxColumns: maxColumns,
      );
      if (columns == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      }
      return Column(
        key: ValueKey('grid-$columns'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var start = 0; start < children.length; start += columns)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = start; i < start + columns; i++) ...[
                    if (i > start) SizedBox(width: spacing),
                    Expanded(
                      child: i < children.length
                          ? _Section(children[i])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    },
  );
}
