import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile
class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

/// Update user profile
class UpdateProfileEvent extends ProfileEvent {
  final String name;

  const UpdateProfileEvent(this.name);

  @override
  List<Object?> get props => [name];
}