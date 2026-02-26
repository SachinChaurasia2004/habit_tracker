import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateName implements UseCase<void, String> {
  final ProfileRepository repository;

  UpdateName(this.repository);

  @override
  Future<Either<Failure, void>> call(String name) async {
    return await repository.updateName(name);
  }
}