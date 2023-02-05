import 'package:flutter/gestures.dart';
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
    required Widget child,
    required CreatorWidget widget,
  }) {
    Size size = widget.size;
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
        return const Size(17, 17);
      case ResizeHandler.topCenter:
        return const Size(30, 3);
      case ResizeHandler.topRight:
        return const Size(17, 17);
      case ResizeHandler.centerLeft:
        return const Size(3, 30);
      case ResizeHandler.centerRight:
        return const Size(3, 30);
      case ResizeHandler.bottomLeft:
        return const Size(17, 17);
      case ResizeHandler.bottomCenter:
        return const Size(30, 3);
      case ResizeHandler.bottomRight:
        return const Size(17, 17);
      default:
        return const Size(0, 0);
    }
  }

  Size get feedbackSize {
    switch (this) {
      case ResizeHandler.topLeft:
        return const Size(30, 30);
      case ResizeHandler.topCenter:
        return const Size(40, 6);
      case ResizeHandler.topRight:
        return const Size(30, 30);
      case ResizeHandler.centerLeft:
        return const Size(6, 40);
      case ResizeHandler.centerRight:
        return const Size(6, 40);
      case ResizeHandler.bottomLeft:
        return const Size(30, 30);
      case ResizeHandler.bottomCenter:
        return const Size(40, 6);
      case ResizeHandler.bottomRight:
        return const Size(30, 30);
      default:
        return const Size(0, 0);
    }
  }

  Size? calculateSize({
    /// Drag update details
    required DragUpdateDetails details,
    /// Previous Size
    required CreatorWidget widget,
    /// Setting this to `true` will keep updating the position of the widget as it is resized (default: `true`)
    /// This will provide the feedback of resizing the widget with the opposite end of the widget locked to a position
    bool updatePosition = true,
    bool keepAspectRatio = false,
  }) {
    double changeInX = details.delta.dx;
    double changeInY = details.delta.dy;
    switch (this) {
      case ResizeHandler.topLeft:
        Size _size = _calculateNewSize(widget, -changeInX, -changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (keepAspectRatio) changeInY = widget.size.height - _size.height;
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.topCenter:
        Size _size = _calculateNewSize(widget, 0, -changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (updatePosition) widget.position = Offset(widget.position.dx, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.topRight:
        Size _size = _calculateNewSize(widget, changeInX, -changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (keepAspectRatio) changeInY = widget.size.height - _size.height;
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;

      case ResizeHandler.centerLeft:
        Size _size = _calculateNewSize(widget, -changeInX, 0, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy);
          return _size;
        }
        return widget.size;
      case ResizeHandler.centerRight:
        Size _size = _calculateNewSize(widget, changeInX, 0, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy);
          return _size;
        }
        return widget.size;

      case ResizeHandler.bottomLeft:
        Size _size = _calculateNewSize(widget, -changeInX, changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (keepAspectRatio) changeInY = _size.height - widget.size.height;
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.bottomCenter:
        Size _size = _calculateNewSize(widget, 0, changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (updatePosition) widget.position = Offset(widget.position.dx, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      case ResizeHandler.bottomRight:
        Size _size = _calculateNewSize(widget, changeInX, changeInY, keepAspectRatio);
        if (widget.allowResize(_size)) {
          if (keepAspectRatio) changeInY = _size.height - widget.size.height;
          if (updatePosition) widget.position = Offset(widget.position.dx + changeInX / 2, widget.position.dy + changeInY / 2,);
          return _size;
        }
        return widget.size;
      default:
        return null;
    }
  }

  Size _calculateNewSize(CreatorWidget widget, double changeInX, double changeInY, bool keepAspectRatio) {
    if (keepAspectRatio) {
      double ratio = widget.size.width/widget.size.height;
      double _width = widget.size.width + (changeInX == 0 ? changeInY : changeInX);
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

  MouseCursor get cursor {
    switch (this) {
      case ResizeHandler.topLeft:
        return SystemMouseCursors.resizeUpLeft;
      case ResizeHandler.topCenter:
        return SystemMouseCursors.resizeUp;
      case ResizeHandler.topRight:
        return SystemMouseCursors.resizeUpRight;
      case ResizeHandler.centerLeft:
        return SystemMouseCursors.resizeLeft;
      case ResizeHandler.centerRight:
        return SystemMouseCursors.resizeRight;
      case ResizeHandler.bottomLeft:
        return SystemMouseCursors.resizeDownLeft;
      case ResizeHandler.bottomCenter:
        return SystemMouseCursors.resizeDown;
      case ResizeHandler.bottomRight:
        return SystemMouseCursors.resizeDownRight;
      default:
        return SystemMouseCursors.basic;
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
    this.isResizing = false,
    this.color,
    /// Setting this to `true` will keep updating the position of the widget as it is resized (default: `true`)
    /// This will provide the feedback of resizing the widget with the opposite end of the widget locked to a position
    this.updatePosition = true,
    this.keepAspectRatio = false,
    /// Set to `true` to reduce the size of resize handlers
    this.isMinimized = false
  }) : super(key: key);

  final ResizeHandler type;
  final CreatorWidget widget;
  final void Function(Size size) onSizeChange;
  final void Function({DragStartDetails? details, ResizeHandler? handler})? onResizeStart;
  final void Function({DragEndDetails? details, ResizeHandler? handler})? onResizeEnd;
  final bool isVisible;
  /// Set to `true` if the widget is currently being resized
  final bool isResizing;
  final Color? color;
  final bool updatePosition;
  final bool keepAspectRatio;
  final bool isMinimized;

  @override
  _ResizeHandlerBallState createState() => _ResizeHandlerBallState();
}

class _ResizeHandlerBallState extends State<ResizeHandlerBall> {

  bool isDragging = false;

  bool get minimizeSize => widget.isResizing || widget.isMinimized;

  @override
  Widget build(BuildContext context) {
    return widget.type.positioned(
      widget: widget.widget,
      child: Visibility(
        // duration: kAnimationDuration,
        // curve: Sprung(),
        // scale: widget.isVisible ? 1 : 0,
        visible: widget.isVisible,
        child: MouseRegion(
          cursor: widget.type.cursor,
          onHover: (event) => setState(() => isDragging = true),
          onExit: (event) => setState(() => isDragging = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            dragStartBehavior: DragStartBehavior.down,
            onPanUpdate: _onDrag,
            onPanEnd: _onDragEnd,
            onPanStart: _onDragStart,
            onPanCancel: _onDragCancel,
            onTapDown: (details) => _onDragStart(),
            onTapCancel: _onDragCancel,
            onTapUp: (details) => _onDragCancel(),
            child: IgnorePointer(
              ignoring: !widget.isVisible,
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
                      color: color,
                      border: borderColor != null ? Border.all(
                        color: borderColor!,
                        width: 1
                      ) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: const Offset(0, 0)
                        )
                      ]
                      // border: Border.all(
                      //   color: Colors.blue,
                      //   width: isDragging ? 2 : 1
                      // ),
                      // borderRadius: BorderRadius.circular(1),
                      // color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get color {
    if (widget.color != null) return widget.color!;
    if (widget.widget.page.widgets.background.type == BackgroundType.color) {
      return widget.widget.page.palette.onBackground;
    } else {
      return Colors.white;
    }
  }

  Color? get borderColor {
    if (widget.color != null) return null;
    if (widget.widget.page.widgets.background.type == BackgroundType.color) {
      return widget.widget.page.palette.background;
    } else {
      return null;
    }
  }

  Size get _size => isDragging ? widget.type.feedbackSize : (minimizeSize ? widget.type.size/2 : widget.type.size);

  void _onDrag(DragUpdateDetails details) {
    Size? size = widget.type.calculateSize(details: details, widget: widget.widget, updatePosition: widget.updatePosition, keepAspectRatio: widget.keepAspectRatio);
    if (size != null) widget.onSizeChange(size);
  }

  void _onDragStart([DragStartDetails? details]) {
    setState(() {
      isDragging = true;
    });
    widget.onResizeStart?.call(details: details, handler: widget.type);
  }

  void _onDragEnd([DragEndDetails? details]) {
    setState(() {
      isDragging = false;
    });
    widget.onResizeEnd?.call(details: details, handler: widget.type);
  }

  void _onDragCancel() => setState(() {
    isDragging = false;
  });

}