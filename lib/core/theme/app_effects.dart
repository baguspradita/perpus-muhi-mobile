import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

/// Noise overlay widget for subtle texture on backgrounds
/// Adds organic feel to flat digital surfaces
class NoiseOverlay extends StatelessWidget {
  final double opacity;
  final Color? color;
  final Widget? child;

  const NoiseOverlay({
    super.key,
    this.opacity = 0.03,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  color ?? AppColors.onSurface,
                  BlendMode.srcATop,
                ),
                child: Image.asset(
                  'assets/images/noise.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback: generated noise pattern via CustomPaint
                    return CustomPaint(
                      painter: _NoisePainter(color: color ?? AppColors.onSurface),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for procedural noise (fallback when asset not available)
class _NoisePainter extends CustomPainter {
  final Color color;

  _NoisePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Generate pseudo-random noise pattern
    final random = _NoiseRandom(42); // Fixed seed for consistency
    const density = 0.15; // 15% pixel density
    const pointSize = 1.0;

    for (double x = 0; x < size.width; x++) {
      for (double y = 0; y < size.height; y++) {
        if (random.nextDouble() < density) {
          canvas.drawRect(Rect.fromLTWH(x, y, pointSize, pointSize), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple pseudo-random number generator with fixed seed
class _NoiseRandom {
  int _seed;

  _NoiseRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1664525 + 1013904223) & 0xFFFFFFFF;
    return _seed / 0xFFFFFFFF;
  }
}

/// Ambient radial gradients for hero sections
/// Adds depth and focus without heavy graphics
class AppGradients {
  // Hero radial gradient - subtle center glow
  static const LinearGradient heroRadial = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x081A2A4A), // 3% navy at top
      Color(0x001A2A4A), // transparent at bottom
    ],
    stops: [0.0, 0.6],
  );

  // Hero radial gradient - warm amber accent
  static const LinearGradient heroWarm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x0AD4A843), // 4% amber at top
      Color(0x00D4A843), // transparent at bottom
    ],
    stops: [0.0, 0.5],
  );

  // Radial gradient for centered hero focus
  static RadialGradient heroCenterRadial({
    Color? primaryColor,
    Color? accentColor,
    double radius = 0.7,
  }) {
    return RadialGradient(
      center: Alignment.center,
      radius: radius,
      colors: [
        (primaryColor ?? AppColors.primary).withValues(alpha: 0.04),
        (accentColor ?? AppColors.accent).withValues(alpha: 0.02),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 1.0],
    );
  }

  // Subtle top-to-bottom fade for sections
  static const LinearGradient sectionFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x050F172A), // 2% dark at bottom
    ],
    stops: [0.0, 1.0],
  );

  // Card hover/press gradient (subtle)
  static const LinearGradient cardPress = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x081A2A4A),
      Color(0x051A2A4A),
    ],
  );

  // Button primary gradient
  static const LinearGradient buttonPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2A4A),
      Color(0xFF15203A),
    ],
  );

  // Button accent gradient
  static const LinearGradient buttonAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4A843),
      Color(0xFFB8923A),
    ],
  );

  // Input focus glow
  static BoxDecoration inputFocusGlow = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AppColors.focusRing.withValues(alpha: 0.2),
        blurRadius: 8,
        spreadRadius: -2,
        offset: const Offset(0, 0),
      ),
    ],
  );

  // Elevated shadow tokens (tinted navy)
  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.15),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.shadowPrimary.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Scaffold wrapper with noise overlay and optional ambient gradient
class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool useNoiseOverlay;
  final Gradient? ambientGradient;

  const ThemedScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.useNoiseOverlay = true,
    this.ambientGradient,
  });

  @override
  Widget build(BuildContext context) {
    final scaffoldBody = Stack(
      children: [
        // Base background
        Container(
          color: backgroundColor ?? AppColors.background,
        ),
        // Ambient gradient
        if (ambientGradient != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: ambientGradient),
              ),
            ),
          ),
        // Actual body content
        if (body != null) body!,
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: useNoiseOverlay
          ? NoiseOverlay(
              opacity: 0.03,
              child: scaffoldBody,
            )
          : scaffoldBody,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: Colors.transparent, // Transparent to show our stack
    );
  }
}

/// Decorated container with elevation shadows
class ElevatedContainer extends StatelessWidget {
  final Widget child;
  final int elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ElevatedContainer({
    super.key,
    required this.child,
    this.elevation = 1,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final shadows = switch (elevation) {
      1 => AppGradients.elevation1,
      2 => AppGradients.elevation2,
      3 => AppGradients.elevation3,
      4 => AppGradients.elevation4,
      _ => AppGradients.elevation1,
    };

    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? AppRadius.card,
        boxShadow: shadows,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppRadius.card,
        child: container,
      );
    }

    return container;
  }
}