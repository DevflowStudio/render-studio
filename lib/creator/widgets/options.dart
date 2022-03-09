import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../rehmat.dart';

class Option {

  Option({
    required this.widget
  });

  final Widget Function(BuildContext context) widget;

  static Option button({
    required String title,
    required Function(BuildContext context) onTap,
    required IconData icon,
    required String tooltip,
    bool greyOut = false
  }) => Option(
    widget: (context) => ButtonWithIcon(
      title: title,
      onTap: onTap,
      icon: icon,
      tooltip: tooltip,
    )
  );

  static Option custom({
    required Widget Function(BuildContext context) widget
  }) => Option(
    widget: (context) => widget(context),
  );

  static Option slider({
    String? label,
    required double value,
    int? divisions,
    required double min,
    required double max,
    required Function(double value) onChange,
    Function(double value)? onChangeStart,
    Function(double value)? onChangeEnd,
  }) => Option(
    widget: (context) => CustomSlider(
      label: label,
      value: value,
      divisions: divisions,
      min: min,
      max: max,
      onChange: onChange
    ),
  );

  static Option font({
    required String font,
    required Function(BuildContext context, String font) onFontSelect,
  }) => Option(
    widget: (context) => ButtonWithIcon(
      title: font,
      onTap: (context) => onFontSelect(context, font),
      child: Text(
        'Aa',
        style: GoogleFonts.getFont(font).copyWith(
          fontSize: Theme.of(context).textTheme.headline6!.fontSize,
          color: Palette.of(context).onSecondaryContainer
        ),
      ),
      tooltip: '$font',
    )
  );

  Widget build(BuildContext context) => widget(context);

}

class CustomSlider extends StatefulWidget {

  CustomSlider({
    Key? key,
    required this.value,
    this.divisions,
    required this.min,
    required this.max,
    required this.onChange,
    this.onChangeStart,
    this.onChangeEnd,
    this.label
  }) : super(key: key);

  final String? label;
  final double value;
  final int? divisions;
  final double min;
  final double max;
  final Function(double value) onChange;
  final Function(double value)? onChangeStart;
  final Function(double value)? onChangeEnd;

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {

  late double value;

  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.label != null) Label(
          label: widget.label!,
          subtitle: true,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 2/3,
          child: Slider(
            value: value,
            label: '$value',
            onChangeStart: widget.onChangeStart,
            onChangeEnd: widget.onChangeEnd,
            onChanged: (value) {
              this.value = value;
              widget.onChange(value);
              setState(() { });
            },
            divisions: widget.divisions,
            min: widget.min,
            max: widget.max,
          ),
        ),
      ],
    );
  }
}