import '../entities/session_state.dart';
import '../repositories/session_repository.dart';

/// Streams live session snapshots from the native layer.
class WatchSession {
  const WatchSession(this._repository);

  final SessionRepository _repository;

  Stream<SessionState> call() => _repository.watch();
}
