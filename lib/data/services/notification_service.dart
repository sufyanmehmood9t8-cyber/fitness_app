import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/utils/stable_id.dart';
import '../models/reminder.dart';

class NotificationPermissionStatus {
  const NotificationPermissionStatus({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
  });

  final bool notificationsGranted;
  final bool exactAlarmsGranted;
}

class ReminderScheduleResult {
  const ReminderScheduleResult({
    required this.scheduledCount,
    required this.usedInexactAlarms,
    required this.notificationsGranted,
  });

  final int scheduledCount;
  final bool usedInexactAlarms;
  final bool notificationsGranted;

  bool get scheduled => scheduledCount > 0;
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String channelId = 'flow_workout_reminders';
  static const String channelName = 'Exercise reminders';
  static const String channelDescription = 'Time to stretch';

  static const String _largeIconBase64 =
      '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'
      'QmCC';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  ValueChanged<String>? onNotificationTap;
  String? _pendingLaunchExerciseId;

  bool get _supportsNotifications =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    if (!_supportsNotifications) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep the timezone package's default if the platform lookup fails.
    }

    const androidSettings =
        AndroidInitializationSettings('ic_stat_flow');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final callback = onNotificationTap;
        if (callback == null) {
          _pendingLaunchExerciseId = payload;
        } else {
          callback(payload);
        }
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        playSound: true,
      ),
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _pendingLaunchExerciseId =
          launch?.notificationResponse?.payload ?? _pendingLaunchExerciseId;
    }
  }

  String? takeLaunchExerciseId() {
    final value = _pendingLaunchExerciseId;
    _pendingLaunchExerciseId = null;
    return value;
  }

  Future<NotificationPermissionStatus> checkPermissions() async {
    if (!_supportsNotifications) {
      return const NotificationPermissionStatus(
        notificationsGranted: false,
        exactAlarmsGranted: false,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.areNotificationsEnabled() ?? false;
      final exact = granted &&
          (await android?.canScheduleExactNotifications() ?? false);
      return NotificationPermissionStatus(
        notificationsGranted: granted,
        exactAlarmsGranted: exact,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final options = await ios?.checkPermissions();
      final granted = options?.isEnabled == true ||
          options?.isProvisionalEnabled == true;
      return NotificationPermissionStatus(
        notificationsGranted: granted,
        exactAlarmsGranted: granted,
      );
    }

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final options = await macos?.checkPermissions();
    final granted = options?.isEnabled == true;
    return NotificationPermissionStatus(
      notificationsGranted: granted,
      exactAlarmsGranted: granted,
    );
  }

  Future<NotificationPermissionStatus> requestPermissions() async {
    if (!_supportsNotifications) {
      return const NotificationPermissionStatus(
        notificationsGranted: false,
        exactAlarmsGranted: false,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) {
        return const NotificationPermissionStatus(
          notificationsGranted: false,
          exactAlarmsGranted: false,
        );
      }
      final existing = await android.areNotificationsEnabled() ?? true;
      final requested = await android.requestNotificationsPermission();
      final granted = requested ?? existing;

      var exact = true;
      if (granted) {
        final canExact =
            await android.canScheduleExactNotifications() ?? true;
        if (!canExact) {
          exact = await android.requestExactAlarmsPermission() ?? false;
        }
      }
      return NotificationPermissionStatus(
        notificationsGranted: granted,
        exactAlarmsGranted: exact,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return NotificationPermissionStatus(
        notificationsGranted: granted,
        exactAlarmsGranted: granted,
      );
    }

    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final granted = await macos?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
    return NotificationPermissionStatus(
      notificationsGranted: granted,
      exactAlarmsGranted: granted,
    );
  }

  NotificationDetails get _details => NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_flow',
          color: AppColors.primary,
          largeIcon: ByteArrayAndroidBitmap.fromBase64String(
            _largeIconBase64,
          ),
          styleInformation: const BigTextStyleInformation(
            'Let start your exercise with this style.',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  int _notificationId(String reminderId, int weekday) =>
      stableNotificationId(reminderId, salt: weekday * 1009);

  DateTime _nextForWeekday(Reminder reminder, int weekday, DateTime now) {
    var daysAhead = (weekday - now.weekday) % 7;
    if (daysAhead < 0) daysAhead += 7;
    var candidate = DateTime(
      now.year,
      now.month,
      now.day + daysAhead,
      reminder.hour,
      reminder.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = DateTime(
        candidate.year,
        candidate.month,
        candidate.day + 7,
        reminder.hour,
        reminder.minute,
      );
    }
    return candidate;
  }

  Future<ReminderScheduleResult> scheduleReminder(
    Reminder reminder, {
    bool skipToday = false,
    bool notificationsGranted = true,
    bool exactAlarmsGranted = true,
  }) async {
    await cancelReminder(reminder.id);
    if (!_supportsNotifications) {
      return ReminderScheduleResult(
        scheduledCount: 0,
        usedInexactAlarms: false,
        notificationsGranted: notificationsGranted,
      );
    }
    if (!reminder.enabled) {
      return ReminderScheduleResult(
        scheduledCount: 0,
        usedInexactAlarms: false,
        notificationsGranted: notificationsGranted,
      );
    }

    final now = DateTime.now();
    var useExact = exactAlarmsGranted;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        useExact = useExact &&
            (await android.canScheduleExactNotifications() ?? false);
      }
    }
    var usedInexact = !useExact;
    var scheduledCount = 0;

    for (final weekday in reminder.days) {
      var next = _nextForWeekday(reminder, weekday, now);
      if (skipToday && FlowDateUtils.isSameDay(next, now)) {
        next = DateTime(
          next.year,
          next.month,
          next.day + 7,
          next.hour,
          next.minute,
        );
      }
      final scheduledDate = tz.TZDateTime.from(next, tz.local);
      final id = _notificationId(reminder.id, weekday);
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: 'Your exercise time',
          body: 'Let start your exercise with this style.',
          scheduledDate: scheduledDate,
          notificationDetails: _details,
          androidScheduleMode: useExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.exerciseId,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } catch (_) {
        usedInexact = true;
        await _plugin.zonedSchedule(
          id: id,
          title: 'Your exercise time',
          body: 'Let start your exercise with this style.',
          scheduledDate: scheduledDate,
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.exerciseId,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
      scheduledCount++;
    }

    return ReminderScheduleResult(
      scheduledCount: scheduledCount,
      usedInexactAlarms: usedInexact,
      notificationsGranted: notificationsGranted,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    if (!_supportsNotifications) return;
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id: _notificationId(reminderId, weekday));
    }
  }

  Future<void> cancelAll() async {
    if (!_supportsNotifications) return;
    await _plugin.cancelAll();
  }
}
