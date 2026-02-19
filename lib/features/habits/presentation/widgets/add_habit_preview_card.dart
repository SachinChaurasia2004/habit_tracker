import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/responsive.dart';
import 'add_habit_icon_data.dart';

class HabitPreviewCard extends StatelessWidget {
  const HabitPreviewCard({
    super.key,
    required this.name,
    required this.iconName,
    required this.color,
  });

  final String name;
  final String iconName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.isTabletOrLarger ? 56.0 : 48.0;

    return Container(
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(iconSize * 0.25),
            ),
            child: Icon(habitIconData(iconName), color: color,
                size: iconSize * 0.54),
          ),
          SizedBox(width: context.spacing(16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Habit Name' : name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: context.fontSize(16),
                    ),
              ),
              SizedBox(height: context.spacing(4)),
              Text(
                '0 Day Streak',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}