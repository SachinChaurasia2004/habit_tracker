import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating the user's profile
class UpdateProfile implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    // Validate name
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    if (params.name.length > 50) {
      return const Left(ValidationFailure('Name too long (max 50 characters)'));
    }

    final profile = UserProfile(
      name: params.name.trim(),
      joinDate: params.joinDate,
    );

    return await repository.updateProfile(profile);
  }
}

/// Parameters for updating profile
class UpdateProfileParams {
  final String name;
  final DateTime? joinDate;

  const UpdateProfileParams({
    required this.name,
    this.joinDate,
  });
}