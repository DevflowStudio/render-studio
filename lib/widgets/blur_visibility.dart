import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:render_studio/utils/utils.dart';

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

class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final bool scale;
  final bool fade;
  final double blurAmount;
  final bool blur;

  FadeIn({
    key,
    required this.child,
    this.duration = kAnimationDuration,
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.scale = true,
    this.fade = true,
    this.blurAmount = 20,
    this.blur = true
  }) : super(key: key) {
    if (manualTrigger == true && controller == null) {
      throw FlutterError('If you want to use manualTrigger:true, \n\n'
        'Then you must provide the controller property, that is a callback like:\n\n'
        ' ( controller: AnimationController) => yourController = controller \n\n');
    }
  }

  @override
  FadeInState createState() => FadeInState();
}

class FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  /// Animation controller that controls this animation
  late AnimationController controller;

  /// is the widget disposed?
  bool disposed = false;

  /// Animation movement value
  late Animation<double> animation;

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = CurvedAnimation(curve: Curves.easeOut, parent: controller);

    if (!widget.manualTrigger && widget.animate) {
      Future.delayed(widget.delay, () {
        if (!disposed) {
          controller.forward();
        }
      });
    }

    if (widget.controller is Function) {
      widget.controller!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Launch the animation ASAP or wait if is needed
    if (widget.animate &&  widget.delay.inMilliseconds == 0 && widget.manualTrigger == false) {
      controller.forward();
    }

    /// If the animation already happen, we can animate it back
    if (!widget.animate) {
      controller.animateBack(0);
    }

    /// Builds the animation with the corresponding
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: widget.scale ? (0.8 + 0.2 * animation.value) : 1,
          child: ImageFiltered(
            imageFilter: widget.blur ? ImageFilter.blur(
              sigmaX: widget.blurAmount * (1 - animation.value),
              sigmaY: widget.blurAmount * (1 - animation.value),
            ) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Opacity(
              opacity: widget.fade ? animation.value : 1,
              child: widget.child,
            ),
          ),
        );
      }
    );
  }
}

class FadeOut extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final bool scale;
  final bool fade;
  final double blurAmount;
  final bool blur;

  FadeOut({
    key,
    required this.child,
    this.duration = kAnimationDuration,
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = false,
    this.scale = true,
    this.fade = true,
    this.blurAmount = 20,
    this.blur = true
  }) : super(key: key) {
    if (manualTrigger == true && controller == null) {
      throw FlutterError('If you want to use manualTrigger:true, \n\n'
        'Then you must provide the controller property, that is a callback like:\n\n'
        ' ( controller: AnimationController) => yourController = controller \n\n');
    }
  }

  @override
  FadeOutState createState() => FadeOutState();
}

class FadeOutState extends State<FadeOut> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool disposed = false;
  late Animation<double> animation;

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(curve: Curves.easeOut, parent: controller));

    if (!widget.manualTrigger && widget.animate) {
      Future.delayed(widget.delay, () {
        if (!disposed) {
          controller.forward();
        }
      });
    }

    if (widget.controller is Function) {
      widget.controller!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate && widget.delay.inMilliseconds == 0 && widget.manualTrigger == false) {
      controller.forward();
    }

    /// If FALSE, animate everything back to original
    if (!widget.animate) {
      controller.animateBack(0);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: widget.scale ? (0.8 + 0.2 * animation.value) : 1,
          child: ImageFiltered(
            imageFilter: widget.blur ? ImageFilter.blur(
              sigmaX: widget.blurAmount * (1 - animation.value),
              sigmaY: widget.blurAmount * (1 - animation.value),
            ) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Opacity(
              opacity: widget.fade ? animation.value : 1,
              child: widget.child,
            ),
          ),
        );
      }
    );
  }
}

class FadeInDown extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final double from;
  final bool fade;
  final double blurAmount;
  final bool scale;
  final bool blur;

  FadeInDown({
    key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.from = 100,
    this.fade = true,
    this.blurAmount = 20,
    this.scale = false,
    this.blur = false
  }) : super(key: key) {
    if (manualTrigger == true && controller == null) {
      throw FlutterError('If you want to use manualTrigger:true, \n\n'
          'Then you must provide the controller property, that is a callback like:\n\n'
          ' ( controller: AnimationController) => yourController = controller \n\n');
    }
  }

  @override
  FadeInDownState createState() => FadeInDownState();
}

/// FadeState class
/// The animation magic happens here
class FadeInDownState extends State<FadeInDown> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  /// is the widget disposed?
  bool disposed = false;

  /// animation movement
  late Animation<double> animation;

  /// animation opacity
  late Animation<double> opacity;

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>(begin: widget.from * -1, end: 0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: const Interval(0, 0.65)));

    if (!widget.manualTrigger && widget.animate) {
      Future.delayed(widget.delay, () {
        if (!disposed) {
          controller.forward();
        }
      });
    }

    /// Returns the controller if the user requires it
    if (widget.controller is Function) {
      widget.controller!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate && widget.delay.inMilliseconds == 0 && widget.manualTrigger == false) {
      controller.forward();
    }

    /// If FALSE, animate everything back to the original state
    if (!widget.animate) {
      controller.animateBack(0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Transform.scale(
            scale: widget.scale ? (0.8 + 0.2 * opacity.value) : 1,
            child: ImageFiltered(
              imageFilter: widget.blur ? ImageFilter.blur(
                sigmaX: widget.blurAmount * (1 - opacity.value),
                sigmaY: widget.blurAmount * (1 - opacity.value),
              ) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Opacity(
                opacity: widget.fade ? opacity.value : 1,
                child: widget.child,
              ),
            ),
          )
        );
      }
    );
  }
}

class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Function(AnimationController)? controller;
  final bool manualTrigger;
  final bool animate;
  final double from;
  final bool fade;
  final double blurAmount;
  final bool scale;
  final bool blur;

  FadeInUp({
    key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = const Duration(milliseconds: 0),
    this.controller,
    this.manualTrigger = false,
    this.animate = true,
    this.from = 100,
    this.fade = true,
    this.blurAmount = 20,
    this.scale = false,
    this.blur = false
  }) : super(key: key) {
    if (manualTrigger == true && controller == null) {
      throw FlutterError('If you want to use manualTrigger:true, \n\n'
        'Then you must provide the controller property, that is a callback like:\n\n'
        ' ( controller: AnimationController) => yourController = controller \n\n');
    }
  }

  @override
  FadeInUpState createState() => FadeInUpState();
}

/// FadeState class
/// The animation magic happens here
class FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  /// Animation controller if requested
  late AnimationController controller;

  /// widget is disposed?
  bool disposed = false;

  /// Animation movement
  late Animation<double> animation;

  /// Animation opacity
  late Animation<double> opacity;

  @override
  void dispose() {
    disposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);

    animation = Tween<double>(begin: widget.from, end: 0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: controller, curve: const Interval(0, 0.65)));

    if (!widget.manualTrigger && widget.animate) {
      Future.delayed(widget.delay, () {
        if (!disposed) {
          controller.forward();
        }
      });
    }

    if (widget.controller is Function) {
      widget.controller!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animate && widget.delay.inMilliseconds == 0 && widget.manualTrigger == false) {
      controller.forward();
    }

    /// If FALSE, animate everything back to the original state
    if (!widget.animate) {
      controller.animateBack(0);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Transform.scale(
            scale: widget.scale ? (0.8 + 0.2 * opacity.value) : 1,
            child: ImageFiltered(
              imageFilter: widget.blur ? ImageFilter.blur(
                sigmaX: widget.blurAmount * (1 - opacity.value),
                sigmaY: widget.blurAmount * (1 - opacity.value),
              ) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Opacity(
                opacity: widget.fade ? opacity.value : 1,
                child: widget.child,
              ),
            ),
          )
        );
      }
    );
  }
}