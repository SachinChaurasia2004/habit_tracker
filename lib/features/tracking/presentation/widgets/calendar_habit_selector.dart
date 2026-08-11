import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class CalendarHabitSelector extends StatefulWidget {
  const CalendarHabitSelector({
    super.key,
    required this.habits,
    required this.selectedHabitId,
    required this.onHabitSelected,
  });

  final List<dynamic> habits;
  final String? selectedHabitId;
  final Function(String habitId) onHabitSelected;

  @override
  State<CalendarHabitSelector> createState() => _CalendarHabitSelectorState();
}

class _CalendarHabitSelectorState extends State<CalendarHabitSelector> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedHabit();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerSelectedHabit() {
    if (widget.selectedHabitId == null || !_scrollController.hasClients) {
      return;
    }

    final index = widget.habits.indexWhere(
      (h) => h.id == widget.selectedHabitId,
    );

    if (index == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 100.0;
    final spacing = 8.0;

    final offset =
        (index * (itemWidth + spacing)) - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant CalendarHabitSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedHabitId != widget.selectedHabitId) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _centerSelectedHabit(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 50,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.pagePadding),
        itemCount: widget.habits.length,
        separatorBuilder: (_, _) => SizedBox(width: context.spacing(8)),
        itemBuilder: (context, index) {
          final habit = widget.habits[index];
          final isSelected = habit.id == widget.selectedHabitId;
          final color = Color(habit.colorCode);

          return GestureDetector(
            onTap: () => widget.onHabitSelected(habit.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing(isSelected ? 20 : 16),
                vertical: context.spacing(8),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white,
                    fontSize: context.fontSize(14),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
