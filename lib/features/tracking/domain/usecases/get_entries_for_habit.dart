import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entry.dart';
import '../repositories/tracking_repository.dart';

/// Use case for retrieving all entries for a specific habit
class GetEntriesForHabit implements UseCase<List<HabitEntry>, GetEntriesForHabitParams> {
  final TrackingRepository repository;

  GetEntriesForHabit(this.repository);

  @override
  Future<Either<Failure, List<HabitEntry>>> call(GetEntriesForHabitParams params) async {
    if (params.startDate != null && params.endDate != null) {
      // Get entries within date range
      return await repository.getEntriesForHabitInRange(
        habitId: params.habitId,
        startDate: params.startDate!,
        endDate: params.endDate!,
      );
    } else {
      // Get all entries for habit
      return await repository.getEntriesForHabit(params.habitId);
    }
  }
}

/// Parameters for getting entries for a habit
class GetEntriesForHabitParams {
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetEntriesForHabitParams({
    required this.habitId,
    this.startDate,
    this.endDate,
  });
}