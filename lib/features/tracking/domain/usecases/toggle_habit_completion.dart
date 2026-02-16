import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entry.dart';
import '../repositories/tracking_repository.dart';

/// Use case for toggling a habit's completion status for a specific date
/// Creates a new entry if one doesn't exist
class ToggleHabitCompletion implements UseCase<HabitEntry, ToggleHabitCompletionParams> {
  final TrackingRepository repository;

  ToggleHabitCompletion(this.repository);

  @override
  Future<Either<Failure, HabitEntry>> call(ToggleHabitCompletionParams params) async {
    // Normalize the date (remove time component)
    final normalizedDate = DateTime(
      params.date.year,
      params.date.month,
      params.date.day,
    );

    return await repository.toggleCompletion(
      habitId: params.habitId,
      date: normalizedDate,
    );
  }
}

/// Parameters for toggling habit completion
class ToggleHabitCompletionParams {
  final String habitId;
  final DateTime date;

  const ToggleHabitCompletionParams({
    required this.habitId,
    required this.date,
  });
}