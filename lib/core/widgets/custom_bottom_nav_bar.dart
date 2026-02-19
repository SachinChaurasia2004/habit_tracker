import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            // Navigation Items Row
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    index: 0,
                    isSelected: currentIndex == 0,
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_today_outlined,
                    index: 1,
                    isSelected: currentIndex == 1,
                  ),
                  // Space for FAB
                  const SizedBox(width: 80),
                  _buildNavItem(
                    icon: Icons.bar_chart_rounded,
                    index: 2,
                    isSelected: currentIndex == 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    index: 3,
                    isSelected: currentIndex == 3,
                  ),
                ],
              ),
            ),
            // Cutout for FAB
            Positioned(
              top: 0,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 28,
          ),
        ),
      ),
    );
  }
}
