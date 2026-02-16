import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/habit_entry.dart';

/// Repository interface for habit tracking operations
abstract class TrackingRepository {
  /// Creates a new habit entry
  /// Returns the created entry or a Failure
  Future<Either<Failure, HabitEntry>> createEntry(HabitEntry entry);

  /// Retrieves all entries for a specific habit
  /// Returns a list of entries or a Failure
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabit(String habitId);

  /// Retrieves all entries for a specific date
  /// Returns a list of entries or a Failure
  Future<Either<Failure, List<HabitEntry>>> getEntriesForDate(DateTime date);

  /// Retrieves entries for a habit within a date range
  /// Returns a list of entries or a Failure
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabitInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Retrieves a specific entry by habit and date
  /// Returns the entry or null if not found, or a Failure
  Future<Either<Failure, HabitEntry?>> getEntryByHabitAndDate({
    required String habitId,
    required DateTime date,
  });

  /// Updates an existing habit entry
  /// Returns the updated entry or a Failure
  Future<Either<Failure, HabitEntry>> updateEntry(HabitEntry entry);

  /// Toggles the completion status of a habit entry
  /// Creates a new entry if one doesn't exist for that date
  /// Returns the entry or a Failure
  Future<Either<Failure, HabitEntry>> toggleCompletion({
    required String habitId,
    required DateTime date,
  });

  /// Deletes a habit entry
  /// Returns Unit (void success) or a Failure
  Future<Either<Failure, Unit>> deleteEntry(String id);

  /// Deletes all entries for a specific habit
  /// Used when a habit is deleted
  /// Returns Unit (void success) or a Failure
  Future<Either<Failure, Unit>> deleteEntriesForHabit(String habitId);

  /// Calculates the current streak for a habit
  /// Returns the streak count or a Failure
  Future<Either<Failure, int>> calculateStreak(String habitId);

  /// Gets the completion percentage for a specific date
  /// Returns the percentage (0-100) or a Failure
  Future<Either<Failure, double>> getDailyCompletionPercentage(DateTime date);
}