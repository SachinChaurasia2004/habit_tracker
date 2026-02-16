import 'package:equatable/equatable.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

/// Load all habits
class LoadHabitsEvent extends HabitEvent {
  const LoadHabitsEvent();
}

/// Load only active habits
class LoadActiveHabitsEvent extends HabitEvent {
  const LoadActiveHabitsEvent();
}

/// Create a new habit
class CreateHabitEvent extends HabitEvent {
  final String name;
  final String iconName;
  final int colorCode;

  const CreateHabitEvent({
    required this.name,
    required this.iconName,
    required this.colorCode,
  });

  @override
  List<Object?> get props => [name, iconName, colorCode];
}

/// Update an existing habit
class UpdateHabitEvent extends HabitEvent {
  final String habitId;
  final String? name;
  final String? iconName;
  final int? colorCode;
  final bool? isActive;

  const UpdateHabitEvent({
    required this.habitId,
    this.name,
    this.iconName,
    this.colorCode,
    this.isActive,
  });

  @override
  List<Object?> get props => [habitId, name, iconName, colorCode, isActive];
}

/// Delete a habit
class DeleteHabitEvent extends HabitEvent {
  final String habitId;

  const DeleteHabitEvent(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

/// Refresh habits list
class RefreshHabitsEvent extends HabitEvent {
  const RefreshHabitsEvent();
}