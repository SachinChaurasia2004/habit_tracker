import 'package:equatable/equatable.dart';

/// Represents the user's profile information
class UserProfile extends Equatable {
  /// User's display name
  final String name;
  
  /// Date when the user started using the app
  final DateTime? joinDate;

  const UserProfile({
    required this.name,
    this.joinDate,
  });

  /// Creates a copy with the given fields replaced
  UserProfile copyWith({
    String? name,
    DateTime? joinDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  @override
  List<Object?> get props => [name, joinDate];

  @override
  bool get stringify => true;
}