import 'package:hive/hive.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import '../models/habit_model.dart';
abstract class HabitLocalDataSource {
  /// Get all habits from local storage
  Future<List<HabitModel>> getAllHabits();

  /// Get a specific habit by ID
  Future<HabitModel> getHabitById(String id);

  /// Save a habit to local storage
  Future<void> saveHabit(HabitModel habit);

  /// Update an existing habit
  Future<void> updateHabit(HabitModel habit);

  /// Delete a habit by ID
  Future<void> deleteHabit(String id);

  /// Check if a habit exists
  Future<bool> habitExists(String id);
}

/// Implementation using Hive
class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final Box<HabitModel> box;

  HabitLocalDataSourceImpl(this.box);

  @override
  Future<List<HabitModel>> getAllHabits() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get habits: ${e.toString()}');
    }
  }

  @override
  Future<HabitModel> getHabitById(String id) async {
    try {
      final habit = box.get(id);
      if (habit == null) {
        throw CacheException('Habit not found: $id');
      }
      return habit;
    } catch (e) {
      throw CacheException('Failed to get habit: ${e.toString()}');
    }
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    try {
      await box.put(habit.id, habit);
    } catch (e) {
      throw CacheException('Failed to save habit: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    try {
      if (!box.containsKey(habit.id)) {
        throw CacheException('Habit not found: ${habit.id}');
      }
      await box.put(habit.id, habit);
    } catch (e) {
      throw CacheException('Failed to update habit: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete habit: ${e.toString()}');
    }
  }

  @override
  Future<bool> habitExists(String id) async {
    try {
      return box.containsKey(id);
    } catch (e) {
      throw CacheException('Failed to check habit existence: ${e.toString()}');
    }
  }
}