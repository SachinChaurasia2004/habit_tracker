import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 2)
class UserProfileModel extends UserProfile {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final DateTime? joinDate;

  const UserProfileModel({
    required this.name,
    this.joinDate,
  }) : super(
          name: name,
          joinDate: joinDate,
        );

  /// Convert Entity to Model
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      name: profile.name,
      joinDate: profile.joinDate,
    );
  }

  /// Convert Model to Entity
  UserProfile toEntity() {
    return UserProfile(
      name: name,
      joinDate: joinDate,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'joinDate': joinDate?.toIso8601String(),
    };
  }

  /// From JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] as String,
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate'] as String)
          : null,
    );
  }

  /// Copy with
  UserProfileModel copyWith({
    String? name,
    DateTime? joinDate,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}