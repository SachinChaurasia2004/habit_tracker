import 'package:intl/intl.dart';

class DateHelper {
  /// Normalize date (remove time component)
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get date key for storage (yyyy-MM-dd)
  static String getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse date key to DateTime
  static DateTime parseDateKey(String key) {
    return DateFormat('yyyy-MM-dd').parse(key);
  }

  /// Format date for display (e.g., "Feb 15")
  static String formatShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// Format date for display (e.g., "February 15, 2026")
  static String formatFull(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  /// Format date relative to today (Today, Yesterday, Feb 15)
  static String formatRelative(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatShort(date);
    }
  }

  /// Get day of week (Monday, Tuesday, etc.)
  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get day of week short (Mon, Tue, etc.)
  static String getDayOfWeekShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Get current week dates (Monday to Sunday)
  static List<DateTime> getCurrentWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    return List.generate(7, (index) {
      return normalize(monday.add(Duration(days: index)));
    });
  }

  /// Get date range for last N days
  static List<DateTime> getLastNDays(int days) {
    final now = normalize(DateTime.now());
    return List.generate(days, (index) {
      return now.subtract(Duration(days: days - 1 - index));
    });
  }

  /// Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startNormalized = normalize(start);
    final endNormalized = normalize(end);
    return endNormalized.difference(startNormalized).inDays;
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    final now = normalize(DateTime.now());
    final checkDate = normalize(date);
    return checkDate.isAfter(now);
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = normalize(DateTime.now());
    final checkDate = normalize(date);
    return checkDate.isBefore(now);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    return normalize(date.subtract(Duration(days: date.weekday - 1)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    return normalize(date.add(Duration(days: 7 - date.weekday)));
  }

  /// Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Get year
  static String getYear(DateTime date) {
    return DateFormat('yyyy').format(date);
  }
}