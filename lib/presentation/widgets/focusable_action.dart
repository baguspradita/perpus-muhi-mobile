import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Wraps a child with a visible focus ring (amber, 2px, 2px offset)
/// when the child or any descendant receives keyboard focus.
///
/// Usage:
/// ```dart
/// FocusableAction(
///   onPressed: () => doSomething(),
///   child: MyButton(),
/// )
/// ```
class FocusableAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? focusPadding;
  final Color? focusColor;
  final double focusWidth;
  final double focusOffset;

  const FocusableAction({
    super.key,
    required this.child,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.focusPadding,
    this.focusColor,
    this.focusWidth = 2.0,
    this.focusOffset = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      onKeyEvent: onPressed != null
          ? (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                onPressed!();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            }
          : null,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            decoration: hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: focusColor ?? AppColors.focusRing,
                      width: focusWidth,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (focusColor ?? AppColors.focusRing).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: focusOffset,
                        offset: Offset(0, 0),
                      ),
                    ],
                  )
                : null,
            child: Padding(
              padding: focusPadding ?? EdgeInsets.zero,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Convenience wrapper for list tiles / cards that need focus ring
/// without tap handling.
class FocusableContainer extends StatelessWidget {
  final Widget child;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry? focusPadding;
  final Color? focusColor;
  final double focusWidth;
  final double focusOffset;
  final BorderRadius? borderRadius;

  const FocusableContainer({
    super.key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.focusPadding,
    this.focusColor,
    this.focusWidth = 2.0,
    this.focusOffset = 2.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: autofocus,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          final radius = borderRadius ?? BorderRadius.circular(8);
          return Container(
            decoration: hasFocus
                ? BoxDecoration(
                    border: Border.all(
                      color: focusColor ?? AppColors.focusRing,
                      width: focusWidth,
                    ),
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: (focusColor ?? AppColors.focusRing).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: focusOffset,
                        offset: Offset(0, 0),
                      ),
                    ],
                  )
                : null,
            child: Padding(
              padding: focusPadding ?? EdgeInsets.zero,
              child: child,
            ),
          );
        },
      ),
    );
  }
}