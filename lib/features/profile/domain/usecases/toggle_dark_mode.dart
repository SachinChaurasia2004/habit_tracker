import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class ToggleDarkMode implements UseCase<void, bool> {
  final ProfileRepository repository;

  ToggleDarkMode(this.repository);

  @override
  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.toggleDarkMode(enabled);
  }
}