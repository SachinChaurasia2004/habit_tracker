import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Get user profile
  Future<Either<Failure, UserProfile>> getProfile();

  /// Update user profile
  Future<Either<Failure, void>> updateProfile(UserProfile profile);

  /// Update user name
  Future<Either<Failure, void>> updateName(String name);

  /// Toggle notifications
  Future<Either<Failure, void>> toggleNotifications(bool enabled);

  /// Toggle dark mode
  Future<Either<Failure, void>> toggleDarkMode(bool enabled);

  /// Update avatar
  Future<Either<Failure, void>> updateAvatar(String? avatarPath);

  /// Reset profile (create default)
  Future<Either<Failure, void>> resetProfile();
}