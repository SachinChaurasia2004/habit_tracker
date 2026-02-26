import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final DateTime joinDate;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String? avatarPath;
  final Map<String, dynamic>? preferences;

  const UserProfile({
    required this.name,
    required this.joinDate,
    this.notificationsEnabled = false,
    this.darkModeEnabled = true,
    this.avatarPath,
    this.preferences,
  });

  UserProfile copyWith({
    String? name,
    DateTime? joinDate,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? avatarPath,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      avatarPath: avatarPath ?? this.avatarPath,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        name,
        joinDate,
        notificationsEnabled,
        darkModeEnabled,
        avatarPath,
        preferences,
      ];
}