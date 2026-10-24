import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A flat, friendly illustration of a doctor studying: black hair, a short
/// beard, white coat and stethoscope, head tilted over an open book.
///
/// Drawn in code so it stays crisp at any size and themes with the app. It
/// breathes, blinks, and lets a heart drift up every few seconds.
class StudyAvatar extends StatefulWidget {
  const StudyAvatar({super.key, this.size = 170, this.animate = true});

  final double size;

  /// Turned off in golden tests so the frame is deterministic.
  final bool animate;

  @override
  State<StudyAvatar> createState() => _StudyAvatarState();
}

class _StudyAvatarState extends State<StudyAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _StudyAvatarPainter(t: _controller.value, dark: dark),
        ),
      ),
    );
  }
}

class _StudyAvatarPainter extends CustomPainter {
  _StudyAvatarPainter({required this.t, required this.dark});

  final double t;
  final bool dark;

  // Palette
  static const _skin = Color(0xFFE3A87A);
  static const _skinShade = Color(0xFFCB8C5E);
  static const _hair = Color(0xFF17130F); // black hair
  static const _beard = Color(0xFF5A4838); // lighter, softer beard
  static const _coat = Color(0xFFFFFCFB);
  static const _coatLine = Color(0xFFE6D8D4);
  static const _page = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double px(double v) => v * w;
    double py(double v) => v * h;

    final breathe = sin(t * 2 * pi) * 0.006;

    // --- soft background disc ---
    canvas.drawCircle(
      Offset(px(0.5), py(0.5)),
      px(0.48),
      Paint()
        ..color = dark
            ? AppColors.plumSurface.withValues(alpha: 0.85)
            : AppColors.blush,
    );

    _paintHeart(canvas, px, py);

    // --- neck ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(px(0.445), py(0.50 + breathe), px(0.555), py(0.66)),
        Radius.circular(px(0.03)),
      ),
      Paint()..color = _skinShade,
    );

    // --- white coat ---
    final top = 0.625 + breathe;
    canvas.drawPath(
      Path()
        ..moveTo(px(0.19), py(0.95))
        ..cubicTo(px(0.205), py(top + 0.08), px(0.29), py(top), px(0.385), py(top - 0.015))
        ..lineTo(px(0.615), py(top - 0.015))
        ..cubicTo(px(0.71), py(top), px(0.795), py(top + 0.08), px(0.81), py(0.95))
        ..close(),
      Paint()..color = _coat,
    );

    // collar: a soft V
    final collar = Paint()..color = _coatLine;
    canvas.drawPath(
      Path()
        ..moveTo(px(0.5), py(top + 0.10))
        ..lineTo(px(0.40), py(top - 0.012))
        ..lineTo(px(0.455), py(top - 0.012))
        ..lineTo(px(0.5), py(top + 0.045))
        ..close(),
      collar,
    );
    canvas.drawPath(
      Path()
        ..moveTo(px(0.5), py(top + 0.10))
        ..lineTo(px(0.60), py(top - 0.012))
        ..lineTo(px(0.545), py(top - 0.012))
        ..lineTo(px(0.5), py(top + 0.045))
        ..close(),
      collar,
    );

    // pocket with a pen
    canvas.drawRect(
      Rect.fromLTRB(px(0.655), py(0.775), px(0.755), py(0.845)),
      Paint()
        ..color = _coatLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = px(0.007),
    );
    canvas.drawLine(
      Offset(px(0.70), py(0.755)),
      Offset(px(0.70), py(0.805)),
      Paint()
        ..color = AppColors.rose
        ..strokeWidth = px(0.014)
        ..strokeCap = StrokeCap.round,
    );

    // --- stethoscope ---
    canvas.drawPath(
      Path()
        ..moveTo(px(0.405), py(top - 0.005))
        ..cubicTo(px(0.385), py(0.80), px(0.60), py(0.82), px(0.60), py(top - 0.005)),
      Paint()
        ..color = AppColors.burgundy
        ..style = PaintingStyle.stroke
        ..strokeWidth = px(0.024)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(px(0.60), py(0.825)), px(0.038),
        Paint()..color = AppColors.burgundy);
    canvas.drawCircle(Offset(px(0.60), py(0.825)), px(0.020),
        Paint()..color = AppColors.rose);

    // --- head, in its own unit space (1 unit = head radius) ---
    canvas.save();
    canvas.translate(px(0.5), py(0.375 + breathe));
    canvas.rotate(0.07 + sin(t * 2 * pi) * 0.012);
    final u = px(0.185);
    canvas.scale(u);

    final head = Rect.fromCenter(center: Offset.zero, width: 2, height: 2.12);
    final hairPaint = Paint()..color = _hair;

    // ears
    for (final dx in [-1.0, 1.0]) {
      canvas.drawCircle(Offset(dx, 0.12), 0.17, Paint()..color = _skinShade);
    }

    // face
    canvas.drawOval(head, Paint()..color = _skin);

    // hair + beard are clipped to the head so edges stay clean
    canvas.save();
    canvas.clipPath(Path()..addOval(head));

    // beard: a light one, hugging the jaw and leaving the cheeks clear
    canvas.drawPath(
      Path()
        ..moveTo(-1.25, 0.28)
        ..quadraticBezierTo(0, 0.96, 1.25, 0.28)
        ..lineTo(1.25, 1.35)
        ..lineTo(-1.25, 1.35)
        ..close(),
      Paint()..color = _beard,
    );
    // moustache
    canvas.drawPath(
      Path()
        ..moveTo(-0.36, 0.34)
        ..quadraticBezierTo(0, 0.21, 0.36, 0.34)
        ..quadraticBezierTo(0, 0.45, -0.36, 0.34)
        ..close(),
      Paint()..color = _beard,
    );

    // hair cap with a soft fringe
    canvas.drawPath(
      Path()
        ..moveTo(-1.25, -0.58)
        ..lineTo(-1.25, -1.4)
        ..lineTo(1.25, -1.4)
        ..lineTo(1.25, -0.58)
        ..quadraticBezierTo(0, -0.26, -1.25, -0.58)
        ..close(),
      hairPaint,
    );
    // narrow sideburns reaching down to the beard
    canvas.drawRect(const Rect.fromLTRB(-1.25, -0.6, -0.9, 0.22), hairPaint);
    canvas.drawRect(const Rect.fromLTRB(0.9, -0.6, 1.25, 0.22), hairPaint);
    canvas.restore();

    // eyebrows
    final brow = Paint()
      ..color = _hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-0.58, -0.26), const Offset(-0.22, -0.31), brow);
    canvas.drawLine(const Offset(0.22, -0.31), const Offset(0.58, -0.26), brow);

    // eyes, lowered towards the book
    final blink = _blink(t);
    for (final dx in [-0.39, 0.39]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(dx, 0.02), width: 0.25, height: 0.29 * blink),
        Paint()..color = _hair,
      );
    }

    // nose
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 0.18), width: 0.22, height: 0.2),
      0.35,
      pi - 0.7,
      false,
      Paint()
        ..color = _skinShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.05
        ..strokeCap = StrokeCap.round,
    );

    // smile between moustache and beard
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(0, 0.50), width: 0.4, height: 0.24),
      0.3,
      pi - 0.6,
      false,
      Paint()
        ..color = _skin
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.06
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();

    // --- desk and open book, over the body ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(px(0.04), py(0.875), px(0.96), py(0.95)),
        Radius.circular(px(0.018)),
      ),
      Paint()..color = dark ? AppColors.deepBurgundy : AppColors.dustyRose,
    );

    final bookPaint = Paint()..color = _page;
    canvas.drawPath(
      Path()
        ..moveTo(px(0.5), py(0.772))
        ..lineTo(px(0.175), py(0.805))
        ..lineTo(px(0.225), py(0.878))
        ..lineTo(px(0.5), py(0.878))
        ..close(),
      bookPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(px(0.5), py(0.772))
        ..lineTo(px(0.825), py(0.805))
        ..lineTo(px(0.775), py(0.878))
        ..lineTo(px(0.5), py(0.878))
        ..close(),
      bookPaint,
    );
    canvas.drawLine(
      Offset(px(0.5), py(0.772)),
      Offset(px(0.5), py(0.878)),
      Paint()
        ..color = AppColors.rose.withValues(alpha: 0.5)
        ..strokeWidth = px(0.009),
    );
    final line = Paint()
      ..color = AppColors.rose.withValues(alpha: 0.32)
      ..strokeWidth = px(0.0065)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final ly = py(0.806 + i * 0.019);
      canvas.drawLine(
          Offset(px(0.245 + i * 0.006), ly), Offset(px(0.465), ly), line);
      canvas.drawLine(
          Offset(px(0.535), ly), Offset(px(0.755 - i * 0.006), ly), line);
    }
  }

  /// Eye openness, 1 = open.
  double _blink(double t) {
    for (final at in [0.35, 0.8]) {
      final d = (t - at).abs();
      if (d < 0.016) return (d / 0.016).clamp(0.12, 1.0);
    }
    return 1;
  }

  void _paintHeart(
      Canvas canvas, double Function(double) px, double Function(double) py) {
    final p = t % 1.0;
    final opacity = sin(p * pi).clamp(0.0, 1.0) * 0.7;
    if (opacity <= 0.02) return;
    final size = px(0.05) * (0.7 + p * 0.4);
    final cx = px(0.8) + sin(p * 3 * pi) * px(0.02);
    final cy = py(0.40 - p * 0.24);
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + size * 0.35)
        ..cubicTo(cx - size * 0.6, cy - size * 0.25, cx - size * 0.3,
            cy - size * 0.7, cx, cy - size * 0.3)
        ..cubicTo(cx + size * 0.3, cy - size * 0.7, cx + size * 0.6,
            cy - size * 0.25, cx, cy + size * 0.35)
        ..close(),
      Paint()..color = AppColors.heart.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _StudyAvatarPainter old) =>
      old.t != t || old.dark != dark;
}
