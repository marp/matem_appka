import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_frequency.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
  debugPrint('background notification tapped: ${notificationResponse.payload}');
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  static const int _lessonReminderNotificationId = 1001;
  static const String _reminderFrequencyKey = 'reminder_frequency';

  static const int _dailyReminderHour = 2;
  static const int _dailyReminderMinute = 12;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (notificationResponse) async {
        // Handle notification tapped logic here
        debugPrint('notification tapped: ${notificationResponse.payload}');
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );


    final TimezoneInfo currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    _initialized = true;
  }

  /// Returns true if notification permission is currently granted, without
  /// showing any system dialogs or requesting it.
  Future<bool> hasPermission() async {
    final notificationStatus = await Permission.notification.status;
    final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
    return notificationStatus.isGranted && scheduleExactAlarmStatus.isGranted;
  }

  Future<Map<Permission, PermissionStatus>> getPermissionsStatus() async {
    final notificationStatus = await Permission.notification.status;
    final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
    return {
      Permission.notification: notificationStatus,
      Permission.scheduleExactAlarm: scheduleExactAlarmStatus,
    };
  }

  Future<bool> ensurePermissionsGranted() async {
    await init();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    return statuses[Permission.notification] == PermissionStatus.granted &&
        statuses[Permission.scheduleExactAlarm] == PermissionStatus.granted;
  }

  Future<void> saveReminderFrequency(ReminderFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderFrequencyKey, frequency.storageKey);
  }

  Future<ReminderFrequency> loadReminderFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_reminderFrequencyKey);
    return ReminderFrequencyStorage.fromStorageKey(value);
  }

  Future<void> scheduleLessonReminders(ReminderFrequency frequency) async {
    await init();

    if (frequency == ReminderFrequency.off) {
      await cancelLessonReminders();
      return;
    }

    await cancelLessonReminders();

    final androidDetails = AndroidNotificationDetails(
      'lesson_reminders',
      'Lesson reminders',
      channelDescription: 'Reminders to take your math lesson',
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = _nextInstanceOfReminderTime();

    final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
    final useExactAlarm = scheduleExactAlarmStatus.isGranted;

    await _plugin.zonedSchedule(
      _lessonReminderNotificationId,
      "Don't lose your streak!",
      'Take a short lesson now and keep your progress going.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: useExactAlarm
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact,
      payload: scheduledDate.toString(),
    );
  }

  tz.TZDateTime _nextInstanceOfReminderTime() {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _dailyReminderHour,
      _dailyReminderMinute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<DateTime?> getNextReminderDate() async {
    final frequency = await loadReminderFrequency();
    if (frequency != ReminderFrequency.everyDay) {
      return null;
    }
    return _nextInstanceOfReminderTime();
  }

  /// Reschedules reminders on app start (useful after reboot/app update).
  Future<void> rescheduleIfEnabled() async {
    final frequency = await loadReminderFrequency();
    if (frequency == ReminderFrequency.everyDay) {
      // Only reschedule if permissions are already granted.
      // Don't ask for permissions on startup.
      if (await hasPermission()) {
        await scheduleLessonReminders(frequency);
      }
    }
  }

  Future<void> cancelLessonReminders() async {
    await init();
    await _plugin.cancel(_lessonReminderNotificationId);
  }

  Future<void> scheduleTestNotificationAfter(Duration delay) async {
    await init();

    final androidDetails = AndroidNotificationDetails(
      'test_scheduled',
      'Test scheduled notifications',
      channelDescription: 'Dev/local testing of scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      9991,
      'Test reminder (planned)',
      'This is a scheduled testing notification.',
      tz.TZDateTime.now(tz.local).add(delay),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: tz.TZDateTime.now(tz.local).add(delay).toString()
    );
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  Future<void> showImmediateTestNotification() async {
    await init();

    final androidDetails = AndroidNotificationDetails(
      'test_immediate',
      'Test immediate notifications',
      channelDescription: 'Dev/local testing of immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      9990,
      'Test reminder',
      'This is immediate testing notification.',
      notificationDetails,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }
}
