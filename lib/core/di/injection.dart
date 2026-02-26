import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/models/user_profile_model.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/toggle_dark_mode.dart';
import '../../features/profile/domain/usecases/toggle_notifications.dart';
import '../../features/profile/domain/usecases/update_name.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
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
import '../../features/tracking/presentation/bloc/calendar_bloc.dart';
import '../../features/tracking/presentation/bloc/stats_bloc.dart';
import '../../features/tracking/presentation/bloc/tracking_bloc.dart';
import '../../features/tracking/domain/usecases/get_monthly_completion.dart';
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

   getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(
      Hive.box<UserProfileModel>('user_profile'),
    ),
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

  // Profile repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      localDataSource: getIt(),
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

  getIt.registerLazySingleton(
    () => GetMonthlyCompletion(
      trackingRepository: getIt(),
    ),
  );

   getIt.registerLazySingleton(() => GetProfile(getIt()));
    getIt.registerLazySingleton(() => UpdateProfile(getIt()));
    getIt.registerLazySingleton(() => UpdateName(getIt()));
    getIt.registerLazySingleton(() => ToggleNotifications(getIt()));
    getIt.registerLazySingleton(() => ToggleDarkMode(getIt()));


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

  getIt.registerFactory(
    () => CalendarBloc(
      getMonthlyCompletion: getIt(),
      getActiveHabits: getIt(),
      trackingRepository: getIt(),
    ),
  );

   getIt.registerFactory(
      () => ProfileBloc(
        getProfile: getIt(),
        updateProfile: getIt(),
        updateName: getIt(),
        toggleNotifications: getIt(),
        toggleDarkMode: getIt(),
        profileRepository: getIt(),
      ),
    );

}

/// Reset all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
