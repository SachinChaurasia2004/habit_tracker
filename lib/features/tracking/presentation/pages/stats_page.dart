import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/stats_bloc.dart';
import '../bloc/stats_event.dart';
import '../bloc/stats_state.dart';
import '../widgets/stats_overview_section.dart';
import '../widgets/stats_trend_chart.dart';
import '../widgets/stats_habit_performance_section.dart';
import '../widgets/stats_top_performers_section.dart';
import '../widgets/stats_insights_section.dart';

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
                  HabitPerformanceSection(
                    performances: state.habitPerformances,
                  ),
                  SizedBox(height: context.spacing(24)),
                  TrendChart(weeklyStats: state.weeklyStats),
                  SizedBox(height: context.spacing(24)),
                  OverviewSection(stats: state.overallStats),
                  SizedBox(height: context.spacing(24)),
                  TopPerformersSection(performers: state.topPerformers),
                  SizedBox(height: context.spacing(24)),
                  InsightsSection(state: state),
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
