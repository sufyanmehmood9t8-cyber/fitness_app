import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/reminder.dart';
import '../data/providers/app_providers.dart';
import 'reminder_banner.dart';

class ReminderBannerHost extends ConsumerStatefulWidget {
  const ReminderBannerHost({
    super.key,
    required this.child,
    required this.onOpen,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<String> onOpen;
  final bool enabled;

  @override
  ConsumerState<ReminderBannerHost> createState() => _ReminderBannerHostState();
}

class _ReminderBannerHostState extends ConsumerState<ReminderBannerHost> {
  Reminder? _reminder;
  bool _shown = false;
  Timer? _hideTimer;
  Timer? _pollTimer;
  String? _lastShownKey;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkDue());
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _checkDue(),
    );
  }

  void _checkDue() {
    if (!mounted || _shown) return;
    final settings = ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;
    final now = DateTime.now();
    final workedOut = ref.read(todayWorkoutProvider);
    final due =
        ref
            .read(remindersProvider)
            .where(
              (reminder) =>
                  reminder.enabled &&
                  reminder.days.contains(now.weekday) &&
                  !(settings.smartReminders && reminder.smart && workedOut) &&
                  _isDue(reminder, now),
            )
            .toList()
          ..sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    if (due.isEmpty) return;

    final reminder = due.first;
    final key =
        '${reminder.id}-${now.year}-${now.month}-'
        '${now.day}-${reminder.timeMinutes}';
    if (key == _lastShownKey) return;
    _lastShownKey = key;
    setState(() {
      _reminder = reminder;
      _shown = true;
    });
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 6), _dismiss);
  }

  bool _isDue(Reminder reminder, DateTime now) {
    final target = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );
    final seconds = now.difference(target).inSeconds;
    return seconds >= 0 && seconds < 60;
  }

  void _dismiss() {
    _hideTimer?.cancel();
    if (!mounted || !_shown) return;
    setState(() => _shown = false);
    Timer(const Duration(milliseconds: 260), () {
      if (mounted) setState(() => _reminder = null);
    });
  }

  void _open() {
    final reminder = _reminder;
    if (reminder == null) return;
    _dismiss();
    widget.onOpen(reminder.exerciseId);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        if (_reminder != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: IgnorePointer(
              ignoring: !_shown,
              child: AnimatedSlide(
                offset: _shown ? Offset.zero : const Offset(0, -1.2),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _shown ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: ReminderBanner(onTap: _open, onDismiss: _dismiss),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
