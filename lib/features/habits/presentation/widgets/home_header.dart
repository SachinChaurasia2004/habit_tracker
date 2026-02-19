import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  const HomeHeader({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final padding = context.pagePadding;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: context.spacing(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              SizedBox(height: context.spacing(4)),
              Text(
                username,
                style: TextStyle(
                  fontSize: context.fontSize(30),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          _AvatarButton(size: context.isTabletOrLarger ? 56 : 48),
        ],
      ),
    );
  }
}
class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(Icons.person, color: Colors.white, size: size * 0.5),
    );
  }
}
