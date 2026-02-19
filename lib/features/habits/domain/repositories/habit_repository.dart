import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  /// Creates a new habit
  Future<Either<Failure, Habit>> createHabit(Habit habit);

  /// Retrieves all habits (active and inactive)
  Future<Either<Failure, List<Habit>>> getAllHabits();

  /// Retrieves only active habits
  Future<Either<Failure, List<Habit>>> getActiveHabits();

  /// Retrieves a specific habit by ID
  Future<Either<Failure, Habit>> getHabitById(String id);

  /// Updates an existing habit
  Future<Either<Failure, Habit>> updateHabit(Habit habit);

  /// Deletes a habit by ID
  Future<Either<Failure, Unit>> deleteHabit(String id);

  /// Soft deletes a habit (marks as inactive)
  Future<Either<Failure, Habit>> deactivateHabit(String id);

  /// Reactivates an inactive habit
  Future<Either<Failure, Habit>> reactivateHabit(String id);
}