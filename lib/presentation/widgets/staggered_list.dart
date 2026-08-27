import 'package:flutter/material.dart';
import '../../core/theme/app_motion.dart';

/// A self-contained staggered entrance list.
///
/// Each item fades in and slides up with an 80ms offset between items.
/// Automatically respects the platform reduced-motion preference by
/// rendering a plain [ListView] when animations are disabled.
class StaggeredListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Key? listKey;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
    this.delay = AppMotion.staggerDelay,
    this.duration = AppMotion.fast,
    this.slideOffset = 0.3,
    this.listKey,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final total = widget.duration +
        widget.delay * (widget.itemCount > 0 ? widget.itemCount - 1 : 0);
    _controller = AnimationController(
      vsync: this,
      duration: total > const Duration(milliseconds: 1600)
          ? const Duration(milliseconds: 1600)
          : total,
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
    final reduce = context.reduceMotion;
    if (reduce) {
      return ListView.builder(
        key: widget.listKey,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: widget.padding,
        controller: widget.controller,
      );
    }

    return ListView.builder(
      key: widget.listKey,
      itemCount: widget.itemCount,
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      controller: widget.controller,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          controller: _controller,
          index: index,
          delay: widget.delay,
          duration: widget.duration,
          slideOffset: widget.slideOffset,
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}

/// A self-contained staggered entrance grid.
class StaggeredGridView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Key? gridKey;

  const StaggeredGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.controller,
    this.delay = AppMotion.staggerDelay,
    this.duration = AppMotion.fast,
    this.slideOffset = 0.3,
    this.gridKey,
  });

  @override
  State<StaggeredGridView> createState() => _StaggeredGridViewState();
}

class _StaggeredGridViewState extends State<StaggeredGridView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final total = widget.duration +
        widget.delay * (widget.itemCount > 0 ? widget.itemCount - 1 : 0);
    _controller = AnimationController(
      vsync: this,
      duration: total > const Duration(milliseconds: 1600)
          ? const Duration(milliseconds: 1600)
          : total,
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
    final reduce = context.reduceMotion;
    if (reduce) {
      return GridView.builder(
        key: widget.gridKey,
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
        gridDelegate: widget.gridDelegate,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: widget.padding,
        controller: widget.controller,
      );
    }

    return GridView.builder(
      key: widget.gridKey,
      itemCount: widget.itemCount,
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: widget.padding,
      controller: widget.controller,
      itemBuilder: (context, index) {
        return _StaggeredItem(
          controller: _controller,
          index: index,
          delay: widget.delay,
          duration: widget.duration,
          slideOffset: widget.slideOffset,
          child: widget.itemBuilder(context, index),
        );
      },
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Widget child;

  const _StaggeredItem({
    required this.controller,
    required this.index,
    required this.delay,
    required this.duration,
    required this.slideOffset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * delay.inMilliseconds) /
        controller.duration!.inMilliseconds;
    final end = start +
        duration.inMilliseconds / controller.duration!.inMilliseconds;

    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: AppMotion.easeOut),
    );

    final slide = Tween<Offset>(
      begin: Offset(0, slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: fade, curve: AppMotion.springOut));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// Per-item staggered entrance that works inside any list (ListView,
/// GridView, SliverList, horizontal rows). Each cell owns a lightweight
/// controller and animates in after `delay * index`, producing a cascading
/// fade + slide-up. Honors reduced-motion by rendering the child directly.
class StaggerCell extends StatefulWidget {
  final int index;
  final Duration delay;
  final Duration duration;
  final double slideOffset;
  final Widget child;

  const StaggerCell({
    super.key,
    required this.index,
    required this.child,
    this.delay = AppMotion.staggerDelay,
    this.duration = AppMotion.fast,
    this.slideOffset = 0.25,
  });

  @override
  State<StaggerCell> createState() => _StaggerCellState();
}

class _StaggerCellState extends State<StaggerCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    final total = widget.duration + widget.delay * widget.index;
    _controller = AnimationController(vsync: this, duration: total);

    final start = widget.index == 0
        ? 0.0
        : (widget.delay.inMilliseconds * widget.index) /
            total.inMilliseconds;
    final end = (widget.delay.inMilliseconds * widget.index +
            widget.duration.inMilliseconds) /
        total.inMilliseconds;

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
          curve: AppMotion.easeOut),
    );
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fade, curve: AppMotion.springOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
