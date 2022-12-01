import 'package:flutter/material.dart';

import '../../rehmat.dart';

enum ResizeHandler {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension ResizeHandlerProperties on ResizeHandler {

  Positioned positioned({
    /// Size of the widget
    required Size size,
    required Widget child
  }) {
    switch (this) {
      case ResizeHandler.topLeft:
        return Positioned(
          top: 0,
          left: 0,
          child: child
        );
      case ResizeHandler.topCenter:
        return Positioned(
          top: 0,
          left: size.width / 2,
          child: child
        );
      case ResizeHandler.topRight:
        return Positioned(
          top: 0,
          right: 0,
          child: child
        );
      case ResizeHandler.centerLeft:
        return Positioned(
          left: 0,
          top: size.height / 2,
          child: child
        );
      case ResizeHandler.centerRight:
        return Positioned(
          right: 0,
          top: size.height / 2,
          child: child
        );
      case ResizeHandler.bottomLeft:
        return Positioned(
          bottom: 0,
          left: 0,
          child: child
        );
      case ResizeHandler.bottomCenter:
        return Positioned(
          bottom: 0,
          left: size.width / 2,
          child: child
        );
      case ResizeHandler.bottomRight:
        return Positioned(
          bottom: 0,
          right: 0,
          child: child
        );
      default:
        return Positioned(
          top: 0,
          left: 0,
          child: child
        );
    }
  }

  Size get size {
    switch (this) {
      case ResizeHandler.topLeft:
        return const Size(10, 10);
      case ResizeHandler.topCenter:
        return const Size(30, 3);
      case ResizeHandler.topRight:
        return const Size(10, 10);
      case ResizeHandler.centerLeft:
        return const Size(3, 30);
      case ResizeHandler.centerRight:
        return const Size(3, 30);
      case ResizeHandler.bottomLeft:
        return const Size(10, 10);
      case ResizeHandler.bottomCenter:
        return const Size(30, 3);
      case ResizeHandler.bottomRight:
        return const Size(10, 10);
      default:
        return const Size(0, 0);
    }
  }

  Size get feedbackSize {
    switch (this) {
      case ResizeHandler.topLeft:
        return const Size(15, 15);
      case ResizeHandler.topCenter:
        return const Size(40, 6);
      case ResizeHandler.topRight:
        return const Size(15, 15);
      case ResizeHandler.centerLeft:
        return const Size(6, 40);
      case ResizeHandler.centerRight:
        return const Size(6, 40);
      case ResizeHandler.bottomLeft:
        return const Size(15, 15);
      case ResizeHandler.bottomCenter:
        return const Size(40, 6);
      case ResizeHandler.bottomRight:
        return const Size(15, 15);
      default:
        return const Size(0, 0);
    }
  }

  Size? calculateSize({
    /// Drag update details
    required DragUpdateDetails details,
    /// Previous Size
    required CreatorWidget widget
  }) {
    double changeInX = details.delta.dx;
    double changeInY = details.delta.dy;
    switch (this) {
      case ResizeHandler.topLeft:
        Size _size = _calculateNewSize(widget, -changeInX, -changeInY);
        if (widget.allowResize(_size)) {
          if (widget.keepAspectRatio) changeInY = widget.size.height - _size.height;
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.topCenter:
        Size _size = _calculateNewSize(widget, 0, -changeInY);
        if (widget.allowResize(_size)) {
          widget.position = Offset(widget.position.dx, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.topRight:
        Size _size = _calculateNewSize(widget, changeInX, -changeInY);
        if (widget.allowResize(_size)) {
          if (widget.keepAspectRatio) changeInY = widget.size.height - _size.height;
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;

      case ResizeHandler.centerLeft:
        Size _size = _calculateNewSize(widget, -changeInX, 0);
        if (widget.allowResize(_size)) {
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy);
          return _size;
        }
        return widget.size;
      case ResizeHandler.centerRight:
        Size _size = _calculateNewSize(widget, changeInX, 0);
        if (widget.allowResize(_size)) {
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy);
          return _size;
        }
        return widget.size;

      case ResizeHandler.bottomLeft:
        Size _size = _calculateNewSize(widget, -changeInX, changeInY);
        if (widget.allowResize(_size)) {
          if (widget.keepAspectRatio) changeInY = _size.height - widget.size.height;
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.bottomCenter:
        Size _size = _calculateNewSize(widget, 0, changeInY);
        if (widget.allowResize(_size)) {
          widget.position = Offset(widget.position.dx, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.bottomRight:
        Size _size = _calculateNewSize(widget, changeInX, changeInY);
        if (widget.allowResize(_size)) {
          if (widget.keepAspectRatio) changeInY = _size.height - widget.size.height;
          widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      default:
        return null;
    }
  }

  Size _calculateNewSize(CreatorWidget widget, double changeInX, double changeInY) {
    if (widget.keepAspectRatio) {
      double ratio = widget.size.width/widget.size.height;
      double _width = widget.size.width + changeInX;
      double _height = _width / ratio;
      return Size(_width, _height);
    }
    else return Size(widget.size.width + changeInX, widget.size.height + changeInY);
  }

  ResizeHandlerType get type {
    switch (this) {
      case ResizeHandler.topLeft:
        return ResizeHandlerType.corner;
      case ResizeHandler.topCenter:
        return ResizeHandlerType.center;
      case ResizeHandler.topRight:
        return ResizeHandlerType.corner;
      case ResizeHandler.centerLeft:
        return ResizeHandlerType.center;
      case ResizeHandler.centerRight:
        return ResizeHandlerType.center;
      case ResizeHandler.bottomLeft:
        return ResizeHandlerType.corner;
      case ResizeHandler.bottomCenter:
        return ResizeHandlerType.center;
      case ResizeHandler.bottomRight:
        return ResizeHandlerType.corner;
      default:
        return ResizeHandlerType.center;
    }
  }

}

enum ResizeHandlerType {
  corner,
  center
}

class ResizeHandlerBall extends StatefulWidget {

  ResizeHandlerBall({
    Key? key,
    required this.type,
    required this.widget,
    required this.onSizeChange,
    this.onResizeStart,
    this.onResizeEnd,
    this.isVisible = true,
    this.isResizing = false
  }) : super(key: key);

  final ResizeHandler type;
  final CreatorWidget widget;
  final Function(Size size) onSizeChange;
  final Function(DragStartDetails details)? onResizeStart;
  final Function(DragEndDetails details)? onResizeEnd;
  final bool isVisible;
  /// Set to `true` if the widget is currently being resized
  final bool isResizing;

  @override
  _ResizeHandlerBallState createState() => _ResizeHandlerBallState();
}

class _ResizeHandlerBallState extends State<ResizeHandlerBall> {

  bool isDragging = false;
  
  Widget build(BuildContext contetx) {
    return widget.type.positioned(
      size: widget.widget.size,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: _onDrag,
        onPanEnd: _onDragEnd,
        onPanStart: _onDragStart,
        onPanCancel: _onDragCancel,
        onTapDown: (details) => setState(() => isDragging = true),
        onTapCancel: _onDragCancel,
        onTapUp: (details) => setState(() => isDragging = false),
        child: IgnorePointer(
          ignoring: !widget.isVisible,
          child: AnimatedOpacity(
            opacity: widget.isVisible ? 1 : 0,
            duration: Constants.animationDuration,
            curve: Curves.easeInOut,
            child: Container(
              width: 40,
              height: 40,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  width: _size.width,
                  height: _size.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        spreadRadius: 1.3,
                        offset: const Offset(0, 0)
                      )
                    ]
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Size get _size => isDragging ? widget.type.feedbackSize : (widget.isResizing ? widget.type.size/2 : widget.type.size);

  void _onDrag(DragUpdateDetails details) {
    Size? size = widget.type.calculateSize(details: details, widget: widget.widget);
    if (size != null) widget.onSizeChange(size);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      isDragging = true;
    });
    if (widget.onResizeStart != null) widget.onResizeStart!(details);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
    if (widget.onResizeEnd != null) widget.onResizeEnd!(details);
  }

  void _onDragCancel() => setState(() {
    isDragging = false;
  });

}