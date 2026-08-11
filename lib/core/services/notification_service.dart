import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      debugPrint('[NotificationService] Initializing...');
      await _configureLocalTimeZone();
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      // Initialize with both Android and iOS settings
      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
      );
      debugPrint('[NotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[NotificationService] Initialize failed: $e');
      rethrow;
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      debugPrint('[NotificationService] Configuring timezone...');
      tz_data.initializeTimeZones();

      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows) {
        debugPrint(
          '[NotificationService] Skipping timezone config for non-mobile platform',
        );
        return;
      }

      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      debugPrint(
        '[NotificationService] Device timezone: ${timeZoneInfo.identifier}',
      );
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      debugPrint('[NotificationService] Timezone configured successfully');
    } catch (e) {
      debugPrint('[NotificationService] Timezone configuration failed: $e');
      rethrow;
    }
  }

  /// Request notification permissions after the user accepts the app prompt.
  Future<bool> requestPermissions() async {
    final androidGranted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    final iosGranted = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? true;
  }

  /// Check whether notifications are currently enabled when the platform supports it.
  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();

    return androidEnabled ?? true;
  }

  AndroidNotificationDetails _androidNotificationDetails() {
    return AndroidNotificationDetails(
      'streak_channel',
      'Streak Notifications',
      channelDescription: 'Notifications for habit streaks',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    print(
      '[NotificationService] Showing immediate notification: id=$id, title=$title',
    );
    final AndroidNotificationDetails androidNotificationDetails =
        _androidNotificationDetails();

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );

    print(
      '[NotificationService] Immediate notification shown successfully: id=$id',
    );
  }

  /// Schedule a daily notification at a specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails =
        _androidNotificationDetails();

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    // Get current timezone
    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(
      time.hour,
      time.minute,
      time.second,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Schedule a one-time notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    print('[NotificationService] STARTING scheduleNotification...');
    print(
      '[NotificationService] ID: $id, Title: $title, ScheduledTime: $scheduledTime',
    );
    try {
      debugPrint(
        '[NotificationService] Scheduling notification: id=$id, time=$scheduledTime, title=$title',
      );

      // Validate scheduled time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint(
          '[NotificationService] WARNING: Scheduled time is in the past, moving to tomorrow',
        );
      }

      print('[NotificationService] Creating Android notification details...');
      final AndroidNotificationDetails androidNotificationDetails =
          _androidNotificationDetails();

      const DarwinNotificationDetails iOSNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iOSNotificationDetails,
      );

      print('[NotificationService] Converting to timezone-aware datetime...');

      // Get current time in the device timezone
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      print('[NotificationService] Current time (TZ): $now');

      // Use TZDateTime.from() to properly convert DateTime to timezone-aware
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      print('[NotificationService] Scheduled time (TZ): $tzScheduledTime');
      print(
        '[NotificationService] Time difference (milliseconds): ${tzScheduledTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch}',
      );

      if (tzScheduledTime.isBefore(now)) {
        print(
          '[NotificationService] ⚠️ WARNING: Scheduled time is in the past! Moving to tomorrow...',
        );
      }

      debugPrint(
        '[NotificationService] TZ DateTime: $tzScheduledTime (local: ${tz.local})',
      );

      print('[NotificationService] Calling zonedSchedule...');
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );

      print('[NotificationService] ✅ NOTIFICATION SCHEDULED SUCCESSFULLY!');
      debugPrint(
        '[NotificationService] Notification scheduled successfully (exact mode)',
      );
    } catch (e) {
      print('[NotificationService] ❌ EXCEPTION IN scheduleNotification: $e');
      debugPrint('[NotificationService] Schedule failed: $e');
      rethrow;
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    try {
      debugPrint('[NotificationService] Cancelling notification: id=$id');
      await _flutterLocalNotificationsPlugin.cancel(id: id);
      debugPrint('[NotificationService] Notification cancelled successfully');
    } catch (e) {
      debugPrint('[NotificationService] Cancel failed: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// DEBUG: Schedule a test notification 10 seconds from now
  Future<void> scheduleTestNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    print(
      '[NotificationService] 🧪 SCHEDULING TEST NOTIFICATION FOR: $testTime',
    );

    await scheduleNotification(
      id: 999999,
      title: 'TEST NOTIFICATION',
      body: 'If you see this, scheduled notifications work!',
      scheduledTime: testTime,
      payload: 'test',
    );
  }

  /// Get next instance of time for daily notification
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, int second) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      second,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
