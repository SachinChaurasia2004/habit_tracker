import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/date_helper.dart';
import '../entities/overall_stats.dart';
import '../repositories/tracking_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetOverallStatistics implements UseCase<OverallStats, GetOverallStatisticsParams> {
  final TrackingRepository trackingRepository;
  final HabitRepository habitRepository;

  GetOverallStatistics({
    required this.trackingRepository,
    required this.habitRepository,
  });

  @override
  Future<Either<Failure, OverallStats>> call(GetOverallStatisticsParams params) async {
    try {
      // Get all active habits
      final habitsResult = await habitRepository.getActiveHabits();
      final habits = habitsResult.fold((l) => [], (r) => r);

      if (habits.isEmpty) {
        return const Right(
          OverallStats(
            totalHabits: 0,
            daysTracked: 0,
            overallCompletionRate: 0,
            bestStreak: 0,
            currentTotalStreak: 0,
          ),
        );
      }

      // Get date range for the period
      final now = DateTime.now();
      final dateRange = _getDateRangeForPeriod(params.period, now);

      // Get all entries for all habits in the range (single bulk query)
      final allEntriesResult = await trackingRepository.getAllEntriesInRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      final allEntries = allEntriesResult.fold((l) => [], (r) => r);

      // Calculate days tracked (using Set for unique dates)
      final daysTracked = allEntries
          .map((entry) => DateHelper.getDateKey(entry.date))
          .toSet()
          .length;

      // Calculate completion rate
      final completionRate = _calculateCompletionRate(
        allEntries,
        habits.length,
        dateRange,
      );

      final bestStreak = await _getBestStreak(
        habits.map<String>((h) => h.id as String).toList(),
      );

      return Right(
        OverallStats(
          totalHabits: habits.length,
          daysTracked: daysTracked,
          overallCompletionRate: completionRate,
          bestStreak: bestStreak,
          currentTotalStreak: 0,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  double _calculateCompletionRate(
    List<dynamic> entries,
    int totalHabits,
    DateRange dateRange,
  ) {
    if (totalHabits == 0) return 0;

    final now = DateHelper.normalize(DateTime.now());
    final daysInPeriod = dateRange.end.difference(dateRange.start).inDays + 1;

    final futureDays = dateRange.end.isAfter(now)
        ? dateRange.end.difference(now).inDays
        : 0;

    final actualDays = daysInPeriod - futureDays;

    if (actualDays <= 0) return 0;

    final totalPossible = actualDays * totalHabits;
    final totalCompleted = entries.where((e) => e.isCompleted).length;

    final percentage = (totalCompleted / totalPossible) * 100;
    return double.parse(percentage.toStringAsFixed(1));
  }

  Future<int> _getBestStreak(List<String> habitIds) async {
    if (habitIds.isEmpty) return 0;

    final streaksFutures = habitIds.map((id) async {
      final result = await trackingRepository.calculateStreak(id);
      return result.fold((l) => 0, (r) => r);
    });

    final streaks = await Future.wait(streaksFutures);
    return streaks.reduce((max, streak) => streak > max ? streak : max);
  }

  DateRange _getDateRangeForPeriod(OverallStatsPeriod period, DateTime now) {
    final normalizedNow = DateHelper.normalize(now);

    switch (period) {
      case OverallStatsPeriod.week:
        final startDate = normalizedNow.subtract(const Duration(days: 6));
        return DateRange(start: startDate, end: normalizedNow);

      case OverallStatsPeriod.month:
        final startDate = DateTime(normalizedNow.year, normalizedNow.month, 1);
        return DateRange(start: startDate, end: normalizedNow);

      case OverallStatsPeriod.year:
        final startDate = DateTime(normalizedNow.year, 1, 1);
        return DateRange(start: startDate, end: normalizedNow);
    }
  }
}

class GetOverallStatisticsParams {
  final OverallStatsPeriod period;

  const GetOverallStatisticsParams({
    this.period = OverallStatsPeriod.week,
  });
}
enum OverallStatsPeriod {
  week,
  month,
  year,
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });
}
