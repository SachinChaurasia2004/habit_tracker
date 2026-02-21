import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit_performance.dart';
import '../repositories/tracking_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';

class GetHabitPerformance implements UseCase<List<HabitPerformance>, GetHabitPerformanceParams> {
  final TrackingRepository trackingRepository;
  final HabitRepository habitRepository;

  GetHabitPerformance({
    required this.trackingRepository,
    required this.habitRepository,
  });

  @override
  Future<Either<Failure, List<HabitPerformance>>> call(GetHabitPerformanceParams params) async {
    try {
      // Get all active habits
      final habitsResult = await habitRepository.getActiveHabits();
      final habits = habitsResult.fold((l) => [], (r) => r);

      if (habits.isEmpty) {
        return const Right([]);
      }

      // Get all entries in range (single bulk query)
      final entriesResult = await trackingRepository.getAllEntriesInRange(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      final allEntries = entriesResult.fold((l) => [], (r) => r);

      // Group entries by habit ID (functional approach)
      final entriesByHabit = <String, List<dynamic>>{};
      for (final entry in allEntries) {
        entriesByHabit.putIfAbsent(entry.habitId, () => []).add(entry);
      }

      // Calculate total days in period
      final totalDays = params.endDate.difference(params.startDate).inDays + 1;

      // Get all streaks in parallel
      final streaksFutures = habits.map((habit) async {
        final result = await trackingRepository.calculateStreak(habit.id);
        return MapEntry(habit.id, result.fold((l) => 0, (r) => r));
      });

      final streaksMap = Map.fromEntries(await Future.wait(streaksFutures));

      // Build performance list using map
      final performances = habits.map((habit) {
        final habitEntries = entriesByHabit[habit.id] ?? [];
        final completedEntries = habitEntries.where((e) => e.isCompleted).toList();
        
        final completionRate = totalDays > 0 
            ? (completedEntries.length / totalDays) * 100 
            : 0.0;

        return HabitPerformance(
          habitId: habit.id,
          habitName: habit.name,
          colorCode: habit.colorCode,
          completionRate: completionRate,
          currentStreak: streaksMap[habit.id] ?? 0,
          bestStreak: streaksMap[habit.id] ?? 0,
          totalCompletions: completedEntries.length,
        );
      }).toList();

      // Sort by completion rate (descending)
      performances.sort((a, b) => b.completionRate.compareTo(a.completionRate));

      return Right(performances);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

class GetHabitPerformanceParams {
  final DateTime startDate;
  final DateTime endDate;

  const GetHabitPerformanceParams({
    required this.startDate,
    required this.endDate,
  });
}