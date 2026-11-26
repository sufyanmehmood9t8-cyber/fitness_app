import '../models/reminder.dart';
import '../services/storage_service.dart';

class ReminderRepository {
  ReminderRepository(this._storage);

  final StorageService _storage;

  List<Reminder> loadAll() => _storage.loadReminders();

  Future<void> upsert(Reminder reminder) =>
      _storage.saveReminder(reminder);

  Future<void> delete(String id) => _storage.deleteReminder(id);
}
