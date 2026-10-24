import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../love_notes/domain/love_notes_repository.dart';
import '../../../stats/domain/entities/focus_stats.dart';
import '../../../stats/domain/usecases/record_completed_session.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/usecases/get_session_state.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/watch_session.dart';

part 'session_event.dart';
part 'session_state_ui.dart';

/// The heart of the app: coordinates the native enforcement layer, keeps the
/// countdown smooth, rotates love notes and records finished sessions into the
/// stats.
class SessionBloc extends Bloc<SessionEvent, SessionUiState> {
  SessionBloc({
    required StartSession startSession,
    required WatchSession watchSession,
    required GetSessionState getSessionState,
    required RecordCompletedSession recordCompletedSession,
    required LoveNotesRepository loveNotes,
  })  : _startSession = startSession,
        _getSessionState = getSessionState,
        _recordCompletedSession = recordCompletedSession,
        _loveNotes = loveNotes,
        super(const SessionUiState.initial()) {
    on<SessionStartRequested>(_onStart);
    on<SessionRefreshRequested>(_onRefresh);
    on<_SessionSnapshotReceived>(_onSnapshot);
    on<_SessionTicked>(_onTick);
    on<SessionNoteRotated>(_onNoteRotated);
    on<SessionCompletionShown>(_onCompletionShown);

    _subscription = watchSession().listen(
      (s) => add(_SessionSnapshotReceived(s)),
    );
  }

  final StartSession _startSession;
  final GetSessionState _getSessionState;
  final RecordCompletedSession _recordCompletedSession;
  final LoveNotesRepository _loveNotes;

  late final StreamSubscription<SessionState> _subscription;
  Timer? _ticker;

  // Anchor used to smooth the countdown between native updates.
  Duration _anchorRemaining = Duration.zero;
  DateTime _anchorAt = DateTime.now();
  bool _handlingCompletion = false;

  Future<void> _onStart(
    SessionStartRequested event,
    Emitter<SessionUiState> emit,
  ) async {
    emit(state.copyWith(starting: true, error: null));
    final result = await _startSession(
      duration: event.duration,
      packages: event.packages,
    );
    await result.fold(
      (failure) async =>
          emit(state.copyWith(starting: false, error: failure.message)),
      (_) async {
        final note = await _loveNotes.randomNote();
        emit(state.copyWith(starting: false, activeNote: note));
        add(const SessionRefreshRequested());
      },
    );
  }

  Future<void> _onRefresh(
    SessionRefreshRequested event,
    Emitter<SessionUiState> emit,
  ) async {
    final snapshot = await _getSessionState();
    add(_SessionSnapshotReceived(snapshot));
  }

  Future<void> _onSnapshot(
    _SessionSnapshotReceived event,
    Emitter<SessionUiState> emit,
  ) async {
    final snapshot = event.snapshot;
    _anchorRemaining = snapshot.remaining;
    _anchorAt = DateTime.now();

    // Ensure there's a note to show while active.
    var note = state.activeNote;
    if (snapshot.isActive && note.isEmpty) {
      note = await _loveNotes.randomNote();
    }

    emit(state.copyWith(session: snapshot, activeNote: note));

    if (snapshot.isActive) {
      _startTicker();
    } else {
      _stopTicker();
    }

    // A session finished while we weren't looking → celebrate + record.
    if (snapshot.hasPendingCompletion && !_handlingCompletion) {
      _handlingCompletion = true;
      final stats = await _recordCompletedSession(
        duration: snapshot.completedDuration,
      );
      final message = await _loveNotes.randomCompleteMessage();
      emit(state.copyWith(
        celebrate: true,
        celebrationMessage: message,
        lastCompletedStats: stats,
      ));
    }
  }

  void _onTick(_SessionTicked event, Emitter<SessionUiState> emit) {
    if (!state.isActive) return;
    final elapsed = DateTime.now().difference(_anchorAt);
    var remaining = _anchorRemaining - elapsed;
    if (remaining.isNegative) remaining = Duration.zero;
    emit(state.copyWith(
      session: SessionState(
        status: state.session.status,
        remaining: remaining,
        total: state.session.total,
        blockedPackages: state.session.blockedPackages,
      ),
    ));
  }

  Future<void> _onNoteRotated(
    SessionNoteRotated event,
    Emitter<SessionUiState> emit,
  ) async {
    final note = await _loveNotes.randomNote();
    emit(state.copyWith(activeNote: note));
  }

  void _onCompletionShown(
    SessionCompletionShown event,
    Emitter<SessionUiState> emit,
  ) {
    _handlingCompletion = false;
    emit(state.copyWith(celebrate: false));
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _SessionTicked()),
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _stopTicker();
    _subscription.cancel();
    return super.close();
  }
}
