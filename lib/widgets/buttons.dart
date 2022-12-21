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
    return _RenderButton(
      child: widget.child,
      isLoading: widget.isLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: Palette.of(context).primaryContainer,
      textColor: Palette.of(context).onPrimaryContainer
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
    return _RenderButton(
      child: widget.child,
      isLoading: widget.isLoading,
      disabled: widget.disabled,
      feedback: widget.feedback,
      onLongPress: widget.onLongPress,
      onPressed: widget.onPressed,
      backgroundColor: Palette.of(context).background,
      textColor: Palette.of(context).onBackground,
      border: Border.all(
        color: Palette.of(context).outline,
        width: 0
      ),
    );
  }

}

class _RenderButton extends StatefulWidget {

  const _RenderButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.feedback = true,
    this.disabled = false,
    this.isLoading = false,
    required this.backgroundColor,
    required this.textColor,
    this.border
  }) : super(key: key);

  final Widget child;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final bool feedback;
  final bool disabled;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final Border? border;

  @override
  State<_RenderButton> createState() => _RenderButtonState();
}

class _RenderButtonState extends State<_RenderButton> {

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
    return GestureDetector(
      onPanDown: (details) => reduceRadius(),
      onTapDown: (details) => reduceRadius(),
      onPanCancel: () => resetRadius(),
      onTapUp: (details) => resetRadius(),
      onTapCancel: () => resetRadius(),
      onTap: widget.onPressed != null ? () {
        reduceRadius();
        TapFeedback.tap();
        widget.onPressed?.call();
        Future.delayed(const Duration(milliseconds: 160), () => resetRadius());
      } : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          border: widget.border
        ),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: widget.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 17
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: widget.isLoading ? SizedBox(
                height: 18,
                width: 18,
                child: Spinner(
                  valueColor: widget.textColor,
                  strokeWidth: 2,
                )
              ) : widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void reduceRadius() => setState(() => radius = 10);

  void resetRadius() => setState(() => radius = 40);

}