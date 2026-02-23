import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Less',
            style: TextStyle(
              fontSize: context.fontSize(12),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: context.spacing(8)),
          ...List.generate(5, (index) {
            final colors = [
              AppColors.surfaceVariant,
              AppColors.success.withOpacity(0.3),
              AppColors.success.withOpacity(0.5),
              AppColors.success.withOpacity(0.7),
              AppColors.success,
            ];
            return Container(
              width: 16,
              height: 16,
              margin: EdgeInsets.symmetric(horizontal: context.spacing(2)),
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
          SizedBox(width: context.spacing(8)),
          Text(
            'More',
            style: TextStyle(
              fontSize: context.fontSize(12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

