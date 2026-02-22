import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../../../tracking/presentation/bloc/calendar_bloc.dart';
import '../../../tracking/presentation/bloc/calendar_event.dart';
import '../../../tracking/presentation/bloc/calendar_state.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateHelper.normalize(_focusedDay);
    // Load initial data
    context.read<CalendarBloc>().add(LoadMonthCompletionEvent(_focusedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CalendarBloc>().add(
                    RefreshCalendarEvent(_focusedDay),
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CalendarError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.error),
                  SizedBox(height: context.spacing(16)),
                  Text(state.message),
                  SizedBox(height: context.spacing(16)),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CalendarBloc>().add(
                            LoadMonthCompletionEvent(_focusedDay),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarLoaded) {
            return Column(
              children: [
                _buildCalendar(state),
                SizedBox(height: context.spacing(16)),
                _buildHeatmapLegend(),
                SizedBox(height: context.spacing(16)),
                _buildMonthlyStats(state.monthStats),
                SizedBox(height: context.spacing(16)),
                Expanded(
                  child: _buildSelectedDayHabits(state),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCalendar(CalendarLoaded state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.week: 'Week',
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (selectedDay.isAfter(DateTime.now())) {
            _showFutureDateMessage();
            return;
          }

          setState(() {
            _selectedDay = DateHelper.normalize(selectedDay);
            _focusedDay = focusedDay;
          });
          
          context.read<CalendarBloc>().add(
                LoadDateHabitsEvent(_selectedDay!),
              );
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          context.read<CalendarBloc>().add(
                LoadMonthCompletionEvent(focusedDay),
              );
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false, false, state.completionData);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, true, false, state.completionData);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, false, true, state.completionData);
          },
          outsideBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              false,
              false,
              state.completionData,
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
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
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

  Widget _buildDayCell(
    DateTime day,
    bool isSelected,
    bool isToday,
    Map<String, double> completionData, {
    bool isOutside = false,
  }) {
    final dateKey = DateHelper.getDateKey(day);
    final completionRate = completionData[dateKey] ?? 0.0;
    
    Color cellColor;
    if (isOutside) {
      cellColor = Colors.transparent;
    } else if (isSelected) {
      cellColor = AppColors.primary;
    } else if (isToday) {
      cellColor = AppColors.primary.withOpacity(0.3);
    } else if (completionRate > 0) {
      cellColor = _getHeatmapColor(completionRate);
    } else {
      cellColor = AppColors.surfaceVariant;
    }

    return Container(
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
    );
  }

  Color _getHeatmapColor(double completionRate) {
    if (completionRate >= 80) {
      return AppColors.success;
    } else if (completionRate >= 60) {
      return AppColors.success.withOpacity(0.7);
    } else if (completionRate >= 40) {
      return AppColors.success.withOpacity(0.5);
    } else if (completionRate >= 20) {
      return AppColors.success.withOpacity(0.3);
    } else {
      return AppColors.surfaceVariant;
    }
  }

  Widget _buildHeatmapLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Less',
            style: TextStyle(
              fontSize: context.fontSize(12),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: context.spacing(8)),
          ...List.generate(5, (index) {
            final colors = [
              AppColors.surfaceVariant,
              AppColors.success.withOpacity(0.3),
              AppColors.success.withOpacity(0.5),
              AppColors.success.withOpacity(0.7),
              AppColors.success,
            ];
            return Container(
              width: 16,
              height: 16,
              margin: EdgeInsets.symmetric(horizontal: context.spacing(2)),
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
          SizedBox(width: context.spacing(8)),
          Text(
            'More',
            style: TextStyle(
              fontSize: context.fontSize(12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(MonthStats stats) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Days Tracked',
            '${stats.daysTracked}',
            Icons.calendar_today,
            AppColors.primary,
          ),
          _buildStatItem(
            'Completion',
            '${stats.completionRate.toInt()}%',
            Icons.check_circle,
            AppColors.success,
          ),
          _buildStatItem(
            'Best Streak',
            '${stats.bestStreak}',
            Icons.local_fire_department,
            AppColors.readOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: context.spacing(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.fontSize(20),
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
        ),
      ],
    );
  }

  Widget _buildSelectedDayHabits(CalendarLoaded state) {
    if (state.habitsForSelectedDate.isEmpty) {
      return _buildEmptyState('No habits for this day');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getDateLabel(state.selectedDate),
                style: TextStyle(
                  fontSize: context.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!DateHelper.isToday(state.selectedDate))
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.spacing(12),
                    vertical: context.spacing(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: context.fontSize(12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: context.spacing(12)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
            itemCount: state.habitsForSelectedDate.length,
            itemBuilder: (context, index) {
              final habitWithStatus = state.habitsForSelectedDate[index];
              return _buildHabitItem(
                habitWithStatus.habit.name,
                habitWithStatus.isCompleted,
                Color(habitWithStatus.habit.colorCode),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHabitItem(String name, bool isCompleted, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(12)),
      padding: EdgeInsets.all(context.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted ? color : AppColors.textSecondary,
            size: 24,
          ),
          SizedBox(width: context.spacing(12)),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: context.fontSize(16),
                fontWeight: FontWeight.w600,
                color: Colors.white,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (isCompleted)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing(8),
                vertical: context.spacing(4),
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            message,
            style: TextStyle(
              fontSize: context.fontSize(16),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    if (DateHelper.isToday(date)) {
      return 'Today\'s Habits';
    } else if (DateHelper.isYesterday(date)) {
      return 'Yesterday';
    } else {
      return DateHelper.formatFull(date);
    }
  }

  void _showFutureDateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cannot select future dates'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}