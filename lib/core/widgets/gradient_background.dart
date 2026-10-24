import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A soft vertical gradient wash that adapts to the current theme.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark ? AppColors.darkGradient : AppColors.lightGradient,
        ),
      ),
      child: child,
    );
  }
}
