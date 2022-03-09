import 'package:flutter/material.dart';
import '../rehmat.dart';

class Button extends StatefulWidget {

  const Button({
    Key? key,
    required this.text,
    this.isLoading = false,
    this.background,
    this.onPressed,
    this.padding,
    this.margin,
    this.disabled = false,
    this.icon,
    this.disabledText,
    this.radius,
    this.iconSize
  }) : super(key: key);

  /// The text to be displayed as button child
  final String text;

  final String? disabledText;

  /// Set to true to show a spinner as button child
  /// It will also disable onPressed parameter
  final bool isLoading;

  /// Color of button
  final Color? background;

  /// Function to call when button is pressed
  final void Function()? onPressed;

  final bool disabled;

  final IconData? icon;

  final double? iconSize;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final BorderRadius? radius;

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.margin,
      child: Builder(
        builder: (context) {
          if (widget.icon != null) {
            return ElevatedButton.icon(
            onPressed: onPressed,
            icon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: icon,
            ),
            label: child,
            style: style,
          );
          }

          return ElevatedButton(
            onPressed: onPressed,
            child: child,
            style: style,
          );
        },
      ),
    );
  }

  void Function()? get onPressed => widget.disabled ? () {} : (widget.isLoading ? () {} : widget.onPressed);

  Widget? get icon => widget.icon != null ? Icon(
    widget.icon,
    color: widget.disabled ? Colors.grey[700] : App.textColorFromBackground(_background),
    size: widget.iconSize
  ) : null;

  Widget get child => widget.isLoading ? const SizedBox(
    width: 14,
    height: 14,
    child: Spinner(
      strokeWidth: 2,
    ),
  ) : Text(
    widget.disabled ? widget.disabledText ?? widget.text : widget.text,
    style: TextStyle(
      color: widget.disabled ? Palette.of(context).onSurface.withOpacity(0.38) : Palette.of(context).onPrimary
    ),
  );

  ButtonStyle get style => ElevatedButton.styleFrom(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: widget.radius ?? Constants.borderRadius,
    ),
    padding: padding,
    primary: background,
  );

  Color? get background =>  (widget.disabled || widget.isLoading)
    ? Palette.of(context).onSurface.withOpacity(0.12)
    : _background;
  
  Color get _background => widget.background ?? Palette.of(context).primary;

  EdgeInsetsGeometry get padding {
    if (widget.padding != null) {
      return widget.padding!;
    } else if (widget.text.length < 10) {
      return const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 30
    );
    } else {
      return const EdgeInsets.symmetric(
      vertical: 15,
      horizontal: 17
    );
    }
  }

}

class TextIconButton extends StatefulWidget {

  const TextIconButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed
  }) : super(key: key);

  final String text;

  final IconData icon;

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
          color: Palette.of(context).secondaryContainer
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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
                style: Theme.of(context).textTheme.button?.copyWith(
                  color: Palette.of(context).onSecondaryContainer
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}