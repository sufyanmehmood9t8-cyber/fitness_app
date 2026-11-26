import 'package:hive_flutter/hive_flutter.dart';

import '../models/program.dart';
import '../models/reminder.dart';
import '../models/user_progress.dart';
import '../models/user_stats.dart';
import '../seed/seed_data.dart';

class StorageService {
  StorageService._(
    this._remindersBox,
    this._progressBox,
    this._settingsBox,
  );

  static StorageService? _instance;
  static StorageService get instance {
    final value = _instance;
    if (value == null) {
      throw StateError('StorageService has not been initialized.');
    }
    return value;
  }

  final Box<dynamic> _remindersBox;
  final Box<dynamic> _progressBox;
  final Box<dynamic> _settingsBox;

  static Future<StorageService> initialize({String? hivePath}) async {
    if (hivePath == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(hivePath);
    }
    final reminders = await Hive.openBox<dynamic>('flow_reminders_v1');
    final progress = await Hive.openBox<dynamic>('flow_progress_v1');
    final settings = await Hive.openBox<dynamic>('flow_settings_v1');
    final service = StorageService._(reminders, progress, settings);
    _instance = service;
    await service._seedProgressIfNeeded();
    return service;
  }

  Future<void> _seedProgressIfNeeded() async {
    if (_progressBox.containsKey('progress')) return;
    final now = DateTime.now();
    final initial = UserProgress(
      stats: UserStats(
        xp: 120,
        streak: 2,
        totalMinutes: 36,
        lastWorkoutDate: now.subtract(const Duration(days: 1)),
      ),
      program: const Program(
        id: 'flexibility-foundation',
        name: 'Flexibility Foundation',
        days: 30,
        currentDay: 4,
        progress: 0.4,
        exerciseIds: SeedData.programIds,
      ),
      completedSessionIds: const <String>[],
    );
    await _progressBox.put('progress', initial.toJson());
  }

  List<Reminder> loadReminders() {
    final result = <Reminder>[];
    for (final value in _remindersBox.values) {
      if (value is Map) {
        try {
          result.add(
            Reminder.fromJson(Map<String, dynamic>.from(value)),
          );
        } catch (_) {
          // Skip a single corrupt record rather than breaking the list.
        }
      }
    }
    result.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    return result;
  }

  Future<void> saveReminder(Reminder reminder) async {
    await _remindersBox.put(reminder.id, reminder.toJson());
  }

  Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  UserProgress loadProgress() {
    final value = _progressBox.get('progress');
    if (value is Map) {
      try {
        return UserProgress.fromJson(Map<String, dynamic>.from(value));
      } catch (_) {}
    }
    return UserProgress(
      stats: const UserStats(xp: 0, streak: 0, totalMinutes: 0),
      program: const Program(
        id: 'flexibility-foundation',
        name: 'Flexibility Foundation',
        days: 30,
        currentDay: 1,
        progress: 0,
        exerciseIds: SeedData.programIds,
      ),
      completedSessionIds: const <String>[],
    );
  }

  Future<void> saveProgress(UserProgress progress) async {
    await _progressBox.put('progress', progress.toJson());
  }

  bool get notificationsEnabled =>
      _settingsBox.get('notificationsEnabled', defaultValue: true) as bool;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox.put('notificationsEnabled', enabled);
  }

  bool get smartReminders =>
      _settingsBox.get('smartReminders', defaultValue: false) as bool;

  Future<void> setSmartReminders(bool enabled) async {
    await _settingsBox.put('smartReminders', enabled);
  }

  bool get notificationsPrompted =>
      _settingsBox.get('notificationsPrompted', defaultValue: false) as bool;

  Future<void> markNotificationsPrompted() async {
    await _settingsBox.put('notificationsPrompted', true);
  }

  String? get lastInAppReminderKey =>
      _settingsBox.get('lastInAppReminderKey') as String?;

  Future<void> setLastInAppReminderKey(String key) async {
    await _settingsBox.put('lastInAppReminderKey', key);
  }

  bool get onboardingDone =>
      _settingsBox.get('onboardingDone', defaultValue: false) as bool;

  Future<void> setOnboardingDone(bool value) async {
    await _settingsBox.put('onboardingDone', value);
  }

  bool get assessmentDone =>
      _settingsBox.get('assessmentDone', defaultValue: false) as bool;

  Future<void> setAssessmentDone(bool value) async {
    await _settingsBox.put('assessmentDone', value);
  }

  bool get assessmentSkipped =>
      _settingsBox.get('assessmentSkipped', defaultValue: false) as bool;

  Future<void> setAssessmentSkipped(bool value) async {
    await _settingsBox.put('assessmentSkipped', value);
  }

  bool get goalsDone =>
      _settingsBox.get('goalsDone', defaultValue: false) as bool;

  Future<void> setGoalsDone(bool value) async {
    await _settingsBox.put('goalsDone', value);
  }

  bool get goalsSkipped =>
      _settingsBox.get('goalsSkipped', defaultValue: false) as bool;

  Future<void> setGoalsSkipped(bool value) async {
    await _settingsBox.put('goalsSkipped', value);
  }

  String get userName =>
      (_settingsBox.get('userName') as String?) ?? '';

  Future<void> setUserName(String value) async {
    await _settingsBox.put('userName', value);
  }

  Map<String, dynamic> get assessmentData {
    final value = _settingsBox.get('assessmentData');
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  Future<void> saveAssessmentData(Map<String, dynamic> data) async {
    await _settingsBox.put('assessmentData', data);
  }

  Future<void> clearAll() async {
    await _remindersBox.clear();
    await _progressBox.clear();
    await _settingsBox.clear();
    await _seedProgressIfNeeded();
  }
}
