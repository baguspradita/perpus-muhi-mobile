import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_motion.dart';

class AppTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  Color _getBorderColor() {
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return AppColors.danger;
    }
    if (!_focusNode.hasFocus && _hasFocus) {
      return AppColors.outline;
    }
    if (_hasFocus) {
      return AppColors.focusRing;
    }
    return widget.enabled ? AppColors.outline : AppColors.outlineVariant;
  }

  double _getBorderWidth() {
    if (_hasFocus) return 2.0;
    if (widget.errorText != null && widget.errorText!.isNotEmpty) return 1.5;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveFillColor = widget.enabled
        ? AppColors.surfaceContainerLowest
        : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (floating animation handled by InputDecoration)
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          initialValue: widget.initialValue,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            helperText: widget.helperText,
            hintStyle: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            labelStyle: AppTypography.labelMd.copyWith(
              color: _hasFocus
                  ? AppColors.focusRing
                  : AppColors.onSurfaceVariant,
            ),
            helperStyle: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            errorStyle: AppTypography.bodySm.copyWith(
              color: AppColors.danger,
            ),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _hasFocus
                          ? AppColors.focusRing
                          : AppColors.onSurfaceVariant,
                      size: AppSpacing.iconMd,
                    ),
                    child: widget.prefixIcon!,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _hasFocus
                          ? AppColors.focusRing
                          : AppColors.onSurfaceVariant,
                      size: AppSpacing.iconMd,
                    ),
                    child: widget.suffixIcon!,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.inputPaddingHorizontal,
              vertical: AppSpacing.inputPaddingVertical,
            ),
            filled: true,
            fillColor: effectiveFillColor,
            // Border: 1px outline
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: widget.enabled ? AppColors.outline : AppColors.outlineVariant,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: widget.enabled ? AppColors.outline : AppColors.outlineVariant,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.focusRing,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.danger,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: const BorderSide(
                color: AppColors.danger,
                width: 2.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide(
                color: AppColors.outlineVariant,
                width: 1.0,
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            floatingLabelStyle: AppTypography.labelMd.copyWith(
              color: AppColors.focusRing,
            ),
            alignLabelWithHint: true,
          ),
          style: AppTypography.bodyMd.copyWith(
            color: widget.enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onTapOutside: (_) => _focusNode.unfocus(),
        ),
      ],
    );
  }
}