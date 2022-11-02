import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created a widget that does not take occupy any space
/// Limitations:
/// • It takes time to calculate the size of child widget, therefore positioning of the widget is not accurate at first render and fixes in a few milliseconds
///   To tackly this limitation, the positioning of the widget is animated
class NoSpaceWidget extends StatefulWidget {

  NoSpaceWidget({
    Key? key,
    required this.child
  }) : super(key: key);

  final Widget child;

  @override
  State<NoSpaceWidget> createState() => _NoSpaceWidgetState();
}

class _NoSpaceWidgetState extends State<NoSpaceWidget> {

  Size size = Size(0, 0);
  double opacity = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: widget.child
          ),
        ],
      ),
    );
  }

}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}