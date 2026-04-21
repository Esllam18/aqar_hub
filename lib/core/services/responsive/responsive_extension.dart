import 'package:flutter/material.dart';
import 'breakpoints.dart';

extension ResponsiveExtension on BuildContext {
  // ── Screen Dimensions ─────────────────────────────────────────────────────

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ── Core Scaling Methods ──────────────────────────────────────────────────

  /// Width fraction: context.w(0.8) → 80% of screen width
  double w(double fraction) => (screenWidth * fraction.clamp(0.0, 1.0));

  /// Height fraction: context.h(0.3) → 30% of screen height
  double h(double fraction) => (screenHeight * fraction.clamp(0.0, 1.0));

  /// Responsive size based on design width (375 base):
  /// context.r(200) → scales 200dp proportionally to screen
  double r(double size) =>
      size * (screenWidth / Breakpoints.designWidth).clamp(0.75, 1.5);

  /// Responsive font size: context.sp(18)
  double sp(double size) =>
      size * (screenWidth / Breakpoints.designWidth).clamp(0.85, 1.3);

  // ── Device Type ───────────────────────────────────────────────────────────

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  // ── Orientation ───────────────────────────────────────────────────────────

  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  // ── Safe Area ─────────────────────────────────────────────────────────────

  EdgeInsets get safePadding => MediaQuery.paddingOf(this);
  double get safeTop => MediaQuery.paddingOf(this).top;
  double get safeBottom => MediaQuery.paddingOf(this).bottom;

  // ── Keyboard ──────────────────────────────────────────────────────────────

  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  // ── Responsive Value Switcher ─────────────────────────────────────────────

  /// Returns different values per breakpoint:
  /// context.responsive(mobile: 16.0, tablet: 24.0, desktop: 32.0)
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ── Scaled EdgeInsets Helpers ─────────────────────────────────────────────

  EdgeInsets rAll(double value) => EdgeInsets.all(r(value));

  EdgeInsets rSymmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: r(horizontal), vertical: r(vertical));

  EdgeInsets rOnly({
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) => EdgeInsets.only(
    left: r(left),
    right: r(right),
    top: r(top),
    bottom: r(bottom),
  );

  /// Standard horizontal screen padding
  EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: w(0.05));
}
