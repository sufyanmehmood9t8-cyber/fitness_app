import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsRepository {
  SettingsRepository(this._storage);

  final StorageService _storage;

  AppSettings load() => AppSettings(
        notificationsEnabled: _storage.notificationsEnabled,
        smartReminders: _storage.smartReminders,
      );

  Future<void> save(AppSettings settings) async {
    await _storage.setNotificationsEnabled(settings.notificationsEnabled);
    await _storage.setSmartReminders(settings.smartReminders);
  }

  bool get notificationsPrompted => _storage.notificationsPrompted;

  Future<void> markNotificationsPrompted() =>
      _storage.markNotificationsPrompted();

  String? get lastInAppReminderKey => _storage.lastInAppReminderKey;

  Future<void> setLastInAppReminderKey(String key) =>
      _storage.setLastInAppReminderKey(key);
}
