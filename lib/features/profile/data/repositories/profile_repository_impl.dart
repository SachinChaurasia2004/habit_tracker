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
      final profileModel = await localDataSource.getProfile();
      return Right(profileModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(UserProfile profile) async {
    try {
      final profileModel = UserProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(profileModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateName(String name) async {
    try {
      final currentProfile = await localDataSource.getProfile();
      final updatedProfile = UserProfileModel(
        name: name,
        joinDate: currentProfile.joinDate,
        notificationsEnabled: currentProfile.notificationsEnabled,
        darkModeEnabled: currentProfile.darkModeEnabled,
        avatarPath: currentProfile.avatarPath,
        preferences: currentProfile.preferences,
      );
      await localDataSource.saveProfile(updatedProfile);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleNotifications(bool enabled) async {
    try {
      final currentProfile = await localDataSource.getProfile();
      final updatedProfile = UserProfileModel(
        name: currentProfile.name,
        joinDate: currentProfile.joinDate,
        notificationsEnabled: enabled,
        darkModeEnabled: currentProfile.darkModeEnabled,
        avatarPath: currentProfile.avatarPath,
        preferences: currentProfile.preferences,
      );
      await localDataSource.saveProfile(updatedProfile);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleDarkMode(bool enabled) async {
    try {
      final currentProfile = await localDataSource.getProfile();
      final updatedProfile = UserProfileModel(
        name: currentProfile.name,
        joinDate: currentProfile.joinDate,
        notificationsEnabled: currentProfile.notificationsEnabled,
        darkModeEnabled: enabled,
        avatarPath: currentProfile.avatarPath,
        preferences: currentProfile.preferences,
      );
      await localDataSource.saveProfile(updatedProfile);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAvatar(String? avatarPath) async {
    try {
      final currentProfile = await localDataSource.getProfile();
      final updatedProfile = UserProfileModel(
        name: currentProfile.name,
        joinDate: currentProfile.joinDate,
        notificationsEnabled: currentProfile.notificationsEnabled,
        darkModeEnabled: currentProfile.darkModeEnabled,
        avatarPath: avatarPath,
        preferences: currentProfile.preferences,
      );
      await localDataSource.saveProfile(updatedProfile);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetProfile() async {
    try {
      await localDataSource.deleteProfile();
      final defaultProfile = UserProfileModel.createDefault();
      await localDataSource.saveProfile(defaultProfile);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}