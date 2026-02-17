import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
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
      
      // Sort by date descending (most recent first)
      final sortedModels = models.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      int streak = 0;
      DateTime checkDate = DateTime.now();
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day);

      for (final model in sortedModels) {
        final entryDate = DateTime(
          model.date.year,
          model.date.month,
          model.date.day,
        );

        if (entryDate == checkDate && model.isCompleted) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (entryDate.isBefore(checkDate)) {
          // Gap found, streak broken
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
}
