import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A keyboard-accessible "skip to content" link.
///
/// It is the first focusable element and only becomes visible once it
/// receives focus (e.g. by pressing Tab on page load). Activating it
/// (Enter/Space or tap) moves focus to [targetFocusNode], letting
/// keyboard and screen-reader users jump straight to the main content.
class SkipToContent extends StatelessWidget {
  final FocusNode targetFocusNode;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const SkipToContent({
    super.key,
    required this.targetFocusNode,
    this.label = 'Lewati ke konten',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: true,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Offstage(
            offstage: !hasFocus,
            child: GestureDetector(
              onTap: () => targetFocusNode.requestFocus(),
              child: Container(
                color: backgroundColor ?? AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
