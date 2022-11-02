import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../rehmat.dart';

class Editor extends StatefulWidget {
  
  const Editor({
    Key? key,
    required this.tabs,
    required this.project,
    required this.page,
    required this.widget,
  }) : super(key: key);

  final List<EditorTab> tabs;
  final Project project;
  final CreatorPage page;
  final CreatorWidget widget;

  Widget get build => this;

  static Size calculateSize(BuildContext context) {
    Size editorSize = Size(double.infinity, MediaQuery.of(context).size.height * 0.25); // The editor can only be allowed to cover 23% of the screen area.
    if (MediaQuery.of(context).size.height * 0.25 > 180) editorSize = Size(double.infinity, 180);
    return editorSize;
  }

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> with TickerProviderStateMixin {

  @override
  void initState() {
    widget.widget.addListener(onPropertyChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.widget.removeListener(onPropertyChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size editorSize = Editor.calculateSize(context);
    return DefaultTabController(
      length: widget.tabs.length,
      child: SizedBox.fromSize(
        size: editorSize,
        child: Container(
          decoration: BoxDecoration(
            color: Palette.of(context).surfaceVariant,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TabBar(
                enableFeedback: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Constants.getThemedBlackAndWhite(context),
                labelColor: Constants.getThemedBlackAndWhite(context),
                indicator: widget.tabs.length > 1 ? null : const BoxDecoration(),
                unselectedLabelColor: Constants.getThemedBlackAndWhite(context).withOpacity(0.5),
                isScrollable: true,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                tabs: List.generate(
                  widget.tabs.length,
                  (index) => Tab(
                    text: widget.tabs[index].tab,
                  )
                )
              ),
              const Divider(
                indent: 0,
                height: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    // color: Colors.yellow,
                    child: SizedBox.fromSize(
                      size: Size.fromHeight(editorSize.height * 3/5),
                      child: Center(
                        child: SizedBox.fromSize(
                          size: Size.fromHeight(editorSize.height * 1.1/2),
                          child: Container(
                            // color: Colors.red,
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                widget.tabs.length,
                                (index) {
                                  return widget.tabs[index].build(context);
                                }
                              )
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }

  void onPropertyChange() {
    setState(() { });
  }

}

class EditorTab {

  EditorTab({
    required this.tab,
    required this.options,
    this.type = EditorTabType.row,
    this.actions = const [],
  });

  final List<Option> options;
  final String tab;
  final EditorTabType type;
  final List<IconButton> actions;

  static Future<T?> modal<T>(BuildContext context, {
    required EditorTab tab,
    double? height,
    Widget Function(BuildContext context, Widget child)? builder,
    List<Widget> actions = const [],
    EdgeInsets? padding
  }) => showModalBottomSheet<T>(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    builder: (context) => Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Palette.of(context).surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            spreadRadius: 0,
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NewBackButton(
                    size: 20,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      tab.tab,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(),
                    ),
                  ),
                ],
              ),
              ... actions,
            ],
          ),
          if (builder != null) builder(context, tab.build(context))
          else Container(
            // color: Colors.red,
            constraints: BoxConstraints(
              minHeight: Editor.calculateSize(context).height - 50,
              maxHeight: MediaQuery.of(context).size.height/2.7,
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
              child: tab.build(context),
            ),
          ),
        ],
      )
    ),
  );

  Widget build(BuildContext context) {
    switch (type) {
      case EditorTabType.row:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: options[index].build(context),
          ),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
        );
      case EditorTabType.column:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) => options[index].build(context),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
        );
      case EditorTabType.single:
        return options[0].build(context);
      case EditorTabType.grid:
        return SizedBox(
          height: 80,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: options.length ~/ 2),
            itemBuilder: (context, index) => Container(
              color: Colors.red.withOpacity(0.2),
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(5),
              child: options[index].build(context),
            ),
            itemCount: options.length,
            // physics: NeverScrollableScrollPhysics(),
          ),
        );
      default:
    }
    return Container();
  }

  static EditorTab opacity({
    required double opacity,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: opacity,
        min: 0.05,
        max: 1,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
      )
    ],
    tab: 'Opacity'
  );

  static EditorTab rotate({
    required double angle,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: angle,
        min: 0,
        max: 360,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
        divisions: 45
      )
    ],
    tab: 'Rotate'
  );

  static EditorTab scale({
    required Size size,
    required Size minSize,
    required Size maxSize,
    required Function(Size value) onChange,
    Function(Size value)? onChangeEnd,
  }) {

    double ratio = size.width / size.height;
    
    double min = (ratio < 1) ? minSize.height : minSize.width;
    double max = (ratio < 1) ? maxSize.height : maxSize.width;

    Size _calculateSize({required double value}) {
      if (ratio < 1) {
        return Size(value * ratio, value);
      } else {
        return Size(value, value / ratio);
      }
    }

    return EditorTab(
      type: EditorTabType.single,
      tab: 'Scale',
      options: [
        Option.slider(
          value: ratio < 1 ? size.height : size.width,
          min: min,
          max: max,
          label: 'Scale',
          onChange: (value) {
            onChange(_calculateSize(value: value));
          },
          onChangeEnd: (value) {
            if (onChangeEnd != null) onChangeEnd(_calculateSize(value: value));
          },
          divisions: 45
        )
      ],
    );
    
  }

  static EditorTab size({
    required double current,
    required double min,
    required double max,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: current,
        min: min,
        max: max,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
      )
    ],
    tab: 'Size'
  );

  static EditorTab picker({
    required String title,
    required List<Widget> children,
    required void Function(int index)? onSelectedItemChanged,
    double itemExtent = 30,
    int initialIndex = 0
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.picker(
        children: children,
        onSelectedItemChanged: onSelectedItemChanged,
        itemExtent: itemExtent,
        initialIndex: initialIndex
      )
    ],
    tab: title
  );

  static EditorTab pickerBuilder({
    required String title,
    required Widget? Function(BuildContext context, int index) itemBuilder,
    required void Function(int index)? onSelectedItemChanged,
    int? childCount,
    double itemExtent = 30,
    int initialIndex = 0
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.pickerBuilder(
        itemBuilder: itemBuilder,
        onSelectedItemChanged: onSelectedItemChanged,
        childCount: childCount,
        initialIndex: initialIndex,
        itemExtent: itemExtent
      )
    ],
    tab: title
  );

  static EditorTab nudge({
    required Function(double dx) onDXchange,
    required Function(double dy) onDYchange,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonWithIcon(
              onTap: (context) {
                onDYchange(-Constants.nudgeSenstivity);
                TapFeedback.light();
              },
              tooltip: 'Move Up',
              icon: Icons.expand_less,
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWithIcon(
                  onTap: (context) {
                    onDXchange(-Constants.nudgeSenstivity);
                  },
                  tooltip: 'Move Left',
                  icon: Icons.chevron_left,
                ),
                SizedBox(width: 6),
                ButtonWithIcon(
                  onTap: (context) {
                    onDYchange(Constants.nudgeSenstivity);
                  },
                  tooltip: 'Move Down',
                  icon: Icons.expand_more,
                ),
                SizedBox(width: 6),
                ButtonWithIcon(
                  onTap: (context) {
                    onDXchange(Constants.nudgeSenstivity);
                  },
                  tooltip: 'Move Right',
                  icon: Icons.chevron_right,
                ),
              ]
            )
          ],
        ),
      )
    ],
    tab: 'Nudge'
  );

  static EditorTab paddingEditor({
    required EdgeInsets padding,
    required Function(EdgeInsets value) onChange,
    double? min,
    double? max,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _PaddingEditor(
          padding: padding,
          onChange: onChange,
          min: min,
          max: max
        ),
      )
    ],
    tab: 'Padding'
  );

  static EditorTab shadow<T>({
    required Shadow shadow,
    required void Function(T? value) onChange,
    void Function(T? value)? onChangeEnd,
  }) {
    return EditorTab(
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => _ShadowEditor<T>(
            shadow: shadow,
            onChange: onChange,
            onChangeEnd: onChangeEnd,
          ),
        )
      ],
      tab: 'Shadow Editor'
    );
  }

  static EditorTab palette({
    required CreatorPage page,
    required void Function(ColorPalette palette) onSelected
  }) => EditorTab(
    tab: 'Palette',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _PaletteListView(
                title: 'Current',
                palettes: [
                  page.palette
                ],
                onSelected: onSelected,
                page: page,
              ),
              SizedBox(
                height: 150,
                child: VerticalDivider(),
              ),
              _PaletteListView(
                title: 'Saved',
                palettes: [
                  ... paletteManager.palettes
                ],
                onSelected: onSelected,
                page: page,
              ),
              SizedBox(
                height: 150,
                child: Center(child: VerticalDivider()),
              ),
              FutureBuilder(
                future: paletteManager.suggestions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _PaletteListView(
                      title: 'Suggestion',
                      palettes: snapshot.data as List<ColorPalette>,
                      onSelected: onSelected,
                      page: page,
                    );
                  } else {
                    return SizedBox(
                      height: 150,
                      width: 100,
                      child: Center(
                        child: Spinner(
                          adaptive: true,
                        ),
                      ),
                    );
                  }
                  // return _PaletteListView(
                  //   title: 'Suggestions',
                  //   palettes: [
                  //     ... List.generate(paletteManager.palettes.length < 5 ? 5 : 3, (index) => ColorPalette.offlineGenerator())
                  //   ],
                  // );
                },
              )
            ],
          ),
        ),
      )
    ]
  );

}

enum EditorTabType {
  /// Arrange the options in a list
  row,
  column,
  /// Arrange the options in a grid
  grid,
  /// Center align the single widget
  single
}

extension EditorTabTypeExtension on EditorTabType {

  // Size get size {
  //   switch (this) {
  //     case EditorTabType.row:
  //       return const Size(double.maxFinite, 90);
  //     case EditorTabType.column:
  //       return const Size(double.maxFinite, 90);
  //     default:
  //       return const Size(double.maxFinite, 90);
  //   }
  // }

}

class _PaddingEditor extends StatefulWidget {

  _PaddingEditor({
    Key? key,
    required this.padding,
    required this.onChange,
    this.max,
    this.min
  }) : super(key: key);

  final EdgeInsets padding;
  final Function(EdgeInsets value) onChange;
  final double? max;
  final double? min;

  @override
  State<_PaddingEditor> createState() => __PaddingEditorState();
}

class __PaddingEditorState extends State<_PaddingEditor> {

  late EdgeInsets padding;

  double horizontal = 0;
  double vertical = 0;

  bool locked = true;

  @override
  void initState() {
    padding = widget.padding;
    horizontal = padding.left;
    vertical = padding.top;
    if (horizontal == vertical) locked = true;
    else locked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: locked ? vertical : horizontal,
              label: 'Horizontal',
              min: widget.min ?? 0,
              max: widget.max ?? 24,
              onChanged: (value) {
                if (locked) {
                  horizontal = vertical = value;
                  padding = EdgeInsets.symmetric(vertical: value, horizontal: value);
                } else {
                  horizontal = value;
                  padding = EdgeInsets.symmetric(horizontal: value, vertical: vertical);
                }
                setState(() { });
                widget.onChange(padding);
              },
            ),
            Slider(
              value: vertical,
              label: 'Vertical',
              min: widget.min ?? 0,
              max: widget.max ?? 24,
              onChanged: (value) {
                print('Vertical: $value');
                if (locked) {
                  horizontal = vertical = value;
                  padding = EdgeInsets.symmetric(vertical: value, horizontal: value);
                } else {
                  vertical = value;
                  padding = EdgeInsets.symmetric(horizontal: value, vertical: vertical);
                }
                setState(() { });
                widget.onChange(padding);
              },
            ),
          ],
        ),
        SizedBox(width: 24),
        OutlinedIconButtons(
          onPressed: () {
            TapFeedback.light();
            setState(() => locked = !locked);
          },
          icon: Icon(
            locked ? Icons.lock : Icons.lock_open,
          ),
        )
      ],
    );
  }

  Widget iconButton() {
    if (locked) return FilledTonalIconButton(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(Icons.lock)
    );
    else return OutlinedIconButtons(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(Icons.lock_open)
    );
  }
  
}

class _ShadowEditor<T> extends StatefulWidget {

  _ShadowEditor({
    Key? key,
    required this.shadow,
    required this.onChange,
    this.onChangeEnd,
  });

  final Shadow shadow;
  final void Function(T value) onChange;
  final void Function(T value)? onChangeEnd;

  @override
  State<_ShadowEditor<T>> createState() => __ShadowEditorState<T>();
}

class __ShadowEditorState<T> extends State<_ShadowEditor<T>> {

  late T shadow;

  Shadow get _shadow => shadow as Shadow;

  late final TextEditingController xController;
  late final TextEditingController yController;
  late final TextEditingController opactiyController;
  late final TextEditingController blurController;
  final TextEditingController spreadController = TextEditingController(text: '0');

  Color color = Colors.black;
  double opacity = 0.3;
  double x = 0;
  double y = 0;
  double blur = 0;
  double spread = 0;

  @override
  void initState() {
    shadow = (widget.shadow as T);
    color = _shadow.color;
    x = _shadow.offset.dx;
    y = _shadow.offset.dy;
    blur = _shadow.blurRadius;
    opacity = _shadow.color.opacity.trimToDecimal(1);
    xController = TextEditingController.fromValue(TextEditingValue(text: x.toString()));
    yController = TextEditingController.fromValue(TextEditingValue(text: y.toString()));
    blurController = TextEditingController.fromValue(TextEditingValue(text: blur.toString()));
    opactiyController = TextEditingController.fromValue(TextEditingValue(text: opacity.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12,),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.start,
        children: [
          _ShadowEditorGroupValueEditor(
            label: 'X',
            textEditingController: xController,
            signed: true,
            onChange: (value) {
              x = value;
              onChange();
            },
          ),
          _ShadowEditorGroupValueEditor(
            label: 'Blur',
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textEditingController: blurController,
            onChange: (value) {
              blur = value;
              onChange();
            },
          ),
          _ShadowEditorGroupValueEditor(
            label: 'Y',
            signed: true,
            textEditingController: yController,
            onChange: (value) {
              y = value;
              onChange();
            },
          ),
          if (shadow.runtimeType != BoxShadow) _ShadowEditorGroupValueEditor(
            label: 'Spread',
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textEditingController: spreadController,
            onChange: (value) {
              spread = value;
              onChange();
            },
          ),
          ... [
            _ShadowEditorGroupValueEditor(
              label: 'Opacity',
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textEditingController: opactiyController,
              onChange: (value) {
                opacity = value;
                onChange();
              },
            ),
            _ShadowEditorGroupWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ColorSelector(
                  title: 'Color',
                  onColorSelect: (color) {
                    this.color = color;
                    onChange();
                  },
                  reverseOrder: true,
                  size: const Size(40, 40),
                  color: color,
                  tooltip: 'Shadow Color',
                ),
              )
            ),
          ].maybeReverse(shadow.runtimeType != BoxShadow)
        ],
      ),
    );
  }

  void onChange() {
    if (shadow.runtimeType == BoxShadow) {
      shadow = BoxShadow(
        color: color.withOpacity(opacity),
        offset: Offset(x, y),
        blurRadius: blur,
        spreadRadius: spread,
      ) as T;
    } else if (shadow.runtimeType == Shadow) {
      shadow = Shadow(
        color: color.withOpacity(opacity),
        offset: Offset(x, y),
        blurRadius: blur,
      ) as T;
    }
    widget.onChange(shadow);
  }

}

class _ShadowEditorGroupWidget extends StatelessWidget {

  const _ShadowEditorGroupWidget({
    Key? key,
    required this.child
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width/2 - 24,
      child: child,
    );
  }
}

class _ShadowEditorGroupValueEditor extends StatelessWidget {

  const _ShadowEditorGroupValueEditor({
    Key? key,
    required this.label,
    required this.onChange,
    this.mainAxisAlignment,
    this.textEditingController,
    this.signed = false
  }) : super(key: key);

  final TextEditingController? textEditingController;
  final MainAxisAlignment? mainAxisAlignment;
  final String label;
  final Function(double value) onChange;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    return _ShadowEditorGroupWidget(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
            ),
          ),
          Spacer(),
          SizedBox.fromSize(
            size: const Size(100, 50),
            child: TextFormField(
              controller: textEditingController,
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,1}'))
              ],
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
                signed: signed
              ),
              onChanged: (value) {
                if (value.isEmpty) return;
                try {
                  double _value = double.parse(value);
                  print(onChange);
                  onChange(_value);
                } catch (e) {
                  onChange(0);
                }
              },
            )
          )
        ],
      ),
    );
  }
}

class _PaletteViewModal extends StatefulWidget {

  _PaletteViewModal({
    Key? key,
    required this.palette,
    required this.onSelected,
    required this.page
  }) : super(key: key);

  final ColorPalette palette;
  final void Function(ColorPalette) onSelected;
  final CreatorPage page;

  @override
  State<_PaletteViewModal> createState() => __PaletteViewModalState();
}

class __PaletteViewModalState extends State<_PaletteViewModal> {

  @override
  void initState() {
    super.initState();
    widget.page.addListener(_onPageChange);
  }

  @override
  void dispose() {
    widget.page.removeListener(_onPageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.palette.refresh();
        widget.onSelected(widget.palette);
        setState(() { });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 70,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (Color color in widget.palette.colors) Flexible(
                      child: AnimatedContainer(
                        duration: Constants.animationDuration,
                        width: 70,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: color,
                            width: 0
                          )
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              AnimatedSwitcher(
                duration: Constants.animationDuration,
                child: widget.page.palette == widget.palette ? Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.page.palette.colors.middle.computeTextColor().withOpacity(0.25)
                        ),
                        child: Icon(
                          CupertinoIcons.shuffle,
                          size: 18,
                          color: widget.page.palette.colors.middle.computeTextColor(),
                        )
                      ),
                    ),
                  )
                ) : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onPageChange() {
    setState(() { });
  }

}

class _PaletteListView extends StatefulWidget {

  _PaletteListView({
    Key? key,
    required this.title,
    required this.palettes,
    required this.onSelected,
    required this.page
  }) : super(key: key);

  final String title;
  final List<ColorPalette> palettes;
  final void Function(ColorPalette) onSelected;
  final CreatorPage page;

  @override
  State<_PaletteListView> createState() => __PaletteListViewState();
}

class __PaletteListViewState extends State<_PaletteListView> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.subtitle1
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SizedBox(
                height: 140,
                child: _PaletteViewModal(
                  palette: widget.palettes[index],
                  onSelected: widget.onSelected,
                  page: widget.page,
                ),
              ),
              itemCount: widget.palettes.length,
              separatorBuilder: (context, index) => SizedBox(width: 9),
            ),
          )
        ],
      ),
    );
  }

}