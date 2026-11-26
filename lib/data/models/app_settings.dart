class AppSettings {
  const AppSettings({
    required this.notificationsEnabled,
    required this.smartReminders,
  });

  final bool notificationsEnabled;
  final bool smartReminders;

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? smartReminders,
  }) {
    return AppSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      smartReminders: smartReminders ?? this.smartReminders,
    );
  }
}
