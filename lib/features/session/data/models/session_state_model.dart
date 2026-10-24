import '../../domain/entities/session_state.dart';

/// Maps the raw map coming from the native layer into a [SessionState].
class SessionStateModel {
  SessionStateModel._();

  static SessionState fromMap(Map<String, dynamic> map) {
    final statusStr = (map['status'] as String?) ?? 'idle';
    final status = switch (statusStr) {
      'active' => SessionStatus.active,
      'completed' => SessionStatus.completed,
      _ => SessionStatus.idle,
    };
    return SessionState(
      status: status,
      remaining: Duration(milliseconds: (map['remainingMs'] as num?)?.toInt() ?? 0),
      total: Duration(milliseconds: (map['totalMs'] as num?)?.toInt() ?? 0),
      blockedPackages: (map['packages'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      hasPendingCompletion: map['hasPendingCompletion'] == true,
      completedDuration:
          Duration(milliseconds: (map['completedDurationMs'] as num?)?.toInt() ?? 0),
    );
  }
}
