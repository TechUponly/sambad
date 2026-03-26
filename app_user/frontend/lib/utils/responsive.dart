import 'package:flutter/material.dart';

/// Responsive utility for dynamic sizing based on screen dimensions.
/// Reference device: iPhone 13 (375 x 812).
class Responsive {
  static const double _refWidth = 375.0;
  static const double _refHeight = 812.0;

  /// Get screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Scale factor relative to reference width
  static double _sw(BuildContext context) => width(context) / _refWidth;

  /// Scale font size relative to screen width (clamped to avoid extremes)
  static double fontSize(BuildContext context, double base) {
    final scale = _sw(context);
    return base * scale.clamp(0.8, 1.3);
  }

  /// Scale horizontal spacing/padding
  static double horizontal(BuildContext context, double base) {
    return base * _sw(context);
  }

  /// Scale vertical spacing/padding  
  static double vertical(BuildContext context, double base) {
    final scale = height(context) / _refHeight;
    return base * scale.clamp(0.85, 1.3);
  }

  /// Scale a general dimension (icons, avatars) based on width
  static double size(BuildContext context, double base) {
    return base * _sw(context).clamp(0.85, 1.4);
  }

  /// Scale border radius
  static double radius(BuildContext context, double base) {
    return base * _sw(context).clamp(0.9, 1.2);
  }

  /// Get responsive EdgeInsets (all sides)
  static EdgeInsets paddingAll(BuildContext context, double base) {
    final s = horizontal(context, base);
    return EdgeInsets.all(s);
  }

  /// Get responsive EdgeInsets (symmetric)
  static EdgeInsets paddingSymmetric(
    BuildContext context, {
    double h = 0,
    double v = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal(context, h),
      vertical: vertical(context, v),
    );
  }

  /// Proportional width (e.g., 0.75 = 75% of screen)
  static double widthPercent(BuildContext context, double percent) {
    return width(context) * percent;
  }

  /// Proportional height
  static double heightPercent(BuildContext context, double percent) {
    return height(context) * percent;
  }

  /// Is the screen small (< 360px width, like iPhone SE)
  static bool isSmallScreen(BuildContext context) => width(context) < 360;

  /// Is the screen large (> 428px width, like iPad or large phones)
  static bool isLargeScreen(BuildContext context) => width(context) > 428;
}
