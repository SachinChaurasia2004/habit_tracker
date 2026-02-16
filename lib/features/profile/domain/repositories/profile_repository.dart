import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

/// Repository interface for user profile operations
abstract class ProfileRepository {
  /// Retrieves the user's profile
  /// Returns the profile or a Failure
  Future<Either<Failure, UserProfile>> getProfile();

  /// Updates the user's profile
  /// Returns the updated profile or a Failure
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);

  /// Creates a new user profile
  /// Returns the created profile or a Failure
  Future<Either<Failure, UserProfile>> createProfile(UserProfile profile);

  /// Checks if a profile exists
  /// Returns true if profile exists, false otherwise
  Future<Either<Failure, bool>> profileExists();
}