import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../../../tracking/presentation/bloc/tracking_state.dart';
import '../../../tracking/presentation/bloc/stats_bloc.dart';
import '../../../tracking/presentation/bloc/stats_event.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_state.dart';
import '../pages/add_habit_page.dart';
import 'empty_habits_view.dart';
import 'habit_card_widget.dart';

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

              // On tablets, show a 2-column grid instead of a single list.
              final isTablet = context.isTabletOrLarger;
              final horizontalPadding = context.pagePadding;

              if (isTablet) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.2,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCard(
                        context,
                        habitState.habits[index],
                        streaks,
                        completionStatus,
                      ),
                      childCount: habitState.habits.length,
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildCard(
                      context,
                      habitState.habits[index],
                      streaks,
                      completionStatus,
                    ),
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

  Widget _buildCard(
    BuildContext context,
    habit,
    Map<String, int> streaks,
    Map<String, bool> completionStatus,
  ) {
    return HabitCardWidget(
      habit: habit,
      streak: streaks[habit.id] ?? 0,
      isCompleted: completionStatus[habit.id] ?? false,
      date: currentDate,
      onToggle: () {
        context.read<TrackingBloc>().add(
          ToggleHabitCompletionEvent(habitId: habit.id, date: DateTime.now()),
        );
        context.read<StatisticsBloc>().add(const RefreshStatisticsEvent());
      },
      onEdit: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddHabitPage(habit: habit)),
      ),
      onDelete: () => onDeleteRequested(context, habit.id),
    );
  }
}
