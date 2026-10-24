import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/features/stats/data/stats_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StatsRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = StatsRepositoryImpl(prefs);
  });

  test('starts empty', () async {
    final stats = await repo.getStats();
    expect(stats.sessionsCompleted, 0);
    expect(stats.totalFocus, Duration.zero);
    expect(stats.currentStreak, 0);
  });

  test('records a completed session and starts a streak at 1', () async {
    final day = DateTime(2026, 1, 1);
    final stats = await repo.recordCompletedSession(
      duration: const Duration(minutes: 45),
      day: day,
    );
    expect(stats.sessionsCompleted, 1);
    expect(stats.totalFocus, const Duration(minutes: 45));
    expect(stats.currentStreak, 1);
    expect(stats.longestStreak, 1);
  });

  test('consecutive days grow the streak', () async {
    await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 1),
    );
    final d2 = await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 2),
    );
    expect(d2.currentStreak, 2);
    final d3 = await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 3),
    );
    expect(d3.currentStreak, 3);
    expect(d3.longestStreak, 3);
    expect(d3.totalFocus, const Duration(hours: 3));
  });

  test('a second session the same day does not grow the streak', () async {
    await repo.recordCompletedSession(
      duration: const Duration(minutes: 30),
      day: DateTime(2026, 1, 1, 9),
    );
    final again = await repo.recordCompletedSession(
      duration: const Duration(minutes: 30),
      day: DateTime(2026, 1, 1, 18),
    );
    expect(again.currentStreak, 1);
    expect(again.sessionsCompleted, 2);
  });

  test('a gap resets the streak but keeps the longest', () async {
    await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 1),
    );
    await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 2),
    );
    final afterGap = await repo.recordCompletedSession(
      duration: const Duration(hours: 1),
      day: DateTime(2026, 1, 10),
    );
    expect(afterGap.currentStreak, 1);
    expect(afterGap.longestStreak, 2);
  });

  test('emits updates on the watch stream', () async {
    expectLater(repo.watch(), emits(predicate((dynamic s) => true)));
    await repo.recordCompletedSession(
      duration: const Duration(minutes: 20),
      day: DateTime(2026, 1, 1),
    );
  });
}
