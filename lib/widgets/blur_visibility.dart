import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBlurVisibility extends StatefulWidget {
  final Widget child;
  final bool visible;

  const AnimatedBlurVisibility({
    required this.child,
    required this.visible,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedBlurVisibility> createState() => _AnimatedBlurVisibilityState();
}

class _AnimatedBlurVisibilityState extends State<AnimatedBlurVisibility> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  bool _isChildVisible = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!widget.visible) setState(() => _isChildVisible = false);
      } else if (status == AnimationStatus.reverse) {
        setState(() => _isChildVisible = true);
      }
    });

    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(_controller);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(_controller);

    // Set the initial animation state based on widget visibility
    widget.visible ? _controller.reverse() : _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedBlurVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      widget.visible ? _controller.reverse() : _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _isChildVisible,
      child: ClipRRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blurAnimation.value, sigmaY: _blurAnimation.value),
                  child: Opacity(
                    opacity: 0,
                    child: child,
                  ),
                )
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}