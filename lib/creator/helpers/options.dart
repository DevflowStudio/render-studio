import 'package:auto_size_text/auto_size_text.dart';
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
    String? tooltip,
    Function(BuildContext context)? onLongPress,
    bool greyOut = false,
  }) => Option(
    widget: (context) => ButtonWithIcon(
      title: title,
      onTap: onTap,
      onLongPress: onLongPress,
      icon: icon,
      tooltip: tooltip,
    )
  );

  static Option divider() => Option(
    widget: (context) => VerticalDivider(
      indent: 3,
      endIndent: 24,
    )
  );

  static Option toggle({
    Key? key,
    required String title,
    // Title to display when the toggle is off
    String? disabledTitle,
    required bool value,
    required Function(bool value) onChange,
    /// The icon to display when the toggle is enabled
    required IconData enabledIcon,
    /// The icon to display when the toggle is disabled
    required IconData disabledIcon,
    required String enabledTooltip,
    required String disabledTooltip,
    bool greyOut = false
  }) => Option(
    widget: (context) => ToggleIconButton(
      key: key,
      title: title,
      disabledTitle: disabledTitle,
      disabledIcon: disabledIcon,
      enabledIcon: enabledIcon,
      onChange: onChange,
      value: value,
      disabledTooltip: disabledTooltip,
      enabledTooltip: enabledTooltip,
    )
  );

  static Option custom({
    required Widget Function(BuildContext context) widget
  }) => Option(
    widget: (context) => widget(context),
  );

  static Option color(CreatorWidget widget, {
    Color? selected,
    ColorPalette? palette,
    required Function(Color? color) onChange,
    required Function(Color? color) onChangeEnd,
    String? title,
    IconData? icon,
    String? tooltip,
    bool allowClear = false,
    bool allowOpacity = true,
  }) => Option.button(
    title: title ?? 'Color',
    onTap: (context) async {
      widget.page.editorManager.openModal(
        padding: EdgeInsets.zero,
        actions: (dismiss) => [
          if (allowClear) IconButton(
            onPressed: () => onChange(null),
            icon: Icon(RenderIcons.delete)
          )
        ],
        tab: (context, setState) => EditorTab.color(
          context,
          onChange: onChange,
          palette: palette,
          selected: selected,
          allowOpacity: allowOpacity,
        ),
        onDismiss: () {
          onChangeEnd(null);
        },
      );
    },
    icon: icon ?? RenderIcons.color,
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
    List<num>? snapPoints,
    num? snapSensitivity,
    bool showValueEditor = false
  }) => Option(
    widget: (context) => CustomSlider(
      label: label,
      value: value,
      divisions: divisions,
      min: min,
      max: max,
      onChange: onChange,
      onChangeEnd: onChangeEnd,
      onChangeStart: onChangeStart,
      snapPoints: snapPoints,
      snapSensitivity: snapSensitivity,
      showValueEditor: showValueEditor,
    ),
  );

  static Option openReorderTab({
    required CreatorWidget widget,
  }) => Option.button(
    title: 'Reorder',
    onTap: (context) {
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.reorder(
          widget: widget,
          onReorder: () {},
          onReorderEnd: () {}
        )
      );
    },
    icon: RenderIcons.layers
  );

  static Option showSlider(CreatorWidget widget, {
    String? label,
    required String title,
    required IconData icon,
    required double value,
    int? divisions,
    required double min,
    required double max,
    required Function(double value) onChange,
    Function(double value)? onChangeStart,
    Function()? onChangeEnd,
    String? tooltip,
    num? snapSensitivity,
    List<num>? snapPoints,
    bool showValueEditor = false
  }) => Option.button(
    title: title,
    tooltip: tooltip,
    onTap: (context) async {
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab(
          name: title,
          type: EditorTabType.single,
          options: [
            Option.slider(
              value: value,
              min: min,
              max: max,
              onChange: onChange,
              onChangeStart: onChangeStart,
              snapPoints: snapPoints,
              snapSensitivity: snapSensitivity,
              showValueEditor: showValueEditor,
            )
          ]
        ),
        onDismiss: () {
          onChangeEnd?.call();
        }
      );
    },
    icon: icon
  );

  static Option picker({
    required List<Widget> children,
    required void Function(int)? onSelectedItemChanged,
    double itemExtent = 30,
    int initialIndex = 0
  }) => Option(
    widget: (context) => SizedBox(
      width: MediaQuery.of(context).size.width - 24,
      height: ((children.length < itemExtent) ? children.length : itemExtent) * 20,
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
        useMagnifier: true,
        magnification: 1.1,
        diameterRatio: 1.3,
        squeeze: 0.9,
      ),
    )
  );

  static Option font(CreatorWidget widget, {
    required String fontFamily,
    required onChange(WidgetChange change, String? font),
    bool isSelected = false
  }) => Option(
    widget: (context) => StatefulBuilder(
      builder: (context, setState) {
        return ButtonWithIcon(
          title: 'Font',
          onTap: (context) async {
            String _initialFont = fontFamily;
            widget.page.editorManager.openModal(
              actions: (dismiss) => [
                IconButton(
                  onPressed: () async {
                    String? _font = await AppRouter.push<String>(context, page: const FontSelector());
                    if (_font != null) fontFamily = _font;
                    onChange(WidgetChange.misc, _font);
                    dismiss();
                  },
                  icon: Icon(RenderIcons.search)
                )
              ],
              tab: (context, setState) {
                List<String> fonts = [
                  'Roboto',
                  'Inter',
                  'Poppins',
                  'Abril Fatface',
                  'Open Sans',
                  'Alegreya',
                  'Montserrat',
                  'Noto Sans',
                  'Ubuntu',
                  'Merriweather',
                  'Lato',
                  'Raleway',
                  'Oswald',
                  'Lora',
                  'Nunito',
                  'Playfair Display',
                  'PT Sans',
                  'PT Serif',
                  'Roboto Slab',
                  'Source Sans Pro',
                  'Fira Sans',
                  'Work Sans',
                  'Barlow Condensed',
                ];
                if (!fonts.contains(fontFamily)) fonts.insert(0, fontFamily);
                return EditorTab(
                  name: 'Fonts',
                  type: EditorTabType.single,
                  options: [
                    Option.custom(
                      widget: (context) => SizedBox(
                        height: 170,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          scrollDirection: Axis.horizontal,
                          itemCount: fonts.length,
                          itemBuilder: (context, index) {
                            String font = fonts[index];
                            return SizedBox(
                              height: 80,
                              width: 80,
                              child: InkWell(
                                onTap: () {
                                  fontFamily = font;
                                  onChange(WidgetChange.misc, font);
                                  setState(() { });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: font == fontFamily ? Palette.of(context).surfaceVariant : null,
                                    border: font == fontFamily ? Border.all(
                                      color: Palette.of(context).outline,
                                      width: 2
                                    ) : null,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Aa',
                                        style: GoogleFonts.getFont(font).copyWith(
                                          fontSize: 40,
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                      AutoSizeText(
                                        font,
                                        minFontSize: 12,
                                        maxFontSize: 16,
                                        wrapWords: false,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Google Sans',
                                          height: 0.77,
                                          color: Constants.getThemedObject(context, light: Colors.grey, dark: Colors.grey[400])
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    )
                  ],
                );
              },
              onDismiss: () {
                if (fontFamily != _initialFont) onChange(WidgetChange.update, null);
                else onChange(WidgetChange.misc, null);
              },
            );
          },
          child: Text(
            'Aa',
            style: GoogleFonts.getFont(fontFamily).copyWith(
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              color: Palette.of(context).onSecondaryContainer,
            ),
          ),
          tooltip: 'Select Font',
        );
      }
    )
  );

  static Option rotate({
    required CreatorWidget widget,
    String title = 'Rotate',
    IconData icon = RenderIcons.refresh,
    String tooltip = 'Tap to open angle adjuster',
  }) => Option.button(
    title: 'Rotate',
    onTap: (context) {
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.rotate(
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
    required CreatorWidget widget,
    String title = 'Scale',
    IconData icon = RenderIcons.scale,
    String tooltip = 'Tap to scale the widget size',
  }) => Option.button(
    title: title,
    onTap: (context) {
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.scale(
          size: widget.size,
          minSize: widget.minSize ?? Size(20, 20),
          maxSize: widget.page.project.contentSize * 1.5,
          onChange: (value) {
            widget.size  = value;
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
    required CreatorWidget widget,
    String title = 'Opacity',
    IconData icon = RenderIcons.opacity,
    String tooltip = 'Opacity',
  }) => Option.button(
    title: title,
    onTap: (context) {
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.opacity(
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
    required CreatorWidget widget,
    String title = 'Nudge',
    IconData icon = RenderIcons.nudge,
    String tooltip = 'Nudge',
  }) => Option.button(
    title: title,
    onTap: (context) async {
      widget.setHandlersVisibility(false);
      widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.nudge(
          widget: widget,
          onDXchange: (dx) {
            widget.position = Offset(widget.position.dx + dx, widget.position.dy);
            widget.updateListeners(WidgetChange.misc);
          },
          onDYchange: (dy) {
            widget.position = Offset(widget.position.dx, widget.position.dy + dy);
            widget.updateListeners(WidgetChange.misc);
          },
        ),
        onDismiss: () {
          widget.setHandlersVisibility(true);
        }
      );
      widget.updateListeners(WidgetChange.update, historyMessage: 'Nudge');
    },
    icon: icon,
    tooltip: tooltip
  );

  static Option position({
    required CreatorWidget widget,
    String title = 'Position',
    IconData? icon,
    String tooltip = 'Position the widget across the page',
  }) {
    icon ??= RenderIcons.position;
    return Option.button(
      title: title,
      onTap: (context) => widget.page.editorManager.openModal(
        tab: (context, setState) => EditorTab.position(
          widget: widget
        )
      ),
      icon: icon,
      tooltip: tooltip
    );
  }

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
    this.label,
    this.snapPoints,
    this.snapSensitivity,
    this.actions = const [],
    /// Whether to show the value editor of the slider along with the slider
    this.showValueEditor = false,
  }) : super(key: key);

  final String? label;
  final double value;
  final int? divisions;
  final double min;
  final double max;
  final Function(double value) onChange;
  final Function(double value)? onChangeStart;
  final Function(double value)? onChangeEnd;
  final List<num>? snapPoints;
  final num? snapSensitivity;
  final List<Widget> actions;
  final bool showValueEditor;

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {

  late double value;

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    value = widget.value;
    if (value > widget.max) value = widget.max;
    if (value < widget.min) value = widget.min;
    _controller.text = value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ... [
          Text(
            widget.label ?? 'Label',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant
            ),
          ),
          SizedBox(height: 6),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Slider(
                value: value,
                onChangeStart: widget.onChangeStart,
                onChangeEnd: (value) {
                  onChange(value);
                  widget.onChangeEnd?.call(this.value);
                },
                onChanged: (value) {
                  onChange(value);
                  widget.onChange(this.value);
                },
                divisions: widget.divisions,
                min: widget.min,
                max: widget.max,
              ),
            ),
            if (widget.actions.isNotEmpty) ... [
              SizedBox(width: 12),
              ... widget.actions,
            ],
            if (widget.showValueEditor) ... [
              SizedBox(width: 12,),
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  onTapOutside: (event) {
                    if (_controller.text.isNotEmpty) {
                      double? val = double.tryParse(_controller.text);
                      if (val != null) {
                        if (val > widget.max) val = widget.max;
                        if (val < widget.min) val = widget.min;
                        onChange(val);
                        widget.onChange(this.value);
                      }
                    }
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  textAlign: TextAlign.center,
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty) {
                      double? val = double.tryParse(value);
                      if (val != null) {
                        if (val > widget.max) val = widget.max;
                        if (val < widget.min) val = widget.min;
                        onChange(val);
                        widget.onChange(this.value);
                      }
                    }
                  },
                ),
              ),
              SizedBox(width: 12)
            ]
          ],
        ),
      ],
    );
  }

  void onChange(double value) {
    this.value = value;
    if (widget.snapPoints != null) {
      num closest = widget.snapPoints!.findClosestNumber(value);
      if ((closest - value).abs() < 2 * (widget.snapSensitivity ?? preferences.snapSensitivity)) this.value = closest.toDouble();
    }
    _controller.text = this.value.toStringAsFixed(2);
    setState(() { });
  }

}