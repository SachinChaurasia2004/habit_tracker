import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class EmptyHabitsView extends StatelessWidget {
  const EmptyHabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first habit',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}