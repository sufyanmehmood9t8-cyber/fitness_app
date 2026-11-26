/// Stable, platform-independent ID hash. Used for deterministic notification
/// IDs so reminders can be cancelled even after a restart.
int stableNotificationId(String value, {int salt = 0}) {
  var hash = 0x811C9DC5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return ((hash + salt) & 0x7FFFFFFF);
}
