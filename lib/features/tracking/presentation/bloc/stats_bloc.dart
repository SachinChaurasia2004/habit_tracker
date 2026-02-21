import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit_performance.dart';
import '../../domain/usecases/get_overall_stats.dart';
import '../../domain/usecases/get_weekly_stats.dart';
import '../../domain/usecases/get_habit_performance.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetOverallStatistics getOverallStatistics;
  final GetWeeklyStatistics getWeeklyStatistics;
  final GetHabitPerformance getHabitPerformance;

  StatisticsBloc({
    required this.getOverallStatistics,
    required this.getWeeklyStatistics,
    required this.getHabitPerformance,
  }) : super(const StatisticsInitial()) {
    on<LoadStatisticsEvent>(_onLoadStatistics);
    on<RefreshStatisticsEvent>(_onRefreshStatistics);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  Future<void> _onLoadStatistics(
    LoadStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    try {
      // Convert UI period to domain period
      final domainPeriod = _convertPeriod(event.period);

      // Get overall stats for the selected period
      final overallResult = await getOverallStatistics(
        GetOverallStatisticsParams(period: domainPeriod),
      );

      if (overallResult.isLeft()) {
        emit(StatisticsError(
          overallResult.fold((l) => l.message, (r) => ''),
        ));
        return;
      }

      final overallStats = overallResult.fold((l) => null, (r) => r)!;

      // Get weekly stats (always last 7 days for the chart)
      final weeklyResult = await getWeeklyStatistics(
        const GetWeeklyStatisticsParams(),
      );

      if (weeklyResult.isLeft()) {
        emit(StatisticsError(
          weeklyResult.fold((l) => l.message, (r) => ''),
        ));
        return;
      }

      final weeklyStats = weeklyResult.fold((l) => null, (r) => r)!;

      // Get habit performance for the selected period
      final endDate = DateTime.now();
      final startDate = _getStartDateForPeriod(event.period, endDate);

      final performanceResult = await getHabitPerformance(
        GetHabitPerformanceParams(
          startDate: startDate,
          endDate: endDate,
        ),
      );

      final habitPerformances = performanceResult.fold(
        (l) => <HabitPerformance>[],
        (r) => r,
      );

      emit(StatisticsLoaded(
        overallStats: overallStats,
        weeklyStats: weeklyStats,
        habitPerformances: habitPerformances,
        currentPeriod: event.period,
      ));
    } catch (e) {
      emit(StatisticsError('Failed to load statistics: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshStatistics(
    RefreshStatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    final currentPeriod = state is StatisticsLoaded
        ? (state as StatisticsLoaded).currentPeriod
        : StatisticsPeriod.week;

    add(LoadStatisticsEvent(period: currentPeriod));
  }

  Future<void> _onChangePeriod(
    ChangePeriodEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    add(LoadStatisticsEvent(period: event.period));
  }

  DateTime _getStartDateForPeriod(StatisticsPeriod period, DateTime endDate) {
    switch (period) {
      case StatisticsPeriod.week:
        return endDate.subtract(const Duration(days: 6));
      case StatisticsPeriod.month:
        return DateTime(endDate.year, endDate.month, 1);
      case StatisticsPeriod.year:
        return DateTime(endDate.year, 1, 1);
    }
  }

  // Convert UI period enum to domain period enum
  OverallStatsPeriod _convertPeriod(StatisticsPeriod uiPeriod) {
    switch (uiPeriod) {
      case StatisticsPeriod.week:
        return OverallStatsPeriod.week;
      case StatisticsPeriod.month:
        return OverallStatsPeriod.month;
      case StatisticsPeriod.year:
        return OverallStatsPeriod.year;
    }
  }
}
