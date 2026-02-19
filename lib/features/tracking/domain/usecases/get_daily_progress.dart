import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/tracking_repository.dart';

/// Use case for getting the completion percentage for a specific date
class GetDailyProgress implements UseCase<double, GetDailyProgressParams> {
  final TrackingRepository repository;

  GetDailyProgress(this.repository);

  @override
  Future<Either<Failure, double>> call(GetDailyProgressParams params) async {
    // Normalize the date (remove time component)
    final normalizedDate = DateTime(
      params.date.year,
      params.date.month,
      params.date.day,
    );

    return await repository.getDailyCompletionPercentage(normalizedDate);
  }
}

/// Parameters for getting daily progress
class GetDailyProgressParams {
  final DateTime date;

  const GetDailyProgressParams({required this.date});
}