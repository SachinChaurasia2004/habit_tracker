import 'package:hive/hive.dart';
import '../../domain/entities/habit_entry.dart';

part 'habit_entry_model.g.dart';

@HiveType(typeId: 1)
class HabitEntryModel extends HabitEntry {
  @override
  @HiveField(0)
  final String id;
  
  @override
  @HiveField(1)
  final String habitId;
  
  @override
  @HiveField(2)
  final DateTime date;
  
  @override
  @HiveField(3)
  final bool isCompleted;

  const HabitEntryModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  }) : super(
          id: id,
          habitId: habitId,
          date: date,
          isCompleted: isCompleted,
        );

  /// Convert Entity to Model
  factory HabitEntryModel.fromEntity(HabitEntry entry) {
    return HabitEntryModel(
      id: entry.id,
      habitId: entry.habitId,
      date: entry.date,
      isCompleted: entry.isCompleted,
    );
  }

  /// Convert Model to Entity
  HabitEntry toEntity() {
    return HabitEntry(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  /// From JSON
  factory HabitEntryModel.fromJson(Map<String, dynamic> json) {
    return HabitEntryModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  /// Copy with
  @override
  HabitEntryModel copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
  }) {
    return HabitEntryModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Helper to get normalized date key for indexing
  static String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get this entry's date key
  String get dateKey => getDateKey(date);
}