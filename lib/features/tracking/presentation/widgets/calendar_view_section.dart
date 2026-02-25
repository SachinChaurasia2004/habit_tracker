import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';

class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Map<String, double> completionData;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;
  final Color? habitColor;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.completionData,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now(),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
        },
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              context: context,
              day: day,
              isSelected: false,
              isToday: false,
              completionData: completionData,
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              context: context,
              day: day,
              isSelected: true,
              isToday: false,
              completionData: completionData,
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              context: context,
              day: day,
              isSelected: false,
              isToday: true,
              completionData: completionData,
            );
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              context: context,
              day: day,
              isSelected: false,
              isToday: false,
              completionData: completionData,
              isOutside: true,
            );
          },
        ),
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.all(context.spacing(4)),
          defaultDecoration: const BoxDecoration(),
          selectedDecoration: const BoxDecoration(),
          todayDecoration: const BoxDecoration(),
          outsideDecoration: const BoxDecoration(),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: context.fontSize(18),
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: context.fontSize(12),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: context.fontSize(12),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required bool isSelected,
    required bool isToday,
    required Map<String, double> completionData,
    bool isOutside = false,
  }) {
    final dateKey = DateHelper.getDateKey(day);
    final completionRate = completionData[dateKey] ?? 0.0;

    Color cellColor;
    if (isOutside) {
      cellColor = Colors.transparent;
    } else if (isSelected) {
      cellColor = AppColors.primary;
    } else if (completionRate > 0) {
      cellColor = _getHeatmapColor(completionRate);
    } else {
      cellColor = AppColors.surfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: isOutside
                  ? AppColors.textSecondary.withOpacity(0.3)
                  : isSelected || (completionRate > 75)
                  ? Colors.white
                  : Colors.white70,
              fontSize: context.fontSize(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _getHeatmapColor(double completionRate) {
    final baseColor = habitColor ?? AppColors.success;
    if (completionRate >= 80) {
      return baseColor;
    } else if (completionRate >= 60) {
      return baseColor.withOpacity(0.7);
    } else if (completionRate >= 40) {
      return baseColor.withOpacity(0.5);
    } else if (completionRate >= 20) {
      return baseColor.withOpacity(0.3);
    } else {
      return AppColors.surfaceVariant;
    }
  }
}
