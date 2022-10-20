import 'package:flutter/cupertino.dart';
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
    Function(BuildContext context)? onLongPress,
    bool greyOut = false
  }) => Option(
    widget: (context) => ButtonWithIcon(
      title: title,
      onTap: onTap,
      onLongPress: onLongPress,
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

  static Option picker({
    required List<Widget> children,
    required void Function(int)? onSelectedItemChanged,
    double itemExtent = 30,
    int initialIndex = 0
  }) => Option(
    widget: (context) => SizedBox(
      width: MediaQuery.of(context).size.width - 24,
      child: CupertinoPicker(
        itemExtent: itemExtent,
        onSelectedItemChanged: onSelectedItemChanged,
        children: children,
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        magnification: 1.1,
        diameterRatio: 1.3,
        squeeze: 1,
      ),
    )
  );

  static Option pickerBuilder({
    required Widget? Function(BuildContext context, int index) itemBuilder,
    required void Function(int index)? onSelectedItemChanged,
    int? childCount,
    double itemExtent = 30,
    int initialIndex = 0
  }) => Option(
    widget: (context) => SizedBox(
      width: MediaQuery.of(context).size.width - 24,
      child: CupertinoPicker.builder(
        itemExtent: itemExtent,
        onSelectedItemChanged: onSelectedItemChanged,
        childCount: childCount,
        itemBuilder: itemBuilder,
        scrollController: FixedExtentScrollController(initialItem: initialIndex),
        magnification: 1.1,
        diameterRatio: 1.3,
        squeeze: 1,
      ),
    )
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) Label(
          label: widget.label!,
          subtitle: true,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 2/3,
          child: Slider(
            value: value,
            label: widget.label ?? value.trimToDecimal(1).toString(),
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