abstract class AppSpacing {
  // ==================== SPACING TOKENS ====================
  // Base 4px rhythm with optical adjustments

  // Base unit
  static const double base = 4.0;

  // Spacing scale (4px multiples) - Optical adjustments applied
  static const double xs = 4.0;       // 1 * base
  static const double sm = 8.0;       // 2 * base
  static const double md = 16.0;      // 4 * base
  static const double lg = 24.0;      // 6 * base
  static const double xl = 32.0;      // 8 * base
  static const double xxl = 40.0;     // 10 * base
  static const double xxxl = 48.0;    // 12 * base
  static const double xxxxl = 64.0;   // 16 * base

  // Optical spacing - bottom padding 1.25x top for visual balance
  static const double mdTop = 16.0;
  static const double mdBottom = 20.0; // md * 1.25
  static const double lgTop = 24.0;
  static const double lgBottom = 30.0; // lg * 1.25
  static const double xlTop = 32.0;
  static const double xlBottom = 40.0; // xl * 1.25

  // Layout constraints
  static const double gutter = 16.0;        // Page horizontal padding
  static const double marginMobile = 16.0;
  static const double marginTablet = 32.0;
  static const double marginDesktop = 64.0;
  static const double safeArea = 56.0;      // Bottom bar safe area

  // Component-specific
  static const double cardPadding = 16.0;
  static const double cardGap = 16.0;
  static const double sectionGap = 32.0;
  static const double componentGap = 12.0;

  // Input/Control
  static const double inputPaddingHorizontal = 16.0;
  static const double inputPaddingVertical = 14.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 14.0;
  static const double buttonMinHeight = 48.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
}