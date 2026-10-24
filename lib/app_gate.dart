import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/session/domain/repositories/session_repository.dart';
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/session/presentation/pages/active_session_page.dart';
import 'features/session/presentation/pages/home_page.dart';
import 'features/session/presentation/pages/session_complete_page.dart';
import 'injection_container.dart';

/// Decides what the app shows at the root: an active session takes over the
/// whole screen; otherwise onboarding (first run) or the home screen. Also
/// watches for a finished session and shows the celebration.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> with WidgetsBindingObserver {
  late bool _onboardingDone;
  bool _showingCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _onboardingDone =
        sl<SharedPreferences>().getBool(AppConstants.keyOnboardingDone) ?? false;
    context.read<SessionBloc>().add(const SessionRefreshRequested());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<SessionBloc>().add(const SessionRefreshRequested());
    }
  }

  Future<void> _completeOnboarding() async {
    await sl<SharedPreferences>().setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) setState(() => _onboardingDone = true);
  }

  Future<void> _showCelebration(SessionUiState state) async {
    _showingCelebration = true;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => SessionCompletePage(
          message: state.celebrationMessage,
          completed: state.session.completedDuration,
          stats: state.lastCompletedStats,
          onContinue: () => Navigator.of(context).pop(),
        ),
      ),
    );
    // Acknowledge so native clears the pending flag, then reset UI.
    await sl<SessionRepository>().acknowledgeCompletion();
    if (mounted) {
      context.read<SessionBloc>().add(const SessionCompletionShown());
    }
    _showingCelebration = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionBloc, SessionUiState>(
      listenWhen: (prev, next) => prev.celebrate != next.celebrate,
      listener: (context, state) {
        if (state.celebrate && !_showingCelebration) {
          _showCelebration(state);
        }
      },
      builder: (context, state) {
        if (state.isActive) {
          return const ActiveSessionPage();
        }
        if (!_onboardingDone) {
          return OnboardingPage(onDone: _completeOnboarding);
        }
        return const HomePage();
      },
    );
  }
}
