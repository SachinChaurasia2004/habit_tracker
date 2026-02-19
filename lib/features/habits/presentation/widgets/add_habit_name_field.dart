import 'package:flutter/material.dart';
import '../../../../../core/utils/app_constants.dart';

class HabitNameField extends StatelessWidget {
  const HabitNameField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (_) => onChanged(),
      decoration: const InputDecoration(hintText: 'e.g., Morning Yoga'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a habit name';
        }
        if (value.length > AppConstants.habitNameMaxLength) {
          return 'Name too long (max ${AppConstants.habitNameMaxLength} characters)';
        }
        return null;
      },
    );
  }
}