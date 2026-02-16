import 'package:equatable/equatable.dart';

/// Represents a single tracking entry for a habit on a specific date.
/// Records whether the habit was completed on that day.
class HabitEntry extends Equatable {
  /// Unique identifier for this entry
  final String id;
  
  /// Reference to the parent Habit
  final String habitId;
  
  /// The date this entry is for (time component should be stripped)
  final DateTime date;
  
  /// Whether the habit was completed on this date
  final bool isCompleted;

  const HabitEntry({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });

  /// Creates a copy with the given fields replaced
  HabitEntry copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? isCompleted,
  }) {
    return HabitEntry(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Returns a normalized date (with time component stripped to 00:00:00)
  DateTime get normalizedDate {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  List<Object?> get props => [id, habitId, normalizedDate, isCompleted];

  @override
  bool get stringify => true;
}