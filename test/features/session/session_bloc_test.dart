import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/core/error/failures.dart';
import 'package:for_anis/features/love_notes/domain/love_notes.dart';
import 'package:for_anis/features/love_notes/domain/love_notes_repository.dart';
import 'package:for_anis/features/session/domain/entities/session_state.dart';
import 'package:for_anis/features/session/domain/repositories/session_repository.dart';
import 'package:for_anis/features/session/domain/usecases/get_session_state.dart';
import 'package:for_anis/features/session/domain/usecases/start_session.dart';
import 'package:for_anis/features/session/domain/usecases/watch_session.dart';
import 'package:for_anis/features/session/presentation/bloc/session_bloc.dart';
import 'package:for_anis/features/stats/domain/entities/focus_stats.dart';
import 'package:for_anis/features/stats/domain/repositories/stats_repository.dart';
import 'package:for_anis/features/stats/domain/usecases/record_completed_session.dart';

class _FakeSessionRepository implements SessionRepository {
  final _controller = StreamController<SessionState>.broadcast();
  SessionState state = const SessionState.idle();

  void push(SessionState s) {
    state = s;
    _controller.add(s);
  }

  @override
  Stream<SessionState> watch() => _controller.stream;

  @override
  Future<SessionState> current() async => state;

  @override
  Future<Either<Failure, Unit>> start({
    required Duration duration,
    required List<String> packages,
  }) async {
    state = SessionState(
      status: SessionStatus.active,
      remaining: duration,
      total: duration,
      blockedPackages: packages,
    );
    return const Right(unit);
  }

  @override
  Future<void> acknowledgeCompletion() async {}

  void dispose() => _controller.close();
}

class _FakeStatsRepository implements StatsRepository {
  int recordCalls = 0;
  Duration? recordedDuration;

  @override
  Future<FocusStats> getStats() async => FocusStats.empty;

  @override
  Stream<FocusStats> watch() => const Stream.empty();

  @override
  Future<FocusStats> recordCompletedSession({
    required Duration duration,
    required DateTime day,
  }) async {
    recordCalls++;
    recordedDuration = duration;
    return FocusStats(
      totalFocus: duration,
      sessionsCompleted: 1,
      currentStreak: 1,
      longestStreak: 1,
    );
  }
}

class _FakeLoveNotes implements LoveNotesRepository {
  @override
  Future<LoveNotes> load() async => const LoveNotes(
        signature: '— Sirine',
        notes: ['keep going'],
        sessionComplete: ['you did it'],
        milestones: {},
      );

  @override
  Future<String> randomNote() async => 'keep going';

  @override
  Future<String> randomCompleteMessage() async => 'you did it';

  @override
  Future<String> signature() async => '— Sirine';
}

void main() {
  late _FakeSessionRepository session;
  late _FakeStatsRepository stats;
  late SessionBloc bloc;

  setUp(() {
    session = _FakeSessionRepository();
    stats = _FakeStatsRepository();
    bloc = SessionBloc(
      startSession: StartSession(session),
      watchSession: WatchSession(session),
      getSessionState: GetSessionState(session),
      recordCompletedSession: RecordCompletedSession(stats),
      loveNotes: _FakeLoveNotes(),
    );
  });

  tearDown(() async {
    await bloc.close();
    session.dispose();
  });

  test('starting a valid session becomes active with a love note', () async {
    bloc.add(SessionStartRequested(
      duration: const Duration(minutes: 30),
      packages: const ['com.instagram.android'],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(bloc.state.isActive, isTrue);
    expect(bloc.state.starting, isFalse);
    expect(bloc.state.activeNote, 'keep going');
  });

  test('a pending completion snapshot records stats and celebrates', () async {
    session.push(const SessionState(
      status: SessionStatus.completed,
      hasPendingCompletion: true,
      completedDuration: Duration(minutes: 45),
    ));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(stats.recordCalls, 1);
    expect(stats.recordedDuration, const Duration(minutes: 45));
    expect(bloc.state.celebrate, isTrue);
    expect(bloc.state.celebrationMessage, 'you did it');
    expect(bloc.state.lastCompletedStats?.sessionsCompleted, 1);
  });

  test('completion is only recorded once per pending flag', () async {
    const snap = SessionState(
      status: SessionStatus.completed,
      hasPendingCompletion: true,
      completedDuration: Duration(minutes: 20),
    );
    session.push(snap);
    session.push(snap);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(stats.recordCalls, 1);
  });
}
