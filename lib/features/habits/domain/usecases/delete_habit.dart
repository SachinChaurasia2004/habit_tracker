import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/habit_repository.dart';
import '../../../tracking/domain/repositories/tracking_repository.dart';

/// Use case for deleting a habit
class DeleteHabit implements UseCase<Unit, DeleteHabitParams> {
  final HabitRepository habitRepository;
  final TrackingRepository trackingRepository;

  DeleteHabit({
    required this.habitRepository,
    required this.trackingRepository,
  });

  @override
  Future<Either<Failure, Unit>> call(DeleteHabitParams params) async {
    // First, delete all tracking entries for this habit
    final deleteEntriesResult = await trackingRepository.deleteEntriesForHabit(params.habitId);

    // If deleting entries fails, return the failure
    if (deleteEntriesResult.isLeft()) {
      return deleteEntriesResult;
    }

    return await habitRepository.deleteHabit(params.habitId);
  }
}

/// Parameters for deleting a habit
class DeleteHabitParams {
  final String habitId;

  const DeleteHabitParams({required this.habitId});
}