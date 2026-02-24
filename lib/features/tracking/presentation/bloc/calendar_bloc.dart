import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../domain/usecases/get_monthly_completion.dart';
import '../../../habits/domain/usecases/get_active_habits.dart';
import '../../domain/repositories/tracking_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetMonthlyCompletion getMonthlyCompletion;
  final GetActiveHabits getActiveHabits;
  final TrackingRepository trackingRepository;

  CalendarBloc({
    required this.getMonthlyCompletion,
    required this.getActiveHabits,
    required this.trackingRepository,
  }) : super(const CalendarInitial()) {
    on<LoadMonthCompletionEvent>(_onLoadMonthCompletion);
    on<LoadDateHabitsEvent>(_onLoadDateHabits);
    on<RefreshCalendarEvent>(_onRefreshCalendar);
  }

  Future<void> _onLoadMonthCompletion(
    LoadMonthCompletionEvent event,
    Emitter<CalendarState> emit,
  ) async {
    final previousState = state;
    emit(const CalendarLoading());

    try {
      // Load habits for today
      final today = DateHelper.normalize(DateTime.now());
      final habitsWithStatus = await _getHabitsForDate(today);

      if (habitsWithStatus.isEmpty) {
        emit(const CalendarError('No active habits to show on calendar.'));
        return;
      }

      // Determine selected habit (from event, previous state, or default)
      String? selectedHabitId = event.selectedHabitId;
      if (selectedHabitId == null && previousState is CalendarLoaded) {
        selectedHabitId = previousState.selectedHabit?.id;
      }
      selectedHabitId ??= habitsWithStatus.first.habit.id;

      final selectedHabit = habitsWithStatus
          .firstWhere(
            (hws) => hws.habit.id == selectedHabitId,
            orElse: () => habitsWithStatus.first,
          )
          .habit;

      // Get completion data for the selected habit in the month
      final completionResult = await getMonthlyCompletion(
        GetMonthlyCompletionParams(
          month: event.month,
          habitId: selectedHabit.id,
        ),
      );

      if (completionResult.isLeft()) {
        emit(CalendarError(
          completionResult.fold((l) => l.message, (r) => ''),
        ));
        return;
      }

      final Map<String, double> completionData =
          completionResult.fold((l) => <String, double>{}, (r) => r);

      // Calculate month stats for the selected habit
      final monthStats = _calculateMonthStats(completionData);

      emit(CalendarLoaded(
        completionData: completionData,
        habitsForSelectedDate: habitsWithStatus,
        selectedDate: today,
        monthStats: monthStats,
        selectedHabit: selectedHabit,
      ));
    } catch (e) {
      emit(CalendarError('Failed to load calendar: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDateHabits(
    LoadDateHabitsEvent event,
    Emitter<CalendarState> emit,
  ) async {
    if (state is! CalendarLoaded) return;

    final currentState = state as CalendarLoaded;
    
    try {
      // Load habits for the selected date
      final habitsWithStatus = await _getHabitsForDate(event.date);

      emit(currentState.copyWith(
        habitsForSelectedDate: habitsWithStatus,
        selectedDate: event.date,
      ));
    } catch (e) {
      // Keep current state, just show error
      emit(CalendarError('Failed to load habits: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendarEvent event,
    Emitter<CalendarState> emit,
  ) async {
    String? selectedHabitId;
    final currentState = state;
    if (currentState is CalendarLoaded) {
      selectedHabitId = currentState.selectedHabit?.id;
    }

    add(
      LoadMonthCompletionEvent(
        event.month,
        selectedHabitId: selectedHabitId,
      ),
    );
  }

  Future<List<HabitWithStatus>> _getHabitsForDate(DateTime date) async {
    // Get all active habits
    final habitsResult = await getActiveHabits();
    final habits = habitsResult.fold((l) => [], (r) => r);

    if (habits.isEmpty) {
      return [];
    }

    // Get entries for the date
    final entriesResult = await trackingRepository.getEntriesForDate(date);
    final entries = entriesResult.fold((l) => [], (r) => r);

    // Create map of habit IDs to completion status
    final completionMap = <String, bool>{};
    for (final entry in entries) {
      completionMap[entry.habitId] = entry.isCompleted;
    }

    // Combine habits with their status
    return habits.map((habit) {
      final isCompleted = completionMap[habit.id] ?? false;
      return HabitWithStatus(habit: habit, isCompleted: isCompleted);
    }).toList();
  }

  MonthStats _calculateMonthStats(Map<String, double> completionData) {
    if (completionData.isEmpty) {
      return const MonthStats(
        daysTracked: 0,
        completionRate: 0,
        bestStreak: 0,
      );
    }

    // Days tracked (days with any completion data)
    final daysTracked = completionData.values.where((rate) => rate > 0).length;

    // Average completion rate
    final totalRate = completionData.values.reduce((a, b) => a + b);
    final avgRate = totalRate / completionData.length;

    // Best streak (consecutive days with 100% completion)
    int bestStreak = 0;
    int currentStreak = 0;
    
    final sortedDates = completionData.keys.toList()..sort();
    for (final dateKey in sortedDates) {
      if (completionData[dateKey]! >= 100) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return MonthStats(
      daysTracked: daysTracked,
      completionRate: avgRate,
      bestStreak: bestStreak,
    );
  }
}