import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/date_helper.dart';
import '../repositories/tracking_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetMonthlyCompletion implements UseCase<Map<String, double>, GetMonthlyCompletionParams> {
  final TrackingRepository trackingRepository;
  final HabitRepository habitRepository;

  GetMonthlyCompletion({
    required this.trackingRepository,
    required this.habitRepository,
  });

  @override
  Future<Either<Failure, Map<String, double>>> call(
    GetMonthlyCompletionParams params,
  ) async {
    try {
      // Get active habits
      final habitsResult = await habitRepository.getActiveHabits();
      final habits = habitsResult.fold((l) => [], (r) => r);

      if (habits.isEmpty) {
        return const Right({});
      }

      // Get first and last day of month
      final year = params.month.year;
      final month = params.month.month;
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      // Get all entries for the month
      final entriesResult = await trackingRepository.getAllEntriesInRange(
        startDate: firstDay,
        endDate: lastDay,
      );

      final entries = entriesResult.fold((l) => [], (r) => r);

      // Group entries by date
      final entriesByDate = <String, List<dynamic>>{};
      for (final entry in entries) {
        final dateKey = DateHelper.getDateKey(entry.date);
        entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
      }

      // Calculate completion rate for each day
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
          final completedCount = dayEntries.where((e) => e.isCompleted).length;
          final percentage = (completedCount / habits.length) * 100;
          completionData[dateKey] = percentage;
        }
      }

      return Right(completionData);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class GetMonthlyCompletionParams {
  final DateTime month;

  const GetMonthlyCompletionParams({required this.month});
}