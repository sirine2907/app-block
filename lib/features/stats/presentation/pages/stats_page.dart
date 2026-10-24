import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../bloc/stats_cubit.dart';

/// Lifetime focus stats with sweet milestone messages.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your focus')),
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<StatsCubit, StatsState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final s = state.stats;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.schedule,
                          value: DurationFormat.hours(s.totalFocus),
                          label: 'focused',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.check_circle_outline,
                          value: '${s.sessionsCompleted}',
                          label: s.sessionsCompleted == 1 ? 'session' : 'sessions',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.local_fire_department,
                          value: '${s.currentStreak}',
                          label: 'day streak',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.emoji_events_outlined,
                          value: '${s.longestStreak}',
                          label: 'best streak',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Milestones', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (state.milestones.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Finish your first session to unlock a little note '
                          'from me. 💗',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    )
                  else
                    ...state.milestones.map(
                      (m) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.favorite,
                              color: Color(0xFFE8738F)),
                          title: Text(m.title,
                              style: theme.textTheme.titleLarge),
                          subtitle: Text(m.message),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
