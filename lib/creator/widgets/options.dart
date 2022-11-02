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

  static Option toggle({
    Key? key,
    required String title,
    required bool Function() valueBuilder,
    required Function(bool value) onChange,
    required IconData enabledIcon,
    required IconData disabledIcon,
    required String enabledTooltip,
    required String disabledTooltip,
    bool greyOut = false
  }) => Option(
    widget: (context) => ToggleIconButton(
      key: key,
      title: title,
      disabledIcon: disabledIcon,
      enabledIcon: enabledIcon,
      onChange: onChange,
      valueBuilder: valueBuilder,
      disabledTooltip: disabledTooltip,
      enabledTooltip: enabledTooltip,
    )
  );

  static Option custom({
    required Widget Function(BuildContext context) widget
  }) => Option(
    widget: (context) => widget(context),
  );

  static Option color({
    Color Function()? selected,
    ColorPalette Function()? palette,
    required Function(Color color) onChange,
    String? title,
    IconData? icon,
    String? tooltip,
  }) => Option.button(
    title: title ?? 'Color',
    onTap: (context) async {
      Color? color = await AppRouter.push(context, page: ColorTool(palette: palette?.call(), selection: selected?.call(),));
      if (color != null) onChange(color);
    },
    icon: icon ?? Icons.color_lens,
    tooltip: tooltip ?? 'Tap to select a color',
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
      height: MediaQuery.of(context).size.height / 5,
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

  static Option rotate({
    String title = 'Rotate',
    IconData icon = Icons.refresh,
    String tooltip = 'Tap to open angle adjuster',
    required CreatorWidget widget,
    required Project project
  }) => Option.button(
    title: 'Rotate',
    onTap: (context) {
      EditorTab.modal(
        context,
        tab: EditorTab.rotate(
          angle: widget.angle,
          onChange: (value) {
            widget.angle = value;
            widget.updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            widget.angle = value;
            widget.updateListeners(WidgetChange.update);
          },
        )
      );
    },
    icon: icon,
    tooltip: tooltip
  );

  static Option scale({
    String title = 'Scale',
    IconData icon = Icons.format_shapes_rounded,
    String tooltip = 'Tap to scale the widget size',
    required CreatorWidget widget,
    required Project project
  }) => Option.button(
    title: title,
    onTap: (context) {
      EditorTab.modal(
        context,
        tab: EditorTab.scale(
          size: widget.size,
          minSize: widget.minSize ?? Size(20, 20),
          maxSize: project.contentSize(context),
          onChange: (value) {
            widget.size  = value;
            widget.updateResizeHandlers();
            widget.updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            widget.size  = value;
            widget.updateListeners(WidgetChange.update);
          },
        )
      );
    },
    icon: icon,
    tooltip: tooltip
  );

  static Option opacity({
    String title = 'Opacity',
    IconData icon = Icons.opacity,
    String tooltip = 'Opacity',
    required CreatorWidget widget,
    required Project project
  }) => Option.button(
    title: title,
    onTap: (context) {
      EditorTab.modal(
        context,
        tab: EditorTab.opacity(
          opacity: widget.opacity,
          onChange: (value) {
            widget.opacity = value;
            widget.updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            widget.opacity = value;
            widget.updateListeners(WidgetChange.update);
          },
        ),
      );
    },
    icon: icon,
    tooltip: tooltip
  );

  static Option nudge({
    String title = 'Nudge',
    IconData icon = Icons.drag_indicator,
    String tooltip = 'Nudge',
    required CreatorWidget widget,
    required Project project
  }) => Option.button(
    title: title,
    onTap: (context) async {
      await EditorTab.modal(
        context,
        tab: EditorTab.nudge(
          onDXchange: (dx) {
            widget.position = Offset(widget.position.dx + dx, widget.position.dy);
            widget.updateListeners(WidgetChange.misc);
          },
          onDYchange: (dy) {
            widget.position = Offset(widget.position.dx, widget.position.dy + dy);
            widget.updateListeners(WidgetChange.misc);
          },
        )
      );
      widget.updateListeners(WidgetChange.update);
    },
    icon: icon,
    tooltip: tooltip
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