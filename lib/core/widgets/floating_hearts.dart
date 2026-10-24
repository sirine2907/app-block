import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A gentle field of hearts drifting upward, used behind the countdown.
///
/// Purely decorative and lightweight: a handful of hearts on a single
/// repeating animation controller.
class FloatingHearts extends StatefulWidget {
  const FloatingHearts({
    super.key,
    this.count = 12,
    this.color = AppColors.heart,
  });

  final int count;
  final Color color;

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Heart> _hearts;

  @override
  void initState() {
    super.initState();
    final rnd = Random(7);
    _hearts = List.generate(widget.count, (_) => _Heart.random(rnd));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HeartsPainter(_hearts, _controller.value, widget.color),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Heart {
  _Heart(this.x, this.size, this.phase, this.speed, this.drift);

  final double x; // 0..1 horizontal position
  final double size;
  final double phase; // 0..1 start offset in the loop
  final double speed; // loop multiplier
  final double drift; // horizontal sway amplitude

  factory _Heart.random(Random rnd) => _Heart(
        rnd.nextDouble(),
        8 + rnd.nextDouble() * 16,
        rnd.nextDouble(),
        0.6 + rnd.nextDouble() * 0.8,
        0.02 + rnd.nextDouble() * 0.05,
      );
}

class _HeartsPainter extends CustomPainter {
  _HeartsPainter(this.hearts, this.t, this.color);

  final List<_Heart> hearts;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (final h in hearts) {
      final progress = (t * h.speed + h.phase) % 1.0;
      final y = size.height * (1.0 - progress);
      final sway = sin(progress * 2 * pi) * h.drift * size.width;
      final x = h.x * size.width + sway;
      // Fade in at the bottom, out at the top.
      final opacity = (sin(progress * pi)).clamp(0.0, 1.0) * 0.5;
      _drawHeart(canvas, Offset(x, y), h.size, color.withValues(alpha: opacity));
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    final w = size;
    final h = size;
    path.moveTo(center.dx, center.dy + h * 0.35);
    path.cubicTo(
      center.dx - w * 0.6, center.dy - h * 0.25,
      center.dx - w * 0.3, center.dy - h * 0.7,
      center.dx, center.dy - h * 0.3,
    );
    path.cubicTo(
      center.dx + w * 0.3, center.dy - h * 0.7,
      center.dx + w * 0.6, center.dy - h * 0.25,
      center.dx, center.dy + h * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartsPainter old) => old.t != t;
}
