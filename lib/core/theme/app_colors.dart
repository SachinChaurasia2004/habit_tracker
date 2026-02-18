import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const Color background = Color(0xFF1A1A1A); 
  static const Color cardBackground = Color.fromARGB(255, 42, 42, 42);
  static const Color surfaceVariant = Color(0xFF333333);

  // Primary Brand Color
  static const Color primary = Color(0xFF6366F1); 
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Habit Colors
  static const Color yogaGreen = Color(0xFF10B981);
  static const Color waterBlue = Color(0xFF3B82F6);
  static const Color readOrange = Color(0xFFF59E0B);
  static const Color gymRed = Color(0xFFEF4444);
  static const Color meditationPurple = Color(0xFF8B5CF6);
  static const Color walkYellow = Color(0xFFFBBF24);

  // UI Element Colors
  static const Color divider = Color(0xFF374151);
  static const Color disabled = Color(0xFF4B5563);
  static const Color overlay = Color(0x80000000);

  // Gradient Colors
  static const List<Color> progressGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  // Habit Color Palette
  static const List<Color> habitColors = [
    yogaGreen,
    waterBlue,
    readOrange,
    gymRed,
    meditationPurple,
    walkYellow,
    Color(0xFFEC4899), 
    Color(0xFF14B8A6), 
  ];

  static Color getHabitColor(int index) {
    return habitColors[index % habitColors.length];
  }
}
