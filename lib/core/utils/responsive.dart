import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

/// Responsive helper based on Material 3 breakpoints.
/// compact  < 600px  (phones)
/// medium   600–840px (tablets portrait, large phones landscape)
/// expanded > 840px  (tablets landscape, desktops)
extension Responsive on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < 600) return ScreenSize.compact;
    if (w < 840) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;
  bool get isTabletOrLarger => !isCompact;

  /// Horizontal page padding — grows with screen width.
  double get pagePadding {
    if (isExpanded) return screenWidth * 0.08;
    if (isMedium) return 32.0;
    return 20.0;
  }

  /// Max content width — prevents content stretching too wide on large screens.
  double get contentMaxWidth {
    if (isExpanded) return 900.0;
    if (isMedium) return 680.0;
    return double.infinity;
  }

  /// Scales a base font size proportionally on larger screens.
  double fontSize(double base) {
    if (isExpanded) return base * 1.15;
    if (isMedium) return base * 1.08;
    return base;
  }

  /// Scales a base spacing value.
  double spacing(double base) {
    if (isExpanded) return base * 1.25;
    if (isMedium) return base * 1.1;
    return base;
  }
}