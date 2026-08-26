/// Responsive breakpoints for adaptive layouts
/// Based on Material 3 breakpoints with library-specific adjustments

import 'package:flutter/material.dart';

abstract class AppBreakpoints {
  // Breakpoint values (width in dp)
  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 900;
  static const double wide = 1200;
  static const double ultraWide = 1600;

  // Named breakpoints for easy reference
  static const Breakpoint xs = Breakpoint('xs', mobile);
  static const Breakpoint sm = Breakpoint('sm', tablet);
  static const Breakpoint md = Breakpoint('md', desktop);
  static const Breakpoint lg = Breakpoint('lg', wide);
  static const Breakpoint xl = Breakpoint('xl', ultraWide);

  // All breakpoints in order
  static const List<Breakpoint> all = [xs, sm, md, lg, xl];

  /// Get current breakpoint from width
  static Breakpoint fromWidth(double width) {
    for (int i = all.length - 1; i >= 0; i--) {
      if (width >= all[i].minWidth) {
        return all[i];
      }
    }
    return xs;
  }

  /// Check if width is at least given breakpoint
  static bool isAtLeast(double width, Breakpoint breakpoint) {
    return width >= breakpoint.minWidth;
  }

  /// Check if width is less than given breakpoint
  static bool isLessThan(double width, Breakpoint breakpoint) {
    return width < breakpoint.minWidth;
  }

  /// Responsive value builder
  static T responsive<T>(
    double width, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
    T? ultraWide,
  }) {
    final bp = fromWidth(width);
    switch (bp) {
      case Breakpoint(name: 'xl'):
        return ultraWide ?? wide ?? desktop ?? tablet ?? mobile;
      case Breakpoint(name: 'lg'):
        return wide ?? desktop ?? tablet ?? mobile;
      case Breakpoint(name: 'md'):
        return desktop ?? tablet ?? mobile;
      case Breakpoint(name: 'sm'):
        return tablet ?? mobile;
      default:
        return mobile;
    }
  }
}

/// Represents a single breakpoint
class Breakpoint {
  final String name;
  final double minWidth;

  const Breakpoint(this.name, this.minWidth);

  @override
  String toString() => 'Breakpoint.$name ($minWidth dp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Breakpoint && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Extension for easy breakpoint access in BuildContext
extension BreakpointContext on BuildContext {
  Breakpoint get breakpoint => AppBreakpoints.fromWidth(MediaQuery.of(this).size.width);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => breakpoint == AppBreakpoints.xs;
  bool get isTablet => breakpoint == AppBreakpoints.sm;
  bool get isDesktop => breakpoint == AppBreakpoints.md;
  bool get isWide => breakpoint == AppBreakpoints.lg;
  bool get isUltraWide => breakpoint == AppBreakpoints.xl;

  bool get isAtLeastTablet => AppBreakpoints.isAtLeast(screenWidth, AppBreakpoints.sm);
  bool get isAtLeastDesktop => AppBreakpoints.isAtLeast(screenWidth, AppBreakpoints.md);
  bool get isAtLeastWide => AppBreakpoints.isAtLeast(screenWidth, AppBreakpoints.lg);
}