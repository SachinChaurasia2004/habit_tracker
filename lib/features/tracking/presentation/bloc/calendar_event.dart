import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Load completion data for a month
class LoadMonthCompletionEvent extends CalendarEvent {
  final DateTime month;

  const LoadMonthCompletionEvent(this.month);

  @override
  List<Object?> get props => [month];
}

/// Load habits for a specific date
class LoadDateHabitsEvent extends CalendarEvent {
  final DateTime date;

  const LoadDateHabitsEvent(this.date);

  @override
  List<Object?> get props => [date];
}

/// Refresh calendar data
class RefreshCalendarEvent extends CalendarEvent {
  final DateTime month;

  const RefreshCalendarEvent(this.month);

  @override
  List<Object?> get props => [month];
}