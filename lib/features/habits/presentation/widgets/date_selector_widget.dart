import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';


class DateSelectorWidget extends StatefulWidget {
  const DateSelectorWidget({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
  });

  final DateTime currentDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  State<DateSelectorWidget> createState() => _DateSelectorWidgetState();
}

class _DateSelectorWidgetState extends State<DateSelectorWidget> {
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _weekDates = DateHelper.getCurrentWeek();
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDate != widget.currentDate) {
      _weekDates = DateHelper.getCurrentWeek();
    }
  }

  void _onDateTapped(BuildContext context, DateTime date) {
    if (date.isAfter(DateHelper.normalize(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot select a future date'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      widget.onDateChanged(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.pagePadding;
    final itemWidth = context.isTabletOrLarger ? 88.0 : 72.0;
    final itemSpacing = context.isTabletOrLarger ? 12.0 : 8.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: context.spacing(8),
      ),
      child: Row(
        children: _weekDates.map((date) {
          return Padding(
            padding: EdgeInsets.only(right: itemSpacing),
            child: _DateItem(
              date: date,
              width: itemWidth,
              isSelected: DateHelper.isSameDay(date, widget.currentDate),
              isToday: DateHelper.isToday(date),
              onTap: () => _onDateTapped(context, date),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  const _DateItem({
    required this.date,
    required this.width,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final double width;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        padding: EdgeInsets.symmetric(vertical: context.spacing(12)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBackground),
        ),
        child: Column(
          children: [
            Text(
              DateHelper.getDayOfWeekShort(date),
              style: TextStyle(
                fontSize: context.fontSize(12),
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: context.spacing(8)),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: context.fontSize(16),
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
  }
}