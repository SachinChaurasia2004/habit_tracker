import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../habits/domain/entities/habit.dart';
import '../../domain/entities/habit_entry.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/get_daily_entries.dart';
import '../../domain/usecases/calculate_streak.dart';
import '../../domain/usecases/get_daily_progress.dart';
import '../../../habits/domain/usecases/get_active_habits.dart';
import '../../../../core/services/streak_notification_service.dart';
import '../../../../core/utils/date_helper.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final ToggleHabitCompletion toggleHabitCompletion;
  final GetDailyEntries getDailyEntries;
  final CalculateStreak calculateStreak;
  final GetDailyProgress getDailyProgress;
  final GetActiveHabits getActiveHabits;
  final StreakNotificationService streakNotificationService;
  final Set<String> _sentIncompleteReminderKeys = {};

  TrackingBloc({
    required this.toggleHabitCompletion,
    required this.getDailyEntries,
    required this.calculateStreak,
    required this.getDailyProgress,
    required this.getActiveHabits,
    required this.streakNotificationService,
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
    Emitter<TrackingState> emit, {
    bool showLoading = true,
  }) async {
    try {
      debugPrint('[TrackingBloc] Loading tracking for date: $date');
      if (showLoading) {
        emit(const TrackingLoading());
      }

      // Get active habits
      final habitsResult = await getActiveHabits();
      if (habitsResult.isLeft()) {
        final errorMsg = habitsResult.fold((l) => l.message, (r) => '');
        debugPrint('[TrackingBloc] Error loading habits: $errorMsg');
        emit(TrackingError(errorMsg));
        return;
      }

      final habits = habitsResult.fold((l) => <Habit>[], (r) => r);
      debugPrint('[TrackingBloc] Loaded ${habits.length} active habits');
      for (final habit in habits) {
        debugPrint(
          '[TrackingBloc]   - ${habit.name}: reminder=${habit.hasReminder ? "${habit.reminderHour}:${habit.reminderMinute}" : "none"}',
        );
      }

      // Get daily entries
      final entriesResult = await getDailyEntries(
        GetDailyEntriesParams(date: date),
      );

      if (entriesResult.isLeft()) {
        final errorMsg = entriesResult.fold((l) => l.message, (r) => '');
        debugPrint('[TrackingBloc] Error loading entries: $errorMsg');
        emit(TrackingError(errorMsg));
        return;
      }

      final entries = entriesResult.fold((l) => <HabitEntry>[], (r) => r);
      debugPrint('[TrackingBloc] Loaded ${entries.length} entries for date');

      // Get daily progress
      final progressResult = await getDailyProgress(
        GetDailyProgressParams(date: date),
      );

      final progress = progressResult.fold((l) => 0.0, (r) => r);

      // Calculate streaks for ALL active habits
      final streaks = <String, int>{};
      for (final habit in habits) {
        final streakResult = await calculateStreak(
          CalculateStreakParams(habitId: habit.id),
        );
        streaks[habit.id] = streakResult.fold((l) => 0, (r) => r);
      }

      await _syncIncompleteHabitReminders(
        date: date,
        habits: habits,
        entries: entries,
      );

      emit(
        TrackingLoaded(
          entries: entries,
          progressPercentage: progress,
          streaks: streaks,
          date: date,
        ),
      );
      debugPrint('[TrackingBloc] Tracking loaded successfully');
    } catch (e) {
      debugPrint('[TrackingBloc] Unexpected error loading tracking: $e');
      emit(TrackingError('Failed to load tracking: $e'));
    }
  }

  Future<void> _onToggleHabitCompletion(
    ToggleHabitCompletionEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await toggleHabitCompletion(
      ToggleHabitCompletionParams(habitId: event.habitId, date: event.date),
    );

    await result.fold((failure) async => emit(TrackingError(failure.message)), (
      entry,
    ) async {
      if (entry.isCompleted) {
        await _tryCancelIncompleteReminder(event.habitId);
      }

      await _loadTrackingForDate(event.date, emit, showLoading: false);
    });
  }

  Future<void> _syncIncompleteHabitReminders({
    required DateTime date,
    required List<Habit> habits,
    required List<HabitEntry> entries,
  }) async {
    try {
      final now = DateTime.now();
      debugPrint(
        '[TrackingBloc] Syncing incomplete habit reminders for date: $date',
      );
      debugPrint('[TrackingBloc] Current time: $now');

      if (!DateHelper.isSameDay(date, now)) {
        debugPrint('[TrackingBloc] Date is not today, skipping reminder sync');
        return;
      }

      final completedHabitIds = entries
          .where((entry) => entry.isCompleted)
          .map((entry) => entry.habitId)
          .toSet();
      final dateKey = DateHelper.getDateKey(date);

      debugPrint('[TrackingBloc] Completed habits: $completedHabitIds');
      debugPrint('[TrackingBloc] Processing ${habits.length} habits');

      for (final habit in habits) {
        debugPrint(
          '[TrackingBloc] --- Processing habit: ${habit.name} (${habit.id})',
        );

        if (!habit.hasReminder) {
          debugPrint('[TrackingBloc]   No reminder set for this habit');
          await _tryCancelIncompleteReminder(habit.id);
          continue;
        }

        debugPrint(
          '[TrackingBloc]   Reminder time: ${habit.reminderHour}:${habit.reminderMinute}',
        );

        if (completedHabitIds.contains(habit.id)) {
          debugPrint(
            '[TrackingBloc]   Habit already completed, cancelling reminder',
          );
          await _tryCancelIncompleteReminder(habit.id);
          continue;
        }

        final reminderTime = DateTime(
          now.year,
          now.month,
          now.day,
          habit.reminderHour!,
          habit.reminderMinute!,
        );

        debugPrint('[TrackingBloc]   Reminder scheduled for: $reminderTime');

        // Always (re)schedule the notification for today if incomplete and reminder is set for later today
        if (reminderTime.isAfter(now)) {
          debugPrint(
            '[TrackingBloc]   Reminder time is in the future, scheduling...',
          );
          await _tryCancelIncompleteReminder(
            habit.id,
          ); // Cancel any previous schedule for today
          await _tryScheduleIncompleteReminder(
            habitId: habit.id,
            habitName: habit.name,
            reminderTime: reminderTime,
          );
          continue;
        }

        // If the reminder time is in the past, show immediate notification (once per day)
        debugPrint('[TrackingBloc]   Reminder time is in the past');
        final reminderKey = '${habit.id}:$dateKey';
        if (!_sentIncompleteReminderKeys.add(reminderKey)) {
          debugPrint('[TrackingBloc]   Already sent today, skipping');
          continue;
        }
        debugPrint('[TrackingBloc]   Showing immediate notification');
        streakNotificationService.showIncompleteHabitReminder(
          habitName: habit.name,
          missedDays: 0,
        );
      }
      debugPrint('[TrackingBloc] Reminder sync completed');
    } catch (e) {
      debugPrint('[TrackingBloc] Error during reminder sync: $e');
    }
  }

  Future<void> _tryScheduleIncompleteReminder({
    required String habitId,
    required String habitName,
    required DateTime reminderTime,
  }) async {
    try {
      debugPrint(
        '[TrackingBloc] Checking notification permissions for $habitName',
      );
      print('[TrackingBloc] 🔔 CHECKING PERMISSIONS FOR: $habitName');
      final notificationsAllowed = await streakNotificationService
          .requestPermissions();

      if (!notificationsAllowed) {
        print('[TrackingBloc] ❌ PERMISSIONS DENIED FOR: $habitName');
        debugPrint(
          '[TrackingBloc] Notifications permission denied for $habitName',
        );
        return;
      }

      print('[TrackingBloc] ✅ PERMISSIONS GRANTED FOR: $habitName');
      debugPrint(
        '[TrackingBloc] Permissions granted, scheduling reminder for $habitName at $reminderTime',
      );

      print(
        '[TrackingBloc] 📍 CALLING scheduleIncompleteHabitReminder for: $habitName at $reminderTime',
      );
      await streakNotificationService.scheduleIncompleteHabitReminder(
        habitId: habitId,
        habitName: habitName,
        reminderTime: reminderTime,
      );
      print('[TrackingBloc] ✅ REMINDER SCHEDULING COMPLETED FOR: $habitName');
    } catch (error) {
      print('[TrackingBloc] ❌ EXCEPTION SCHEDULING REMINDER: $error');
      debugPrint(
        '[TrackingBloc] Failed to schedule habit reminder for $habitName: $error',
      );
      // Habit tracking should keep working even when OS notification scheduling fails.
    }
  }

  Future<void> _tryCancelIncompleteReminder(String habitId) async {
    try {
      debugPrint('[TrackingBloc] Cancelling reminder for habit: $habitId');
      await streakNotificationService.cancelIncompleteHabitReminder(habitId);
      debugPrint(
        '[TrackingBloc] Successfully cancelled reminder for: $habitId',
      );
    } catch (error) {
      debugPrint(
        '[TrackingBloc] Failed to cancel habit reminder for $habitId: $error',
      );
      // Habit tracking should keep working even when OS notification cancellation fails.
    }
  }

  Future<void> _onRefreshTracking(
    RefreshTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    await _loadTrackingForDate(DateTime.now(), emit);
  }
}
