import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final model = await localDataSource.getProfile();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      if (e.message.contains('not found')) {
        return Left(NotFoundFailure(e.message));
      }
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
    UserProfile profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(model);
      return Right(profile);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> createProfile(
    UserProfile profile,
  ) async {
    try {
      final exists = await localDataSource.profileExists();
      if (exists) {
        return const Left(ValidationFailure('Profile already exists'));
      }

      final model = UserProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(model);
      return Right(profile);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> profileExists() async {
    try {
      final exists = await localDataSource.profileExists();
      return Right(exists);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}