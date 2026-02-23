import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/calendar_state.dart';

class MonthlyStatsCard extends StatelessWidget {
  final MonthStats stats;

  const MonthlyStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Days Tracked',
            value: '${stats.daysTracked}',
            icon: Icons.calendar_today,
            color: AppColors.primary,
          ),
          _StatItem(
            label: 'Completion',
            value: '${stats.completionRate.toInt()}%',
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
          _StatItem(
            label: 'Best Streak',
            value: '${stats.bestStreak}',
            icon: Icons.local_fire_department,
            color: AppColors.readOrange,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: context.spacing(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.fontSize(20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: context.spacing(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: context.fontSize(12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

