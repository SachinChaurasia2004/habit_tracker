import 'package:equatable/equatable.dart';

class HabitPerformance extends Equatable {
  final String habitId;
  final String habitName;
  final int colorCode;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;

  const HabitPerformance({
    required this.habitId,
    required this.habitName,
    required this.colorCode,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCompletions,
  });

  @override
  List<Object?> get props => [
        habitId,
        habitName,
        colorCode,
        completionRate,
        currentStreak,
        bestStreak,
        totalCompletions,
      ];
}