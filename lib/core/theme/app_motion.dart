// Motion tokens and spring curves for consistent animation
// Based on Material 3 motion with spring physics for natural feel

import 'package:flutter/material.dart';

abstract class AppMotion {
  // ==================== DURATION TOKENS ====================

  static const Duration instant = Duration(milliseconds: 0);
  static const Duration extraFast = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration extraSlow = Duration(milliseconds: 500);

  // Stagger delay for list/grid entrance animations
  static const Duration staggerDelay = Duration(milliseconds: 80);
  static const Duration staggerDelayFast = Duration(milliseconds: 50);

  // Page transition durations
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration pageTransitionFast = Duration(milliseconds: 200);

  // ==================== EASING CURVES ====================

  // Standard Material easing
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // Spring curves for natural, weighty feel
  // Using cubic-bezier approximations of spring physics
  static const Curve springOut = Cubic(0.34, 1.56, 0.64, 1.0);      // Overshoot spring
  static const Curve springIn = Cubic(0.5, 0.0, 0.75, 0.0);         // Spring in
  static const Curve springInOut = Cubic(0.68, -0.55, 0.265, 1.55); // Spring both ways

  // Gentle spring (less overshoot)
  static const Curve springGentle = Cubic(0.25, 1.0, 0.5, 1.0);

  // Sharp spring (more overshoot)
  static const Curve springSharp = Cubic(0.4, 1.8, 0.6, 1.0);

  // Press/tap feedback
  static const Curve pressDown = Cubic(0.4, 0.0, 1.0, 1.0);   // Fast press
  static const Curve pressUp = springOut;                       // Spring back

  // ==================== TRANSITION PRESETS ====================

  // Fade + slide up (for list/grid items)
  static const Offset slideUpOffset = Offset(0, 0.3);
  static const Offset slideDownOffset = Offset(0, -0.3);
  static const Offset slideLeftOffset = Offset(-0.3, 0);
  static const Offset slideRightOffset = Offset(0.3, 0);

  // Scale for press feedback
  static const double pressScale = 0.98;
  static const double hoverScale = 1.02;

  // ==================== ANIMATION BUILDERS ====================

  /// Staggered animation for list items
  static Animation<double> staggeredFadeIn({
    required AnimationController controller,
    required int index,
    Duration? delay,
    Duration? duration,
  }) {
    final d = delay ?? staggerDelay;
    final dur = duration ?? fast;

    final start = (index * d.inMilliseconds) / controller.duration!.inMilliseconds;
    final end = start + dur.inMilliseconds / controller.duration!.inMilliseconds;

    return CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: easeOut,
      ),
    );
  }

  /// Staggered slide + fade
  static Animation<Offset> staggeredSlideUp({
    required AnimationController controller,
    required int index,
    Duration? delay,
    Duration? duration,
    Offset? beginOffset,
  }) {
    final fadeAnim = staggeredFadeIn(
      controller: controller,
      index: index,
      delay: delay,
      duration: duration,
    );

    return Tween<Offset>(
      begin: beginOffset ?? slideUpOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: fadeAnim,
      curve: springOut,
    ));
  }

  /// Scale animation for press feedback
  static Animation<double> pressScaleAnim({
    required AnimationController controller,
    double begin = 1.0,
    double end = pressScale,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: pressDown),
    );
  }

  /// Spring scale release
  static Animation<double> releaseScaleAnim({
    required AnimationController controller,
    double begin = pressScale,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: pressUp),
    );
  }

  /// Page route transition - slide from right with fade
  static PageRouteBuilder<T> slideRightFade<T>({
    required Widget page,
    Duration? duration,
    Curve? curve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? pageTransition,
      reverseTransitionDuration: duration ?? pageTransitionFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnim = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve ?? springOut,
        ));

        final fadeAnim = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeOut,
        ));

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: child,
          ),
        );
      },
    );
  }

  /// Page route transition - fade only
  static PageRouteBuilder<T> fadeOnly<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? pageTransitionFast,
      reverseTransitionDuration: duration ?? pageTransitionFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Page route transition - scale + fade (for modals/dialogs)
  static PageRouteBuilder<T> scaleFade<T>({
    required Widget page,
    Duration? duration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? fast,
      reverseTransitionDuration: duration ?? extraFast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnim = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: springOut,
        ));

        final fadeAnim = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeOut,
        ));

        return ScaleTransition(
          scale: scaleAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: child,
          ),
        );
      },
    );
  }

  /// Bottom sheet enter animation
  static Animation<Offset> bottomSheetEnter({
    required AnimationController controller,
  }) {
    return Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: springOut,
    ));
  }

  /// Bottom sheet exit animation
  static Animation<Offset> bottomSheetExit({
    required AnimationController controller,
  }) {
    return Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: easeIn,
    ));
  }
}

/// Reduced motion support
extension ReducedMotion on BuildContext {
  bool get reduceMotion {
    final mediaQuery = MediaQuery.of(this);
    return mediaQuery.disableAnimations || mediaQuery.boldText;
  }

  /// Get duration respecting reduced motion preference
  Duration motionDuration(Duration normal) {
    return reduceMotion ? Duration.zero : normal;
  }

  /// Get curve respecting reduced motion preference
  Curve motionCurve(Curve normal) {
    return reduceMotion ? Curves.linear : normal;
  }
}

/// Mixin for widgets that need stagger controller
/// Usage: class _MyWidgetState extends State\<MyWidget> with StaggerControllerMixin {
mixin StaggerControllerMixin<T extends StatefulWidget> on State<T> {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Long enough for ~10 items
      vsync: this as TickerProvider,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  AnimationController get staggerController => _staggerController;

  /// Build staggered animation for index
  Animation<double> staggerFade(int index, {Duration? delay}) {
    return AppMotion.staggeredFadeIn(
      controller: _staggerController,
      index: index,
      delay: delay,
    );
  }

  Animation<Offset> staggerSlide(int index, {Duration? delay}) {
    return AppMotion.staggeredSlideUp(
      controller: _staggerController,
      index: index,
      delay: delay,
    );
  }
}