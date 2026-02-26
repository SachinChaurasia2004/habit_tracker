import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final Color activeColor;

  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        pageCount,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isActive ? 32 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive
            ? activeColor
            : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }
}