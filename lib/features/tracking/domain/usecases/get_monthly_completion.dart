import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/date_helper.dart';
import '../repositories/tracking_repository.dart';

class GetMonthlyCompletion
    implements UseCase<Map<String, double>, GetMonthlyCompletionParams> {
  final TrackingRepository trackingRepository;

  GetMonthlyCompletion({
    required this.trackingRepository,
  });

  @override
  Future<Either<Failure, Map<String, double>>> call(
    GetMonthlyCompletionParams params,
  ) async {
    try {
      // Get first and last day of month
      final year = params.month.year;
      final month = params.month.month;
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      // Get all entries for this habit in the month
      final entriesResult = await trackingRepository.getEntriesForHabitInRange(
        habitId: params.habitId,
        startDate: firstDay,
        endDate: lastDay,
      );

      return entriesResult.fold(
        (failure) => Left(failure),
        (entries) {
          // Group entries by date
          final entriesByDate = <String, List<dynamic>>{};
          for (final entry in entries) {
            final dateKey = DateHelper.getDateKey(entry.date);
            entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
          }

          // Calculate completion (0 or 100) for each day
          final completionData = <String, double>{};

          for (int day = 1; day <= lastDay.day; day++) {
            final date = DateTime(year, month, day);

            // Skip future dates
            if (date.isAfter(DateTime.now())) continue;

            final dateKey = DateHelper.getDateKey(date);
            final dayEntries = entriesByDate[dateKey] ?? [];

            if (dayEntries.isEmpty) {
              completionData[dateKey] = 0.0;
            } else {
              final hasCompleted = dayEntries.any((e) => e.isCompleted);
              completionData[dateKey] = hasCompleted ? 100.0 : 0.0;
            }
          }

          return Right(completionData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class GetMonthlyCompletionParams {
  final DateTime month;
  final String habitId;

  const GetMonthlyCompletionParams({
    required this.month,
    required this.habitId,
  });
}