import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/habit.dart';

class HabitCardWidget extends StatelessWidget {
  final Habit habit;
  final int streak;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.streak,
    required this.isCompleted,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final habitColor = Color(habit.colorCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        // Border color matches the habit's icon color when completed
        border: isCompleted
            ? Border.all(color: habitColor, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          onLongPress: () => _showOptions(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habitColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(habit.iconName),
                    color: habitColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Habit Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: habitColor,
                          decorationThickness: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'Completed' : '$streak Day Streak',
                        style: TextStyle(
                          fontSize: 13,
                          // Completed text also matches habit color
                          color: isCompleted
                              ? habitColor
                              : AppColors.textSecondary,
                          fontWeight:
                              isCompleted ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        // Border and fill color match habit color
                        color: isCompleted
                            ? habitColor
                            : AppColors.textSecondary,
                        width: 2,
                      ),
                      color: isCompleted ? habitColor : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit Habit'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Habit'),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'yoga':
      case 'meditation':
        return Icons.self_improvement;
      case 'water':
        return Icons.water_drop;
      case 'book':
        return Icons.menu_book;
      case 'gym':
        return Icons.fitness_center;
      case 'walk':
        return Icons.directions_walk;
      case 'sleep':
        return Icons.bedtime;
      case 'nutrition':
        return Icons.restaurant;
      default:
        return Icons.check_circle_outline;
    }
  }
}