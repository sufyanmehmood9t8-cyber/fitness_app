import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../data/models/reminder.dart';
import '../../data/providers/app_providers.dart';
import '../../data/seed/seed_data.dart';
import '../../widgets/flow_background.dart';

const Color _rowBackground = Color(0xFFF7F7F7);
const Color _iconCircle = Color(0xFFDCEBFA);

class SavedRemindersScreen extends ConsumerStatefulWidget {
  const SavedRemindersScreen({super.key});

  @override
  ConsumerState<SavedRemindersScreen> createState() =>
      _SavedRemindersScreenState();
}

class _SavedRemindersScreenState extends ConsumerState<SavedRemindersScreen> {
  Timer? _minuteTicker;

  @override
  void initState() {
    super.initState();
    _minuteTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    final now = DateTime.now();
    final groups = _groupReminders(reminders, now);

    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: FlowBackground(
        child: Column(
          children: <Widget>[
            const _RemindersHeader(),
            Expanded(
              child: reminders.isEmpty
                  ? _EmptyReminders(onAdd: () => context.push('/reminders/new'))
                  : SafeArea(
                      top: false,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: groups.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _DateGroupCard(
                            date: group.date,
                            reminders: group.reminders,
                            now: now,
                            onEdit: (reminder) => context.push(
                              '/reminders/new?edit=${reminder.id}',
                            ),
                            onDelete: (reminder) =>
                                _deleteReminder(context, reminder),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ReminderGroup> _groupReminders(List<Reminder> reminders, DateTime now) {
    final grouped = <DateTime, List<Reminder>>{};
    for (final reminder in reminders) {
      final occurrence = reminder.occursToday(now)
          ? DateTime(
              now.year,
              now.month,
              now.day,
              reminder.hour,
              reminder.minute,
            )
          : reminder.nextOccurrence(now);
      final date = FlowDateUtils.dayOnly(occurrence);
      grouped.putIfAbsent(date, () => <Reminder>[]).add(reminder);
    }

    final today = FlowDateUtils.dayOnly(now);
    final groups = grouped.entries.map((entry) {
      final rows = entry.value
        ..sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
      return _ReminderGroup(date: entry.key, reminders: rows);
    }).toList();

    groups.sort((a, b) {
      final aToday = FlowDateUtils.isSameDay(a.date, today);
      final bToday = FlowDateUtils.isSameDay(b.date, today);
      if (aToday != bToday) return aToday ? -1 : 1;
      return a.date.compareTo(b.date);
    });
    return groups;
  }

  Future<void> _deleteReminder(BuildContext context, Reminder reminder) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(remindersProvider.notifier).remove(reminder.id);
    await ref.read(notificationServiceProvider).cancelReminder(reminder.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${reminder.title} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await ref.read(remindersProvider.notifier).restore(reminder);
            if (!reminder.enabled ||
                !ref.read(settingsProvider).notificationsEnabled) {
              return;
            }
            await ref
                .read(notificationServiceProvider)
                .scheduleReminder(
                  reminder,
                  skipToday: reminder.smart && ref.read(todayWorkoutProvider),
                );
          },
        ),
      ),
    );
  }
}

class _ReminderGroup {
  const _ReminderGroup({required this.date, required this.reminders});

  final DateTime date;
  final List<Reminder> reminders;
}

class _RemindersHeader extends StatelessWidget {
  const _RemindersHeader();

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            label: 'Go back',
            child: SizedBox(
              width: 44,
              height: 44,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _handleBack(context),
                child: const Icon(
                  LucideIcons.arrowLeft,
                  size: 21,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Saved Reminders',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateGroupCard extends StatelessWidget {
  const _DateGroupCard({
    required this.date,
    required this.reminders,
    required this.now,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime date;
  final List<Reminder> reminders;
  final DateTime now;
  final ValueChanged<Reminder> onEdit;
  final ValueChanged<Reminder> onDelete;

  @override
  Widget build(BuildContext context) {
    final isToday = FlowDateUtils.isSameDay(date, now);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D4299E1),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            FlowDateUtils.formatGroupDate(date),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < reminders.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 8),
            Dismissible(
              key: ValueKey<String>('reminder-${reminders[index].id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: AppColors.urgent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.trash2,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              onDismissed: (_) => onDelete(reminders[index]),
              child: _ReminderRow(
                reminder: reminders[index],
                now: now,
                isToday: isToday,
                onTap: () => onEdit(reminders[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminder,
    required this.now,
    required this.isToday,
    required this.onTap,
  });

  final Reminder reminder;
  final DateTime now;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = SeedData.byId(reminder.exerciseId);
    final durationMinutes = exercise == null
        ? null
        : (exercise.durationSec / 60).ceil();
    final title = reminder.title.trim().isEmpty
        ? 'Your exercise time'
        : reminder.title;
    final durationLabel = durationMinutes == null
        ? '30 min'
        : '$durationMinutes min remaining';
    final statusLabel = isToday
        ? _todayStatus(reminder, now)
        : _futureStatus(reminder);
    final statusColor = isToday ? AppColors.urgent : AppColors.primary;

    return Material(
      color: _rowBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      durationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: _iconCircle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _todayStatus(Reminder reminder, DateTime now) {
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );
    final remaining = target.difference(now).inMinutes;
    final totalMinutes = remaining < 0 ? 0 : remaining;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final paddedMinutes = minutes.toString().padLeft(2, '0');
    if (hours > 0) {
      return 'Today, $hours:$paddedMinutes hour remaining';
    }
    return 'Today, 00:$paddedMinutes min remaining';
  }

  String _futureStatus(Reminder reminder) {
    return 'Selected time : ${reminder.timeLabel.toLowerCase()}';
  }
}

class _EmptyReminders extends StatelessWidget {
  const _EmptyReminders({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'No reminders yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a gentle nudge for the moments you want to move.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          LucideIcons.plus,
                          size: 16,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Add Reminder',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
