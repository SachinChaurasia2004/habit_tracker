import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ProgressCircle extends StatelessWidget {
  const ProgressCircle({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = context.isTabletOrLarger ? 120.0 : 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressCirclePainter(progress),
        child: Center(
          child: Text(
            '${progress.toInt()}%',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  const _ProgressCirclePainter(this.progress);

  final double progress;

  static const double _strokeRatio = 0.08;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final strokeWidth = size.width * _strokeRatio;
    final radius = size.width / 2 - strokeWidth / 2;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;

    // Progress arc
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * (progress / 100).clamp(0.0, 1.0),
      false,
      Paint()
        ..shader = LinearGradient(
          colors: AppColors.progressGradient,
        ).createShader(arcRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ProgressCirclePainter old) => old.progress != progress;
}
