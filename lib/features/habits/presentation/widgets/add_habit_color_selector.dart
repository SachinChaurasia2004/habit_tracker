import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';

class HabitColorSelector extends StatelessWidget {
  const HabitColorSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final dotSize = context.isTabletOrLarger ? 60.0 : 52.0;
    final spacing = context.spacing(12);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: List.generate(AppColors.habitColors.length, (index) {
        final color = AppColors.habitColors[index];
        final isSelected = selectedIndex == index;

        return InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check, color: Colors.white, size: dotSize * 0.45)
                : null,
          ),
        );
      }),
    );
  }
}
