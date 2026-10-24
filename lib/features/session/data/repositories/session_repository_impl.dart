import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/platform/focus_channel.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/session_repository.dart';
import '../models/session_state_model.dart';

/// Talks to the native enforcement layer through [FocusChannel].
class SessionRepositoryImpl implements SessionRepository {
  SessionRepositoryImpl(this._channel);

  final FocusChannel _channel;

  @override
  Stream<SessionState> watch() =>
      _channel.sessionStateStream.map(SessionStateModel.fromMap);

  @override
  Future<SessionState> current() async {
    try {
      final map = await _channel.getState();
      return SessionStateModel.fromMap(map);
    } on PlatformException {
      return const SessionState.idle();
    }
  }

  @override
  Future<Either<Failure, Unit>> start({
    required Duration duration,
    required List<String> packages,
  }) async {
    try {
      final ok = await _channel.startSession(
        durationMs: duration.inMilliseconds,
        packages: packages,
      );
      if (!ok) {
        return const Left(PlatformFailure('Could not start the session.'));
      }
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(PlatformFailure(e.message ?? 'Could not start the session.'));
    }
  }

  @override
  Future<void> acknowledgeCompletion() async {
    try {
      await _channel.acknowledgeCompletion();
    } on PlatformException {
      // Non-fatal.
    }
  }
}
