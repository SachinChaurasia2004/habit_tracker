import 'package:equatable/equatable.dart';

/// Represents a habit that the user wants to track.

class Habit extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final int colorCode;
  final DateTime createdAt;
  final bool isActive;
  final int? reminderHour;
  final int? reminderMinute;

  const Habit({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
    required this.createdAt,
    this.isActive = true,
    this.reminderHour,
    this.reminderMinute,
  });

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  Habit copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorCode,
    DateTime? createdAt,
    bool? isActive,
    int? reminderHour,
    int? reminderMinute,
    bool clearReminder = false,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      reminderHour: clearReminder ? null : reminderHour ?? this.reminderHour,
      reminderMinute:
          clearReminder ? null : reminderMinute ?? this.reminderMinute,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        colorCode,
        createdAt,
        isActive,
        reminderHour,
        reminderMinute,
      ];

  @override
  bool get stringify => true;
}
