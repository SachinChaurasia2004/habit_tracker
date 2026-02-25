import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/habit.dart';
import 'add_habit_icon_data.dart';

class HabitCardWidget extends StatelessWidget {
  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.streak,
    required this.isCompleted,
    required this.date,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  final Habit habit;
  final int streak;
  final bool isCompleted;
  final DateTime date;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  bool get _isToday => DateHelper.isToday(date);
  bool get _isPast => date.isBefore(DateHelper.normalize(DateTime.now()));
  bool get _isFuture => date.isAfter(DateHelper.normalize(DateTime.now()));
  String get _streakText => '$streak ${streak == 1 ? 'Day' : 'Days'} Streak';

  String get _statusText {
    if (_isFuture) return 'Upcoming';
    if (isCompleted) return _streakText;
    if (_isPast) return 'Missed';
    return _streakText;
  }

  @override
  Widget build(BuildContext context) {
    final habitColor = Color(habit.colorCode);
    final iconSize = context.isTabletOrLarger ? 56.0 : 48.0;

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing(12)),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted ? Border.all(color: habitColor, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isToday ? onToggle : null,
          onLongPress: () => _showOptions(context),
          borderRadius: BorderRadius.circular(16),
          child: Opacity(
            opacity: _isToday ? 1.0 : 0.6,
            child: Padding(
              padding: EdgeInsets.all(context.spacing(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _HabitIcon(
                    iconName: habit.iconName,
                    color: habitColor,
                    size: iconSize,
                  ),
                  SizedBox(width: context.spacing(16)),
                  Expanded(
                    child: _HabitInfo(
                      name: habit.name,
                      statusText: _statusText,
                      isCompleted: isCompleted,
                      habitColor: habitColor,
                      fontSize: context.fontSize(16),
                      subFontSize: context.fontSize(13),
                    ),
                  ),
                  _CheckCircle(
                    isCompleted: isCompleted,
                    habitColor: habitColor,
                    size: context.isTabletOrLarger ? 34.0 : 28.0,
                    onTap: _isToday ? onToggle : null,
                  ),
                ],
              ),
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
      builder: (_) => _HabitOptionsSheet(onEdit: onEdit, onDelete: onDelete),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _HabitIcon extends StatelessWidget {
  const _HabitIcon({
    required this.iconName,
    required this.color,
    required this.size,
  });

  final String iconName;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(habitIconData(iconName), color: color, size: size * 0.5),
    );
  }
}

class _HabitInfo extends StatelessWidget {
  const _HabitInfo({
    required this.name,
    required this.statusText,
    required this.isCompleted,
    required this.habitColor,
    required this.fontSize,
    required this.subFontSize,
  });

  final String name;
  final String statusText;
  final bool isCompleted;
  final Color habitColor;
  final double fontSize;
  final double subFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: habitColor,
            decorationThickness: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          statusText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: subFontSize,
            color: isCompleted ? habitColor : AppColors.textSecondary,
            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    required this.isCompleted,
    required this.habitColor,
    required this.size,
    required this.onTap,
  });

  final bool isCompleted;
  final Color habitColor;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted ? habitColor : AppColors.textSecondary,
            width: 2,
          ),
          color: isCompleted ? habitColor : Colors.transparent,
        ),
        child: isCompleted
            ? Icon(Icons.check, size: size * 0.55, color: Colors.white)
            : null,
      ),
    );
  }
}

class _HabitOptionsSheet extends StatelessWidget {
  const _HabitOptionsSheet({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
  }
}
