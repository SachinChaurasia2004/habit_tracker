import 'package:equatable/equatable.dart';
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure related to local storage/cache operations
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache failure']);
}

/// Failure when trying to create a habit that already exists
class DuplicateHabitFailure extends Failure {
  const DuplicateHabitFailure([super.message = 'Habit already exists']);
}

/// Failure when a requested habit is not found
class HabitNotFoundFailure extends Failure {
  const HabitNotFoundFailure([super.message = 'Habit not found']);
}

/// Failure due to invalid input/parameters
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Failure when trying to access data that doesn't exist
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred']);
}