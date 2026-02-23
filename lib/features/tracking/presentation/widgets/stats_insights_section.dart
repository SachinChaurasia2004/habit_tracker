import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/stats_state.dart';

class InsightsSection extends StatelessWidget {
  const InsightsSection({super.key, required this.state});

  final StatisticsLoaded state;

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(state);

    if (insights.isEmpty) return const SizedBox.shrink();

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
              const Text('💡', style: TextStyle(fontSize: 24)),
              SizedBox(width: context.spacing(8)),
              Text(
                'Insights',
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          ...insights.map((insight) => _InsightItem(insight: insight)),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights(StatisticsLoaded state) {
    final insights = <_Insight>[];

    // Positive insight for high completion rate
    if (state.overallStats.overallCompletionRate >= 75) {
      insights.add(
        _Insight(
          title: '🔥 You\'re on fire!',
          description:
              'Your completion rate is ${state.overallStats.overallCompletionRate.toInt()}%. Keep it up!',
          type: _InsightType.positive,
        ),
      );
    }

    // Warning for low performing habits
    final needsAttention = state.needsAttention;
    if (needsAttention.isNotEmpty) {
      final habitName = needsAttention.first.habitName;
      insights.add(
        _Insight(
          title: '⚠️ Needs attention',
          description:
              '"$habitName" has a low completion rate. Try setting a reminder!',
          type: _InsightType.warning,
        ),
      );
    }

    // Info about best streak
    if (state.overallStats.bestStreak >= 7) {
      insights.add(
        _Insight(
          title: '⭐ Amazing streak!',
          description:
              'Your best streak is ${state.overallStats.bestStreak} days. Can you beat it?',
          type: _InsightType.info,
        ),
      );
    }

    // Improvement insight
    if (state.weeklyStats.averageCompletionRate > 50) {
      insights.add(
        _Insight(
          title: '📈 Great progress',
          description:
              'You completed ${state.weeklyStats.totalCompletions} habits this week!',
          type: _InsightType.positive,
        ),
      );
    }

    return insights;
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({required this.insight});

  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: insight.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: context.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.spacing(4)),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: context.fontSize(12),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Insight {
  final String title;
  final String description;
  final _InsightType type;

  const _Insight({
    required this.title,
    required this.description,
    required this.type,
  });

  Color get color {
    switch (type) {
      case _InsightType.positive:
        return AppColors.success;
      case _InsightType.warning:
        return AppColors.warning;
      case _InsightType.info:
        return AppColors.info;
    }
  }
}

enum _InsightType { positive, warning, info }

