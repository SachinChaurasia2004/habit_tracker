import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitLocalDataSource localDataSource;

  HabitRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Habit>> createHabit(Habit habit) async {
    try {
      // Check if habit already exists
      final exists = await localDataSource.habitExists(habit.id);
      if (exists) {
        return const Left(DuplicateHabitFailure('Habit already exists'));
      }

      // Convert entity to model and save
      final model = HabitModel.fromEntity(habit);
      await localDataSource.saveHabit(model);
      
      return Right(habit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Habit>>> getAllHabits() async {
    try {
      final models = await localDataSource.getAllHabits();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Habit>>> getActiveHabits() async {
    try {
      final models = await localDataSource.getAllHabits();
      final activeEntities = models
          .where((model) => model.isActive)
          .map((model) => model.toEntity())
          .toList();
      return Right(activeEntities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> getHabitById(String id) async {
    try {
      final model = await localDataSource.getHabitById(id);
      return Right(model.toEntity());
    } on CacheException catch (e) {
      if (e.message.contains('not found')) {
        return Left(HabitNotFoundFailure(e.message));
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> updateHabit(Habit habit) async {
    try {
      final model = HabitModel.fromEntity(habit);
      await localDataSource.updateHabit(model);
      return Right(habit);
    } on CacheException catch (e) {
      if (e.message.contains('not found')) {
        return Left(HabitNotFoundFailure(e.message));
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHabit(String id) async {
    try {
      await localDataSource.deleteHabit(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> deactivateHabit(String id) async {
    try {
      final model = await localDataSource.getHabitById(id);
      final updatedModel = model.copyWith(isActive: false);
      await localDataSource.updateHabit(updatedModel);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      if (e.message.contains('not found')) {
        return Left(HabitNotFoundFailure(e.message));
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> reactivateHabit(String id) async {
    try {
      final model = await localDataSource.getHabitById(id);
      final updatedModel = model.copyWith(isActive: true);
      await localDataSource.updateHabit(updatedModel);
      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      if (e.message.contains('not found')) {
        return Left(HabitNotFoundFailure(e.message));
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}