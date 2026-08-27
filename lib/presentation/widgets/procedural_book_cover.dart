import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Procedural SVG-style book cover generator
/// Generates consistent, brand-aligned covers from book ID
/// 3 templates: Spine, Geometric, Iconic
class ProceduralBookCover extends StatelessWidget {
  final String title;
  final String author;
  final int bookId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProceduralBookCover({
    super.key,
    required this.title,
    required this.author,
    required this.bookId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  // Cover template by bookId
  CoverTemplate get _template =>
      CoverTemplate.values[bookId % CoverTemplate.values.length];

  // Color palette - monochrome navy-tinted with amber accent
  Color get _baseColor {
    final palettes = [
      const Color(0xFF1A2A4A), // Navy
      const Color(0xFF2D3F5F), // Navy light
      const Color(0xFF3E4F6B), // Navy medium
      const Color(0xFF0F1A2E), // Navy dark
      const Color(0xFF21344F), // Navy blue
    ];
    return palettes[bookId % palettes.length];
  }

  Color get _accentColor => const Color(0xFFD4A843); // Amber

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _baseColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          // Template-specific background
          _buildTemplateBackground(),
          // Title overlay
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _truncate(title, 24),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _truncate(author, 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateBackground() {
    switch (_template) {
      case CoverTemplate.spine:
        return _buildSpineTemplate();
      case CoverTemplate.geometric:
        return _buildGeometricTemplate();
      case CoverTemplate.iconic:
        return _buildIconicTemplate();
    }
  }

  Widget _buildSpineTemplate() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SpinePainter(
          baseColor: _baseColor,
          accentColor: _accentColor,
        ),
      ),
    );
  }

  Widget _buildGeometricTemplate() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GeometricPainter(
          baseColor: _baseColor,
          accentColor: _accentColor,
          seed: bookId,
        ),
      ),
    );
  }

  Widget _buildIconicTemplate() {
    return Center(
      child: Icon(
        _getGenreIcon(),
        size: 56,
        color: _accentColor.withValues(alpha: 0.3),
      ),
    );
  }

  IconData _getGenreIcon() {
    final icons = [
      Icons.menu_book,
      Icons.science,
      Icons.library_books,
      Icons.auto_stories,
      Icons.school_rounded,
      Icons.lightbulb,
    ];
    return icons[bookId % icons.length];
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

enum CoverTemplate { spine, geometric, iconic }

/// Spine template - vertical lines + accent spine
class _SpinePainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  _SpinePainter({required this.baseColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accentColor.withValues(alpha: 0.8);

    // Vertical accent line (spine)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.12, 0, 4, size.height),
      paint,
    );

    // Horizontal lines (pages)
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (double y = size.height * 0.2;
        y < size.height * 0.8;
        y += size.height * 0.15) {
      canvas.drawLine(
        Offset(size.width * 0.2, y),
        Offset(size.width * 0.85, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Geometric template - abstract blocks
class _GeometricPainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;
  final int seed;

  _GeometricPainter({
    required this.baseColor,
    required this.accentColor,
    required this.seed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = _CoverRandom(seed);

    // Large circle
    final circlePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(size.width * (0.3 + random.nextDouble() * 0.4),
          size.height * (0.2 + random.nextDouble() * 0.3)),
      size.width * (0.15 + random.nextDouble() * 0.2),
      circlePaint,
    );

    // Rectangle block
    final rectPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * (0.1 + random.nextDouble() * 0.3),
        size.height * (0.1 + random.nextDouble() * 0.2),
        size.width * (0.2 + random.nextDouble() * 0.3),
        size.width * (0.1 + random.nextDouble() * 0.2),
      ),
      rectPaint,
    );

    // Diagonal line
    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.3),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple deterministic random for cover generation
class _CoverRandom {
  int _seed;

  _CoverRandom(this._seed);

  double nextDouble() {
    _seed = (_seed * 1664525 + 1013904223) & 0x7FFFFFFF;
    return _seed / 0x7FFFFFFF;
  }
}