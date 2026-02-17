import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
// Data
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/tracking/data/datasources/tracking_local_datasource.dart';
import '../../features/tracking/data/models/habit_entry_model.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
// Domain
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/get_all_habits.dart';
import '../../features/habits/domain/usecases/get_active_habits.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/toggle_habit_completion.dart';
import '../../features/tracking/domain/usecases/get_daily_entries.dart';
import '../../features/tracking/domain/usecases/calculate_streak.dart';
import '../../features/tracking/domain/usecases/get_daily_progress.dart';
import '../../features/tracking/domain/usecases/get_entries_for_habit.dart';
// Presentation (BLoCs)
import '../../features/habits/presentation/bloc/habit_bloc.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';

final getIt = GetIt.instance;

/// Setup all dependencies
Future<void> setupDependencies() async {
  // ========== EXTERNAL ==========
  // Hive Boxes
  getIt.registerLazySingleton<Box<HabitModel>>(
    () => Hive.box<HabitModel>('habits'),
  );
  getIt.registerLazySingleton<Box<HabitEntryModel>>(
    () => Hive.box<HabitEntryModel>('entries'),
  );

  // ========== DATA SOURCES ==========
  getIt.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSourceImpl(getIt()),
  );

// ========== REPOSITORIES ==========
getIt.registerLazySingleton<HabitRepository>(
  () => HabitRepositoryImpl(localDataSource: getIt()),
);

getIt.registerLazySingleton<TrackingRepository>(
  () => TrackingRepositoryImpl(
    localDataSource: getIt(),
    habitRepository: getIt(), // ADD THIS
  ),
);

  // ========== USE CASES - HABITS ==========
  getIt.registerLazySingleton(() => CreateHabit(getIt()));
  getIt.registerLazySingleton(() => GetAllHabits(getIt()));
  getIt.registerLazySingleton(() => GetActiveHabits(getIt()));
  getIt.registerLazySingleton(() => UpdateHabit(getIt()));
  getIt.registerLazySingleton(() => DeleteHabit(
        habitRepository: getIt(),
        trackingRepository: getIt(),
      ));

  // ========== USE CASES - TRACKING ==========
  getIt.registerLazySingleton(() => ToggleHabitCompletion(getIt()));
  getIt.registerLazySingleton(() => GetDailyEntries(getIt()));
  getIt.registerLazySingleton(() => CalculateStreak(getIt()));
  getIt.registerLazySingleton(() => GetDailyProgress(getIt()));
  getIt.registerLazySingleton(() => GetEntriesForHabit(getIt()));


  // ========== BLOCS ==========
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

}

/// Reset all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}