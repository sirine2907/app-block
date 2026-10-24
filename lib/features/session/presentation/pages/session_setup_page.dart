import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../injection_container.dart';
import '../../../apps/domain/usecases/get_blocked_selection.dart';
import '../bloc/session_bloc.dart';

/// Pick a duration (15 min – 8 h) and confirm an uncancellable session.
class SessionSetupPage extends StatefulWidget {
  const SessionSetupPage({super.key});

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  static const _min = 15;
  static const _max = 480; // 8 hours
  int _minutes = 45;
  List<String> _packages = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final packages = await sl<GetBlockedSelection>()();
    setState(() {
      _packages = packages;
      _loading = false;
    });
  }

  Duration get _duration => Duration(minutes: _minutes);

  Future<void> _confirmAndStart() async {
    if (_packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one app to block first.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Ready, my love?'),
        content: Text(
          'You\'re about to focus for ${DurationFormat.friendly(_duration)}.\n\n'
          'Once it starts, it can\'t be cancelled, ended early, or uninstalled. '
          'The only way out is to finish. I believe in you. 💗',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start focusing'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<SessionBloc>().add(
            SessionStartRequested(duration: _duration, packages: _packages),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<SessionBloc, SessionUiState>(
      listenWhen: (prev, next) =>
          prev.isActive != next.isActive || prev.error != next.error,
      listener: (context, state) {
        if (state.isActive) {
          Navigator.of(context).popUntil((r) => r.isFirst);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Set your focus')),
        body: GradientBackground(
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(),
                        Text('How long, Anis?',
                            style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 20),
                        Text(
                          DurationFormat.friendly(_duration),
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 52,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _minutes.toDouble(),
                          min: _min.toDouble(),
                          max: _max.toDouble(),
                          divisions: (_max - _min) ~/ 5,
                          label: DurationFormat.friendly(_duration),
                          onChanged: (v) =>
                              setState(() => _minutes = (v ~/ 5) * 5),
                        ),
                        Wrap(
                          spacing: 10,
                          children: [25, 45, 60, 120, 240]
                              .map((m) => ChoiceChip(
                                    label: Text(DurationFormat.friendly(
                                        Duration(minutes: m))),
                                    selected: _minutes == m,
                                    onSelected: (_) =>
                                        setState(() => _minutes = m),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: ListTile(
                            leading: Icon(Icons.block,
                                color: theme.colorScheme.primary),
                            title: Text(_packages.length == 1
                                ? '1 app will be blocked'
                                : '${_packages.length} apps will be blocked'),
                            subtitle: const Text(
                                'Edit the list from the home screen.'),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Minimum 15 minutes · maximum 8 hours',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<SessionBloc, SessionUiState>(
                            builder: (context, state) => ElevatedButton(
                              onPressed:
                                  state.starting ? null : _confirmAndStart,
                              child: state.starting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Start focusing, my love'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
