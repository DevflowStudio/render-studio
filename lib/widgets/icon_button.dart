import 'package:flutter/material.dart';

import '../rehmat.dart';

class ColorSelector extends StatefulWidget {

  const ColorSelector({
    Key? key,
    required this.title,
    required this.onColorSelect,
    required this.color,
    required this.tooltip,
    this.size,
    this.borderWidth = 5
  }) : super(key: key);

  final String title;
  final Function(Color color) onColorSelect;
  final Color color;
  final String tooltip;

  final Size? size;
  final double borderWidth;

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {

  double radius = 60;

  late Color color;

  @override
  void initState() {
    color = widget.color;
    super.initState();
  }
  
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        height: widget.size?.height ?? 60,
        width: 100,
        child: Row(
          children: [
            GestureDetector(
              onPanDown: (details) => reduceRadius(),
              onTapDown: (details) => reduceRadius(),
              onPanCancel: () => resetRadius(),
              onTapUp: (details) => resetRadius(),
              onTapCancel: () => resetRadius(),
              onTap: () async {
                reduceRadius();
                TapFeedback.light();
                Color? _color = await Palette.showColorPicker(
                  context: context,
                  defaultColor: color
                );
                if (_color != null) {
                  color = _color;
                  widget.onColorSelect(color);
                }
                setState(() { });
                Future.delayed(const Duration(milliseconds: 300), () => resetRadius());
              },
              child: AnimatedContainer(
                duration: Constants.animationDuration,
                height: widget.size?.height ?? 60,
                width: widget.size?.width ?? 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Palette.of(context).background,
                    width: widget.borderWidth
                  )
                ),
              ),
            ),
            Container(width: 10,),
            Flexible(
              flex: 1,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void reduceRadius() => setState(() => radius = 20);

  void resetRadius() => setState(() => radius = 60);

}

class ButtonWithIcon extends StatefulWidget {

  const ButtonWithIcon({
    Key? key,
    this.title,
    required this.onTap,
    this.child,
    this.icon,
    required this.tooltip,
    this.borderRadius = 60,
    this.feedbackBorderRadius = 20,
    this.size,
    this.greyOut = false
  }) : super(key: key);

  final String? title;
  final Function(BuildContext context) onTap;
  final IconData? icon;
  final Widget? child;
  final String tooltip;

  final Size? size;
  final double borderRadius;
  final double feedbackBorderRadius;

  /// Setting this to `true` will make the icon look grey, showing the button is disabled or the value is turned off
  final bool greyOut;

  @override
  _ButtonWithIconState createState() => _ButtonWithIconState();
}

class _ButtonWithIconState extends State<ButtonWithIcon> {

  double radius = 60;
  
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        height: calculateHeight(),
        width: 60,
        child: Column(
          children: [
            GestureDetector(
              onPanDown: (details) => reduceRadius(),
              onTapDown: (details) => reduceRadius(),
              onPanCancel: () => resetRadius(),
              onTapUp: (details) => resetRadius(),
              onTapCancel: () => resetRadius(),
              onTap: () {
                reduceRadius();
                TapFeedback.tap();
                widget.onTap(context);
                Future.delayed(const Duration(milliseconds: 300), () => resetRadius());
              },
              child: AnimatedContainer(
                duration: Constants.animationDuration,
                height: widget.size?.height ?? 60,
                width: widget.size?.width ?? 60,
                decoration: BoxDecoration(
                  color: Palette.of(context).secondaryContainer,
                  borderRadius: BorderRadius.circular(radius)
                ),
                child: Center(
                  child: widget.child ?? Icon(
                    widget.icon,
                    color: widget.greyOut ? Colors.grey[700] : Palette.of(context).onSecondaryContainer
                  ),
                ),
              ),
            ),
            if (widget.title != null) ... [
              Container(height: 10,),
              Flexible(
                flex: 1,
                child: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.subtitle1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  void reduceRadius() => setState(() => radius = widget.feedbackBorderRadius);

  void resetRadius() => setState(() => radius = widget.borderRadius);

  double calculateHeight() {
    if (widget.title != null) {
      return Theme.of(context).textTheme.subtitle1!.fontSize! + 10 + 60;
    } else {
      return Theme.of(context).textTheme.subtitle1!.fontSize!;
    }
  }

}