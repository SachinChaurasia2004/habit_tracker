import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../tracking/domain/entities/habit_performance.dart';
import '../../../tracking/domain/entities/overall_stats.dart';
import '../../../tracking/domain/entities/weekly_stats.dart';
import '../../../tracking/presentation/bloc/stats_bloc.dart';
import '../../../tracking/presentation/bloc/stats_event.dart';
import '../../../tracking/presentation/bloc/stats_state.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(const LoadStatisticsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          BlocBuilder<StatisticsBloc, StatisticsState>(
            builder: (context, state) {
              if (state is! StatisticsLoaded) return const SizedBox.shrink();

              return PopupMenuButton<StatisticsPeriod>(
                initialValue: state.currentPeriod,
                onSelected: (period) {
                  context.read<StatisticsBloc>().add(ChangePeriodEvent(period));
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: StatisticsPeriod.week,
                    child: Text('Week'),
                  ),
                  const PopupMenuItem(
                    value: StatisticsPeriod.month,
                    child: Text('Month'),
                  ),
                  const PopupMenuItem(
                    value: StatisticsPeriod.year,
                    child: Text('Year'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        state.periodLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
        builder: (context, state) {
          if (state is StatisticsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is StatisticsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<StatisticsBloc>().add(
                        const RefreshStatisticsEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is StatisticsLoaded) {
            if (!state.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No statistics yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking habits to see your stats',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsBloc>().add(
                  const RefreshStatisticsEvent(),
                );
              },
              child: ListView(
                padding: EdgeInsets.all(context.pagePadding),
                children: [
                  _OverviewSection(stats: state.overallStats),
                  SizedBox(height: context.spacing(24)),
                  _TrendChart(weeklyStats: state.weeklyStats),
                  SizedBox(height: context.spacing(24)),
                  _HabitPerformanceSection(
                    performances: state.habitPerformances,
                  ),
                  SizedBox(height: context.spacing(24)),
                  _TopPerformersSection(performers: state.topPerformers),
                  SizedBox(height: context.spacing(24)),
                  _InsightsSection(state: state),
                  const SizedBox(height: 100),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.stats});

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

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.weeklyStats});

  final WeeklyStats weeklyStats;

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
            'Weekly Trend',
            style: TextStyle(
              fontSize: context.fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          return Text(
                            days[value.toInt()],
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.fontSize(12),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyStats.dailyCompletions
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.completedCount.toDouble(),
                          ),
                        )
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitPerformanceSection extends StatelessWidget {
  const _HabitPerformanceSection({required this.performances});

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

class _TopPerformersSection extends StatelessWidget {
  const _TopPerformersSection({required this.performers});

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
              color: Color(performance.colorCode).withOpacity(0.2),
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

class _InsightsSection extends StatelessWidget {
  const _InsightsSection({required this.state});

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
