import 'package:equatable/equatable.dart';
import '../../domain/entities/habit_entry.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TrackingInitial extends TrackingState {
  const TrackingInitial();
}

/// Loading state
class TrackingLoading extends TrackingState {
  const TrackingLoading();
}

/// Tracking data loaded
class TrackingLoaded extends TrackingState {
  final List<HabitEntry> entries;
  final double progressPercentage;
  final Map<String, int> streaks;
  final DateTime date;

  const TrackingLoaded({
    required this.entries,
    required this.progressPercentage,
    required this.streaks,
    required this.date,
  });

  @override
  List<Object?> get props => [entries, progressPercentage, streaks, date];

  /// Check if a habit is completed
  bool isHabitCompleted(String habitId) {
    return entries.any((entry) => 
      entry.habitId == habitId && entry.isCompleted
    );
  }

  /// Get completion count
  int get completedCount => entries.where((e) => e.isCompleted).length;

  /// Get total count
  int get totalCount => entries.length;
}

/// Habit completion toggled
class HabitCompletionToggled extends TrackingState {
  final HabitEntry entry;

  const HabitCompletionToggled(this.entry);

  @override
  List<Object?> get props => [entry];
}

/// Error state
class TrackingError extends TrackingState {
  final String message;

  const TrackingError(this.message);

  @override
  List<Object?> get props => [message];
}