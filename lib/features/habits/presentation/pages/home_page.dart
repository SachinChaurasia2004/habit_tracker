import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../../../tracking/presentation/bloc/tracking_state.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/habit_card.dart';
import '../widgets/progress_circle.dart';
import '../widgets/calendar_week_view.dart';
import 'add_habit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
    context.read<TrackingBloc>().add(const LoadTodayTrackingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HabitBloc>().add(const RefreshHabitsEvent());
            context.read<TrackingBloc>().add(const RefreshTrackingEvent());
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, state) {
                                  if (state is ProfileLoaded) {
                                    return Text(
                                      state.profile.name,
                                      style: Theme.of(context).textTheme.displayLarge,
                                    );
                                  }
                                  return Text(
                                    'Sachin',
                                    style: Theme.of(context).textTheme.displayLarge,
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Calendar Week View
              const SliverToBoxAdapter(
                child: CalendarWeekView(),
              ),

              // Daily Goals Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: BlocBuilder<TrackingBloc, TrackingState>(
                    builder: (context, state) {
                      double progress = 0.0;
                      String message = 'Keep it up! 👏';

                      if (state is TrackingLoaded) {
                        progress = state.progressPercentage;
                        message = AppConstants.getMotivationalMessage(progress);
                      }

                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            AppConstants.cardBorderRadius,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Daily Goals',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  BlocBuilder<TrackingBloc, TrackingState>(
                                    builder: (context, state) {
                                      if (state is TrackingLoaded) {
                                        return Text(
                                          '${state.completedCount} of ${state.totalCount} habits completed today!',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        );
                                      }
                                      return Text(
                                        'Loading...',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                  ),
                ),
              ),

              // Today's Habits Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    8,
                    AppConstants.defaultPadding,
                    8,
                  ),
                  child: Text(
                    'Today\'s Habits',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),

              // Habits List
              BlocBuilder<HabitBloc, HabitState>(
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
                    if (habitState.habits.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_task,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No habits yet',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first habit',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return BlocBuilder<TrackingBloc, TrackingState>(
                      builder: (context, trackingState) {
                        Map<String, int> streaks = {};
                        Map<String, bool> completionStatus = {};

                        if (trackingState is TrackingLoaded) {
                          streaks = trackingState.streaks;
                          for (final habit in habitState.habits) {
                            completionStatus[habit.id] = 
                                trackingState.isHabitCompleted(habit.id);
                          }
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final habit = habitState.habits[index];
                                return HabitCard(
                                  habit: habit,
                                  streak: streaks[habit.id] ?? 0,
                                  isCompleted: completionStatus[habit.id] ?? false,
                                  onToggle: () {
                                    context.read<TrackingBloc>().add(
                                          ToggleHabitCompletionEvent(
                                            habitId: habit.id,
                                            date: DateTime.now(),
                                          ),
                                        );
                                  },
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddHabitPage(
                                          habit: habit,
                                        ),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteDialog(context, habit.id);
                                  },
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
              ),

              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHabitPage(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String habitId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text(
          'Are you sure you want to delete this habit? This will also delete all tracking data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitBloc>().add(DeleteHabitEvent(habitId));
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
