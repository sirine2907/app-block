import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// A soft card that shows a love note "from Sirine", with a gentle fade when
/// the note changes.
class LoveNoteCard extends StatelessWidget {
  const LoveNoteCard({
    super.key,
    required this.note,
    this.signature = '— Sirine 💗',
    this.compact = false,
  });

  final String note;
  final String signature;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Card(
        key: ValueKey(note),
        child: Padding(
          padding: EdgeInsets.all(compact ? 18 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite, color: AppColors.heart, size: compact ? 20 : 26),
              SizedBox(height: compact ? 10 : 14),
              Text(
                note,
                textAlign: TextAlign.center,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: compact ? 20 : 24,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                signature,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
