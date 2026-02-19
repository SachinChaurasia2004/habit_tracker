import 'package:flutter/material.dart';
import 'package:habit_tracker/core/utils/responsive.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _barHeight = 70;
  static const double _fabCutoutWidth = 80;
  static const double _fabCutoutHeight = 40;

  @override
  Widget build(BuildContext context) {
    final cutoutLeft = context.screenWidth / 2 - _fabCutoutWidth / 2;
    final iconSize = context.isTabletOrLarger ? 32.0 : 28.0;

    return Container(
      height: _barHeight,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(icon: Icons.home,             index: 0, currentIndex: currentIndex, onTap: onTap, iconSize: iconSize),
                  _NavItem(icon: Icons.calendar_month,   index: 1, currentIndex: currentIndex, onTap: onTap, iconSize: iconSize),
                  const SizedBox(width: _fabCutoutWidth),
                  _NavItem(icon: Icons.bar_chart_rounded, index: 2, currentIndex: currentIndex, onTap: onTap, iconSize: iconSize),
                  _NavItem(icon: Icons.person,           index: 3, currentIndex: currentIndex, onTap: onTap, iconSize: iconSize),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: cutoutLeft,
              child: const _FabCutout(),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.iconSize,
  });

  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double iconSize;

  bool get _isSelected => currentIndex == index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: SizedBox.expand(
          child: Icon(
            icon,
            size: iconSize,
            color: _isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FabCutout extends StatelessWidget {
  const _FabCutout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CustomBottomNavBar._fabCutoutWidth,
      height: CustomBottomNavBar._fabCutoutHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
    );
  }
}