import 'package:fitness_app/data/models/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Reminder reminder({
    required int timeMinutes,
    required List<int> days,
    bool smart = false,
  }) {
    return Reminder(
      id: 'test-reminder',
      title: 'Morning stretch',
      description: 'Split training',
      timeMinutes: timeMinutes,
      days: days,
      smart: smart,
      exerciseId: 'split-training',
      enabled: true,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('occursToday only matches future times on selected days', () {
    final now = DateTime(2026, 10, 26, 8);
    final upcoming = reminder(
      timeMinutes: 9 * 60,
      days: <int>[now.weekday],
    );
    final passed = reminder(
      timeMinutes: 7 * 60,
      days: <int>[now.weekday],
    );
    final wrongDay = reminder(
      timeMinutes: 9 * 60,
      days: <int>{1, 2, 3, 4, 5, 6, 7}
          .difference(<int>{now.weekday})
          .toList(),
    );

    expect(upcoming.occursToday(now), isTrue);
    expect(passed.occursToday(now), isFalse);
    expect(wrongDay.occursToday(now), isFalse);
  });

  test('nextOccurrence rolls a passed time to the following week', () {
    final now = DateTime(2026, 10, 26, 10);
    final passed = reminder(
      timeMinutes: 9 * 60,
      days: <int>[now.weekday],
    );
    final next = passed.nextOccurrence(now);
    expect(next.difference(now).inDays, greaterThanOrEqualTo(6));
    expect(next.hour, 9);
    expect(next.minute, 0);
  });

  test('labels daily schedules and serializes cleanly', () {
    final daily = reminder(
      timeMinutes: 7 * 60 + 30,
      days: <int>[1, 2, 3, 4, 5, 6, 7],
      smart: true,
    );
    expect(daily.timeLabel, '7:30 AM');
    expect(daily.dayLabel(), 'Every day');

    final restored = Reminder.fromJson(daily.toJson());
    expect(restored.id, daily.id);
    expect(restored.days, daily.days);
    expect(restored.smart, isTrue);
    expect(restored.timeMinutes, 450);
  });
}
