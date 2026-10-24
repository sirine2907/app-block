import 'package:equatable/equatable.dart';

/// Lifetime focus statistics, with sweet milestone copy derived from them.
class FocusStats extends Equatable {
  const FocusStats({
    this.totalFocus = Duration.zero,
    this.sessionsCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  final Duration totalFocus;
  final int sessionsCompleted;
  final int currentStreak;
  final int longestStreak;

  static const FocusStats empty = FocusStats();

  @override
  List<Object?> get props => [
        totalFocus,
        sessionsCompleted,
        currentStreak,
        longestStreak,
      ];
}
