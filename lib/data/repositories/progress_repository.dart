import '../../core/utils/date_time_utils.dart';
import '../../core/utils/stats_engine.dart';
import '../models/user_progress.dart';
import '../models/user_stats.dart';
import '../services/storage_service.dart';

class ProgressRepository {
  ProgressRepository(this._storage);

  final StorageService _storage;

  UserProgress load() => _storage.loadProgress();

  Future<UserProgress> recordWorkout({
    required String sessionId,
    required int xp,
    required Duration duration,
    required int exerciseCount,
    DateTime? now,
  }) async {
    final current = load();
    if (current.completedSessionIds.contains(sessionId)) {
      return current;
    }
    final timestamp = now ?? DateTime.now();

    final stats = current.stats;
    final nextStreak = StatsEngine.nextStreak(
      currentStreak: stats.streak,
      lastWorkout: stats.lastWorkoutDate,
      now: timestamp,
    );
    final addedMinutes = duration.inSeconds <= 0
        ? 0
        : (duration.inSeconds / 60).ceil();
    final updatedStats = UserStats(
      xp: stats.xp + xp,
      streak: nextStreak,
      totalMinutes: stats.totalMinutes + addedMinutes,
      lastWorkoutDate: timestamp,
    );

    final program = current.program;
    final updatedProgram = program.copyWith(
      progress: StatsEngine.nextProgramProgress(
        current: program.progress,
        exerciseCount: exerciseCount,
      ),
      currentDay: (program.currentDay + 1).clamp(1, program.days),
    );

    final sessions = <String>[
      ...current.completedSessionIds,
      sessionId,
    ];
    final trimmed = sessions.length > 50
        ? sessions.sublist(sessions.length - 50)
        : sessions;

    final updated = UserProgress(
      stats: updatedStats,
      program: updatedProgram,
      completedSessionIds: trimmed,
    );
    await _storage.saveProgress(updated);
    return updated;
  }

  bool workedOutToday(UserProgress progress, DateTime now) {
    final last = progress.stats.lastWorkoutDate;
    if (last == null) return false;
    return FlowDateUtils.isSameDay(last, now);
  }
}
