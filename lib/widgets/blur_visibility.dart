import 'dart:ui';

import 'package:flutter/material.dart';

class UnblurTransition extends StatefulWidget {
  const UnblurTransition({
    super.key,
    required this.child,
    required this.animation,
    this.isReverse = false,
    this.scale = false,
  });

  final Widget child;
  final bool scale;
  final Animation<double> animation;
  final bool isReverse;

  @override
  State<UnblurTransition> createState() => _UnblurTransitionState();
}

class _UnblurTransitionState extends State<UnblurTransition> with SingleTickerProviderStateMixin {

  late Animation<double> animation;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    animation = widget.animation;
  }

  @override
  void didUpdateWidget(UnblurTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation != oldWidget.animation) {
      _controller?.dispose();
      _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      animation = CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );
      _controller!.forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 20 * ((widget.isReverse ? 1 : 0) - animation.value),
        sigmaY: 20 * ((widget.isReverse ? 1 : 0) - animation.value),
      ),
      child: Transform.scale(
        scale: widget.scale ? 0.8 + (0.2 * animation.value) : 1,
        child: widget.child,
      ),
    );
  }
}

class AnimatedBlurVisibility extends StatefulWidget {
  const AnimatedBlurVisibility({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  State<AnimatedBlurVisibility> createState() => _AnimatedBlurVisibilityState();
}

class _AnimatedBlurVisibilityState extends State<AnimatedBlurVisibility> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Replace with kAnimationDuration if it's defined
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller);

    if (widget.visible) {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBlurVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      widget.visible ? controller.forward() : controller.reverse();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 10 * (1 - animation.value),
            sigmaY: 10 * (1 - animation.value),
          ),
          child: widget.child,
        );
      },
    );
  }
}