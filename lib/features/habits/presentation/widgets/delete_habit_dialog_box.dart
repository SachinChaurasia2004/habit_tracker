import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';

class DeleteHabitDialog extends StatelessWidget {
  const DeleteHabitDialog({super.key, required this.habitId});

  final String habitId;

  static Future<void> show(BuildContext context, String habitId) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<HabitBloc>(),
        child: DeleteHabitDialog(habitId: habitId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: const Text('Delete Habit'),
      content: const Text('Are you sure you want to delete this habit? '),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            context.read<HabitBloc>().add(DeleteHabitEvent(habitId));
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
