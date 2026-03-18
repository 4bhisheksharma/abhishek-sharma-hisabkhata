import 'package:flutter/material.dart';

/// Centralized responsive helpers based on a 375x812 reference design.
class Responsive {
  static const double _baseWidth = 375;
  static const double _baseHeight = 812;

  static Size _screenSize(BuildContext context) => MediaQuery.of(context).size;

  static bool isSmallPhone(BuildContext context) =>
      _screenSize(context).width < 360;

  static bool isTablet(BuildContext context) =>
      _screenSize(context).width >= 600;

  static double w(BuildContext context, double value) {
    final width = _screenSize(context).width;
    return value * (width / _baseWidth);
  }

  static double h(BuildContext context, double value) {
    final height = _screenSize(context).height;
    return value * (height / _baseHeight);
  }

  static double sp(BuildContext context, double value) {
    final scale = (w(context, value) / value + h(context, value) / value) / 2;
    final clampedScale = scale.clamp(0.85, 1.25);
    return value * clampedScale;
  }

  static double radius(BuildContext context, double value) {
    final scale = w(context, value) / value;
    return value * scale.clamp(0.85, 1.25);
  }

  static double adaptive(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? smallPhone,
  }) {
    if (isTablet(context) && tablet != null) return tablet;
    if (isSmallPhone(context) && smallPhone != null) return smallPhone;
    return mobile;
  }
}
