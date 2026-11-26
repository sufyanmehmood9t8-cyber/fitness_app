import 'package:fitness_app/core/utils/stats_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XP', () {
    test('awards forty XP per completed exercise', () {
      expect(StatsEngine.xpForSession(0), 0);
      expect(StatsEngine.xpForSession(1), 40);
      expect(StatsEngine.xpForSession(3), 120);
    });
  });

  group('streak', () {
    final now = DateTime(2026, 10, 26, 9);

    test('starts at one after the first workout', () {
      expect(
        StatsEngine.nextStreak(
          currentStreak: 0,
          lastWorkout: null,
          now: now,
        ),
        1,
      );
    });

    test('keeps the streak for a second workout on the same day', () {
      expect(
        StatsEngine.nextStreak(
          currentStreak: 4,
          lastWorkout: DateTime(2026, 10, 26, 7),
          now: now,
        ),
        4,
      );
    });

    test('increments for consecutive days', () {
      expect(
        StatsEngine.nextStreak(
          currentStreak: 4,
          lastWorkout: DateTime(2026, 10, 25, 20),
          now: now,
        ),
        5,
      );
    });

    test('resets after a missed day', () {
      expect(
        StatsEngine.nextStreak(
          currentStreak: 8,
          lastWorkout: DateTime(2026, 10, 23, 20),
          now: now,
        ),
        1,
      );
    });
  });

  group('program', () {
    test('advances by one exercise and caps at one', () {
      expect(
        StatsEngine.nextProgramProgress(current: 0.4, exerciseCount: 5),
        closeTo(0.6, 0.0001),
      );
      expect(
        StatsEngine.nextProgramProgress(current: 0.95, exerciseCount: 5),
        1,
      );
      expect(
        StatsEngine.nextProgramProgress(current: 0.5, exerciseCount: 0),
        0.5,
      );
    });

    test('finds the current exercise index', () {
      expect(
        StatsEngine.programExerciseIndex(
          progress: 0.4,
          exerciseCount: 5,
        ),
        2,
      );
      expect(
        StatsEngine.programExerciseIndex(
          progress: 1,
          exerciseCount: 5,
        ),
        4,
      );
    });
  });
}
