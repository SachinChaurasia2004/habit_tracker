import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for creating a new habit
class CreateHabit implements UseCase<Habit, CreateHabitParams> {
  final HabitRepository repository;

  CreateHabit(this.repository);

  @override
  Future<Either<Failure, Habit>> call(CreateHabitParams params) async {
    // Validate habit name
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Habit name cannot be empty'));
    }

    if (params.name.length > 50) {
      return const Left(ValidationFailure('Habit name too long (max 50 characters)'));
    }

    // Create the habit entity
    final habit = Habit(
      id: params.id,
      name: params.name.trim(),
      iconName: params.iconName,
      colorCode: params.colorCode,
      createdAt: DateTime.now(),
      isActive: true,
    );

    // Delegate to repository
    return await repository.createHabit(habit);
  }
}

/// Parameters for creating a habit
class CreateHabitParams {
  final String id;
  final String name;
  final String iconName;
  final int colorCode;

  const CreateHabitParams({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
  });
}