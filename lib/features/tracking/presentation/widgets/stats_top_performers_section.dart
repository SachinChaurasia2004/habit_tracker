import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/habit_performance.dart';

class TopPerformersSection extends StatelessWidget {
  const TopPerformersSection({super.key, required this.performers});

  final List<HabitPerformance> performers;

  @override
  Widget build(BuildContext context) {
    if (performers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              SizedBox(width: context.spacing(8)),
              Text(
                'Top Performers',
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          ...performers.asMap().entries.map((entry) {
            final index = entry.key;
            final performer = entry.value;
            return _TopPerformerItem(rank: index + 1, performance: performer);
          }),
        ],
      ),
    );
  }
}

class _TopPerformerItem extends StatelessWidget {
  const _TopPerformerItem({required this.rank, required this.performance});

  final int rank;
  final HabitPerformance performance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing(12)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Color(performance.colorCode).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: context.fontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Color(performance.colorCode),
                ),
              ),
            ),
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.habitName,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${performance.currentStreak} day streak',
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.emoji_events,
            color: Color(performance.colorCode),
            size: 24,
          ),
        ],
      ),
    );
  }
}

