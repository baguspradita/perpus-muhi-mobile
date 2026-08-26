import 'package:flutter/material.dart';

abstract class AppColors {
  // ==================== DESIGN SYSTEM COLORS ====================

  // Primary - Deep Navy (trust, knowledge, academia)
  static const Color primary = Color(0xFF1A2A4A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD6E4F0);
  static const Color onPrimaryContainer = Color(0xFF0F172A);
  static const Color inversePrimary = Color(0xFF94A3B8);

  // Accent - Warm Amber (warmth, highlights, CTAs) — single accent only
  static const Color accent = Color(0xFFD4A843);
  static const Color onAccent = Color(0xFF1A2A4A);
  static const Color accentContainer = Color(0xFFFFF8E7);
  static const Color onAccentContainer = Color(0xFF1A2A4A);

  // Semantic Colors (status only, not for general UI)
  static const Color success = Color(0xFF059669);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccessContainer = Color(0xFF064E3B);

  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  static const Color danger = Color(0xFFDC2626);
  static const Color onDanger = Color(0xFFFFFFFF);
  static const Color dangerContainer = Color(0xFFFEF2F2);
  static const Color onDangerContainer = Color(0xFF991B1B);

  static const Color info = Color(0xFF2563EB);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfoContainer = Color(0xFF1E3A8A);

  // Surface Scale (Material 3 Surface Tokens) - Warm Navy tinted
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceDim = Color(0xFFE2E8F0);
  static const Color surfaceBright = Color(0xFFF8FAFC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color surfaceContainerHighest = Color(0xFF94A3B8);

  // On Surface
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF475569);

  // Inverse Surface
  static const Color inverseSurface = Color(0xFF0F172A);
  static const Color inverseOnSurface = Color(0xFFF8FAFC);

  // Outline
  static const Color outline = Color(0xFF94A3B8);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  // Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFE2E8F0);

  // Fixed Variants
  static const Color primaryFixed = Color(0xFFD6E4F0);
  static const Color primaryFixedDim = Color(0xFF94A3B8);
  static const Color onPrimaryFixed = Color(0xFF0F172A);
  static const Color onPrimaryFixedVariant = Color(0xFF1A2A4A);

  static const Color accentFixed = Color(0xFFFFF8E7);
  static const Color accentFixedDim = Color(0xFFFDE68A);
  static const Color onAccentFixed = Color(0xFF1A2A4A);
  static const Color onAccentFixedVariant = Color(0xFFD4A843);

  // Shadow (tinted navy, not black)
  static const Color shadowPrimary = Color(0x1A1A2A4A);
  static const Color shadowLight = Color(0x0D0F172A);

  // Focus Ring
  static const Color focusRing = Color(0xFFD4A843);

  // Status Colors (Semantic) - Legacy aliases
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningLight = Color(0xFFFFF3C7);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ==================== LEGACY ALIASES (for backward compatibility) ====================
  static const Color textPrimary = onSurface;
  static const Color textHeading = onSurface;
  static const Color textBody = onSurfaceVariant;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;

  // Old semantic color names (mapped to new danger/warning/success)
  static const Color error = danger;
  static const Color onError = onDanger;
  static const Color errorContainer = dangerContainer;
  static const Color onErrorContainer = onDangerContainer;
  static const Color secondary = accent;
  static const Color onSecondary = onAccent;
  static const Color secondaryContainer = accentContainer;
  static const Color onSecondaryContainer = onAccentContainer;
  static const Color tertiary = accent;
  static const Color onTertiary = onAccent;
  static const Color tertiaryContainer = accentContainer;
  static const Color onTertiaryContainer = onAccentContainer;

  static const Color primaryHover = primary;
  static const Color primaryLight = primaryContainer;
  static const Color primaryBorder = outlineVariant;
  static const Color secondaryLight = accentContainer;
  static const Color errorLight = dangerContainer;
  static const Color border = outlineVariant;
  static const Color borderLight = outlineVariant;
  static const Color divider = outlineVariant;

  static const Color starFilled = Color(0xFFD4A843);
  static const Color categoryBg = primaryContainer;
}