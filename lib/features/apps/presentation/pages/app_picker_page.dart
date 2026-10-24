import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../domain/entities/installed_app.dart';
import '../bloc/apps_bloc.dart';

/// Lets Anis choose which apps a session will block. Selection is saved back
/// to preferences on confirm.
class AppPickerPage extends StatelessWidget {
  const AppPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps to block'),
        actions: [
          BlocBuilder<AppsBloc, AppsState>(
            builder: (context, state) => TextButton(
              onPressed: () {
                context.read<AppsBloc>().add(const SelectionSaved());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved 💗')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          top: false,
          child: BlocBuilder<AppsBloc, AppsState>(
            builder: (context, state) {
              if (state.status == AppsStatus.loading ||
                  state.status == AppsStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == AppsStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load your apps.\n${state.error ?? ''}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      onChanged: (q) =>
                          context.read<AppsBloc>().add(AppSearchChanged(q)),
                      decoration: InputDecoration(
                        hintText: 'Search apps',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.favorite, size: 18),
                          label: const Text('Social media'),
                          onPressed: () => context
                              .read<AppsBloc>()
                              .add(const SocialPresetApplied()),
                        ),
                        const SizedBox(width: 10),
                        ActionChip(
                          avatar: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear'),
                          onPressed: () => context
                              .read<AppsBloc>()
                              .add(const SelectionCleared()),
                        ),
                        const Spacer(),
                        Text(
                          '${state.selectedCount} selected',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: state.visibleApps.length,
                      itemBuilder: (context, i) {
                        final app = state.visibleApps[i];
                        final selected = state.selected.contains(app.packageName);
                        return _AppRow(
                          app: app,
                          selected: selected,
                          onTap: () => context
                              .read<AppsBloc>()
                              .add(AppToggled(app.packageName)),
                        );
                      },
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

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.app,
    required this.selected,
    required this.onTap,
  });

  final InstalledApp app;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 42,
        height: 42,
        child: app.icon != null
            ? Image.memory(app.icon!, gaplessPlayback: true)
            : CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
                ),
              ),
      ),
      title: Text(app.appName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        app.packageName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Checkbox(
        value: selected,
        onChanged: (_) => onTap(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
