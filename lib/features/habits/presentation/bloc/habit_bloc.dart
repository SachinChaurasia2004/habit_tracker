import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/get_all_habits.dart';
import '../../domain/usecases/get_active_habits.dart';
import '../../domain/usecases/update_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabit createHabit;
  final GetAllHabits getAllHabits;
  final GetActiveHabits getActiveHabits;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;

  HabitBloc({
    required this.createHabit,
    required this.getAllHabits,
    required this.getActiveHabits,
    required this.updateHabit,
    required this.deleteHabit,
  }) : super(const HabitInitial()) {
    on<LoadHabitsEvent>(_onLoadHabits);
    on<LoadActiveHabitsEvent>(_onLoadActiveHabits);
    on<CreateHabitEvent>(_onCreateHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<RefreshHabitsEvent>(_onRefreshHabits);
  }

  Future<void> _onLoadHabits(
    LoadHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(const HabitLoading());

    final result = await getAllHabits();

    result.fold(
      (failure) => emit(HabitError(failure.message)),
      (habits) => emit(HabitsLoaded(habits)),
    );
  }

  Future<void> _onLoadActiveHabits(
    LoadActiveHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(const HabitLoading());

    final result = await getActiveHabits();

    result.fold(
      (failure) => emit(HabitError(failure.message)),
      (habits) => emit(HabitsLoaded(habits)),
    );
  }

  Future<void> _onCreateHabit(
    CreateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(const HabitLoading());

    debugPrint('[HabitBloc] Creating habit: ${event.name}');
    debugPrint(
      '[HabitBloc]   Reminder: ${event.reminderHour != null ? "${event.reminderHour}:${event.reminderMinute}" : "none"}',
    );

    final result = await createHabit(
      CreateHabitParams(
        id: const Uuid().v4(),
        name: event.name,
        iconName: event.iconName,
        colorCode: event.colorCode,
        reminderHour: event.reminderHour,
        reminderMinute: event.reminderMinute,
      ),
    );

    result.fold(
      (failure) {
        debugPrint('[HabitBloc] Failed to create habit: ${failure.message}');
        emit(HabitError(failure.message));
      },
      (habit) {
        debugPrint('[HabitBloc] Habit created successfully: ${habit.id}');
        emit(HabitCreated(habit));
        // Reload habits after creation
        add(const LoadActiveHabitsEvent());
      },
    );
  }

  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(const HabitLoading());

    final result = await updateHabit(
      UpdateHabitParams(
        habitId: event.habitId,
        name: event.name,
        iconName: event.iconName,
        colorCode: event.colorCode,
        isActive: event.isActive,
        reminderHour: event.reminderHour,
        reminderMinute: event.reminderMinute,
        clearReminder: event.clearReminder,
      ),
    );

    result.fold((failure) => emit(HabitError(failure.message)), (habit) {
      emit(HabitUpdated(habit));
      // Reload habits after update
      add(const LoadActiveHabitsEvent());
    });
  }

  Future<void> _onDeleteHabit(
    DeleteHabitEvent event,
    Emitter<HabitState> emit,
  ) async {
    emit(const HabitLoading());

    final result = await deleteHabit(DeleteHabitParams(habitId: event.habitId));

    result.fold((failure) => emit(HabitError(failure.message)), (_) {
      emit(const HabitDeleted());
      // Reload habits after deletion
      add(const LoadActiveHabitsEvent());
    });
  }

  Future<void> _onRefreshHabits(
    RefreshHabitsEvent event,
    Emitter<HabitState> emit,
  ) async {
    // Don't show loading for refresh
    final result = await getActiveHabits();

    result.fold(
      (failure) => emit(HabitError(failure.message)),
      (habits) => emit(HabitsLoaded(habits)),
    );
  }
}
