import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_profile_model.dart';

/// Interface for profile data source operations
abstract class ProfileLocalDataSource {
  /// Get the user profile
  Future<UserProfileModel> getProfile();

  /// Save the user profile
  Future<void> saveProfile(UserProfileModel profile);

  /// Check if profile exists
  Future<bool> profileExists();

  /// Delete profile
  Future<void> deleteProfile();
}

/// Implementation using Hive
class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final Box<UserProfileModel> box;
  static const String profileKey = 'user_profile';

  ProfileLocalDataSourceImpl(this.box);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final profile = box.get(profileKey);
      if (profile == null) {
        throw CacheException('Profile not found');
      }
      return profile;
    } catch (e) {
      throw CacheException('Failed to get profile: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await box.put(profileKey, profile);
    } catch (e) {
      throw CacheException('Failed to save profile: ${e.toString()}');
    }
  }

  @override
  Future<bool> profileExists() async {
    try {
      return box.containsKey(profileKey);
    } catch (e) {
      throw CacheException('Failed to check profile existence: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      await box.delete(profileKey);
    } catch (e) {
      throw CacheException('Failed to delete profile: ${e.toString()}');
    }
  }
}