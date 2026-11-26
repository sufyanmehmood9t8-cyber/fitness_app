import '../../core/utils/date_time_utils.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.timeMinutes,
    required this.days,
    required this.smart,
    required this.exerciseId,
    required this.enabled,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final int timeMinutes;
  final List<int> days;
  final bool smart;
  final String exerciseId;
  final bool enabled;
  final DateTime createdAt;

  int get hour => (timeMinutes % (24 * 60)) ~/ 60;
  int get minute => timeMinutes % 60;
  String get timeLabel => FlowDateUtils.formatMinutesOfDay(timeMinutes);

  DateTime nextOccurrence(DateTime now) {
    if (days.isEmpty) return now.add(const Duration(days: 7));
    DateTime? best;
    for (final weekday in days) {
      var daysAhead = (weekday - now.weekday) % 7;
      if (daysAhead < 0) daysAhead += 7;
      var candidate = DateTime(
        now.year,
        now.month,
        now.day + daysAhead,
        hour,
        minute,
      );
      if (!candidate.isAfter(now)) {
        candidate = DateTime(
          candidate.year,
          candidate.month,
          candidate.day + 7,
          hour,
          minute,
        );
      }
      if (best == null || candidate.isBefore(best)) {
        best = candidate;
      }
    }
    return best ??
        DateTime(
          now.year,
          now.month,
          now.day + 7,
          hour,
          minute,
        );
  }

  bool occursToday(DateTime now) =>
      days.contains(now.weekday) &&
      !DateTime(now.year, now.month, now.day, hour, minute).isBefore(now);

  String dayLabel() {
    const names = <int, String>{
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    if (days.length == 7) return 'Every day';
    final sorted = [...days]..sort();
    return sorted.map((day) => names[day] ?? '').join(', ');
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    int? timeMinutes,
    List<int>? days,
    bool? smart,
    String? exerciseId,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      days: days ?? this.days,
      smart: smart ?? this.smart,
      exerciseId: exerciseId ?? this.exerciseId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'timeMinutes': timeMinutes,
        'days': days,
        'smart': smart,
        'exerciseId': exerciseId,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        timeMinutes: (json['timeMinutes'] as num?)?.toInt() ?? 0,
        days: (json['days'] as List<dynamic>? ?? <dynamic>[])
            .map((value) => (value as num).toInt())
            .toList(growable: false),
        smart: json['smart'] as bool? ?? false,
        exerciseId: json['exerciseId'] as String? ?? 'split-training',
        enabled: json['enabled'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
