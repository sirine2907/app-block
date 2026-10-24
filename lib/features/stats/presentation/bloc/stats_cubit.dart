import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../love_notes/domain/love_notes_repository.dart';
import '../../domain/entities/focus_stats.dart';
import '../../domain/usecases/get_stats.dart';
import '../../domain/repositories/stats_repository.dart';

/// A milestone the user has reached, with its sweet message.
class Milestone extends Equatable {
  const Milestone(this.title, this.message);

  final String title;
  final String message;

  @override
  List<Object?> get props => [title, message];
}

class StatsState extends Equatable {
  const StatsState({
    this.loading = true,
    this.stats = FocusStats.empty,
    this.milestones = const [],
  });

  final bool loading;
  final FocusStats stats;
  final List<Milestone> milestones;

  StatsState copyWith({
    bool? loading,
    FocusStats? stats,
    List<Milestone>? milestones,
  }) {
    return StatsState(
      loading: loading ?? this.loading,
      stats: stats ?? this.stats,
      milestones: milestones ?? this.milestones,
    );
  }

  @override
  List<Object?> get props => [loading, stats, milestones];
}

/// Loads stats, listens for updates, and derives milestone messages.
class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    required GetStats getStats,
    required StatsRepository repository,
    required LoveNotesRepository loveNotes,
  })  : _getStats = getStats,
        _repository = repository,
        _loveNotes = loveNotes,
        super(const StatsState()) {
    _subscription = _repository.watch().listen(_apply);
  }

  final GetStats _getStats;
  final StatsRepository _repository;
  final LoveNotesRepository _loveNotes;
  late final StreamSubscription<FocusStats> _subscription;

  Future<void> load() async {
    final stats = await _getStats();
    await _apply(stats);
  }

  Future<void> _apply(FocusStats stats) async {
    final notes = await _loveNotes.load();
    final m = notes.milestones;
    final reached = <Milestone>[];

    void addIf(bool cond, String key, String title) {
      if (cond && m.containsKey(key)) {
        reached.add(Milestone(title, m[key]!));
      }
    }

    final hours = stats.totalFocus.inMinutes / 60.0;
    addIf(stats.sessionsCompleted >= 1, 'first_session', 'First session');
    addIf(hours >= 5, '5_hours', '5 hours');
    addIf(hours >= 10, '10_hours', '10 hours');
    addIf(hours >= 25, '25_hours', '25 hours');
    addIf(hours >= 50, '50_hours', '50 hours');
    addIf(stats.longestStreak >= 7, '7_day_streak', '7-day streak');

    emit(state.copyWith(loading: false, stats: stats, milestones: reached));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
