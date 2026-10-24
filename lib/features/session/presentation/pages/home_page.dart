import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/greeting.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/anis_portrait.dart';
import '../../../../injection_container.dart';
import '../../../apps/presentation/bloc/apps_bloc.dart';
import '../../../apps/presentation/pages/app_picker_page.dart';
import '../../../stats/presentation/pages/stats_page.dart';
import 'session_setup_page.dart';

/// The home screen Anis lands on: a warm greeting and the way into a session.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPicker(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => sl<AppsBloc>()..add(const AppsLoaded()),
          child: const AppPickerPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.insights_rounded),
                    tooltip: 'Your focus',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StatsPage(),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const AnisPortrait(size: 170),
                const SizedBox(height: 24),
                Text(
                  Greeting.now(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.displayMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ready to make Sirine proud?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.favorite),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SessionSetupPage(),
                      ),
                    ),
                    label: const Text('Start focusing, my love'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.apps_rounded),
                    onPressed: () => _openPicker(context),
                    label: const Text('Choose apps to block'),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
