import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/core/utils/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../tracking/presentation/bloc/tracking_bloc.dart';
import '../../../tracking/presentation/bloc/tracking_event.dart';
import '../../../tracking/presentation/bloc/tracking_state.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../widgets/habit_card_widget.dart';
import '../widgets/progress_circle.dart';
import '../widgets/date_selector_widget.dart';
import 'add_habit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _currentDate ;
  @override
  void initState() {
    super.initState();
    _currentDate = DateHelper.normalize(DateTime.now());
    _loadData();
  }

  void _loadData() {
    context.read<HabitBloc>().add(const LoadActiveHabitsEvent());
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(_currentDate));
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _currentDate = DateHelper.normalize(newDate);
    });
    // Load tracking for the new date
    context.read<TrackingBloc>().add(LoadDateTrackingEvent(newDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: BlocListener<HabitBloc, HabitState>(
            listener: (context, state) {
              // Refresh tracking when habits are created, updated, or deleted
              if (state is HabitCreated ||
                  state is HabitUpdated ||
                  state is HabitDeleted) {
                // Refresh tracking data
                context.read<TrackingBloc>().add(
                  LoadDateTrackingEvent(_currentDate),
                );
              }
            },
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Sachin',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Date Selector
                SliverToBoxAdapter(child: DateSelectorWidget(
                  currentDate: _currentDate,
                  onDateChanged: _onDateChanged,
                )),

                // Daily Goals Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<TrackingBloc, TrackingState>(
                      builder: (context, state) {
                        double progress = 0.0;
                        int completed = 0;
                        int total = 0;
                        String message = 'Keep it up! 👏';

                        if (state is TrackingLoaded) {
                          progress = state.progressPercentage;
                          completed = state.completedCount;
                          total = state.totalCount;
                          message = AppConstants.getMotivationalMessage(
                            progress,
                          );
                        }

                        // Show total habits count from habit bloc
                        return BlocBuilder<HabitBloc, HabitState>(
                          builder: (context, habitState) {
                            if (habitState is HabitsLoaded) {
                              total = habitState.habits.length;
                            }

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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                  ),
                ),

                // Today's Habits Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      _currentDate.isAtSameMomentAs(DateTime.now()) 
                              ? 'Today\'s Habits'
                              : DateHelper.formatRelative(_currentDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
                                Icon(
                                  Icons.add_task,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No habits yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to create your first habit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
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
                            // Streaks are calculated for ALL habits
                            streaks = trackingState.streaks;

                            // Completion status only for habits with entries today
                            for (final habit in habitState.habits) {
                              completionStatus[habit.id] = trackingState
                                  .isHabitCompleted(habit.id);
                            }
                          }

                          return SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final habit = habitState.habits[index];
                                return HabitCardWidget(
                                  habit: habit,
                                  streak:
                                      streaks[habit.id] ??
                                      0, // Show 0 if not found
                                  isCompleted:
                                      completionStatus[habit.id] ?? false,
                                      date: _currentDate,
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
                                        builder: (context) =>
                                            AddHabitPage(habit: habit),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteDialog(context, habit.id);
                                  },
                                );
                              }, childCount: habitState.habits.length),
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

                // Bottom Spacing for Navigation Bar
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String habitId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
