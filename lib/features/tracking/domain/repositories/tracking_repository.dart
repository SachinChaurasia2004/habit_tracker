import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit_entry.dart';

/// Repository interface for habit tracking operations
abstract class TrackingRepository {
  /// Creates a new habit entry
  Future<Either<Failure, HabitEntry>> createEntry(HabitEntry entry);

  /// Retrieves all entries for a specific habit
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabit(String habitId);

  /// Retrieves all entries for a specific date
  Future<Either<Failure, List<HabitEntry>>> getEntriesForDate(DateTime date);

  /// Retrieves entries for a habit within a date range
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabitInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retrieves a specific entry by habit and date
  Future<Either<Failure, HabitEntry?>> getEntryByHabitAndDate({
    required String habitId,
    required DateTime date,
  });

  /// Updates an existing habit entry
  Future<Either<Failure, HabitEntry>> updateEntry(HabitEntry entry);

  /// Toggles the completion status of a habit entry
  Future<Either<Failure, HabitEntry>> toggleCompletion({
    required String habitId,
    required DateTime date,
  });

  /// Deletes a habit entry
  Future<Either<Failure, Unit>> deleteEntry(String id);

  /// Deletes all entries for a specific habit
  Future<Either<Failure, Unit>> deleteEntriesForHabit(String habitId);

  /// Calculates the current streak for a habit
  Future<Either<Failure, int>> calculateStreak(String habitId);

  /// Gets the completion percentage for a specific date
  Future<Either<Failure, double>> getDailyCompletionPercentage(DateTime date);
}