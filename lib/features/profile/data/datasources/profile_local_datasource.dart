import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> saveProfile(UserProfileModel profile);
  Future<void> deleteProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _profileKey = 'user_profile';
  final Box<UserProfileModel> box;

  ProfileLocalDataSourceImpl(this.box);

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final profile = box.get(_profileKey);
      
      if (profile == null) {
        // Create and save default profile
        final defaultProfile = UserProfileModel.createDefault();
        await box.put(_profileKey, defaultProfile);
        return defaultProfile;
      }
      
      return profile;
    } catch (e) {
      throw CacheException('Failed to get profile: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await box.put(_profileKey, profile);
    } catch (e) {
      throw CacheException('Failed to save profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile() async {
    try {
      await box.delete(_profileKey);
    } catch (e) {
      throw CacheException('Failed to delete profile: ${e.toString()}');
    }
  }
}