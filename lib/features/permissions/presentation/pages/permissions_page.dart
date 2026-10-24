import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_background.dart';
import '../../domain/permission.dart';
import '../bloc/permissions_cubit.dart';
import '../widgets/permission_info.dart';

/// The permission checklist. A session can't start until every item is green.
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key, this.onAllGranted});

  /// Called when the user continues with everything granted.
  final VoidCallback? onAllGranted;

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PermissionsCubit>().refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check whenever we come back from a system settings screen.
    if (state == AppLifecycleState.resumed) {
      context.read<PermissionsCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('A little setup')),
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PermissionsCubit, PermissionsState>(
            builder: (context, state) {
              if (!state.loaded) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      'For Anis needs a few permissions to keep your focus safe. '
                      'Here\'s exactly what each one does.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${state.grantedCount} of ${state.statuses.length} granted',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: state.statuses.length,
                      itemBuilder: (context, i) {
                        final status = state.statuses[i];
                        return _PermissionTile(status: status);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.allGranted
                            ? widget.onAllGranted
                            : null,
                        child: Text(
                          state.allGranted
                              ? 'All set — continue 💗'
                              : 'Grant everything to continue',
                        ),
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

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.status});

  final PermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = PermissionInfo.of(status.type);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(info.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(info.why, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 10),
                  if (status.granted)
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        Text('Granted', style: theme.textTheme.labelLarge),
                      ],
                    )
                  else
                    OutlinedButton(
                      onPressed: () =>
                          context.read<PermissionsCubit>().request(status.type),
                      child: const Text('Grant'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
