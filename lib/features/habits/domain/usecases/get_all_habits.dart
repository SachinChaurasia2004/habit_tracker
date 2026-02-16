import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Use case for retrieving all habits
class GetAllHabits implements UseCaseNoParams<List<Habit>> {
  final HabitRepository repository;

  GetAllHabits(this.repository);

  @override
  Future<Either<Failure, List<Habit>>> call() async {
    return await repository.getAllHabits();
  }
}