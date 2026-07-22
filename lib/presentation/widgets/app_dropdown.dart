import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppDropdown extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final bool isRequired;
  final List<String> options;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String Function(String)? errorFormatter;

  const AppDropdown({
    super.key,
    this.hintText,
    this.labelText,
    this.errorText,
    this.isRequired = false,
    required this.options,
    this.value,
    this.onChanged,
    this.errorFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              labelText!,
              style: AppTypography.label.copyWith(
                color: AppColors.textBody,
              ),
            ),
          ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.rMd,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.rMd,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.rMd,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.rMd,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.rMd,
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          style: AppTypography.bodyMedium,
          value: value,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (val) {
            if (isRequired && (val == null || val.isEmpty)) {
              return errorText ?? 'Harap pilih opsi';
            }
            return null;
          },
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
