import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/countdown_ring.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../core/widgets/love_note_card.dart';
import '../../../../injection_container.dart';
import '../../../permissions/domain/permission.dart';
import '../../../permissions/domain/permissions_repository.dart';
import '../bloc/session_bloc.dart';

/// The active-session screen. There is intentionally no way to stop a session
/// here — no cancel button, and the system back button is swallowed.
class ActiveSessionPage extends StatefulWidget {
  const ActiveSessionPage({super.key});

  @override
  State<ActiveSessionPage> createState() => _ActiveSessionPageState();
}

class _ActiveSessionPageState extends State<ActiveSessionPage>
    with WidgetsBindingObserver {
  Timer? _noteTimer;
  bool _accessibilityOff = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Rotate the love note every few minutes.
    _noteTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => context.read<SessionBloc>().add(const SessionNoteRotated()),
    );
    _checkAccessibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAccessibility();
  }

  /// Blocking relies on the Accessibility Service, which Android disables when
  /// the app is updated. If it's off, warn loudly so a session isn't silently
  /// unprotected.
  Future<void> _checkAccessibility() async {
    final statuses = await sl<PermissionsRepository>().checkAll();
    final acc = statuses
        .firstWhere((s) => s.type == PermissionType.accessibility)
        .granted;
    if (mounted) setState(() => _accessibilityOff = !acc);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: BlocBuilder<SessionBloc, SessionUiState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      Text('Focusing', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Stay with it. I\'m right here.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (_accessibilityOff) ...[
                        const SizedBox(height: 16),
                        _AccessibilityWarning(onFix: () async {
                          await sl<PermissionsRepository>()
                              .request(PermissionType.accessibility);
                        }),
                      ],
                      const SizedBox(height: 28),
                      CountdownRing(
                        remaining: state.remaining,
                        progress: state.progress,
                      ),
                      const SizedBox(height: 28),
                      LoveNoteCard(note: state.activeNote),
                      const SizedBox(height: 24),
                      _BlockedList(packages: state.session.blockedPackages),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded,
                              size: 16, color: theme.textTheme.bodySmall?.color),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'This session can\'t be stopped early — '
                              'and that\'s exactly why it works.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown during a session if the Accessibility Service has been turned off,
/// since blocking can't work without it.
class _AccessibilityWarning extends StatelessWidget {
  const _AccessibilityWarning({required this.onFix});

  final Future<void> Function() onFix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFF9A6A00)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The Accessibility Service is off, so blocking is slower '
                    'to react. Turn it back on for instant blocking.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onFix,
                child: const Text('Turn it back on'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockedList extends StatelessWidget {
  const _BlockedList({required this.packages});

  final List<String> packages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (packages.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                    packages.length == 1
                        ? '1 app resting'
                        : '${packages.length} apps resting',
                    style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'They\'ll be here when you\'re done.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
