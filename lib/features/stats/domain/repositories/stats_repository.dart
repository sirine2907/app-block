import '../entities/focus_stats.dart';

/// Stores and exposes lifetime focus statistics.
abstract class StatsRepository {
  Future<FocusStats> getStats();

  Stream<FocusStats> watch();

  /// Records a completed session of [duration] finishing on [day].
  ///
  /// Updates totals, the completed count and the day streak.
  Future<FocusStats> recordCompletedSession({
    required Duration duration,
    required DateTime day,
  });
}
