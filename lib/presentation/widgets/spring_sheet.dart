import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// Wraps bottom-sheet content with a spring slide-up + fade entrance.
/// Respects reduced-motion by rendering the child immediately.
class SpringSheet extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SpringSheet({
    super.key,
    required this.child,
    this.duration = AppMotion.medium,
  });

  @override
  State<SpringSheet> createState() => _SpringSheetState();
}

class _SpringSheetState extends State<SpringSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.springOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
