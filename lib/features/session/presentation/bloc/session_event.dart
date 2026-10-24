part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Start a new, uncancellable session.
class SessionStartRequested extends SessionEvent {
  const SessionStartRequested({required this.duration, required this.packages});

  final Duration duration;
  final List<String> packages;

  @override
  List<Object?> get props => [duration, packages];
}

/// Re-query native state (on app launch / resume).
class SessionRefreshRequested extends SessionEvent {
  const SessionRefreshRequested();
}

/// Internal: a fresh snapshot arrived from the native stream.
class _SessionSnapshotReceived extends SessionEvent {
  const _SessionSnapshotReceived(this.snapshot);

  final SessionState snapshot;

  @override
  List<Object?> get props => [snapshot];
}

/// Internal: the one-second ticker fired (smooths the countdown).
class _SessionTicked extends SessionEvent {
  const _SessionTicked();
}

/// Rotate to a new love note on the active screen.
class SessionNoteRotated extends SessionEvent {
  const SessionNoteRotated();
}

/// The completion screen has been shown; clear the celebratory flag.
class SessionCompletionShown extends SessionEvent {
  const SessionCompletionShown();
}
