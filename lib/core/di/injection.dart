import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/tracking/data/datasources/tracking_local_datasource.dart';
import '../../features/tracking/data/models/habit_entry_model.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/get_all_habits.dart';
import '../../features/habits/domain/usecases/get_active_habits.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/get_habit_performance.dart';
import '../../features/tracking/domain/usecases/get_overall_stats.dart';
import '../../features/tracking/domain/usecases/get_weekly_stats.dart';
import '../../features/tracking/domain/usecases/toggle_habit_completion.dart';
import '../../features/tracking/domain/usecases/get_daily_entries.dart';
import '../../features/tracking/domain/usecases/calculate_streak.dart';
import '../../features/tracking/domain/usecases/get_daily_progress.dart';
import '../../features/tracking/domain/usecases/get_entries_for_habit.dart';
import '../../features/habits/presentation/bloc/habit_bloc.dart';
import '../../features/tracking/presentation/bloc/stats_bloc.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';
import '../utils/app_constants.dart';

final getIt = GetIt.instance;

/// Setup all dependencies
Future<void> setupDependencies() async {
  // Hive Boxes
  getIt.registerLazySingleton<Box<HabitModel>>(
    () => Hive.box<HabitModel>(AppConstants.habitsBoxName),
  );
  getIt.registerLazySingleton<Box<HabitEntryModel>>(
    () => Hive.box<HabitEntryModel>(AppConstants.entriesBoxName),
  );

  // DATA SOURCES
  getIt.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSourceImpl(getIt()),
  );

  // REPOSITORIES
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(
      localDataSource: getIt(),
      habitRepository: getIt(),
    ),
  );

  // USE CASES - HABITS
  getIt.registerLazySingleton(() => CreateHabit(getIt()));
  getIt.registerLazySingleton(() => GetAllHabits(getIt()));
  getIt.registerLazySingleton(() => GetActiveHabits(getIt()));
  getIt.registerLazySingleton(() => UpdateHabit(getIt()));
  getIt.registerLazySingleton(
    () => DeleteHabit(habitRepository: getIt(), trackingRepository: getIt()),
  );

  // USE CASES - TRACKING
  getIt.registerLazySingleton(() => ToggleHabitCompletion(getIt()));
  getIt.registerLazySingleton(() => GetDailyEntries(getIt()));
  getIt.registerLazySingleton(() => CalculateStreak(getIt()));
  getIt.registerLazySingleton(() => GetDailyProgress(getIt()));
  getIt.registerLazySingleton(() => GetEntriesForHabit(getIt()));

  // ========== USE CASES - STATISTICS ==========
  getIt.registerLazySingleton(
    () => GetOverallStatistics(
      trackingRepository: getIt(),
      habitRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetWeeklyStatistics(
      trackingRepository: getIt(),
      habitRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetHabitPerformance(
      trackingRepository: getIt(),
      habitRepository: getIt(),
    ),
  );

  // BLOCS
  getIt.registerFactory(
    () => HabitBloc(
      createHabit: getIt(),
      getAllHabits: getIt(),
      getActiveHabits: getIt(),
      updateHabit: getIt(),
      deleteHabit: getIt(),
    ),
  );

  getIt.registerFactory(
    () => TrackingBloc(
      toggleHabitCompletion: getIt(),
      getDailyEntries: getIt(),
      calculateStreak: getIt(),
      getDailyProgress: getIt(),
      getActiveHabits: getIt(),
    ),
  );

   // ========== BLOCS - STATISTICS ==========
  getIt.registerFactory(
    () => StatisticsBloc(
      getOverallStatistics: getIt(),
      getWeeklyStatistics: getIt(),
      getHabitPerformance: getIt(),
    ),
  );
}

/// Reset all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
