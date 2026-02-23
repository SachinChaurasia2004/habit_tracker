import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../bloc/calendar_state.dart';
import '../widgets/calendar_view.dart';
import '../widgets/heatmap_legend.dart';
import '../widgets/monthly_stats_card.dart';
import '../widgets/selected_day_habits_section.dart';

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
                CalendarView(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  calendarFormat: _calendarFormat,
                  completionData: state.completionData,
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
                ),
                SizedBox(height: context.spacing(16)),
                const HeatmapLegend(),
                SizedBox(height: context.spacing(16)),
                MonthlyStatsCard(stats: state.monthStats),
                SizedBox(height: context.spacing(16)),
                Expanded(
                  child: SelectedDayHabitsSection(
                    selectedDate: state.selectedDate,
                    habits: state.habitsForSelectedDate,
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
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
