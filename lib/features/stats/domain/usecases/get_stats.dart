import '../entities/focus_stats.dart';
import '../repositories/stats_repository.dart';

/// Reads the current lifetime stats.
class GetStats {
  const GetStats(this._repository);

  final StatsRepository _repository;

  Future<FocusStats> call() => _repository.getStats();
}
