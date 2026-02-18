import 'package:equatable/equatable.dart';

/// Represents a habit that the user wants to track.

class Habit extends Equatable {

  final String id;
  final String name;
  final String iconName;
  final int colorCode;
  final DateTime createdAt;
  final bool isActive;

  const Habit({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorCode,
    required this.createdAt,
    this.isActive = true,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorCode,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorCode: colorCode ?? this.colorCode,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, colorCode, createdAt, isActive];

  @override
  bool get stringify => true;
}