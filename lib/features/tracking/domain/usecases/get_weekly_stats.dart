import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/date_helper.dart';
import '../entities/weekly_stats.dart';
import '../repositories/tracking_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetWeeklyStatistics implements UseCase<WeeklyStats, GetWeeklyStatisticsParams> {
  final TrackingRepository trackingRepository;
  final HabitRepository habitRepository;

  GetWeeklyStatistics({
    required this.trackingRepository,
    required this.habitRepository,
  });

  @override
  Future<Either<Failure, WeeklyStats>> call(GetWeeklyStatisticsParams params) async {
    try {
      final endDate = params.endDate ?? DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 6));

      // Get active habits count
      final habitsResult = await habitRepository.getActiveHabits();
      final totalHabits = habitsResult.fold((l) => 0, (r) => r.length);

      if (totalHabits == 0) {
        return const Right(WeeklyStats(
          dailyCompletions: [],
          averageCompletionRate: 0,
          totalCompletions: 0,
        ));
      }

      // Get all entries for the week (single bulk query)
      final entriesResult = await trackingRepository.getAllEntriesInRange(
        startDate: startDate,
        endDate: endDate,
      );

      final entries = entriesResult.fold((l) => [], (r) => r);

      // Group entries by date 
      final entriesByDate = <String, List<dynamic>>{};
      for (final entry in entries) {
        final dateKey = DateHelper.getDateKey(entry.date);
        entriesByDate.putIfAbsent(dateKey, () => []).add(entry);
      }

      // Generate daily completions for 7 days
      final dailyCompletions = List.generate(7, (index) {
        final date = DateHelper.normalize(startDate.add(Duration(days: index)));
        final dateKey = DateHelper.getDateKey(date);
        final dayEntries = entriesByDate[dateKey] ?? [];
        final completedCount = dayEntries.where((e) => e.isCompleted).length;

        return DailyCompletion(
          date: date,
          completedCount: completedCount,
          totalCount: totalHabits,
          percentage: (completedCount / totalHabits) * 100,
        );
      });

      final totalCompletions = dailyCompletions
          .map((d) => d.completedCount)
          .reduce((sum, count) => sum + count);

      final avgCompletionRate = dailyCompletions
          .map((d) => d.percentage)
          .reduce((sum, pct) => sum + pct) / 7;

      return Right(WeeklyStats(
        dailyCompletions: dailyCompletions,
        averageCompletionRate: avgCompletionRate,
        totalCompletions: totalCompletions,
      ));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class GetWeeklyStatisticsParams {
  final DateTime? endDate;

  const GetWeeklyStatisticsParams({this.endDate});
}