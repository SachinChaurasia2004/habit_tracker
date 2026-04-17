import 'dart:async';

import 'notification_service.dart';

class StreakNotificationService {
  static final StreakNotificationService _instance =
      StreakNotificationService._internal();

  final NotificationService _notificationService = NotificationService();

  StreakNotificationService._internal();

  factory StreakNotificationService() {
    return _instance;
  }

  /// Initialize the streak notification service
  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  /// Request OS notification permissions after explaining why they are needed.
  Future<bool> requestPermissions() async {
    return _notificationService.requestPermissions();
  }

  /// Check whether notifications are enabled when supported by the platform.
  Future<bool> areNotificationsEnabled() async {
    return _notificationService.areNotificationsEnabled();
  }

  /// Show a congratulation notification when a habit is completed
  void showHabitCompletedNotification({
    required String habitName,
    required int streak,
  }) {
    final String title = 'Great Job! 🎉';
    final String body =
        '$habitName completed! You\'re on a $streak day streak!';
    final int notificationId = habitName.hashCode;

    _notificationService.showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: 'habit_completed:$habitName',
    );
  }

  /// Show milestone notification for streaks (7, 14, 30, etc.)
  void showStreakMilestoneNotification({
    required String habitName,
    required int streak,
  }) {
    late final String title;
    late final String emoji;

    if (streak == 7) {
      title = 'One Week Strong! 🌟';
      emoji = '⭐';
    } else if (streak == 14) {
      title = 'Two Weeks Incredible! 💪';
      emoji = '💪';
    } else if (streak == 30) {
      title = 'One Month Legend! 🏆';
      emoji = '🏆';
    } else if (streak == 60) {
      title = 'Two Months Unstoppable! 🚀';
      emoji = '🚀';
    } else if (streak == 100) {
      title = 'Century Club! 💯';
      emoji = '💯';
    } else {
      return; // No notification for other milestones
    }

    final String body =
        '$habitName: $streak day streak! $emoji\nYou\'re making incredible progress!';
    final int notificationId = 'milestone_${habitName.hashCode}'.hashCode;

    _notificationService.showNotification(
      id: notificationId % 2147483647, // Ensure positive ID
      title: title,
      body: body,
      payload: 'milestone_reached:$habitName:$streak',
    );
  }

  /// Show a reminder notification for incomplete habits
  void showIncompleteHabitReminder({
    required String habitName,
    required int missedDays,
  }) {
    final String title = 'Habit Reminder';
    final String body =
        'You still have $habitName to finish today.\n'
        'A small step now keeps your momentum going.';
    final int notificationId = 'reminder_${habitName.hashCode}'.hashCode;

    _notificationService.showNotification(
      id: notificationId % 2147483647, // Ensure positive ID
      title: title,
      body: body,
      payload: 'streak_reminder:$habitName',
    );
  }

  /// Schedule a one-time reminder for an incomplete habit.
  Future<void> scheduleIncompleteHabitReminder({
    required String habitId,
    required String habitName,
    required DateTime reminderTime,
  }) async {
    try {
      final String title = 'Habit Reminder';
      final String body =
          'You still have $habitName to finish today.\n'
          'A small step now keeps your momentum going.';
      final int notificationId = _incompleteReminderId(habitId);

      print(
        '[StreakNotificationService] Scheduling incomplete reminder: '
        'habitId=$habitId, habitName=$habitName, '
        'reminderTime=$reminderTime, notificationId=$notificationId',
      );

      // Schedule with standard notification service
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: title,
        body: body,
        scheduledTime: reminderTime,
        payload: 'streak_reminder:$habitId',
      );

      print(
        '[StreakNotificationService] Incomplete reminder scheduled successfully',
      );
    } catch (e) {
      print(
        '[StreakNotificationService] Failed to schedule incomplete reminder: $e',
      );
      rethrow;
    }
  }

  /// Cancel today's pending incomplete reminder for a habit.
  Future<void> cancelIncompleteHabitReminder(String habitId) async {
    await _notificationService.cancelNotification(
      _incompleteReminderId(habitId),
    );
  }

  /// Show a streak broken notification
  void showStreakBrokenNotification({
    required String habitName,
    required int previousStreak,
  }) {
    final String title = 'Streak Broken 💔';
    final String body =
        '$habitName streak ended at $previousStreak days.\n'
        'Don\'t worry, every streak starts again!';
    final int notificationId = 'broken_${habitName.hashCode}'.hashCode;

    _notificationService.showNotification(
      id: notificationId % 2147483647, // Ensure positive ID
      title: title,
      body: body,
      payload: 'streak_broken:$habitName',
    );
  }

  /// Schedule a daily reminder notification
  Future<void> scheduleDailyReminderNotification({
    required String habitName,
    required DateTime reminderTime,
  }) async {
    final String title = 'Time to Build Your Streak! ⏰';
    final String body = 'Don\'t forget to complete $habitName today!';
    final int notificationId = 'daily_${habitName.hashCode}'.hashCode;

    await _notificationService.scheduleDailyNotification(
      id: notificationId % 2147483647, // Ensure positive ID
      title: title,
      body: body,
      time: reminderTime,
      payload: 'daily_reminder:$habitName',
    );
  }

  /// Cancel daily reminder for a habit
  Future<void> cancelDailyReminder(String habitName) async {
    final int notificationId = 'daily_${habitName.hashCode}'.hashCode;
    await _notificationService.cancelNotification(notificationId % 2147483647);
  }

  /// Cancel all streak notifications
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  /// Get notification messages based on streak length (for UI feedback)
  static String getStreakMessage(int streak) {
    if (streak == 0) {
      return 'Start your streak today!';
    } else if (streak == 1) {
      return 'Great start! Keep it going! 🌱';
    } else if (streak < 7) {
      return 'You\'re on fire! 🔥';
    } else if (streak < 14) {
      return 'One week strong! 🌟';
    } else if (streak < 30) {
      return 'Two weeks incredible! 💪';
    } else if (streak < 60) {
      return 'One month legend! 🏆';
    } else if (streak < 100) {
      return 'Two months unstoppable! 🚀';
    } else {
      return 'Century club! 💯';
    }
  }

  /// Check if a milestone was reached
  static bool isMilestoneStreak(int streak) {
    return streak == 7 ||
        streak == 14 ||
        streak == 30 ||
        streak == 60 ||
        streak == 100;
  }

  int _incompleteReminderId(String habitId) {
    return 'incomplete_$habitId'.hashCode & 0x7fffffff;
  }
}
