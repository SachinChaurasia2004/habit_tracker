import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF7C7EFF), Color(0xFF6366F1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final size = context.isTabletOrLarger ? 76.0 : 66.0;
    final iconSize = context.isTabletOrLarger ? 32.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _gradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Icon(Icons.add, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}