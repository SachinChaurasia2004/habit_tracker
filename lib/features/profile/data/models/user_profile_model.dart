import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 3)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final DateTime joinDate;

  @HiveField(2)
  final bool notificationsEnabled;

  @HiveField(3)
  final bool darkModeEnabled;

  @HiveField(4)
  final String? avatarPath;

  @HiveField(5)
  final Map<String, dynamic>? preferences;

  UserProfileModel({
    required this.name,
    required this.joinDate,
    this.notificationsEnabled = false,
    this.darkModeEnabled = true,
    this.avatarPath,
    this.preferences,
  });

  // Convert to entity
  UserProfile toEntity() {
    return UserProfile(
      name: name,
      joinDate: joinDate,
      notificationsEnabled: notificationsEnabled,
      darkModeEnabled: darkModeEnabled,
      avatarPath: avatarPath,
      preferences: preferences,
    );
  }

  // Create from entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      name: profile.name,
      joinDate: profile.joinDate,
      notificationsEnabled: profile.notificationsEnabled,
      darkModeEnabled: profile.darkModeEnabled,
      avatarPath: profile.avatarPath,
      preferences: profile.preferences,
    );
  }

  // Create default profile
  factory UserProfileModel.createDefault() {
    return UserProfileModel(
      name: 'User',
      joinDate: DateTime.now(),
      notificationsEnabled: false,
      darkModeEnabled: true,
    );
  }
}