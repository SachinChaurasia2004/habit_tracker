import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for creating a new habit
class CreateHabit implements UseCase<Habit, CreateHabitParams> {
  final HabitRepository repository;

  CreateHabit(this.repository);

  @override
  Future<Either<Failure, Habit>> call(CreateHabitParams params) async {
    
     final nameValidation = Validators.validateHabitName(params.name);
    if (nameValidation != null) {
      return Left(nameValidation);
    }

    // Create the habit entity
    final habit = Habit(
      id: params.id,
      name: params.name.trim(),
      iconName: params.iconName,
      colorCode: params.colorCode,
      createdAt: DateTime.now(),
      isActive: true,
      reminderHour: params.reminderHour,
      reminderMinute: params.reminderMinute,
    );

    return await repository.createHabit(habit);
  }
}

/// Parameters for creating a habit
class CreateHabitParams {
  final String id;
  final String name;
  final String iconName;
  final int colorCode;
  final int? reminderHour;
  final int? reminderMinute;

  const CreateHabitParams({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
    this.reminderHour,
    this.reminderMinute,
  });
}
