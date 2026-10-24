import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../repositories/session_repository.dart';

/// Validates a requested session and hands it to the repository to start.
///
/// Enforces the hard limits: at least 15 minutes, at most 8 hours, and at
/// least one app selected.
class StartSession {
  const StartSession(this._repository);

  final SessionRepository _repository;

  Future<Either<Failure, Unit>> call({
    required Duration duration,
    required List<String> packages,
  }) async {
    if (duration < AppConstants.minSessionDuration) {
      return const Left(
        ValidationFailure('A session must be at least 15 minutes.'),
      );
    }
    if (duration > AppConstants.maxSessionDuration) {
      return const Left(
        ValidationFailure('A session can be at most 8 hours.'),
      );
    }
    if (packages.isEmpty) {
      return const Left(
        ValidationFailure('Choose at least one app to block first.'),
      );
    }
    return _repository.start(duration: duration, packages: packages);
  }
}
