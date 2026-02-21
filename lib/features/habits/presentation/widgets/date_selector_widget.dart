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
  final _scrollController = ScrollController();
  final _dates = <DateTime>[];
  var _isLoading = false;

  static const _loadThreshold = 100.0;
  static const _maxHistoryDays = 7;

  @override
  void initState() {
    super.initState();
    _initializeDates();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeDates() {
    final currentWeek = DateHelper.getCurrentWeek();
    final previousWeek = _getWeekBefore(currentWeek.first);

    _dates
      ..addAll(previousWeek)
      ..addAll(currentWeek);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToDate());
  }

  void _scrollToDate() {
    final index = _dates.indexWhere(
      (date) => DateHelper.isSameDay(date, widget.currentDate),
    );

    if (index == -1 || !_scrollController.hasClients) return;

    final itemWidth = context.isTabletOrLarger ? 88.0 : 72.0;
    final itemSpacing = context.isTabletOrLarger ? 12.0 : 8.0;
    final screenWidth = MediaQuery.of(context).size.width;

    final offset =
        (index * (itemWidth + itemSpacing)) -
        (screenWidth / 2) +
        (itemWidth / 2) +
        context.pagePadding;

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(DateSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DateHelper.isSameDay(oldWidget.currentDate, widget.currentDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToDate());
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading) return;

    if (_scrollController.position.pixels < _loadThreshold) {
      _loadPreviousWeek();
    }
  }

  void _loadPreviousWeek() {
    final earliestDate = _dates.first;
    final oldestAllowed = DateTime.now().subtract(
      const Duration(days: _maxHistoryDays),
    );

    if (earliestDate.isBefore(oldestAllowed)) return;

    _isLoading = true;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      final previousWeek = _getWeekBefore(earliestDate);
      final currentOffset = _scrollController.offset;
      final itemWidth = context.isTabletOrLarger ? 88.0 : 72.0;
      final itemSpacing = context.isTabletOrLarger ? 12.0 : 8.0;
      final addedWidth = (itemWidth + itemSpacing) * 7;

      setState(() {
        _dates.insertAll(0, previousWeek);
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(currentOffset + addedWidth);
        }
      });
    });
  }

  List<DateTime> _getWeekBefore(DateTime date) {
    final weekStart = date.subtract(const Duration(days: 7));
    return List.generate(
      7,
      (i) => DateHelper.normalize(weekStart.add(Duration(days: i))),
    );
  }

  void _onDateTapped(DateTime date) {
    if (date.isAfter(DateHelper.normalize(DateTime.now()))) {
      _showFutureDateSnackbar();
    } else {
      widget.onDateChanged(date);
    }
  }

  void _showFutureDateSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Cannot select a future date'),
        backgroundColor: AppColors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = context.isTabletOrLarger ? 88.0 : 72.0;
    final itemSpacing = context.isTabletOrLarger ? 12.0 : 8.0;

    return SizedBox(
      height: itemWidth + context.spacing(24),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: context.pagePadding,
          vertical: context.spacing(8),
        ),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
        itemBuilder: (_, index) => _DateItem(
          date: _dates[index],
          width: itemWidth,
          isSelected: DateHelper.isSameDay(_dates[index], widget.currentDate),
          isToday: DateHelper.isToday(_dates[index]),
          onTap: () => _onDateTapped(_dates[index]),
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
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
