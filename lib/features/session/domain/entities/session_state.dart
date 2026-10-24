import 'package:equatable/equatable.dart';

/// Where a focus session is in its lifecycle.
enum SessionStatus { idle, active, completed }

/// A snapshot of the session as reported by the native enforcement layer.
///
/// The native side is the source of truth: it owns the cheat-proof timer and
/// streams these snapshots up to Flutter. The UI only renders them.
class SessionState extends Equatable {
  const SessionState({
    required this.status,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
    this.blockedPackages = const [],
    this.hasPendingCompletion = false,
    this.completedDuration = Duration.zero,
  });

  final SessionStatus status;

  /// Time left in an active session.
  final Duration remaining;

  /// The total length the session was started with.
  final Duration total;

  final List<String> blockedPackages;

  /// True when a session finished while the UI wasn't watching and the
  /// celebration screen still needs to be shown.
  final bool hasPendingCompletion;

  /// The length of the session tied to [hasPendingCompletion].
  final Duration completedDuration;

  bool get isActive => status == SessionStatus.active;

  /// How far through the session we are, 0..1, for the countdown ring.
  double get progress {
    if (total.inMilliseconds <= 0) return 0;
    final done = total.inMilliseconds - remaining.inMilliseconds;
    return (done / total.inMilliseconds).clamp(0.0, 1.0);
  }

  const SessionState.idle() : this(status: SessionStatus.idle);

  @override
  List<Object?> get props => [
        status,
        remaining,
        total,
        blockedPackages,
        hasPendingCompletion,
        completedDuration,
      ];
}
