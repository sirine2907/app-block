import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/duration_format.dart';
import 'floating_hearts.dart';

/// The big circular countdown with floating hearts inside the ring.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.remaining,
    required this.progress,
    this.size = 280,
  });

  final Duration remaining;
  final double progress; // 0..1 completed
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: size - 28,
              height: size - 28,
              child: FloatingHearts(count: 10),
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              track: theme.colorScheme.primary.withValues(alpha: 0.15),
              ringStart: AppColors.heart,
              ringEnd: theme.colorScheme.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DurationFormat.clock(remaining),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFeatures: const [],
                  fontWeight: FontWeight.w600,
                  fontSize: 44,
                ),
              ),
              const SizedBox(height: 4),
              Text('left, my love', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.ringStart,
    required this.ringEnd,
  });

  final double progress;
  final Color track;
  final Color ringStart;
  final Color ringEnd;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final sweep = 2 * pi * progress.clamp(0.0, 1.0);
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [ringStart, ringEnd],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
