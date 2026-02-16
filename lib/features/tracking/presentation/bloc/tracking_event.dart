import 'package:equatable/equatable.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Load today's tracking data
class LoadTodayTrackingEvent extends TrackingEvent {
  const LoadTodayTrackingEvent();
}

/// Load tracking data for a specific date
class LoadDateTrackingEvent extends TrackingEvent {
  final DateTime date;

  const LoadDateTrackingEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// Toggle habit completion
class ToggleHabitCompletionEvent extends TrackingEvent {
  final String habitId;
  final DateTime date;

  const ToggleHabitCompletionEvent({
    required this.habitId,
    required this.date,
  });

  @override
  List<Object?> get props => [habitId, date];
}

/// Refresh tracking data
class RefreshTrackingEvent extends TrackingEvent {
  const RefreshTrackingEvent();
}