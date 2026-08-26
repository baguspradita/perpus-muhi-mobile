import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double? height;
  final double borderRadius;
  final bool isCircular;
  final Color? baseColor;
  final Color? highlightColor;

  const LoadingShimmer({
    super.key,
    required this.width,
    this.height,
    this.borderRadius = 12,
    this.isCircular = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? AppColors.surfaceContainer;
    final highlight = widget.highlightColor ?? AppColors.surfaceContainerHigh;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height ?? widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.isCircular
                ? BorderRadius.circular(widget.width / 2)
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
              colors: [
                base,
                highlight,
                base,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Composite shimmer for card-like layouts
class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppRadius.card,
        color: AppColors.surfaceContainer,
      ),
      child: LoadingShimmer(
        width: width,
        height: height,
        borderRadius: (borderRadius ?? AppRadius.card).topLeft.x,
      ),
    );
  }
}

/// Shimmer for list items
class ShimmerListTile extends StatelessWidget {
  final double? leadingWidth;
  final double? trailingWidth;

  const ShimmerListTile({
    super.key,
    this.leadingWidth,
    this.trailingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          LoadingShimmer(
            width: leadingWidth ?? 48,
            height: leadingWidth ?? 48,
            borderRadius: 12,
            isCircular: leadingWidth == null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingShimmer(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                LoadingShimmer(
                  width: 120,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          if (trailingWidth != null) ...[
            const SizedBox(width: 12),
            LoadingShimmer(
              width: trailingWidth!,
              height: trailingWidth! * 0.6,
              borderRadius: 4,
            ),
          ],
        ],
      ),
    );
  }
}