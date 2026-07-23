import 'package:flutter/material.dart';

abstract class AppColors {
  // ==================== DESIGN SYSTEM COLORS ====================

  // Surface Scale (Material 3 Surface Tokens)
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFCFDAF2);
  static const Color surfaceBright = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);

  // On Surface
  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF434655);

  // Inverse Surface
  static const Color inverseSurface = Color(0xFF263143);
  static const Color inverseOnSurface = Color(0xFFECF1FF);

  // Outline
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // Primary - Library Blue
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color inversePrimary = Color(0xFFB4C5FF);

  // Secondary
  static const Color secondary = Color(0xFF006591);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF39B8FD);
  static const Color onSecondaryContainer = Color(0xFF004666);

  // Tertiary
  static const Color tertiary = Color(0xFF006242);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF007D55);
  static const Color onTertiaryContainer = Color(0xFFBDFFDB);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Status Colors (Semantic)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Fixed Variants
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  static const Color secondaryFixed = Color(0xFFC9E6FF);
  static const Color secondaryFixedDim = Color(0xFF89CEFF);
  static const Color onSecondaryFixed = Color(0xFF001E2F);
  static const Color onSecondaryFixedVariant = Color(0xFF004C6E);

  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color tertiaryFixedDim = Color(0xFF4EDAA3);
  static const Color onTertiaryFixed = Color(0xFF002113);
  static const Color onTertiaryFixedVariant = Color(0xFF005236);

  // Background
  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF111C2D);
  static const Color surfaceVariant = Color(0xFFD8E3FB);

  // ==================== LEGACY ALIASES (for backward compatibility) ====================
  static const Color textPrimary = onSurface;
  static const Color textHeading = onSurface;
  static const Color textBody = onSurfaceVariant;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;

  static const Color primaryHover = primary;
  static const Color primaryLight = primaryContainer;
  static const Color primaryBorder = outlineVariant;
  static const Color secondaryLight = secondaryFixed;
  static const Color errorLight = errorContainer;
  static const Color border = outlineVariant;
  static const Color borderLight = outlineVariant;
  static const Color divider = outlineVariant;

  static const Color shadowPrimary = Color(0x1A004AC6);
  static const Color shadowLight = Color(0x0D1E293B);

  static const Color starFilled = Color(0xFFFBBF24);
  static const Color categoryBg = primaryFixed;
}
