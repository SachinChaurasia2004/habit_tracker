import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

// Data
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../features/tracking/data/datasources/tracking_local_datasource.dart';
import '../../features/tracking/data/models/habit_entry_model.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/models/user_profile_model.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';

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
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';

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
  getIt.registerLazySingleton<Box<UserProfileModel>>(
    () => Hive.box<UserProfileModel>('profile'),
  );

  // ========== DATA SOURCES ==========
  getIt.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TrackingLocalDataSource>(
    () => TrackingLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(getIt()),
  );

  // ========== REPOSITORIES ==========
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: getIt()),
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

  // ========== USE CASES - PROFILE ==========
  getIt.registerLazySingleton(() => GetProfile(getIt()));
  getIt.registerLazySingleton(() => UpdateProfile(getIt()));

  // ========== BLOCS (will be added later) ==========
  // getIt.registerFactory(() => HabitBloc(...));
  // getIt.registerFactory(() => TrackingBloc(...));
  // getIt.registerFactory(() => ProfileBloc(...));
}

/// Reset all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}