import 'package:flutter/material.dart';
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
          color: widget.color ?? Palette.of(context).secondaryContainer
        ),
        child: Padding(
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 15, vertical: 7),
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

class PrimaryButton extends StatefulWidget {

  PrimaryButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    this.isLoading = false
  }) : super(key: key);

  final Widget child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool isLoading;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: widget.isLoading ? SizedBox(
        height: 18,
        width: 18,
        child: Spinner(
          valueColor: Palette.of(context).onPrimary,
          strokeWidth: 2,
        )
      ) : widget.child,
      onPressed: widget.onPressed,
      onLongPress: widget.onLongPress,
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
    this.isLoading = false
  }) : super(key: key);

  final Widget child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool isLoading;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Palette.of(context).onSecondaryContainer,
        backgroundColor: Palette.of(context).secondaryContainer,
      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
      onPressed: widget.onPressed,
      child: widget.isLoading ? SizedBox(
        height: 18,
        width: 18,
        child: Spinner(
          valueColor: Palette.of(context).onSecondaryContainer,
          strokeWidth: 2,
        )
      ) : widget.child,
    );
  }

}