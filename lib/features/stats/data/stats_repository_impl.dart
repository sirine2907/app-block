import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/entities/focus_stats.dart';
import '../domain/repositories/stats_repository.dart';

/// Stores lifetime stats in [SharedPreferences] and notifies listeners.
class StatsRepositoryImpl implements StatsRepository {
  StatsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  final _controller = StreamController<FocusStats>.broadcast();

  @override
  Future<FocusStats> getStats() async => _read();

  @override
  Stream<FocusStats> watch() => _controller.stream;

  FocusStats _read() {
    return FocusStats(
      totalFocus:
          Duration(milliseconds: _prefs.getInt(AppConstants.keyTotalFocusMs) ?? 0),
      sessionsCompleted: _prefs.getInt(AppConstants.keySessionsCompleted) ?? 0,
      currentStreak: _prefs.getInt(AppConstants.keyCurrentStreak) ?? 0,
      longestStreak: _prefs.getInt(AppConstants.keyLongestStreak) ?? 0,
    );
  }

  @override
  Future<FocusStats> recordCompletedSession({
    required Duration duration,
    required DateTime day,
  }) async {
    final current = _read();
    final newTotal = current.totalFocus + duration;
    final newCount = current.sessionsCompleted + 1;

    final today = _dayIndex(day);
    final lastDay = _prefs.getInt(AppConstants.keyLastSessionDay);
    int streak;
    if (lastDay == null) {
      streak = 1;
    } else if (today == lastDay) {
      // Another session the same day keeps today's streak (never below 1).
      streak = current.currentStreak < 1 ? 1 : current.currentStreak;
    } else if (today == lastDay + 1) {
      streak = current.currentStreak + 1;
    } else {
      streak = 1;
    }
    final longest =
        streak > current.longestStreak ? streak : current.longestStreak;

    await _prefs.setInt(AppConstants.keyTotalFocusMs, newTotal.inMilliseconds);
    await _prefs.setInt(AppConstants.keySessionsCompleted, newCount);
    await _prefs.setInt(AppConstants.keyCurrentStreak, streak);
    await _prefs.setInt(AppConstants.keyLongestStreak, longest);
    await _prefs.setInt(AppConstants.keyLastSessionDay, today);

    final updated = FocusStats(
      totalFocus: newTotal,
      sessionsCompleted: newCount,
      currentStreak: streak,
      longestStreak: longest,
    );
    _controller.add(updated);
    return updated;
  }

  /// Number of whole days since the Unix epoch for the date part of [date].
  int _dayIndex(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    return local.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  }

  void dispose() => _controller.close();
}
