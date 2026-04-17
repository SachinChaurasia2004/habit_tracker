import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for updating an existing habit
class UpdateHabit implements UseCase<Habit, UpdateHabitParams> {
  final HabitRepository repository;

  UpdateHabit(this.repository);

  @override
  Future<Either<Failure, Habit>> call(UpdateHabitParams params) async {
    // Validate habit name if provided
    if (params.name != null) {
      final nameValidation = Validators.validateHabitName(params.name);
      if (nameValidation != null) {
        return Left(nameValidation);
      }
    }

    // Get the existing habit
    final habitResult = await repository.getHabitById(params.habitId);

    return habitResult.fold((failure) => Left(failure), (existingHabit) async {
      // Create updated habit with new values
      final updatedHabit = existingHabit.copyWith(
        name: params.name ?? existingHabit.name,
        iconName: params.iconName ?? existingHabit.iconName,
        colorCode: params.colorCode ?? existingHabit.colorCode,
        isActive: params.isActive ?? existingHabit.isActive,
        reminderHour: params.reminderHour,
        reminderMinute: params.reminderMinute,
        clearReminder: params.clearReminder,
      );

      return await repository.updateHabit(updatedHabit);
    });
  }
}

/// Parameters for updating a habit
class UpdateHabitParams {
  final String habitId;
  final String? name;
  final String? iconName;
  final int? colorCode;
  final bool? isActive;
  final int? reminderHour;
  final int? reminderMinute;
  final bool clearReminder;

  const UpdateHabitParams({
    required this.habitId,
    this.name,
    this.iconName,
    this.colorCode,
    this.isActive,
    this.reminderHour,
    this.reminderMinute,
    this.clearReminder = false,
  });
}
