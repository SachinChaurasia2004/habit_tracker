import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];

  // Helper getters
  String get userName => profile.name;
  DateTime get joinDate => profile.joinDate;
  bool get notificationsEnabled => profile.notificationsEnabled;
  bool get darkModeEnabled => profile.darkModeEnabled;
  String? get avatarPath => profile.avatarPath;

  String get joinDateFormatted {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[joinDate.month - 1]} ${joinDate.year}';
  }

  ProfileLoaded copyWith({
    UserProfile? profile,
  }) {
    return ProfileLoaded(profile ?? this.profile);
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}