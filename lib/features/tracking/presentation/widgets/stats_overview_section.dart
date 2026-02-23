import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/overall_stats.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, required this.stats});

  final OverallStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: context.spacing(12),
      crossAxisSpacing: context.spacing(12),
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          label: 'Total Habits',
          value: stats.totalHabits.toString(),
          icon: Icons.list_alt,
          color: AppColors.primary,
        ),
        _StatCard(
          label: 'Days Tracked',
          value: stats.daysTracked.toString(),
          icon: Icons.calendar_today,
          color: AppColors.yogaGreen,
        ),
        _StatCard(
          label: 'Completion',
          value: '${stats.overallCompletionRate.toInt()}%',
          icon: Icons.trending_up,
          color: AppColors.waterBlue,
        ),
        _StatCard(
          label: 'Best Streak',
          value: '${stats.bestStreak} days',
          icon: Icons.local_fire_department,
          color: AppColors.readOrange,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: context.spacing(8)),
          Text(
            value,
            style: TextStyle(
              fontSize: context.fontSize(24),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

