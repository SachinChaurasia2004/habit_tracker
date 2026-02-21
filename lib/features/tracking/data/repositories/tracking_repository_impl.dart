import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../datasources/tracking_local_datasource.dart';
import '../models/habit_entry_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final TrackingLocalDataSource localDataSource;
  final HabitRepository habitRepository;

  TrackingRepositoryImpl({
    required this.localDataSource,
    required this.habitRepository,
    });

  @override
  Future<Either<Failure, HabitEntry>> createEntry(HabitEntry entry) async {
    try {
      final model = HabitEntryModel.fromEntity(entry);
      await localDataSource.saveEntry(model);
      return Right(entry);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabit(
    String habitId,
  ) async {
    try {
      final models = await localDataSource.getEntriesForHabit(habitId);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntry>>> getEntriesForDate(
    DateTime date,
  ) async {
    try {
      final models = await localDataSource.getEntriesForDate(date);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitEntry>>> getEntriesForHabitInRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allModels = await localDataSource.getEntriesForHabit(habitId);
      
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
      
      final filteredModels = allModels.where((model) {
        final entryDate = DateTime(
          model.date.year,
          model.date.month,
          model.date.day,
        );
        return entryDate.isAfter(normalizedStart.subtract(const Duration(days: 1))) &&
               entryDate.isBefore(normalizedEnd.add(const Duration(days: 1)));
      }).toList();
      
      final entities = filteredModels.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry?>> getEntryByHabitAndDate({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      final model = await localDataSource.getEntryByHabitAndDate(habitId, date);
      return Right(model?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry>> updateEntry(HabitEntry entry) async {
    try {
      final model = HabitEntryModel.fromEntity(entry);
      await localDataSource.updateEntry(model);
      return Right(entry);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitEntry>> toggleCompletion({
    required String habitId,
    required DateTime date,
  }) async {
    try {
      // Normalize date
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      // Check if entry exists
      final existingModel = await localDataSource.getEntryByHabitAndDate(
        habitId,
        normalizedDate,
      );

      if (existingModel != null) {
        // Toggle existing entry
        final updatedModel = existingModel.copyWith(
          isCompleted: !existingModel.isCompleted,
        );
        await localDataSource.updateEntry(updatedModel);
        return Right(updatedModel.toEntity());
      } else {
        // Create new entry (marked as completed)
        final newModel = HabitEntryModel(
          id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
          habitId: habitId,
          date: normalizedDate,
          isCompleted: true,
        );
        await localDataSource.saveEntry(newModel);
        return Right(newModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntriesForHabit(String habitId) async {
    try {
      await localDataSource.deleteEntriesForHabit(habitId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

 @override
Future<Either<Failure, int>> calculateStreak(String habitId) async {
  try {
    final models = await localDataSource.getEntriesForHabit(habitId);
    
    if (models.isEmpty) {
      return const Right(0);
    }

    // Get today's normalized date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create a map of completed dates
    final completedDates = <String, bool>{};
    for (final model in models) {
      if (model.isCompleted) {
        final normalizedDate = DateTime(
          model.date.year,
          model.date.month,
          model.date.day,
        );
        final dateKey = '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';
        completedDates[dateKey] = true;
      }
    }
    
    // Check if today is completed
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayCompleted = completedDates.containsKey(todayKey) && completedDates[todayKey]!;
    
    // Start checking from today if completed, otherwise from yesterday
    DateTime checkDate = todayCompleted ? today : today.subtract(const Duration(days: 1));
    
    // Count consecutive days
    int streak = 0;
    
    // Check up to 365 days back (reasonable limit)
    for (int i = 0; i < 365; i++) {
      final dateKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
      if (completedDates.containsKey(dateKey) && completedDates[dateKey]!) {
        streak++;
        // Move to previous day
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Streak broken
        break;
      }
    }
    
    return Right(streak);
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}

   @override
  Future<Either<Failure, double>> getDailyCompletionPercentage(
    DateTime date,
  ) async {
    try {
      // Get active habits count
      final habitsResult = await habitRepository.getActiveHabits();
      
      if (habitsResult.isLeft()) {
        return const Right(0.0);
      }
      
      final activeHabits = habitsResult.fold((l) => [], (r) => r);
      
      if (activeHabits.isEmpty) {
        return const Right(0.0);
      }

      // Get entries for today
      final models = await localDataSource.getEntriesForDate(date);
      
      // Count completed entries
      final completedCount = models.where((m) => m.isCompleted).length;
      
      // Calculate percentage
      final percentage = (completedCount / activeHabits.length) * 100;
      
      return Right(percentage);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
Future<Either<Failure, List<HabitEntry>>> getAllEntriesInRange({
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    // Normalize dates for comparison
    final normalizedStart = DateHelper.normalize(startDate);
    final normalizedEnd = DateHelper.normalize(endDate);

    // Get ALL entries from the data source (single query)
    final allModels = await localDataSource.getAllEntries();

    // Filter entries within the date range using functional programming
    final filteredModels = allModels.where((model) {
      final entryDate = DateHelper.normalize(model.date);
      return !entryDate.isBefore(normalizedStart) && 
             !entryDate.isAfter(normalizedEnd);
    }).toList();

    // Convert to entities
    final entries = filteredModels.map((model) => model.toEntity()).toList();

    return Right(entries);
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}
}
