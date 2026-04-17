import 'package:hive/hive.dart';
import '../../domain/entities/habit.dart';

part 'habit_model.g.dart'; 

@HiveType(typeId: 0)
class HabitModel extends Habit {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final String name;
  
  @override
  @HiveField(2)
  final String iconName;
  
  @override
  @HiveField(3)
  final int colorCode;
  
  @override
  @HiveField(4)
  final DateTime createdAt;
  
  @override
  @HiveField(5)
  final bool isActive;

  @override
  @HiveField(6)
  final int? reminderHour;

  @override
  @HiveField(7)
  final int? reminderMinute;

  const HabitModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
    required this.createdAt,
    this.isActive = true,
    this.reminderHour,
    this.reminderMinute,
  }) : super(
          id: id,
          name: name,
          iconName: iconName,
          colorCode: colorCode,
          createdAt: createdAt,
          isActive: isActive,
          reminderHour: reminderHour,
          reminderMinute: reminderMinute,
        );

  /// Convert Entity to Model (for saving to Hive)
  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      name: habit.name,
      iconName: habit.iconName,
      colorCode: habit.colorCode,
      createdAt: habit.createdAt,
      isActive: habit.isActive,
      reminderHour: habit.reminderHour,
      reminderMinute: habit.reminderMinute,
    );
  }

  /// Convert Model to Entity (for business logic)
  Habit toEntity() {
    return Habit(
      id: id,
      name: name,
      iconName: iconName,
      colorCode: colorCode,
      createdAt: createdAt,
      isActive: isActive,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );
  }

  /// For JSON serialization (future API integration)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorCode': colorCode,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
    };
  }

  /// From JSON deserialization
  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      colorCode: json['colorCode'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int?,
      reminderMinute: json['reminderMinute'] as int?,
    );
  }

  /// Create a copy with modified fields
  @override
  HabitModel copyWith({
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
    return HabitModel(
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
}
