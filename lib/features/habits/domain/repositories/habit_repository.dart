import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  /// Creates a new habit
  /// Returns the created habit or a Failure
  Future<Either<Failure, Habit>> createHabit(Habit habit);

  /// Retrieves all habits (active and inactive)
  /// Returns a list of habits or a Failure
  Future<Either<Failure, List<Habit>>> getAllHabits();

  /// Retrieves only active habits
  /// Returns a list of active habits or a Failure
  Future<Either<Failure, List<Habit>>> getActiveHabits();

  /// Retrieves a specific habit by ID
  /// Returns the habit or a Failure if not found
  Future<Either<Failure, Habit>> getHabitById(String id);

  /// Updates an existing habit
  /// Returns the updated habit or a Failure
  Future<Either<Failure, Habit>> updateHabit(Habit habit);

  /// Deletes a habit by ID
  /// Returns Unit (void success) or a Failure
  Future<Either<Failure, Unit>> deleteHabit(String id);

  /// Soft deletes a habit (marks as inactive)
  /// Returns the updated habit or a Failure
  Future<Either<Failure, Habit>> deactivateHabit(String id);

  /// Reactivates an inactive habit
  /// Returns the updated habit or a Failure
  Future<Either<Failure, Habit>> reactivateHabit(String id);
}