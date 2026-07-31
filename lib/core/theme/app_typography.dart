import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  // ==================== DESIGN SYSTEM TYPOGRAPHY ====================

  // Headline LG (32px) - Page titles (e.g., "Library Catalog")
  static TextStyle get headlineLg => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
    letterSpacing: -0.03,
    height: 1.15,
  );

  // Headline LG Mobile (24px) - Page titles on mobile
  static TextStyle get headlineLgMobile => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
    letterSpacing: -0.02,
    height: 1.18,
  );

  // Headline MD (20px) - Book titles within cards
  static TextStyle get headlineMd => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
    height: 1.22,
  );

  // Body LG (16px) - Descriptions and long-form text
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.55,
  );

  // Body SM (14px) - Secondary text
  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.5,
  );

  // Label MD (12px) - Metadata like ISBN numbers or publication years
  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.02,
    height: 1.2,
  );

  // Button (15px)
  static TextStyle get button =>
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, height: 1.1);

  // ==================== LEGACY ALIASES (for backward compatibility) ====================
  static TextStyle get display => headlineLg;
  static TextStyle get heading1 => headlineLgMobile;
  static TextStyle get heading2 => heading1;
  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
    letterSpacing: -0.05,
    height: 1.25,
  );
  static TextStyle get bodyMd => bodyLg;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodySm;
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.3,
  );
  static TextStyle get label => labelMd;
  static TextStyle get statNumber => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.0,
  );
}
