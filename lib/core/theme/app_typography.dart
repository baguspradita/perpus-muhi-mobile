import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // ==================== FONT FAMILIES ====================
  // Outfit: geometric, modern (Google Fonts) - replaces Satoshi
  // DM Sans: neutral, legible (Google Fonts)
  // JetBrains Mono: monospace for data (Google Fonts)
  static const String _headingFamily = 'Outfit';
  static const String _bodyFamily = 'DM Sans';
  static const String _dataFamily = 'JetBrains Mono';

  // ==================== DESIGN SYSTEM TYPOGRAPHY ====================

  // Display / Headline (Satoshi) — for page titles, hero text
  static TextStyle get displayLg => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textHeading,
        letterSpacing: -1.2,
        height: 1.05,
      );

  static TextStyle get displayMd => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textHeading,
        letterSpacing: -0.96,
        height: 1.1,
      );

  static TextStyle get displaySm => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textHeading,
        letterSpacing: -0.84,
        height: 1.15,
      );

  // Headline (Satoshi) — for section titles, card titles
  static TextStyle get headlineLg => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textHeading,
        letterSpacing: -0.48,
        height: 1.2,
      );

  static TextStyle get headlineMd => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textHeading,
        letterSpacing: -0.3,
        height: 1.25,
      );

  static TextStyle get headlineSm => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textHeading,
        letterSpacing: -0.18,
        height: 1.3,
      );

  // Title (Satoshi Medium) — for list items, button text
  static TextStyle get titleLg => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textHeading,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get titleMd => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textHeading,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // Body (DM Sans) — for paragraphs, descriptions, long-form text
  static TextStyle get bodyLg => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textBody,
        letterSpacing: 0.15,
        height: 1.6,
      );

  static TextStyle get bodyMd => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textBody,
        letterSpacing: 0.15,
        height: 1.55,
      );

  static TextStyle get bodySm => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textBody,
        letterSpacing: 0.2,
        height: 1.5,
      );

  // Label (DM Sans Medium/SemiBold) — for metadata, captions, form labels
  static TextStyle get labelLg => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMd => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.3,
      );

  static TextStyle get labelSm => GoogleFonts.getFont(
        _bodyFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
        height: 1.2,
      );

  // Button (Satoshi SemiBold)
  static TextStyle get buttonLg => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
        letterSpacing: 0.1,
        height: 1.2,
      );

  static TextStyle get buttonMd => GoogleFonts.getFont(
        _headingFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
        letterSpacing: 0.1,
        height: 1.2,
      );

  // Data / Numbers (JetBrains Mono with tabular-nums)
  static TextStyle get dataLg => GoogleFonts.getFont(
        _dataFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textHeading,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get dataMd => GoogleFonts.getFont(
        _dataFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textHeading,
        letterSpacing: -0.3,
        height: 1.2,
      );

  static TextStyle get dataSm => GoogleFonts.getFont(
        _dataFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textBody,
        letterSpacing: 0,
        height: 1.4,
      );

  static TextStyle get dataXs => GoogleFonts.getFont(
        _dataFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0,
        height: 1.3,
      );

  // ==================== LEGACY ALIASES (for backward compatibility) ====================
  static TextStyle get display => displayMd;
  static TextStyle get heading1 => headlineLg; // 24px - mobile page title
  static TextStyle get heading2 => headlineMd; // 20px
  static TextStyle get heading3 => titleLg; // 16px
  static TextStyle get headlineLgMobile => headlineLg; // 24px - alias for mobile page title
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => bodySm;
  static TextStyle get caption => labelSm;
  static TextStyle get label => labelMd;
  static TextStyle get button => buttonMd;
  static TextStyle get statNumber => dataLg;
}