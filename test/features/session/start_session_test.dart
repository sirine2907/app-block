import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/core/error/failures.dart';
import 'package:for_anis/features/session/domain/repositories/session_repository.dart';
import 'package:for_anis/features/session/domain/entities/session_state.dart';
import 'package:for_anis/features/session/domain/usecases/start_session.dart';

/// A tiny fake repository that records the last start call.
class _FakeSessionRepository implements SessionRepository {
  Duration? lastDuration;
  List<String>? lastPackages;
  Either<Failure, Unit> response = const Right(unit);

  @override
  Future<Either<Failure, Unit>> start({
    required Duration duration,
    required List<String> packages,
  }) async {
    lastDuration = duration;
    lastPackages = packages;
    return response;
  }

  @override
  Future<void> acknowledgeCompletion() async {}

  @override
  Future<SessionState> current() async => const SessionState.idle();

  @override
  Stream<SessionState> watch() => const Stream.empty();
}

void main() {
  late _FakeSessionRepository repo;
  late StartSession usecase;

  setUp(() {
    repo = _FakeSessionRepository();
    usecase = StartSession(repo);
  });

  test('rejects a session shorter than 15 minutes', () async {
    final result = await usecase(
      duration: const Duration(minutes: 10),
      packages: const ['com.instagram.android'],
    );
    expect(result.isLeft(), isTrue);
    result.fold((f) => expect(f, isA<ValidationFailure>()), (_) => fail('nope'));
    expect(repo.lastDuration, isNull); // never reached the repository
  });

  test('rejects a session longer than 8 hours', () async {
    final result = await usecase(
      duration: const Duration(hours: 9),
      packages: const ['com.instagram.android'],
    );
    expect(result.isLeft(), isTrue);
    result.fold((f) => expect(f, isA<ValidationFailure>()), (_) => fail('nope'));
  });

  test('rejects an empty app selection', () async {
    final result = await usecase(
      duration: const Duration(minutes: 30),
      packages: const [],
    );
    expect(result.isLeft(), isTrue);
  });

  test('accepts a valid session and forwards it to the repository', () async {
    final result = await usecase(
      duration: const Duration(hours: 1),
      packages: const ['com.instagram.android', 'com.x.android'],
    );
    expect(result.isRight(), isTrue);
    expect(repo.lastDuration, const Duration(hours: 1));
    expect(repo.lastPackages, ['com.instagram.android', 'com.x.android']);
  });

  test('accepts exactly the 8 hour maximum', () async {
    final result = await usecase(
      duration: const Duration(hours: 8),
      packages: const ['com.instagram.android'],
    );
    expect(result.isRight(), isTrue);
  });
}
