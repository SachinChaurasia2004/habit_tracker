import 'package:equatable/equatable.dart';

class OverallStats extends Equatable {
  final int totalHabits;
  final int daysTracked;
  final double overallCompletionRate;
  final int bestStreak;
  final int currentTotalStreak;

  const OverallStats({
    required this.totalHabits,
    required this.daysTracked,
    required this.overallCompletionRate,
    required this.bestStreak,
    required this.currentTotalStreak,
  });

  @override
  List<Object?> get props => [
        totalHabits,
        daysTracked,
        overallCompletionRate,
        bestStreak,
        currentTotalStreak,
      ];
}