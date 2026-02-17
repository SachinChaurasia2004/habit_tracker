import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/get_daily_entries.dart';
import '../../domain/usecases/calculate_streak.dart';
import '../../domain/usecases/get_daily_progress.dart';
import '../../../habits/domain/usecases/get_active_habits.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final ToggleHabitCompletion toggleHabitCompletion;
  final GetDailyEntries getDailyEntries;
  final CalculateStreak calculateStreak;
  final GetDailyProgress getDailyProgress;
  final GetActiveHabits getActiveHabits;

  TrackingBloc({
    required this.toggleHabitCompletion,
    required this.getDailyEntries,
    required this.calculateStreak,
    required this.getDailyProgress,
    required this.getActiveHabits,
  }) : super(const TrackingInitial()) {
    on<LoadTodayTrackingEvent>(_onLoadTodayTracking);
    on<LoadDateTrackingEvent>(_onLoadDateTracking);
    on<ToggleHabitCompletionEvent>(_onToggleHabitCompletion);
    on<RefreshTrackingEvent>(_onRefreshTracking);
  }

  Future<void> _onLoadTodayTracking(
    LoadTodayTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadTrackingForDate(DateTime.now(), emit);
  }

  Future<void> _onLoadDateTracking(
    LoadDateTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadTrackingForDate(event.date, emit);
  }

  Future<void> _loadTrackingForDate(
    DateTime date,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingLoading());

    // Get active habits
    final habitsResult = await getActiveHabits();
    if (habitsResult.isLeft()) {
      emit(TrackingError(
        habitsResult.fold((l) => l.message, (r) => ''),
      ));
      return;
    }

    final habits = habitsResult.fold((l) => [], (r) => r);

    // Get daily entries
    final entriesResult = await getDailyEntries(
      GetDailyEntriesParams(date: date),
    );

    if (entriesResult.isLeft()) {
      emit(TrackingError(
        entriesResult.fold((l) => l.message, (r) => ''),
      ));
      return;
    }

    final entries = entriesResult.fold<List<HabitEntry>>((l) => const [], (r) => r);

    // Get daily progress
    final progressResult = await getDailyProgress(
      GetDailyProgressParams(date: date),
    );

    final progress = progressResult.fold((l) => 0.0, (r) => r);

    // Calculate streaks for each habit
    final streaks = <String, int>{};
    for (final habit in habits) {
      final streakResult = await calculateStreak(
        CalculateStreakParams(habitId: habit.id),
      );
      streaks[habit.id] = streakResult.fold((l) => 0, (r) => r);
    }

    emit(TrackingLoaded(
      entries: entries,
      progressPercentage: progress,
      streaks: streaks,
      date: date,
    ));
  }

  Future<void> _onToggleHabitCompletion(
    ToggleHabitCompletionEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await toggleHabitCompletion(
      ToggleHabitCompletionParams(
        habitId: event.habitId,
        date: event.date,
      ),
    );

    result.fold(
      (failure) => emit(TrackingError(failure.message)),
      (entry) {
        // Immediately reload tracking to update progress
        add(LoadDateTrackingEvent(event.date));
      },
    );
  }

  Future<void> _onRefreshTracking(
    RefreshTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadTrackingForDate(DateTime.now(), emit);
  }
}
