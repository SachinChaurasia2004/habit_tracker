import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Update entire profile
class UpdateProfileEvent extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Update just the name
class UpdateNameEvent extends ProfileEvent {
  final String name;

  const UpdateNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// Toggle notifications
class ToggleNotificationsEvent extends ProfileEvent {
  final bool enabled;

  const ToggleNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Toggle dark mode
class ToggleDarkModeEvent extends ProfileEvent {
  final bool enabled;

  const ToggleDarkModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Update avatar
class UpdateAvatarEvent extends ProfileEvent {
  final String? avatarPath;

  const UpdateAvatarEvent(this.avatarPath);

  @override
  List<Object?> get props => [avatarPath];
}

/// Reset profile
class ResetProfileEvent extends ProfileEvent {
  const ResetProfileEvent();
}