import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

// Use a standard IconButton with specific style to implement the
// 'Filled' toggle button.
class FilledIconButtons extends StatefulWidget {

  const FilledIconButtons({
    super.key,
    this.selected = false,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip
  });

  final bool selected;
  final void Function() onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;

  @override
  State<FilledIconButtons> createState() => _FilledIconButtonsState();
}

class _FilledIconButtonsState extends State<FilledIconButtons> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      style: IconButton.styleFrom(
        foregroundColor: widget.selected ? colors.onPrimary : colors.primary,
        backgroundColor: widget.selected ? colors.primary : colors.surfaceVariant,
        hoverColor: widget.selected ? colors.onPrimary.withOpacity(0.08) : colors.primary.withOpacity(0.08),
        focusColor: widget.selected ? colors.onPrimary.withOpacity(0.12) : colors.primary.withOpacity(0.12),
        highlightColor: widget.selected ? colors.onPrimary.withOpacity(0.12) : colors.primary.withOpacity(0.12),
      )
    );
  }
}

// Use a standard IconButton with specific style to implement the
// 'Filled Tonal' toggle button.
class FilledTonalIconButton extends StatefulWidget {

  const FilledTonalIconButton({
    super.key,
    this.selected = false,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
    this.padding = const EdgeInsets.all(8.0)
  });

  final bool selected;
  final void Function() onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;
  final EdgeInsetsGeometry padding;

  @override
  State<FilledTonalIconButton> createState() => _FilledTonalIconButtonState();
}

class _FilledTonalIconButtonState extends State<FilledTonalIconButton> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      padding: widget.padding,
      style: IconButton.styleFrom(
        foregroundColor: widget.selected ? colors.onSecondaryContainer : colors.onSurfaceVariant,
        backgroundColor: widget.selected ?  colors.secondaryContainer : colors.surfaceVariant,
        hoverColor: widget.selected ? colors.onSecondaryContainer.withOpacity(0.08) : colors.onSurfaceVariant.withOpacity(0.08),
        focusColor: widget.selected ? colors.onSecondaryContainer.withOpacity(0.12) : colors.onSurfaceVariant.withOpacity(0.12),
        highlightColor: widget.selected ? colors.onSecondaryContainer.withOpacity(0.12) : colors.onSurfaceVariant.withOpacity(0.12),
      ),
    );
  }
}

class OutlinedIconButtons extends StatefulWidget {

  const OutlinedIconButtons({
    super.key,
    this.selected = false,
    required this.onPressed,
    required this.icon,
    this.selectedIcon,
    this.tooltip
  });

  final bool selected;
  final void Function() onPressed;
  final Icon icon;
  final Icon? selectedIcon;
  final String? tooltip;

  @override
  State<OutlinedIconButtons> createState() => _OutlinedIconButtonsState();
}

// Use a standard IconButton with specific style to implement the
// 'Outlined' toggle button.
class _OutlinedIconButtonsState extends State<OutlinedIconButtons> {

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Palette.of(context);

    return IconButton(
      isSelected: widget.selected,
      icon: widget.icon,
      selectedIcon: widget.selectedIcon,
      onPressed: widget.onPressed,
      tooltip: widget.tooltip,
      style: IconButton.styleFrom(
        backgroundColor: widget.selected ? colors.inverseSurface : null,
        hoverColor: widget.selected ? colors.onInverseSurface.withOpacity(0.08) : colors.onSurfaceVariant.withOpacity(0.08),
        focusColor: widget.selected ? colors.onInverseSurface.withOpacity(0.12) : colors.onSurfaceVariant.withOpacity(0.12),
        highlightColor: widget.selected ? colors.onInverseSurface.withOpacity(0.12) : colors.onSurface.withOpacity(0.12),
        side: BorderSide(color: colors.outline),
      ).copyWith(
        foregroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return colors.onInverseSurface;
          }
          if (states.contains(MaterialState.pressed)) {
            return colors.onSurface;
          }
          return null;
        }),
      ),
    );
  }
}

class NewBackButton extends StatefulWidget {

  NewBackButton({
    Key? key,
    this.confirm = false,
    this.confirmMessage,
    this.confirmTitle,
    this.size,
    this.data,
    this.icon
  }) : super(key: key);

  final bool confirm;
  final String? confirmTitle;
  final String? confirmMessage;
  final double? size;
  final dynamic data;
  final IconData? icon;

  @override
  State<NewBackButton> createState() => _NewBackButtonState();
}

class _NewBackButtonState extends State<NewBackButton> {

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.icon ?? CupertinoIcons.arrow_turn_up_left),
      color: Palette.of(context).onBackground,
      iconSize: widget.size,
      onPressed: onBack,
    );
  }

  Future<void> onBack() async {
    if (widget.confirm) {
      if (await Alerts.showConfirmationDialog(context, title: widget.confirmTitle ?? 'Do you want to go back?', description: widget.confirmMessage ?? 'Any unsaved changes will be discarded. This cannot be undone.', cancelButtonText: 'Cancel', confirmButtonText: 'Discard')) Navigator.of(context).pop(widget.data);
    }
    else Navigator.of(context).pop(widget.data);
  }

}

class ColorSelector extends StatefulWidget {

  const ColorSelector({
    Key? key,
    required this.title,
    required this.onColorSelect,
    required this.color,
    required this.tooltip,
    this.size,
    this.borderWidth = 5,
    this.reverseOrder = false
  }) : super(key: key);

  final String title;
  final Function(Color color) onColorSelect;
  final Color color;
  final String tooltip;
  final bool reverseOrder;

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
                  context,
                  selected: color
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
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ].maybeReverse(widget.reverseOrder),
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
    this.onLongPress,
    this.child,
    this.icon,
    required this.tooltip,
    this.borderRadius = 60,
    this.feedbackBorderRadius = 15,
    this.size,
    this.greyOut = false
  }) : super(key: key);

  final String? title;
  final Function(BuildContext context) onTap;
  final Function(BuildContext context)? onLongPress;
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
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onPanDown: (details) => reduceRadius(),
              onTapDown: (details) => reduceRadius(),
              onPanCancel: () => resetRadius(),
              onTapUp: (details) => resetRadius(),
              onTapCancel: () => resetRadius(),
              onLongPress: () {
                if (widget.onLongPress != null) widget.onLongPress!(context);
              },
              onTap: () {
                reduceRadius();
                TapFeedback.tap();
                widget.onTap(context);
                Future.delayed(const Duration(milliseconds: 160), () => resetRadius());
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                height: widget.size?.height ?? 60,
                width: widget.size?.width ?? 60,
                decoration: BoxDecoration(
                  // color: Palette.of(context).surface,
                  color: Constants.getThemedObject(context, light: Colors.grey[100]!.withOpacity(0.5), dark: Colors.grey[900]),
                  border: Border.all(
                    color: Constants.getThemedObject(context, light: Colors.grey[200]!, dark: Colors.grey[800]!),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(radius)
                ),
                child: Center(
                  child: widget.child ?? Icon(
                    widget.icon,
                    color: widget.greyOut ? Colors.grey[700] : Palette.of(context).onSurface
                  ),
                ),
              ),
            ),
            if (widget.title != null) ... [
              Container(height: 6,),
              Container(
                // color: Colors.red,
                child: SizedBox(
                  height: calculateHeight() - 70,
                  child: Center(
                    child: Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                        fontFamily: 'Google Sans'
                      ),
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),
                  ),
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
      return 60;
    }
  }

}

class ToggleIconButton extends StatefulWidget {

  ToggleIconButton({
    Key? key,
    required this.title,
    required this.valueBuilder,
    required this.enabledIcon,
    required this.disabledIcon,
    required this.onChange,
    this.enabledTooltip,
    this.disabledTooltip,
  }) : super(key: key);

  final bool Function() valueBuilder;
  final String title;
  final IconData enabledIcon;
  final IconData disabledIcon;
  final void Function(bool value) onChange;
  final String? enabledTooltip;
  final String? disabledTooltip;

  @override
  State<ToggleIconButton> createState() => _ToggleIconButton();
}

class _ToggleIconButton extends State<ToggleIconButton> {

  late bool value;
  late IconData enabledIcon;
  late IconData disabledIcon;
  late void Function(bool value) onChange;

  @override
  void initState() {
    value = widget.valueBuilder();
    enabledIcon = widget.enabledIcon;
    disabledIcon = widget.disabledIcon;
    onChange = widget.onChange;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ButtonWithIcon(
      icon: value ? enabledIcon : disabledIcon,
      onTap: (context) {
        value = !value;
        onChange(value);
        setState(() { });
      },
      tooltip: (value ? widget.enabledTooltip : widget.disabledTooltip) ?? 'Toggle',
      title: widget.title,
    );
  }

}

class DragHandler extends StatefulWidget {

  DragHandler({
    Key? key,
    this.onPositionUpdate,
    this.onPositionUpdateEnd,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  final void Function(DragUpdateDetails)? onPositionUpdate;
  final void Function(DragEndDetails)? onPositionUpdateEnd;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  State<DragHandler> createState() => _DragHandlerState();
}

class _DragHandlerState extends State<DragHandler> {

  bool isHovering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onPanDown: (details) => setState(() => isHovering = true),
      // onPanCancel: () => setState(() => isHovering = false),
      onPanStart: (details) => setState(() => isHovering = true),
      onPanUpdate: (details) {
        if (widget.onPositionUpdate != null) widget.onPositionUpdate!(details);
      },
      onPanEnd: (details) {
        if (isHovering) setState(() => isHovering = false);
        if (widget.onPositionUpdateEnd != null) widget.onPositionUpdateEnd!(details);
      },
      child: AnimatedContainer(
        duration: Constants.animationDuration,
        height: isHovering ? 40 : 30,
        width: isHovering ? 40 : 30,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Palette.of(context).secondaryContainer,
          borderRadius: BorderRadius.circular(40)
        ),
        child: Center(
          child: Icon(
            RenderIcons.drag,
            size: isHovering ? 30 : 20,
            color: widget.iconColor ?? Palette.of(context).onSecondaryContainer,
          ),
        ),
      ),
    );
  }

}