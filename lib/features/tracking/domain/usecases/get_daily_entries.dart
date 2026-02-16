import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_entry.dart';
import '../repositories/tracking_repository.dart';

/// Use case for retrieving all habit entries for a specific date
class GetDailyEntries implements UseCase<List<HabitEntry>, GetDailyEntriesParams> {
  final TrackingRepository repository;

  GetDailyEntries(this.repository);

  @override
  Future<Either<Failure, List<HabitEntry>>> call(GetDailyEntriesParams params) async {
    // Normalize the date (remove time component)
    final normalizedDate = DateTime(
      params.date.year,
      params.date.month,
      params.date.day,
    );

    return await repository.getEntriesForDate(normalizedDate);
  }
}

/// Parameters for getting daily entries
class GetDailyEntriesParams {
  final DateTime date;

  const GetDailyEntriesParams({required this.date});
}