import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
/// Type parameters:
///   Type: The return type of the use case
///   Params: The input parameters for the use case
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  /// Returns Either a Failure or the success Type
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Use this class when a use case doesn't need parameters
class NoParams {
  const NoParams();
}