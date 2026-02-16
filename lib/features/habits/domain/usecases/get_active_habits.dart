import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for retrieving only active habits
class GetActiveHabits implements UseCaseNoParams<List<Habit>> {
  final HabitRepository repository;

  GetActiveHabits(this.repository);

  @override
  Future<Either<Failure, List<Habit>>> call() async {
    return await repository.getActiveHabits();
  }
}