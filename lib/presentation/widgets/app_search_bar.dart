import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';

class AppSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSubmitted;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isLoading;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.isLoading = false,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: _hasFocus ? AppColors.focusRing : AppColors.outline,
          width: _hasFocus ? 2.0 : 1.0,
        ),
        boxShadow: _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.focusRing.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Cari buku, penulis, atau ISBN...',
          hintStyle: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          prefixIcon: widget.prefixIcon ??
              Icon(
                Icons.search_rounded,
                color: _hasFocus ? AppColors.focusRing : AppColors.onSurfaceVariant,
                size: AppSpacing.iconMd,
              ),
          suffixIcon: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.focusRing),
                      ),
                    ),
                  ),
                )
              : hasText
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.onSurfaceVariant,
                        size: AppSpacing.iconMd,
                      ),
                      onPressed: () {
                        _controller.clear();
                        widget.onClear?.call();
                        widget.onChanged?.call('');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    )
                  : widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.inputPaddingHorizontal,
            vertical: AppSpacing.inputPaddingVertical,
          ),
          isDense: true,
        ),
        style: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurface,
        ),
        onChanged: (value) {
          widget.onChanged?.call(value);
        },
        onSubmitted: (_) => widget.onSubmitted?.call(),
        textInputAction: TextInputAction.search,
      ),
    );
  }
}