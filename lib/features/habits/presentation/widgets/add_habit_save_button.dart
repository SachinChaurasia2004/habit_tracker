import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_state.dart';

class HabitSaveButton extends StatelessWidget {
  const HabitSaveButton({
    super.key,
    required this.isEditMode,
    required this.onPressed,
  });

  final bool isEditMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) {
          final isLoading = state is HabitLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isEditMode ? 'Update Habit' : 'Create Habit'),
          );
        },
      ),
    );
  }
}