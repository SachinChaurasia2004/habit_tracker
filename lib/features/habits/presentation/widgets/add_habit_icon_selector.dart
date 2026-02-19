import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../../../core/utils/responsive.dart';
import 'add_habit_icon_data.dart';

class HabitIconSelector extends StatelessWidget {
  const HabitIconSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.isTabletOrLarger ? 6 : 4;
    final iconSize = context.isTabletOrLarger ? 32.0 : 28.0;
    final spacing = context.spacing(12);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: AppConstants.habitIcons.length,
      itemBuilder: (context, index) {
        final icon = AppConstants.habitIcons[index];
        final isSelected = selected == icon;

        return InkWell(
          onTap: () => onSelected(icon),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                habitIconData(icon),
                size: iconSize,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}