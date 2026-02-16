class AppConstants {
  // App Info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';

  // Database
  static const String habitsBoxName = 'habits';
  static const String entriesBoxName = 'entries';
  static const String profileBoxName = 'profile';

  // Preferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastSyncDate = 'last_sync_date';

  // Validation
  static const int habitNameMinLength = 1;
  static const int habitNameMaxLength = 50;
  static const int profileNameMaxLength = 50;

  // UI
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Date Formats
  static const String dateFormatFull = 'MMMM dd, yyyy';
  static const String dateFormatShort = 'MMM dd';
  static const String dateFormatKey = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';

  // Week Days
  static const List<String> weekDaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> weekDaysFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  // Habit Icons
  static const List<String> habitIcons = [
    'yoga',
    'water',
    'book',
    'gym',
    'meditation',
    'walk',
    'sleep',
    'nutrition',
  ];

  // Progress Messages
  static const List<String> motivationalMessages = [
    'Keep it up! 👏',
    'You\'re doing great! 🌟',
    'Amazing progress! 🎉',
    'Way to go! 💪',
    'Fantastic! 🔥',
    'You\'re on fire! 🚀',
    'Crushing it! 💯',
    'Unstoppable! ⚡',
  ];

  // Get motivational message based on progress
  static String getMotivationalMessage(double progress) {
    if (progress >= 100) {
      return 'Perfect day! 🎉';
    } else if (progress >= 75) {
      return motivationalMessages[2]; // Amazing progress
    } else if (progress >= 50) {
      return motivationalMessages[1]; // You're doing great
    } else if (progress >= 25) {
      return motivationalMessages[0]; // Keep it up
    } else {
      return 'Let\'s get started! 💪';
    }
  }

  // Streak Messages
  static String getStreakMessage(int streak) {
    if (streak >= 30) {
      return '🏆 Legendary!';
    } else if (streak >= 21) {
      return '🔥 On fire!';
    } else if (streak >= 14) {
      return '⭐ Amazing!';
    } else if (streak >= 7) {
      return '💪 Great job!';
    } else if (streak >= 3) {
      return '👍 Keep going!';
    } else if (streak >= 1) {
      return '🌱 Nice start!';
    } else {
      return '';
    }
  }
}