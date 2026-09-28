import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const int dailyReminderId = 1001;
  static const String channelId = 'winter_arc_daily_reminders';
  static const String channelName = 'Daily Habit Reminders';
  static const String channelDescription =
      'Daily notifications to remind you to log and complete your Winter Arc habits.';

  static Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        final String timeZoneName = localTimezone.identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        if (kDebugMode) {
          print('NotificationService: Local timezone initialized to $timeZoneName');
        }
      } catch (tzError) {
        if (kDebugMode) {
          print('Failed to get device timezone, using default: $tzError');
        }
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      _initialized = true;

      // Automatically request runtime permission on app startup
      await requestPermissions();
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService init error: $e');
      }
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final notifGranted =
            await androidImplementation.requestNotificationsPermission();
        try {
          await androidImplementation.requestExactAlarmsPermission();
        } catch (_) {}
        return notifGranted ?? false;
      }

      final iosImplementation = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('requestPermissions error: $e');
      }
    }
    return true;
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();

    try {
      await _plugin.cancel(id: dailyReminderId);

      final scheduledTime = _nextInstanceOfTime(hour, minute);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _plugin.zonedSchedule(
          id: dailyReminderId,
          title: '❄️ Winter Arc Daily Check-in',
          body: 'Stay locked in! Check off today\'s habits and keep your streak alive 🔥',
          scheduledDate: scheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (scheduleError) {
        // Fallback for devices without exact alarm privileges
        await _plugin.zonedSchedule(
          id: dailyReminderId,
          title: '❄️ Winter Arc Daily Check-in',
          body: 'Stay locked in! Check off today\'s habits and keep your streak alive 🔥',
          scheduledDate: scheduledTime,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      if (kDebugMode) {
        print('Scheduled daily reminder at $hour:${minute.toString().padLeft(2, "0")} (Next: $scheduledTime)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('scheduleDailyReminder error: $e');
      }
    }
  }

  static Future<void> cancelDailyReminder() async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: dailyReminderId);
      if (kDebugMode) {
        print('Cancelled daily reminder');
      }
    } catch (e) {
      if (kDebugMode) {
        print('cancelDailyReminder error: $e');
      }
    }
  }

  static Future<void> showTestNotification() async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 999,
      title: '❄️ Winter Arc Reminder Active',
      body: 'Daily reminders are configured and active! Keep grinding 🔥',
      notificationDetails: details,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.Location location = tz.local;
    final tz.TZDateTime now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
