import '../entities/session_state.dart';
import '../repositories/session_repository.dart';

/// Reads the current session state once (used on app launch / resume).
class GetSessionState {
  const GetSessionState(this._repository);

  final SessionRepository _repository;

  Future<SessionState> call() => _repository.current();
}
