import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reminder_frequency.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  static const int _lessonReminderNotificationId = 1001;
  static const String _reminderFrequencyKey = 'reminder_frequency';

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

    await _plugin.initialize(initSettings);

    _initialized = true;
  }

  /// Returns true if notification permission is currently granted, without
  /// showing any system dialogs or requesting it.
  Future<bool> hasPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> ensurePermissionsGranted() async {
    await init();

    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    }

    final newStatus = await Permission.notification.request();

    if (newStatus.isGranted) {
      return true;
    }

    return false;
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
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Simple daily reminder using device time, approximate hour control
    await _plugin.periodicallyShow(
      _lessonReminderNotificationId,
      "Don't lose your streak!",
      'Take a short lesson now and keep your progress going.',
      RepeatInterval.daily,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexact,
    );
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
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    Future.delayed(delay, () {
      _plugin.show(
        9991,
        'Test reminder (zaplanowany)',
        'To jest testowe powiadomienie zaplanowane.',
        notificationDetails,
      );
    });
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
}
