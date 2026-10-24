import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/floating_hearts.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/heart_logo.dart';
import '../../../stats/domain/entities/focus_stats.dart';

/// The celebratory screen shown when a session finishes.
class SessionCompletePage extends StatelessWidget {
  const SessionCompletePage({
    super.key,
    required this.message,
    required this.completed,
    required this.stats,
    required this.onContinue,
  });

  final String message;
  final Duration completed;
  final FocusStats? stats;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: GradientBackground(child: SizedBox())),
            const Positioned.fill(child: FloatingHearts(count: 18)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeartLogo(size: 120),
                    const SizedBox(height: 28),
                    Text(
                      'You did it 💗',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 44,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.displayMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You focused for ${DurationFormat.friendly(completed)}.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    if (stats != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        '${stats!.sessionsCompleted} '
                        '${stats!.sessionsCompleted == 1 ? 'session' : 'sessions'} · '
                        '${DurationFormat.hours(stats!.totalFocus)} total',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        child: const Text('Thank you, Sirine 💗'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
