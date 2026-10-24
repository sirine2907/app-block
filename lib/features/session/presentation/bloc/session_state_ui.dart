part of 'session_bloc.dart';

/// UI-facing session state: wraps the domain [SessionState] with presentation
/// concerns (the current love note, a pending celebration, errors).
class SessionUiState extends Equatable {
  const SessionUiState({
    required this.session,
    this.starting = false,
    this.activeNote = '',
    this.celebrate = false,
    this.celebrationMessage = '',
    this.lastCompletedStats,
    this.error,
  });

  const SessionUiState.initial()
      : session = const SessionState.idle(),
        starting = false,
        activeNote = '',
        celebrate = false,
        celebrationMessage = '',
        lastCompletedStats = null,
        error = null;

  final SessionState session;
  final bool starting;
  final String activeNote;

  /// True when a session just finished and the celebration screen is due.
  final bool celebrate;
  final String celebrationMessage;

  /// Stats snapshot right after recording the finished session.
  final FocusStats? lastCompletedStats;
  final String? error;

  bool get isActive => session.isActive;
  Duration get remaining => session.remaining;
  double get progress => session.progress;

  SessionUiState copyWith({
    SessionState? session,
    bool? starting,
    String? activeNote,
    bool? celebrate,
    String? celebrationMessage,
    FocusStats? lastCompletedStats,
    String? error,
  }) {
    return SessionUiState(
      session: session ?? this.session,
      starting: starting ?? this.starting,
      activeNote: activeNote ?? this.activeNote,
      celebrate: celebrate ?? this.celebrate,
      celebrationMessage: celebrationMessage ?? this.celebrationMessage,
      lastCompletedStats: lastCompletedStats ?? this.lastCompletedStats,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        session,
        starting,
        activeNote,
        celebrate,
        celebrationMessage,
        lastCompletedStats,
        error,
      ];
}
