import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/calendar_state.dart';

class SelectedDayHabitsSection extends StatelessWidget {
  final DateTime selectedDate;
  final List<HabitWithStatus> habits;

  const SelectedDayHabitsSection({
    super.key,
    required this.selectedDate,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return _buildEmptyState(context, 'No habits for this day');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getDateLabel(selectedDate),
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!DateHelper.isToday(selectedDate))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing(12),
                    vertical: context.spacing(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spacing(12)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habitWithStatus = habits[index];
              return _buildHabitItem(
                context: context,
                name: habitWithStatus.habit.name,
                isCompleted: habitWithStatus.isCompleted,
                color: Color(habitWithStatus.habit.colorCode),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitItem({
    required BuildContext context,
    required String name,
    required bool isCompleted,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(12)),
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? color : AppColors.textSecondary,
            size: 24,
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: context.fontSize(16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (isCompleted)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing(8),
                vertical: context.spacing(4),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: context.fontSize(16),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    if (DateHelper.isToday(date)) {
      return 'Today\'s Habits';
    } else if (DateHelper.isYesterday(date)) {
      return 'Yesterday';
    } else {
      return DateHelper.formatFull(date);
    }
  }
}

