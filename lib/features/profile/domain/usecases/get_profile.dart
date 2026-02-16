import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for retrieving the user's profile
class GetProfile implements UseCaseNoParams<UserProfile> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call() async {
    return await repository.getProfile();
  }
}