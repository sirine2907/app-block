import 'package:equatable/equatable.dart';

/// Base class for all recoverable errors surfaced to the UI.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Something went wrong talking to the native Android layer.
class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

/// A value the user supplied was out of range (e.g. duration too long).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Reading or writing local storage failed.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
