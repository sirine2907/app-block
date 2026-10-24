import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'heart_logo.dart';

/// A soft circular portrait of Anis for the home screen.
///
/// Shows `assets/anis.jpg` if it's there — drop in his photo, or any cute
/// cartoon you'd rather use, at that path and it appears automatically. If the
/// file is missing the heart logo is shown instead, so the app always looks
/// finished.
class AnisPortrait extends StatelessWidget {
  const AnisPortrait({super.key, this.size = 170, this.asset = 'assets/anis.jpg'});

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.55), width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.rose.withValues(alpha: 0.25),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                asset,
                fit: BoxFit.cover,
                // No photo yet? Fall back to the heart mark.
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: scheme.surface,
                  child: Center(child: HeartLogo(size: size * 0.62)),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.favorite, color: AppColors.heart, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
