import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:sprung/sprung.dart';
import '../rehmat.dart';

class TextIconButton extends StatefulWidget {

  const TextIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
    this.padding
  }) : super(key: key);

  final String text;

  final IconData icon;

  final Color? color;
  final EdgeInsetsGeometry? padding;

  final Function() onPressed;

  @override
  _TextIconButtonState createState() => _TextIconButtonState();
}

class _TextIconButtonState extends State<TextIconButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: Constants.borderRadius,
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Constants.borderRadius,
          color: widget.color ?? Palette.of(context).surfaceVariant,
          border: Border.all(
            color: Palette.of(context).onSurfaceVariant.withOpacity(0.2),
            width: 0
          )
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: Palette.of(context).onSecondaryContainer
              ),
              Container(width: 5,),
              Text(
                widget.text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Palette.of(context).onSurfaceVariant
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatefulWidget {

  PrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;
  final EdgeInsetsGeometry padding;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: Palette.of(context).onBackground,
      textColor: Palette.of(context).background,
      padding: widget.padding,
    );
  }

}

class SecondaryButton extends StatefulWidget {

  SecondaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;
  final EdgeInsetsGeometry padding;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();

}

class _SecondaryButtonState extends State<SecondaryButton> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      border: BorderSide(
        color: Palette.of(context).onBackground.withOpacity(0.1),
        width: 1
      ),
      backgroundColor: Palette.of(context).surfaceVariant,
      textColor: Palette.of(context).onSurfaceVariant,
      padding: widget.padding,
    );
  }

}

class Button extends StatefulWidget {

  Button({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    /// If true, the button will show a loading indicator when pressed until the onPressed function finishes
    this.autoLoading = false,
    this.backgroundColor,
    this.textColor,
    this.shadow,
    this.border
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool autoLoading;

  final Color? backgroundColor;
  final Color? textColor;
  final BoxShadow? shadow;
  final BorderSide? border;

  @override
  State<Button> createState() => _ButtonState();
  
}

class _ButtonState extends State<Button> {

  @override
  Widget build(BuildContext context) {
    return RawButton(
      child: widget.child,
      autoLoading: widget.autoLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: widget.backgroundColor ?? Palette.of(context).surfaceVariant,
      textColor: widget.textColor ?? Palette.of(context).onSurfaceVariant,
      shadow: widget.shadow,
      border: widget.border
    );
  }

}

class RawButton extends StatefulWidget {

  const RawButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    required this.backgroundColor,
    required this.textColor,
    this.border,
    this.autoLoading = false,
    this.shadow,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
  }) : super(key: key);

  final Widget child;
  final Function()? onPressed;
  final Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final Color backgroundColor;
  final Color textColor;
  final BorderSide? border;
  final bool autoLoading;
  final BoxShadow? shadow;
  final EdgeInsetsGeometry padding;

  @override
  State<RawButton> createState() => RawButtonState();
}

class RawButtonState extends State<RawButton> {

  double radius = 60;

  bool isLoading = false;

  double scale = 1;
  
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
    TextStyle? textStyle = Theme.of(context).textTheme.titleLarge;
    return GestureDetector(
      onPanDown: (details) => reduceRadius(),
      onTapDown: (details) => reduceRadius(),
      onPanCancel: () => resetRadius(),
      onTapUp: (details) => resetRadius(),
      onTapCancel: () => resetRadius(),
      onTap: widget.onPressed != null ? () {
        TapFeedback.tap();
        onPressed();
      } : null,
      child: AnimatedScale(
        duration: kAnimationDuration,
        scale: scale,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Sprung.criticallyDamped,
          // decoration: BoxDecoration(
          //   color: widget.backgroundColor,
          //   borderRadius: BorderRadius.circular(radius),
          //   border: Border.fromBorderSide(widget.border ?? BorderSide.none),
          // ),
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(40),
              smoothness: 0.6,
              side: widget.border?.copyWith(
                color: widget.border?.color.withOpacity(widget.disabled ? 0.5 : 1)
              ) ?? BorderSide.none
            ),
            color: widget.backgroundColor.withOpacity(widget.disabled ? 0.5 : 1),
          ),
          child: DefaultTextStyle(
            style: textStyle!.copyWith(
              color: widget.textColor,
              fontSize: 19,
              fontFamily: 'SF Pro Rounded',
              fontWeight: FontWeight.w500,
              height: 1
            ),
            child: Center(
              child: Padding(
                padding: widget.padding,
                child: isLoading ? SizedBox(
                  height: 19,
                  width: 19,
                  child: Spinner(
                    valueColor: widget.textColor,
                    strokeWidth: 2,
                  )
                ) : widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void reduceRadius() => setState(() => scale = 0.95);

  void resetRadius() => setState(() => scale = 1);

  Future<void> onPressed() async {
    if (widget.onPressed == null || isLoading) return;
    if (widget.autoLoading) setState(() => isLoading = true);
    await widget.onPressed!();
    if (widget.autoLoading) setState(() => isLoading = false);
  }

}

class InkWellButton extends StatelessWidget {

  const InkWellButton({
    super.key,
    required this.child,
    this.radius,
    this.backgroundColor,
    this.onTap
  });

  final Widget child;
  final BorderRadius? radius;
  final Color? backgroundColor;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.transparent
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: child
        ),
      ),
    );
  }

}