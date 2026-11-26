import 'date_time_utils.dart';

abstract final class StatsEngine {
  static const int xpPerExercise = 40;

  static int xpForSession(int completedExercises) {
    if (completedExercises <= 0) return 0;
    return completedExercises * xpPerExercise;
  }

  static int nextStreak({
    required int currentStreak,
    required DateTime? lastWorkout,
    required DateTime now,
  }) {
    if (lastWorkout == null) return 1;
    final today = FlowDateUtils.dayOnly(now);
    final last = FlowDateUtils.dayOnly(lastWorkout);
    final difference = today.difference(last).inDays;
    if (difference == 0) return currentStreak == 0 ? 1 : currentStreak;
    if (difference == 1) return currentStreak + 1;
    if (difference < 0) return currentStreak;
    return 1;
  }

  static double nextProgramProgress({
    required double current,
    required int exerciseCount,
  }) {
    if (exerciseCount <= 0) return current.clamp(0.0, 1.0);
    return (current + (1 / exerciseCount)).clamp(0.0, 1.0);
  }

  static int programExerciseIndex({
    required double progress,
    required int exerciseCount,
  }) {
    if (exerciseCount <= 0) return 0;
    final raw = (progress * exerciseCount).floor();
    return raw.clamp(0, exerciseCount - 1);
  }
}
