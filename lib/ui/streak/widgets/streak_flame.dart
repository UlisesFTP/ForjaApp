import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/forja_theme.dart';

/// The streak flame. Lit, it is orange with a yellow core; unlit, grey.
///
/// It flickers for a moment when it appears, when [play] changes (the
/// streak grew) and when tapped; it then rests, so it never keeps the screen
/// busy. With reduced motion it does not move.
class StreakFlame extends StatefulWidget {
  const StreakFlame({
    super.key,
    required this.size,
    required this.lit,
    this.onPaper = false,
    this.play = 0,
    this.playOnStart = false,
    this.tappable = false,
  });
  final double size;
  final bool lit;

  /// On the light bar the orange is darker, to keep its contrast.
  final bool onPaper;

  /// A change of this number plays the flicker.
  final int play;
  final bool playOnStart;
  final bool tappable;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.playOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _flicker());
    }
  }

  @override
  void didUpdateWidget(StreakFlame old) {
    super.didUpdateWidget(old);
    if (old.play != widget.play) _flicker();
  }

  void _flicker() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flame = ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size(widget.size, widget.size * 1.2),
          painter: FlamePainter(
            t: _controller.value,
            lit: widget.lit,
            onPaper: widget.onPaper,
          ),
        ),
      ),
    );
    if (!widget.tappable) return flame;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _flicker,
      child: flame,
    );
  }
}

/// A rounded flame with a side lick and a yellow core, drawn in a 100×120
/// box. [t] runs 0→1 during a flicker; at 0 and 1 the flame is at rest.
class FlamePainter extends CustomPainter {
  FlamePainter({required this.t, required this.lit, required this.onPaper});
  final double t;
  final bool lit, onPaper;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = 1 - t;
    final wave = math.sin(t * math.pi * 6) * fade;
    final flick = math.sin(t * math.pi * 9 + 1) * fade;
    canvas.save();
    // Grow from the base and sway a little, like a real flame.
    canvas.translate(size.width / 2, size.height);
    canvas.scale(
      size.width / 100 * (1 - .04 * wave),
      size.height / 120 * (1 + .08 * wave),
    );
    canvas.transform(Matrix4.skewX(.06 * flick).storage);
    canvas.translate(-50, -120);

    final outer = Path()
      ..moveTo(50, 4)
      ..cubicTo(58, 22, 86, 38, 87, 68)
      ..cubicTo(88, 98, 70, 117, 50, 117)
      ..cubicTo(30, 117, 12, 99, 13, 73)
      ..cubicTo(14, 56, 23, 46, 32, 40)
      ..cubicTo(32, 52, 36, 59, 43, 62)
      ..cubicTo(39, 43, 42, 22, 50, 4)
      ..close();
    final outerColor = !lit
        ? ForjaColors.flameOff
        : onPaper
        ? ForjaColors.flameDeep
        : ForjaColors.flame;
    canvas.drawPath(outer, Paint()..color = outerColor);

    final core = Path()
      ..moveTo(50, 56)
      ..cubicTo(58, 71, 69, 81, 67, 96)
      ..cubicTo(65, 108, 58, 113, 50, 113)
      ..cubicTo(42, 113, 34, 108, 33, 96)
      ..cubicTo(32, 83, 44, 73, 50, 56)
      ..close();
    canvas.save();
    // The core breathes a little more than the flame.
    canvas.translate(50, 113);
    canvas.scale(1, 1 + .12 * flick);
    canvas.translate(-50, -113);
    canvas.drawPath(
      core,
      Paint()..color = lit ? ForjaColors.flameCore : const Color(0xFFB4B4AE),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(FlamePainter old) =>
      old.t != t || old.lit != lit || old.onPaper != onPaper;
}
