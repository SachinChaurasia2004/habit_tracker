import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';

class DateSelectorWidget extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onDateChanged;

  const DateSelectorWidget({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
  });

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late List<DateTime> weekDates;

  @override
  void initState() {
    super.initState();
    _updateWeekDates();
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDate != widget.currentDate) {
      _updateWeekDates();
    }
  }

  void _updateWeekDates() {
    weekDates = DateHelper.getCurrentWeek();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: weekDates.map((date) {
          final isSelected = DateHelper.isSameDay(date, widget.currentDate);
          final isToday = DateHelper.isToday(date);
          final isFuture = date.isAfter(DateHelper.normalize(DateTime.now()));
          final dayName = DateHelper.getDayOfWeekShort(date);

          return GestureDetector(
            onTap: () {
              if (isFuture) {
                _showFutureDateMessage(context);
              } else {
                widget.onDateChanged(date);
              }
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBackground, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFutureDateMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('future date'),
        backgroundColor: AppColors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
