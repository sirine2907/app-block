import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/session_state.dart';

/// Contract for starting and observing the cheat-proof focus session.
abstract class SessionRepository {
  /// A live stream of session snapshots from the native layer.
  Stream<SessionState> watch();

  /// The current session state, queried on demand (e.g. on app resume).
  Future<SessionState> current();

  /// Starts a session for [duration] that blocks [packages].
  ///
  /// Once started it cannot be cancelled; the only way out is to let the
  /// timer run down.
  Future<Either<Failure, Unit>> start({
    required Duration duration,
    required List<String> packages,
  });

  /// Acknowledges a finished session so native clears the pending flag.
  Future<void> acknowledgeCompletion();
}
