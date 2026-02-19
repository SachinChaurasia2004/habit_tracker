import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class EmptyHabitsView extends StatelessWidget {
  const EmptyHabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTabletOrLarger ? 80.0 : 64.0;
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task, size: iconSize, color: AppColors.textSecondary),
            SizedBox(height: context.spacing(16)),
             Text(
              'No habits yet',
              style: TextStyle(
                fontSize: context.fontSize(18),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: context.spacing(8)),
            Text(
              'Tap + to create your first habit',
              style: TextStyle(fontSize: context.fontSize(14), color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}