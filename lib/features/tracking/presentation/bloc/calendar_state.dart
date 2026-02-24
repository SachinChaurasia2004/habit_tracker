import 'package:equatable/equatable.dart';
import '../../../habits/domain/entities/habit.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  final Map<String, double> completionData;
  final List<HabitWithStatus> habitsForSelectedDate;
  final DateTime selectedDate;
  final MonthStats monthStats;
  final Habit? selectedHabit;

  const CalendarLoaded({
    required this.completionData,
    required this.habitsForSelectedDate,
    required this.selectedDate,
    required this.monthStats,
    required this.selectedHabit,
  });

  @override
  List<Object?> get props => [
        completionData,
        habitsForSelectedDate,
        selectedDate,
        monthStats,
        selectedHabit,
      ];

  CalendarLoaded copyWith({
    Map<String, double>? completionData,
    List<HabitWithStatus>? habitsForSelectedDate,
    DateTime? selectedDate,
    MonthStats? monthStats,
    Habit? selectedHabit,
  }) {
    return CalendarLoaded(
      completionData: completionData ?? this.completionData,
      habitsForSelectedDate: habitsForSelectedDate ?? this.habitsForSelectedDate,
      selectedDate: selectedDate ?? this.selectedDate,
      monthStats: monthStats ?? this.monthStats,
      selectedHabit: selectedHabit ?? this.selectedHabit,
    );
  }
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Helper class to combine habit with its completion status
class HabitWithStatus {
  final Habit habit;
  final bool isCompleted;

  const HabitWithStatus({
    required this.habit,
    required this.isCompleted,
  });
}

/// Monthly statistics
class MonthStats {
  final int daysTracked;
  final double completionRate;
  final int bestStreak;

  const MonthStats({
    required this.daysTracked,
    required this.completionRate,
    required this.bestStreak,
  });
}