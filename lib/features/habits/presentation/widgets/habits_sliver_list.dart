import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_card_widget.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../../../tracking/presentation/bloc/tracking_state.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_state.dart';
import '../pages/add_habit_page.dart';
import 'empty_habits_view.dart';

class HabitsSliverList extends StatelessWidget {
  const HabitsSliverList({
    super.key,
    required this.currentDate,
    required this.onDeleteRequested,
  });

  final DateTime currentDate;
  final void Function(BuildContext context, String habitId) onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (context, habitState) {
        if (habitState is HabitLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (habitState is HabitError) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                habitState.message,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          );
        }

        if (habitState is HabitsLoaded) {
          if (habitState.habits.isEmpty) return const EmptyHabitsView();

          return BlocBuilder<TrackingBloc, TrackingState>(
            builder: (context, trackingState) {
              final streaks = trackingState is TrackingLoaded
                  ? trackingState.streaks
                  : <String, int>{};

              final completionStatus = trackingState is TrackingLoaded
                  ? {
                      for (final habit in habitState.habits)
                        habit.id: trackingState.isHabitCompleted(habit.id),
                    }
                  : <String, bool>{};

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final habit = habitState.habits[index];
                      return HabitCardWidget(
                        habit: habit,
                        streak: streaks[habit.id] ?? 0,
                        isCompleted: completionStatus[habit.id] ?? false,
                        date: currentDate,
                        onToggle: () {
                          context.read<TrackingBloc>().add(
                                ToggleHabitCompletionEvent(
                                  habitId: habit.id,
                                  date: DateTime.now(),
                                ),
                              );
                        },
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddHabitPage(habit: habit),
                          ),
                        ),
                        onDelete: () =>
                            onDeleteRequested(context, habit.id),
                      );
                    },
                    childCount: habitState.habits.length,
                  ),
                ),
              );
            },
          );
        }

        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}