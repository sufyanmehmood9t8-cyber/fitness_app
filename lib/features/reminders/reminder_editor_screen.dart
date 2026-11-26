import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/reminder.dart';
import '../../data/providers/app_providers.dart';
import '../../data/seed/seed_data.dart';
import '../../widgets/app_button.dart';
import '../../widgets/flow_background.dart';

class ReminderEditorScreen extends ConsumerStatefulWidget {
  const ReminderEditorScreen({super.key, this.editId});

  final String? editId;

  @override
  ConsumerState<ReminderEditorScreen> createState() =>
      _ReminderEditorScreenState();
}

class _ReminderEditorScreenState
    extends ConsumerState<ReminderEditorScreen> {
  static const List<int> _hours = <int>[
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  Reminder? _existing;
  Set<int> _selectedDays = <int>{1, 2, 3, 4, 5};
  String _exerciseId = 'split-training';
  bool _smart = true;
  bool _saving = false;
  int _hourIndex = 5;
  int _minuteIndex = 0;
  bool _isPm = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      for (final reminder in ref.read(remindersProvider)) {
        if (reminder.id == widget.editId) {
          _existing = reminder;
          break;
        }
      }
    }
    final existing = _existing;
    if (existing != null) {
      _nameController.text = existing.title;
      _descriptionController.text = existing.description;
      _selectedDays = existing.days.isEmpty
          ? <int>{1, 2, 3, 4, 5}
          : existing.days.toSet();
      _exerciseId = existing.exerciseId.isEmpty
          ? 'split-training'
          : existing.exerciseId;
      _smart = existing.smart;
      final displayHour = existing.hour % 12 == 0 ? 12 : existing.hour % 12;
      _hourIndex = _hours.indexOf(displayHour).clamp(0, 11);
      _minuteIndex = existing.minute.clamp(0, 59);
      _isPm = existing.hour >= 12;
    } else {
      final now = DateTime.now();
      final hasSeconds = now.second > 0 || now.millisecond > 0;
      final target = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      ).add(
        Duration(minutes: hasSeconds ? 1 : 0),
      );
      final displayHour = target.hour % 12 == 0 ? 12 : target.hour % 12;
      _hourIndex = displayHour - 1;
      _minuteIndex = target.minute;
      _isPm = target.hour >= 12;
    }
    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController =
        FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  int get _timeMinutes {
    final displayHour = _hours[_hourIndex];
    final hour24 = (displayHour % 12) + (_isPm ? 12 : 0);
    return hour24 * 60 + _minuteIndex;
  }

  String get _displayTime {
    final displayHour = _hours[_hourIndex];
    return '${displayHour.toString().padLeft(2, '0')}:'
        '${_minuteIndex.toString().padLeft(2, '0')} '
        '${_isPm ? 'PM' : 'AM'}';
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one day for your reminder.'),
        ),
      );
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your reminder a name.')),
      );
      return;
    }

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();
    final exerciseId =
        SeedData.byId(_exerciseId)?.id ?? SeedData.exercises.first.id;
    final reminder = Reminder(
      id: _existing?.id ?? 'rem_${now.millisecondsSinceEpoch}',
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      timeMinutes: _timeMinutes,
      days: _selectedDays.toList()..sort(),
      smart: _smart,
      exerciseId: exerciseId,
      enabled: _existing?.enabled ?? true,
      createdAt: _existing?.createdAt ?? now,
    );

    try {
      await ref.read(remindersProvider.notifier).upsert(reminder);
      final settings = ref.read(settingsProvider);
      final notifications = ref.read(notificationServiceProvider);

      String? message;
      if (settings.notificationsEnabled) {
        final status = await notifications.requestPermissions();
        await ref
            .read(settingsRepositoryProvider)
            .markNotificationsPrompted();
        final result = await notifications.scheduleReminder(
          reminder,
          skipToday:
              _smart && ref.read(todayWorkoutProvider),
          notificationsGranted: status.notificationsGranted,
          exactAlarmsGranted: status.exactAlarmsGranted,
        );
        if (!status.notificationsGranted) {
          message =
              'Reminder saved. Enable notifications to receive reminders.';
        } else if (result.usedInexactAlarms) {
          message =
              'Reminder saved. Timing may vary without exact alarms.';
        }
      } else {
        await notifications.cancelReminder(reminder.id);
      }

      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message ??
                (_existing == null
                    ? 'Reminder added'
                    : 'Reminder updated'),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save the reminder. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: FlowBackground(
        child: Column(
          children: <Widget>[
            _ReminderHeader(
              onOpenSaved: () => context.push('/reminders'),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TitleCard(controller: _nameController),
                    const SizedBox(height: 12),
                    _DescriptionCard(
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 12),
                    _TimeCard(
                      hourIndex: _hourIndex,
                      minuteIndex: _minuteIndex,
                      isPm: _isPm,
                      hourController: _hourController,
                      minuteController: _minuteController,
                      onHourChanged: (value) =>
                          setState(() => _hourIndex = value),
                      onMinuteChanged: (value) =>
                          setState(() => _minuteIndex = value),
                      onPeriodToggle: () =>
                          setState(() => _isPm = !_isPm),
                      displayTime: _displayTime,
                    ),
                    const SizedBox(height: 12),
                    _RepeatCard(
                      selectedDays: _selectedDays,
                      smart: _smart,
                      onDayTap: (weekday, selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.remove(weekday);
                          } else {
                            _selectedDays.add(weekday);
                          }
                        });
                      },
                      onSmartChanged: (value) =>
                          setState(() => _smart = value),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + viewPadding.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x594299E1),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: AppButton(
                  label: 'Save Reminder',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderHeader extends StatelessWidget {
  const _ReminderHeader({required this.onOpenSaved});

  final VoidCallback onOpenSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: <Widget>[
          Semantics(
            button: true,
            label: 'Go back',
            child: SizedBox(
              width: 32,
              height: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 40,
                ),
                splashRadius: 18,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(
                  LucideIcons.arrowLeft,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Set Reminder',
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
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Saved Reminders',
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onOpenSaved,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  child: const Text(
                    'Saved Reminders',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: TextField(
        controller: controller,
        maxLines: 1,
        maxLength: 32,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: '20 time daily Push-ups',
          counterText: '',
          isDense: true,
          filled: false,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 3,
            maxLength: 160,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Optional note',
              counterText: '',
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.hourIndex,
    required this.minuteIndex,
    required this.isPm,
    required this.hourController,
    required this.minuteController,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onPeriodToggle,
    required this.displayTime,
  });

  final int hourIndex;
  final int minuteIndex;
  final bool isPm;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final VoidCallback onPeriodToggle;
  final String displayTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 168,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: -8,
                  right: -8,
                  top: 56,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: _TimeWheel(
                        controller: hourController,
                        itemCount: 12,
                        selectedIndex: hourIndex,
                        labelFor: (index) =>
                            (index + 1).toString().padLeft(2, '0'),
                        semanticLabel: 'Hour',
                        onChanged: onHourChanged,
                      ),
                    ),
                    const SizedBox(
                      width: 18,
                      child: Center(
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _TimeWheel(
                        controller: minuteController,
                        itemCount: 60,
                        selectedIndex: minuteIndex,
                        labelFor: (index) =>
                            index.toString().padLeft(2, '0'),
                        semanticLabel: 'Minute',
                        onChanged: onMinuteChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PeriodToggle(
                      isPm: isPm,
                      onTap: onPeriodToggle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(
                LucideIcons.clock3,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Selected: $displayTime',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.labelFor,
    required this.semanticLabel,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final String Function(int index) labelFor;
  final String semanticLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: labelFor(selectedIndex),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 56,
        physics: const FixedExtentScrollPhysics(),
        perspective: 0.003,
        diameterRatio: 2,
        squeeze: 1,
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List<Widget>.generate(itemCount, (index) {
            final selected = index == selectedIndex;
            return Center(
              child: Text(
                labelFor(index),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFC4C4C4),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.isPm, required this.onTap});

  final bool isPm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isPm ? 'PM' : 'AM';
    return Semantics(
      button: true,
      label: '$label selected, tap to switch period',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 52,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RepeatCard extends StatelessWidget {
  static const List<int> _weekOrder = <int>[7, 1, 2, 3, 4, 5, 6];
  static const List<String> _weekLabels = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  const _RepeatCard({
    required this.selectedDays,
    required this.smart,
    required this.onDayTap,
    required this.onSmartChanged,
  });

  final Set<int> selectedDays;
  final bool smart;
  final void Function(int weekday, bool selected) onDayTap;
  final ValueChanged<bool> onSmartChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                LucideIcons.calendarClock,
                size: 15,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 6),
              Text(
                'REPEAT ON',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(_weekOrder.length, (index) {
              final weekday = _weekOrder[index];
              final selected = selectedDays.contains(weekday);
              return _DayCircle(
                label: _weekLabels[index],
                selected: selected,
                semanticLabel: _fullDayName(weekday),
                onTap: () => onDayTap(weekday, selected),
              );
            }),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  LucideIcons.bell,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Smart Reminders',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: smart,
                  onChanged: onSmartChanged,
                  activeThumbColor: AppColors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.chip,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fullDayName(int weekday) {
    const names = <int, String>{
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return names[weekday] ?? '';
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({
    required this.label,
    required this.selected,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              height: 1,
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const <BoxShadow>[
      BoxShadow(
        color: Color(0x0F4299E1),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );
}
