import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all statistics
class LoadStatisticsEvent extends StatisticsEvent {
  final StatisticsPeriod period;

  const LoadStatisticsEvent({
    this.period = StatisticsPeriod.week,
  });

  @override
  List<Object?> get props => [period];
}

/// Refresh statistics
class RefreshStatisticsEvent extends StatisticsEvent {
  const RefreshStatisticsEvent();
}

/// Change period (week/month/year)
class ChangePeriodEvent extends StatisticsEvent {
  final StatisticsPeriod period;

  const ChangePeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

enum StatisticsPeriod {
  week,
  month,
  year,
}

extension StatisticsPeriodExtension on StatisticsPeriod {
  String get displayName {
    switch (this) {
      case StatisticsPeriod.week:
        return 'Week';
      case StatisticsPeriod.month:
        return 'Month';
      case StatisticsPeriod.year:
        return 'Year';
    }
  }
}