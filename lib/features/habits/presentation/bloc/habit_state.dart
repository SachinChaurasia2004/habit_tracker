import 'package:equatable/equatable.dart';
import '../../domain/entities/habit.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HabitInitial extends HabitState {
  const HabitInitial();
}

/// Loading state
class HabitLoading extends HabitState {
  const HabitLoading();
}

/// Habits loaded successfully
class HabitsLoaded extends HabitState {
  final List<Habit> habits;

  const HabitsLoaded(this.habits);

  @override
  List<Object?> get props => [habits];
}

/// Habit created successfully
class HabitCreated extends HabitState {
  final Habit habit;

  const HabitCreated(this.habit);

  @override
  List<Object?> get props => [habit];
}

/// Habit updated successfully
class HabitUpdated extends HabitState {
  final Habit habit;

  const HabitUpdated(this.habit);

  @override
  List<Object?> get props => [habit];
}

/// Habit deleted successfully
class HabitDeleted extends HabitState {
  const HabitDeleted();
}

/// Error state
class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object?> get props => [message];
}