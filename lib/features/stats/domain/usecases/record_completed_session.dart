import '../entities/focus_stats.dart';
import '../repositories/stats_repository.dart';

/// Records a finished session into the lifetime stats.
class RecordCompletedSession {
  const RecordCompletedSession(this._repository);

  final StatsRepository _repository;

  Future<FocusStats> call({required Duration duration, DateTime? day}) {
    return _repository.recordCompletedSession(
      duration: duration,
      day: day ?? DateTime.now(),
    );
  }
}
