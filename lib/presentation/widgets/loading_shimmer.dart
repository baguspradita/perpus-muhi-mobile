import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  final double width;
  final double? height;
  final double borderRadius;
  final bool isCircular;

  const LoadingShimmer({
    required this.width,
    this.height,
    this.borderRadius = 12,
    this.isCircular = false,
  });

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.isCircular
                ? BorderRadius.circular(widget.width / 2)
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                AppColors.surfaceVariant,
                AppColors.border,
                AppColors.surfaceVariant,
              ],
            ),
          ),
        );
      },
    );
  }
}
