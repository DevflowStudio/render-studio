import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sprung/sprung.dart';

import '../../rehmat.dart';

class Editor extends StatefulWidget {
  
  const Editor({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final CreatorWidget widget;

  Widget get build => this;

  static bool isHidden = false;

  static Size calculateSize(BuildContext context) {
    double verticalPadding = Constants.of(context).bottomPadding + 10;
    Size editorSize = Size(double.infinity, MediaQuery.of(context).size.height * 0.1); // The editor can only be allowed to cover 10% of the screen area.
    if (editorSize.height > 180) editorSize = Size(editorSize.width, 180);
    else if (editorSize.height < 90) editorSize = Size(editorSize.width, 90);
    return Size(editorSize.width, editorSize.height + verticalPadding);
  }

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> with TickerProviderStateMixin {

  late CreatorWidget creatorWidget;

  late TabController tabController;

  @override
  void initState() {
    creatorWidget = widget.widget;
    creatorWidget.addListener(onPropertyChange, [WidgetChange.update, WidgetChange.lock]);
    tabController = TabController(length: creatorWidget.tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    creatorWidget.removeListener(onPropertyChange, [WidgetChange.update, WidgetChange.lock]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size editorSize = Editor.calculateSize(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Palette.of(context).surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            spreadRadius: 0,
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  TabBar(
                    controller: tabController,
                    enableFeedback: true,
                    padding: EdgeInsets.only(
                      right: 50
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorColor: Constants.getThemedBlackAndWhite(context),
                    labelColor: Constants.getThemedBlackAndWhite(context),
                    indicator: creatorWidget.tabs.length > 1 ? null : const BoxDecoration(),
                    unselectedLabelColor: Constants.getThemedBlackAndWhite(context).withOpacity(0.5),
                    isScrollable: true,
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    tabs: List.generate(
                      creatorWidget.tabs.length,
                      (index) => Tab(
                        text: creatorWidget.tabs[index].tab,
                      )
                    ),
                    onTap: (value) {
                      if (!tabController.indexIsChanging) {
                        setState(() {
                          Editor.isHidden = !Editor.isHidden;
                        });
                      } else {
                        if (Editor.isHidden) setState(() {
                          Editor.isHidden = false;
                        });
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Palette.of(context).surface.withOpacity(1),
                            blurRadius: 10,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (Editor.isHidden) {
                            setState(() {
                              Editor.isHidden = false;
                            });
                          } else {
                            creatorWidget.page.widgets.select();
                          }
                        },
                        icon: Icon(Editor.isHidden ? RenderIcons.arrow_up : RenderIcons.arrow_down),
                      ),
                    ),
                  )
                ],
              ),
              const Divider(
                indent: 0,
                endIndent: 0,
                height: 0,
              ),
              AnimatedSize(
                duration: kAnimationDuration * 2,
                curve: Sprung.underDamped,
                child: Editor.isHidden ? SizedBox.fromSize(
                  size: Size.fromHeight(Constants.of(context).bottomPadding),
                ) : SizedBox.fromSize(
                  size: editorSize,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 12,
                      // bottom: Constants.of(context).bottomPadding,
                    ),
                    child: Center(
                      child: TabBarView(
                        controller: tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          creatorWidget.tabs.length,
                          (index) {
                            return creatorWidget.tabs[index].build(context);
                          }
                        )
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          if (creatorWidget.isLocked) Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                TapFeedback.light();
                creatorWidget.unlock();
              },
              child: Container(
                color: Palette.of(context).background.withOpacity(0.25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9
                      ),
                      decoration: BoxDecoration(
                        color: Palette.of(context).onBackground,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.lock_fill,
                            size: Theme.of(context).textTheme.titleLarge?.fontSize,
                            color: Palette.of(context).background
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Locked',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Palette.of(context).background
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  void onPropertyChange() => setState(() { });

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
  final List<Widget> actions;

  static Future<T?> modal<T>(BuildContext context, {
    required EditorTab Function(BuildContext context, void Function(void Function()) setState) tab,
    double? height,
    Widget Function(BuildContext context, Widget child)? builder,
    List<Widget> actions = const [],
    EdgeInsets? padding
  }) => showModalBottomSheet<T>(
    context: context,
    enableDrag: false,
    isScrollControlled: true,
    barrierColor: Colors.transparent,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        EditorTab _tab = tab(context, setState);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Palette.of(context).surface,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 3
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NewBackButton(
                          size: 20,
                          secondary: true,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            _tab.tab,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(),
                          ),
                        ),
                      ],
                    ),
                    ... actions,
                  ],
                ),
              ),
              if (builder != null) SizedBox(
                height: height,
                child: builder(context, _tab.build(context))
              )
              else Container(
                constraints: BoxConstraints(
                  minHeight: Editor.calculateSize(context).height,
                  maxHeight: MediaQuery.of(context).size.height/2.7,
                ),
                child: Padding(
                  padding: padding ?? EdgeInsets.only(
                    left: 5,
                    right: 5,
                    // top: 20,
                    bottom: Constants.of(context).bottomPadding
                  ),
                  child: SizedBox(
                    height: height,
                    child: _tab.build(context)
                  ),
                ),
              ),
            ],
          )
        );
      }
    ),
  );

  Widget build(BuildContext context) {
    switch (type) {
      case EditorTabType.row:
        return ListView.separated(
          shrinkWrap: true,
          itemCount: options.length,
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) => options[index].build(context),
          separatorBuilder: (context, index) => const SizedBox(width: 6),
          physics: const RangeMaintainingScrollPhysics(),
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
        return StaggeredGrid.count(
          crossAxisCount: 2,
          axisDirection: AxisDirection.down,
          children: List.generate(
            options.length,
            (index) => options[index].build(context)
          ),
        );
      case EditorTabType.hGrid:
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          padding: EdgeInsets.symmetric(horizontal: 6),
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          itemBuilder: (context, index) => options[index].build(context),
        );
    }
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
        min: -90,
        max: 90,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
        snapPoints: [
          -90,
          -45,
          0,
          45,
          90,
        ],
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

    double value = ratio < 1 ? size.height : size.width;
    if (value <= min) value = min;

    return EditorTab(
      type: EditorTabType.single,
      tab: 'Scale',
      options: [
        Option.slider(
          value: value,
          min: min,
          max: max,
          label: 'Scale',
          onChange: (value) {
            onChange(_calculateSize(value: value));
          },
          onChangeEnd: (value) {
            if (onChangeEnd != null) onChangeEnd(_calculateSize(value: value));
          }
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
        showValueEditor: true
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

  static EditorTab adjustTab({
    required CreatorWidget widget,
    bool rotate = true,
    bool scale = true,
    bool opacity = true,
    bool nudge = true,
    bool position = true,
    bool order = true,
  }) => EditorTab(
    tab: 'Adjust',
    options: [
      if (rotate) Option.rotate(
        widget: widget.widgetOrGroup,
      ),
      if (scale && widget.group == null) Option.scale(
        widget: widget,
      ),
      if (opacity) Option.opacity(
        widget: widget,
      ),
      if (nudge) Option.nudge(
        widget: widget.widgetOrGroup,
      ),
      if (position) Option.position(
        widget: widget.widgetOrGroup
      ),
      if (order && widget.page.widgets.nWidgets >= 3) Option.openReorderTab(
        widget: widget.widgetOrGroup,
      )
    ]
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
                onDYchange(-Constants.nudgeSensitivity);
                TapFeedback.light();
              },
              tooltip: 'Move Up',
              icon: RenderIcons.arrow_up,
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonWithIcon(
                  onTap: (context) {
                    onDXchange(-Constants.nudgeSensitivity);
                  },
                  tooltip: 'Move Left',
                  icon: RenderIcons.arrow_left,
                ),
                SizedBox(width: 6),
                ButtonWithIcon(
                  onTap: (context) {
                    onDYchange(Constants.nudgeSensitivity);
                  },
                  tooltip: 'Move Down',
                  icon: RenderIcons.arrow_down,
                ),
                SizedBox(width: 6),
                ButtonWithIcon(
                  onTap: (context) {
                    onDXchange(Constants.nudgeSensitivity);
                  },
                  tooltip: 'Move Right',
                  icon: RenderIcons.arrow_right,
                ),
              ]
            )
          ],
        ),
      )
    ],
    tab: 'Nudge'
  );

  static EditorTab position({
    required CreatorWidget widget
  }) => EditorTab(
    tab: 'Position',
    type: EditorTabType.grid,
    options: [
      for (Map data in [
        {
          'title': 'Top',
          'icon': RenderIcons.align_top,
          'alignment': WidgetAlignment.top
        },
        {
          'title': 'Left',
          'icon': RenderIcons.align_left,
          'alignment': WidgetAlignment.left
        },
        {
          'title': 'Middle',
          'icon': RenderIcons.align_middle,
          'alignment': WidgetAlignment.middle
        },
        {
          'title': 'Center',
          'icon': RenderIcons.align_center,
          'alignment': WidgetAlignment.center
        },
        {
          'title': 'Bottom',
          'icon': RenderIcons.align_bottom,
          'alignment': WidgetAlignment.bottom
        },
        {
          'title': 'Right',
          'icon': RenderIcons.align_right,
          'alignment': WidgetAlignment.right
        },
      ]) Option.custom(
        widget: (context) => ListTile(
          title: Text(data['title']),
          leading: Icon(data['icon']),
          onTap: () {
            widget.alignPositioned(data['alignment']);
          },
        )
      )
    ],
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
  }) {
    return EditorTab(
      type: EditorTabType.single,
      options: [
        Option.custom(
          widget: (context) => _ShadowEditor<T>(
            shadow: shadow,
            onChange: onChange,
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
            crossAxisAlignment: CrossAxisAlignment.end,
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
              if (paletteManager.palettes.isNotEmpty) ... [
                SizedBox(
                  height: 150,
                  child: VerticalDivider(
                    endIndent: 10,
                  ),
                ),
                _PaletteListView(
                  title: 'Saved',
                  palettes: [
                    ... paletteManager.palettes
                  ],
                  onSelected: onSelected,
                  page: page,
                ),
              ],
              for (String collectionName in ColorPalette.collections.keys) ... [
                SizedBox(
                  height: 150,
                  child: VerticalDivider(
                    endIndent: 10,
                  ),
                ),
                _PaletteListView(
                  title: collectionName,
                  palettes: ColorPalette.collections[collectionName]!,
                  onSelected: onSelected,
                  page: page,
                )
              ]
            ],
          ),
        ),
      )
    ]
  );

  static EditorTab color(BuildContext context, {
    ColorPalette? palette,
    required void Function(Color color) onChange,
    bool allowOpacity = true,
    Color? selected
  }) => EditorTab(
    tab: 'Color',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => ColorEditorTab(
          onChange: onChange,
          palette: palette,
          color: selected,
          allowOpacity: allowOpacity,
        ),
      )
    ]
  );

  static EditorTab reorder({
    required CreatorWidget widget,
    required void Function() onReorder,
    required void Function() onReorderEnd,
  }) => EditorTab(
    tab: 'Reorder',
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => _ReorderEditorTab(
          widget: widget,
          onReorder: onReorder,
          onReorderEnd: onReorderEnd,
        )
      )
    ]
  );

}

class _ReorderEditorTab extends StatefulWidget {

  const _ReorderEditorTab({
    required this.widget,
    required this.onReorder,
    required this.onReorderEnd,
  });

  final CreatorWidget widget;
  final void Function() onReorder;
  final void Function() onReorderEnd;
  

  @override
  State<_ReorderEditorTab> createState() => __ReorderEditorTabState();
}

class __ReorderEditorTabState extends State<_ReorderEditorTab> {

  late final CreatorWidget creatorWidget;

  @override
  void initState() {
    creatorWidget = widget.widget;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedIconButtons(
          onPressed: (index > 1) ? () {
            reorderByChange(-1);
          } : null,
          icon: Icon(RenderIcons.arrow_down)
        ),
        Expanded(
          child: SizedBox(
            height: 20,
            child: Slider(
              value: creatorWidget.page.widgets.sortedUIDs.indexOf(creatorWidget.uid).toDouble(),
              min: 1,
              max: creatorWidget.page.widgets.sortedUIDs.length.toDouble() - 1,
              divisions: creatorWidget.page.widgets.sortedUIDs.length - 2,
              onChanged: (value) {
                reorder(value.toInt());
                widget.onReorder();
              },
              onChangeEnd: (value) {
                reorder(value.toInt(), notify: true);
                widget.onReorderEnd();
              },
            ),
          ),
        ),
        OutlinedIconButtons(
          onPressed: (index < creatorWidget.page.widgets.nWidgets - 1) ? () {
            reorderByChange(1);
          } : null,
          icon: Icon(RenderIcons.arrow_up)
        ),
      ],
    );
  }

  void reorder(int value, {bool notify = true}) {
    creatorWidget.page.widgets.reorder(creatorWidget.uid, value.toInt(), log: notify);
    setState(() { });
    creatorWidget.page.updateListeners(PageChange.selection);
  }

  void reorderByChange(int change) {
    reorder(index + change, notify: true);
    widget.onReorderEnd();
    creatorWidget.page.updateListeners(PageChange.selection);
  }

  int get index => creatorWidget.page.widgets.sortedUIDs.indexOf(creatorWidget.uid);

}

enum EditorTabType {
  /// Arrange the options in a list
  row,
  column,
  /// Arrange the options in a grid
  grid,
  /// Arrange the options in a horizontal scrollable grid
  hGrid,
  /// Center align the single widget
  single
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_left_right
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
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
                    ),
                  ],
                ),
                SizedBox(height: 12,),
                Row(
                  children: [
                    Icon(
                      RenderIcons.arrow_up_down
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        value: vertical,
                        label: 'Vertical',
                        min: widget.min ?? 0,
                        max: widget.max ?? 24,
                        onChanged: (value) {
                          if (locked) {
                            horizontal = vertical = value;
                            padding = EdgeInsets.symmetric(vertical: value, horizontal: value);
                          } else {
                            vertical = value;
                            padding = EdgeInsets.symmetric(horizontal: horizontal, vertical: value);
                          }
                          setState(() { });
                          widget.onChange(padding);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          OutlinedIconButtons(
            onPressed: () {
              TapFeedback.light();
              setState(() => locked = !locked);
            },
            icon: Icon(
              locked ? RenderIcons.lock : RenderIcons.unlock,
            ),
          )
        ],
      ),
    );
  }

  Widget iconButton() {
    if (locked) return FilledTonalIconButton(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(RenderIcons.lock)
    );
    else return OutlinedIconButtons(
      onPressed: () => setState(() => locked = !locked),
      icon: Icon(RenderIcons.unlock)
    );
  }
  
}

class _ShadowEditor<T> extends StatefulWidget {

  _ShadowEditor({
    Key? key,
    required this.shadow,
    required this.onChange,
  });

  final Shadow shadow;
  final void Function(T value) onChange;

  @override
  State<_ShadowEditor<T>> createState() => __ShadowEditorState<T>();
}

class __ShadowEditorState<T> extends State<_ShadowEditor<T>> {

  late T shadow;

  Shadow get _shadow => shadow as Shadow;

  late final TextEditingController xController;
  late final TextEditingController yController;
  late final TextEditingController opacityController;
  late final TextEditingController blurController;
  final TextEditingController spreadController = TextEditingController(text: '0');

  Color color = Colors.black;
  double opacity = 0.3;
  double distance = 0;
  double direction = 0;
  double blur = 0;
  double spread = 0;

  @override
  void initState() {
    shadow = (widget.shadow as T);
    color = _shadow.color;
    getDirectionAndDistance();
    blur = _shadow.blurRadius;
    opacity = _shadow.color.opacity.trimToDecimal(1);
    blurController = TextEditingController.fromValue(TextEditingValue(text: blur.toString()));
    opacityController = TextEditingController.fromValue(TextEditingValue(text: opacity.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSlider(
            value: distance,
            min: 0,
            max: 20,
            label: 'Distance',
            actions: [
              Text(
                'Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                ),
              ),
              SizedBox(width: 12),
              ColorSelector(
                title: 'Color',
                onColorSelect: (color) {
                  this.opacity = color.opacity;
                  this.color = color.withOpacity(1);
                  onChange();
                },
                reverseOrder: true,
                size: const Size(30, 30),
                color: color,
                tooltip: 'Shadow Color',
              ),
            ],
            onChange: (value) {
              distance = value;
              onChange();
            },
          ),
          CustomSlider(
            value: direction,
            min: 0.0174533,
            max: 6.28319,
            label: 'Direction',
            onChange: (value) {
              direction = value;
              onChange();
            },
          ),
          SizedBox(height: 12),
          CustomSlider(
            value: blur,
            min: 0,
            max: 20,
            label: 'Blur',
            onChange: (value) {
              blur = value;
              onChange();
            },
          ),
        ],
      ),
    );
  }

  void onChange() {
    if (shadow.runtimeType == BoxShadow) {
      shadow = BoxShadow(
        color: color.withOpacity(opacity),
        offset: getOffset(),
        blurRadius: blur,
        spreadRadius: spread,
      ) as T;
    } else if (shadow.runtimeType == Shadow) {
      shadow = Shadow(
        color: color.withOpacity(opacity),
        offset: getOffset(),
        blurRadius: blur,
      ) as T;
    }
    widget.onChange(shadow);
  }

  Offset getOffset() {
    final double x = distance * cos(direction);
    final double y = distance * sin(direction);
    return Offset(x, y);
  }

  void getDirectionAndDistance() {
    final Offset offset = _shadow.offset;
    distance = sqrt(pow(offset.dx, 2) + pow(offset.dy, 2));
    direction = atan2(offset.dy, offset.dx);
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
              style: Theme.of(context).textTheme.titleMedium
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