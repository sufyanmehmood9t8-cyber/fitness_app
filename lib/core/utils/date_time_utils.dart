import 'package:intl/intl.dart';

abstract final class FlowDateUtils {
  static DateTime dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String formatTimeOfDay(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String formatMinutesOfDay(int minutes) {
    final normalized = minutes % (24 * 60);
    return formatTimeOfDay(normalized ~/ 60, normalized % 60);
  }

  static String formatClock(Duration duration) {
    final total = duration.inSeconds.clamp(0, 24 * 60 * 60);
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static String formatSessionMinutes(Duration duration) {
    final total = duration.inSeconds.clamp(0, 24 * 60 * 60);
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatRemaining(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 1 << 30);
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')} min';
  }

  static String formatGroupDate(DateTime date) =>
      DateFormat('d MMMM, yyyy').format(date);

  static String formatShortDate(DateTime date) =>
      DateFormat('d MMM').format(date);

  static String formatWeekdayDate(DateTime date) =>
      DateFormat('EEEE, d MMMM').format(date);

  static String durationBadge(Iterable<int> seconds) {
    if (seconds.isEmpty) return '0 min';
    final low = (seconds.reduce((a, b) => a < b ? a : b) / 60).ceil();
    final high = (seconds.reduce((a, b) => a > b ? a : b) / 60).ceil();
    if (low == high) return '$low min';
    return '$low-$high min';
  }

  static String monthDay(DateTime date) => DateFormat('d MMM').format(date);
}
