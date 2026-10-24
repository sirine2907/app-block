import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The app's heart + lock mark, drawn in code so it scales crisply and tints
/// with the theme. Used on the onboarding and home screens.
class HeartLogo extends StatelessWidget {
  const HeartLogo({super.key, this.size = 96, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HeartLockPainter(c)),
    );
  }
}

class _HeartLockPainter extends CustomPainter {
  _HeartLockPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Heart body.
    final path = Path();
    final cx = w / 2;
    path.moveTo(cx, h * 0.92);
    path.cubicTo(w * -0.05, h * 0.5, w * 0.15, h * 0.05, cx, h * 0.3);
    path.cubicTo(w * 0.85, h * 0.05, w * 1.05, h * 0.5, cx, h * 0.92);
    canvas.drawPath(path, fill);

    // Keyhole (negative space) to suggest a lock.
    final hole = Paint()..color = AppColors.cream.withValues(alpha: 0.95);
    canvas.drawCircle(Offset(cx, h * 0.5), w * 0.08, hole);
    final stem = Rect.fromLTWH(cx - w * 0.035, h * 0.5, w * 0.07, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(stem, Radius.circular(w * 0.02)),
      hole,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartLockPainter old) => old.color != color;
}
