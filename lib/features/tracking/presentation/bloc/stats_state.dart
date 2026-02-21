import 'package:equatable/equatable.dart';
import '../../domain/entities/overall_stats.dart';
import '../../domain/entities/weekly_stats.dart';
import '../../domain/entities/habit_performance.dart';
import 'stats_event.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final OverallStats overallStats;
  final WeeklyStats weeklyStats;
  final List<HabitPerformance> habitPerformances;
  final StatisticsPeriod currentPeriod;

  const StatisticsLoaded({
    required this.overallStats,
    required this.weeklyStats,
    required this.habitPerformances,
    required this.currentPeriod,
  });

  @override
  List<Object?> get props => [
        overallStats,
        weeklyStats,
        habitPerformances,
        currentPeriod,
      ];

  // Helper getters
  List<HabitPerformance> get topPerformers => 
      habitPerformances.take(3).toList();

  List<HabitPerformance> get needsAttention =>
      habitPerformances.where((h) => h.completionRate < 50).toList();

  bool get hasData => habitPerformances.isNotEmpty;

  String get periodLabel => currentPeriod.displayName;
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}