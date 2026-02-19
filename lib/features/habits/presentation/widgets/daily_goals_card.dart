import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/core/utils/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_state.dart';
import '../../presentation/bloc/habit_bloc.dart';
import '../../presentation/bloc/habit_state.dart';
import '../../presentation/widgets/progress_circle.dart';

class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: BlocBuilder<TrackingBloc, TrackingState>(
        builder: (context, trackingState) {
          double progress = 0.0;
          int completed = 0;

          if (trackingState is TrackingLoaded) {
            progress = trackingState.progressPercentage;
            completed = trackingState.completedCount;
          }

          return BlocBuilder<HabitBloc, HabitState>(
            builder: (context, habitState) {
              final total = habitState is HabitsLoaded
                  ? habitState.habits.length
                  : 0;

              final message = AppConstants.getMotivationalMessage(progress);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Daily Goals',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$completed of $total habits completed today!',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ProgressCircle(progress: progress),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}