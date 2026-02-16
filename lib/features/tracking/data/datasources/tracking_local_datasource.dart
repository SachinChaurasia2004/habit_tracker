import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/habit_entry_model.dart';

/// Interface for tracking data source operations
abstract class TrackingLocalDataSource {
  /// Get all entries
  Future<List<HabitEntryModel>> getAllEntries();

  /// Get entries for a specific habit
  Future<List<HabitEntryModel>> getEntriesForHabit(String habitId);

  /// Get entries for a specific date
  Future<List<HabitEntryModel>> getEntriesForDate(DateTime date);

  /// Get a specific entry by habit and date
  Future<HabitEntryModel?> getEntryByHabitAndDate(String habitId, DateTime date);

  /// Save an entry
  Future<void> saveEntry(HabitEntryModel entry);

  /// Update an entry
  Future<void> updateEntry(HabitEntryModel entry);

  /// Delete an entry
  Future<void> deleteEntry(String id);

  /// Delete all entries for a habit
  Future<void> deleteEntriesForHabit(String habitId);
}

/// Implementation using Hive
class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  final Box<HabitEntryModel> box;

  TrackingLocalDataSourceImpl(this.box);

  @override
  Future<List<HabitEntryModel>> getAllEntries() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get entries: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntryModel>> getEntriesForHabit(String habitId) async {
    try {
      return box.values
          .where((entry) => entry.habitId == habitId)
          .toList();
    } catch (e) {
      throw CacheException('Failed to get entries for habit: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntryModel>> getEntriesForDate(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      return box.values.where((entry) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        return entryDate == normalizedDate;
      }).toList();
    } catch (e) {
      throw CacheException('Failed to get entries for date: ${e.toString()}');
    }
  }

  @override
  Future<HabitEntryModel?> getEntryByHabitAndDate(
    String habitId,
    DateTime date,
  ) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      
      for (final entry in box.values) {
        final entryDate = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        
        if (entry.habitId == habitId && entryDate == normalizedDate) {
          return entry;
        }
      }
      
      return null;
    } catch (e) {
      throw CacheException('Failed to get entry: ${e.toString()}');
    }
  }

  @override
  Future<void> saveEntry(HabitEntryModel entry) async {
    try {
      await box.put(entry.id, entry);
    } catch (e) {
      throw CacheException('Failed to save entry: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEntry(HabitEntryModel entry) async {
    try {
      if (!box.containsKey(entry.id)) {
        throw CacheException('Entry not found: ${entry.id}');
      }
      await box.put(entry.id, entry);
    } catch (e) {
      throw CacheException('Failed to update entry: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete entry: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEntriesForHabit(String habitId) async {
    try {
      final entriesToDelete = box.values
          .where((entry) => entry.habitId == habitId)
          .map((entry) => entry.id)
          .toList();

      for (final id in entriesToDelete) {
        await box.delete(id);
      }
    } catch (e) {
      throw CacheException('Failed to delete entries: ${e.toString()}');
    }
  }
}