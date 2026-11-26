import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_time_utils.dart';
import '../models/app_settings.dart';
import '../models/exercise.dart';
import '../models/reminder.dart';
import '../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import '../repositories/reminder_repository.dart';
import '../repositories/settings_repository.dart';
import '../seed/seed_data.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

final storageProvider = Provider<StorageService>(
  (ref) => StorageService.instance,
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(storageProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(storageProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(storageProvider)),
);

final exercisesProvider = Provider<List<Exercise>>(
  (ref) => SeedData.exercises,
);

final categoriesProvider = Provider<List<String>>(
  (ref) => SeedData.categoryNames,
);

class RemindersNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    return ref.watch(reminderRepositoryProvider).loadAll();
  }

  Future<void> upsert(Reminder reminder) async {
    final repository = ref.read(reminderRepositoryProvider);
    await repository.upsert(reminder);
    final updated = [
      ...state.where((item) => item.id != reminder.id),
      reminder,
    ]..sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    state = updated;
  }

  Future<void> remove(String id) async {
    final repository = ref.read(reminderRepositoryProvider);
    state = state.where((reminder) => reminder.id != id).toList();
    await repository.delete(id);
  }

  Future<void> restore(Reminder reminder) async {
    await upsert(reminder);
  }
}

final remindersProvider =
    NotifierProvider<RemindersNotifier, List<Reminder>>(
  RemindersNotifier.new,
);

class ProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() {
    return ref.watch(progressRepositoryProvider).load();
  }

  Future<bool> completeWorkout({
    required String sessionId,
    required int xp,
    required Duration duration,
    required int exerciseCount,
    DateTime? now,
  }) async {
    if (state.completedSessionIds.contains(sessionId)) return false;
    final repository = ref.read(progressRepositoryProvider);
    final updated = await repository.recordWorkout(
      sessionId: sessionId,
      xp: xp,
      duration: duration,
      exerciseCount: exerciseCount,
      now: now,
    );
    state = updated;
    return true;
  }

  bool get workedOutToday => ref
      .read(progressRepositoryProvider)
      .workedOutToday(state, DateTime.now());

  bool workedOutOn(DateTime date) {
    final last = state.stats.lastWorkoutDate;
    if (last == null) return false;
    return FlowDateUtils.isSameDay(last, date);
  }
}

final progressProvider =
    NotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);

final todayWorkoutProvider = Provider<bool>((ref) {
  final progress = ref.watch(progressProvider);
  final last = progress.stats.lastWorkoutDate;
  return last != null && FlowDateUtils.isSameDay(last, DateTime.now());
});

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await ref.read(settingsRepositoryProvider).save(updated);
    state = updated;
  }

  Future<void> setSmartReminders(bool enabled) async {
    final updated = state.copyWith(smartReminders: enabled);
    await ref.read(settingsRepositoryProvider).save(updated);
    state = updated;
  }
}

final settingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
