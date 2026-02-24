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

  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_updateArrowState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowState();
      _centerSelectedHabit();
    });
  }

  void _updateArrowState() {
    if (!_scrollController.hasClients) return;

    setState(() {
      _canScrollLeft = _scrollController.offset > 0;
      _canScrollRight =
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 200).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 200).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Auto center selected habit
  void _centerSelectedHabit() {
    final index = widget.habits.indexWhere(
      (h) => h.id == widget.selectedHabitId,
    );

    if (index == -1 || !_scrollController.hasClients) return;

    final offset = index * 120.0;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
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
    return SizedBox(
      height: context.spacing(52),
      child: Stack(
        children: [
          Row(
            children: [
              /// LEFT ARROW
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canScrollLeft ? 1 : 0.3,
                child: IconButton(
                  onPressed: _canScrollLeft ? _scrollLeft : null,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              /// HABIT LIST
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.habits.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: context.spacing(8)),
                  itemBuilder: (context, index) {
                    final habit = widget.habits[index];
                    final isSelected = habit.id == widget.selectedHabitId;

                    return GestureDetector(
                      onTap: () => widget.onHabitSelected(habit.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing(14),
                          vertical: context.spacing(8),
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(habit.colorCode)
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.white12,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            habit.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.fontSize(14),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// RIGHT ARROW
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _canScrollRight ? 1 : 0.3,
                child: IconButton(
                  onPressed: _canScrollRight ? _scrollRight : null,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          /// LEFT GRADIENT EDGE
          Positioned(
            left: 40,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.background, Colors.transparent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),

          /// RIGHT GRADIENT EDGE
          Positioned(
            right: 40,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 20,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.background],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
