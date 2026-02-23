import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/habit_performance.dart';

class HabitPerformanceSection extends StatelessWidget {
  const HabitPerformanceSection({super.key, required this.performances});

  final List<HabitPerformance> performances;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Performance',
            style: TextStyle(
              fontSize: context.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          ...performances.map(
            (performance) => _HabitBar(performance: performance),
          ),
        ],
      ),
    );
  }
}

class _HabitBar extends StatelessWidget {
  const _HabitBar({required this.performance});

  final HabitPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  performance.habitName,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${performance.completionRate.toInt()}%',
                style: TextStyle(
                  fontSize: context.fontSize(14),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(8)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: performance.completionRate / 100,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(performance.colorCode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

