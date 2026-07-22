import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static TextStyle get display => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
  );

  static TextStyle get heading1 => GoogleFonts.instrumentSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading2 => GoogleFonts.instrumentSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
  );

  static TextStyle get heading3 => GoogleFonts.instrumentSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textHeading,
  );

  static TextStyle get bodyLarge => GoogleFonts.instrumentSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.instrumentSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.3,
  );

  static TextStyle get button => GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get input => GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get label => GoogleFonts.instrumentSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
  );

  static TextStyle get caption => GoogleFonts.instrumentSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle get sectionHeader => GoogleFonts.instrumentSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.05,
  );

  static TextStyle get statNumber => GoogleFonts.instrumentSans(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textHeading,
  );
}
