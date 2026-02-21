import 'package:equatable/equatable.dart';

class WeeklyStats extends Equatable {
  final List<DailyCompletion> dailyCompletions;
  final double averageCompletionRate;
  final int totalCompletions;

  const WeeklyStats({
    required this.dailyCompletions,
    required this.averageCompletionRate,
    required this.totalCompletions,
  });

  @override
  List<Object?> get props => [
        dailyCompletions,
        averageCompletionRate,
        totalCompletions,
      ];
}

class DailyCompletion extends Equatable {
  final DateTime date;
  final int completedCount;
  final int totalCount;
  final double percentage;

  const DailyCompletion({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [date, completedCount, totalCount, percentage];
}