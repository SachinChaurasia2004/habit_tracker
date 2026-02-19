import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tracking_repository.dart';

/// Use case for calculating the current streak for a habit
class CalculateStreak implements UseCase<int, CalculateStreakParams> {
  final TrackingRepository repository;

  CalculateStreak(this.repository);

  @override
  Future<Either<Failure, int>> call(CalculateStreakParams params) async {
    return await repository.calculateStreak(params.habitId);
  }
}

/// Parameters for calculating streak
class CalculateStreakParams {
  final String habitId;

  const CalculateStreakParams({required this.habitId});
}