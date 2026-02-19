import '../error/failures.dart';

/// Validator class for common validation logic
class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  /// Validate habit name
  static Failure? validateHabitName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return const ValidationFailure('Habit name cannot be empty');
    }

    if (name.trim().isEmpty) {
      return const ValidationFailure('Habit name cannot be empty');
    }

    if (name.length > 50) {
      return const ValidationFailure(
        'Habit name too long (max 50 characters)',
      );
    }

    // Check for only whitespace
    if (name.trim().isEmpty) {
      return const ValidationFailure('Habit name cannot be only spaces');
    }

    return null; // Valid
  }

  /// Validate user profile name
  static Failure? validateProfileName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return const ValidationFailure('Name cannot be empty');
    }

    if (name.trim().length < 1) {
      return const ValidationFailure('Name must be at least 1 character');
    }

    if (name.length > 50) {
      return const ValidationFailure('Name too long (max 50 characters)');
    }

    return null; // Valid
  }

  /// Validate habit icon name
  static Failure? validateIconName(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return const ValidationFailure('Icon must be selected');
    }

    // List of valid icon names
    const validIcons = [
      'yoga',
      'water',
      'book',
      'gym',
      'meditation',
      'walk',
      'sleep',
      'nutrition',
    ];

    if (!validIcons.contains(iconName)) {
      return const ValidationFailure('Invalid icon selected');
    }

    return null; // Valid
  }

  /// Validate color code
  static Failure? validateColorCode(int? colorCode) {
    if (colorCode == null) {
      return const ValidationFailure('Color must be selected');
    }

    // Check if color code is in valid range
    if (colorCode < 0 || colorCode > 0xFFFFFFFF) {
      return const ValidationFailure('Invalid color code');
    }

    return null; // Valid
  }

  /// Validate habit ID
  static Failure? validateHabitId(String? id) {
    if (id == null || id.isEmpty) {
      return const ValidationFailure('Habit ID cannot be empty');
    }

    // Optional: Add UUID format validation
    // if (!RegExp(r'^[a-f0-9-]{36}$').hasMatch(id)) {
    //   return const ValidationFailure('Invalid habit ID format');
    // }

    return null; // Valid
  }

  /// Validate date
  static Failure? validateDate(DateTime? date) {
    if (date == null) {
      return const ValidationFailure('Date cannot be null');
    }

    // Check if date is too far in the past (more than 10 years)
    final tenYearsAgo = DateTime.now().subtract(const Duration(days: 3650));
    if (date.isBefore(tenYearsAgo)) {
      return const ValidationFailure('Date is too far in the past');
    }

    // Check if date is in the future
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (date.isAfter(tomorrow)) {
      return const ValidationFailure('Date cannot be in the future');
    }

    return null; // Valid
  }

  /// Validate email (for future use)
  static Failure? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return const ValidationFailure('Email cannot be empty');
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return const ValidationFailure('Invalid email format');
    }

    return null; // Valid
  }

  /// Validate password (for future use)
  static Failure? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return const ValidationFailure('Password cannot be empty');
    }

    if (password.length < 6) {
      return const ValidationFailure(
        'Password must be at least 6 characters',
      );
    }

    if (password.length > 50) {
      return const ValidationFailure('Password too long (max 50 characters)');
    }

    return null; // Valid
  }

  /// Validate multiple fields at once
  static List<Failure> validateAll(List<Failure? Function()> validators) {
    final failures = <Failure>[];
    
    for (final validator in validators) {
      final failure = validator();
      if (failure != null) {
        failures.add(failure);
      }
    }
    
    return failures;
  }

  /// Check if string contains only alphanumeric and spaces
  static bool isAlphanumericWithSpaces(String text) {
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text);
  }

  /// Check if string contains special characters
  static bool hasSpecialCharacters(String text) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text);
  }
}