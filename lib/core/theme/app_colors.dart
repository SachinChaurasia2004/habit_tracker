import 'package:flutter/material.dart';

class AppColors {
  // Background Colors
  static const Color background = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color surfaceVariant = Color(0xFF333333);

  // Primary Brand Color
  static const Color primary = Color(0xFF6366F1); // Purple/Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);

  // Habit Colors (from your screenshot)
  static const Color yogaGreen = Color(0xFF10B981);
  static const Color waterBlue = Color(0xFF3B82F6);
  static const Color readOrange = Color(0xFFF59E0B);
  static const Color gymRed = Color(0xFFEF4444);
  static const Color meditationPurple = Color(0xFF8B5CF6);
  static const Color walkYellow = Color(0xFFFBBF24);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // UI Element Colors
  static const Color divider = Color(0xFF374151);
  static const Color disabled = Color(0xFF4B5563);
  static const Color overlay = Color(0x80000000);

  // Gradient Colors
  static const List<Color> progressGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  // Habit Color Palette (for user selection)
  static const List<Color> habitColors = [
    yogaGreen,
    waterBlue,
    readOrange,
    gymRed,
    meditationPurple,
    walkYellow,
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
  ];

  // Get color by index (safe access)
  static Color getHabitColor(int index) {
    return habitColors[index % habitColors.length];
  }

  // Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  // Convert hex string to color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}