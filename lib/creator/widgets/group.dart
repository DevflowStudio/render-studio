import 'package:flutter/material.dart';

import '../../rehmat.dart';
import '../state.dart';

class Group {

  final String id;

  const Group(this.id);

  factory Group.create(String uid) => Group(uid);

  void ungroup(CreatorWidget widget, {
    bool soft = false
  }) {
    try {
      WidgetGroup group = findGroup(widget);
      group.ungroup(widget.uid, soft: soft);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to ungroup widget');
    }
  }

  void delete(CreatorWidget widget, {
    bool soft = false
  }) {
    try {
      WidgetGroup group = findGroup(widget);
      group.delete(soft: soft);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to delete group');
    }
  }

  void deleteWidget(CreatorWidget widget) {
    try {
      WidgetGroup group = findGroup(widget);
      group.deleteWidget(widget.uid);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to delete widget from group');
    }
  }

  WidgetGroup findGroup(CreatorWidget widget) {
    try {
      return widget.page.widgets.widgets.where((widget) => (widget is WidgetGroup && widget._group == this)).first as WidgetGroup;
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'Failed to get group');
      return WidgetGroup(page: widget.page);
    }
  }

  void lock(CreatorWidget widget) {
    WidgetGroup group = findGroup(widget);
    group.lock();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

}

class WidgetGroup extends CreatorWidget {

  WidgetGroup({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create({
    required CreatorPage page,
    List<CreatorWidget>? widgets
  }) async {
    WidgetGroup? group = await _createGroup(page: page, widgets: widgets);
    if (group == null) return;
    page.widgets.add(group);
    page.widgets.select(group.widgets.first);
  }

  static Future<WidgetGroup?> _createGroup({
    required CreatorPage page,
    List<CreatorWidget>? widgets
  }) async {
    // if (page.widgets.nSelections < 2) {
    //   Alerts.snackbar(context, text: 'Select at least 2 widgets to group');
    //   return null;
    // } else if (page.widgets.nSelections > 10) {
    //   Alerts.snackbar(context, text: 'You can only group up to 10 widgets');
    //   return null;
    // }
    try {
      WidgetGroup group = WidgetGroup(page: page);
      group._group = Group.create(group.uid);
      List<CreatorWidget> _widgets = widgets ?? page.widgets.selections;
      // _widgets.removeWhere((element) => element is WidgetGroup);
      if (_widgets.length < 2) {
        return null;
      } else if (_widgets.length > 10) {
        return null;
      }

      for (CreatorWidget widget in _widgets) {
        if (widget.group != null) {
          widget.group!.ungroup(widget, soft: true);
        }
        widget.group = group._group;
        group.widgets.add(widget);
      }

      if (widgets == null) for (CreatorWidget widget in group.widgets) {
        page.widgets.delete(widget.uid, soft: true);
      }

      group.resizeGroup();

      return group;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to group widgets', stacktrace: stacktrace);
      return null;
    }
  }

  void resizeGroup() {
    List<Offset> _offsets = [];
    List<double> dy = [];
    List<double> dx = [];
    for (CreatorWidget widget in widgets) {
      Offset topLeft;
      Offset topRight;
      Offset bottomLeft;
      Offset bottomRight;
      topLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy - widget.size.height/2);
      bottomLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy + widget.size.height/2);
      topRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy - widget.size.height/2);
      bottomRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy + widget.size.height/2);
      _offsets.addAll([topLeft, topRight, bottomLeft, bottomRight]);
    }
    for (Offset offset in _offsets) {
      dy.add(offset.dy);
      dx.add(offset.dx);
    }
    dy.sort();
    double minDY = dy.first;
    double maxDY = dy.last;
    dx.sort();
    double minDX = dx.first;
    double maxDX = dx.last;

    Offset bottomRight = Offset(maxDX, maxDY);
    Offset topLeft = Offset(minDX, minDY);

    double width = bottomRight.dx - topLeft.dx;
    double height = bottomRight.dy - topLeft.dy;

    // if ((width + 20) < project.canvasSize(context).width) width += 20;
    // if ((height + 20) < project.canvasSize(context).height) height += 20;

    Size _size = Size(width, height);

    Offset center = Offset((bottomRight.dx + topLeft.dx)/2, (bottomRight.dy + topLeft.dy)/2);
    
    position = center;
    size = _size;

    for (CreatorWidget widget in widgets) {
      widget.position = Offset(widget.position.dx - center.dx, widget.position.dy - center.dy);
    }

    updateListeners(WidgetChange.misc);
  }

  void ungroup(String uid, {
    bool soft = false,
  }) {
    CreatorWidget widget = widgets.firstWhere((element) => element.uid == uid);
    widget.position = Offset(widget.position.dx + position.dx, widget.position.dy + position.dy);
    widget.group = null;
    widgets.remove(widget);
    page.widgets.add(widget, soft: true);
    if (widgets.length == 1) {
      ungroup(widgets.first.uid, soft: soft);
      return;
    } else if (widgets.length == 0) {
      page.widgets.delete(this.uid, soft: soft);
      return;
    }
    for (CreatorWidget widget in widgets) {
      widget.position = Offset(widget.position.dx + position.dx, widget.position.dy + position.dy);
    }
    resizeGroup();
    if (!soft) {
      page.widgets.select(widget);
      page.history.log('Ungroup Widget');
    }
  }

  void delete({
    bool soft = false
  }) {
    CreatorWidget _selected = page.widgets.selections.first;
    for (CreatorWidget widget in widgets) {
      widget.group = null;
      widget.position = Offset(widget.position.dx + position.dx, widget.position.dy + position.dy);
      page.widgets.add(widget, soft: true);
    }
    page.widgets.delete(uid, soft: soft);
    if (!soft) page.widgets.select(_selected);
  }

  void deleteWidget(String uid) {
    CreatorWidget widget = widgets.firstWhere((element) => element.uid == uid);
    ungroup(uid, soft: true);
    page.widgets.delete(uid, soft: true);
    widget.onDelete();
    page.history.log('Delete Widget');
  }

  // Inherited
  final String name = 'Group Widget';
  @override
  final String id = 'group';

  late final Group _group;

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight
  ];

  @override
  void onResize(Size size) {
    double scale = size.width / this.size.width;
    bool resizeAllowed = true;
    for (CreatorWidget widget in widgets) {
      var scaledSize = Size(widget.size.width * scale, widget.size.height * scale);
      if (!widget.allowResize(scaledSize)) {
        minSize = size;
        resizeAllowed = false;
        return;
      }
    }
    if (resizeAllowed) for (CreatorWidget widget in widgets) {
      widget.size = Size(widget.size.width * scale, widget.size.height * scale);
      widget.position = Offset(widget.position.dx * scale, widget.position.dy * scale);
    }
    super.onResize(size);
  }

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          icon: RenderIcons.delete,
          title: 'Ungroup',
          tooltip: 'Ungroup all the widgets',
          onTap: (context) async {
            
          },
        ),
        ... defaultOptions
      ],
      tab: 'Group',
    )
  ];

  List<CreatorWidget> widgets = [];

  @override
  bool isSelected() {
    return (page.widgets.selections.toSet().intersection(widgets.toSet()).isNotEmpty && page.widgets.nSelections == 1);
  }

  @override
  bool isOnlySelected() {
    return (page.widgets.selections.toSet().intersection(widgets.toSet()).isNotEmpty && page.widgets.nSelections == 1);
  }

  @override
  bool scale(double scale) {
    for (CreatorWidget widget in widgets) {
      if (!widget.scale(scale)) return false;
    }
    return super.scale(scale);
  }

  @override
  bool get isLocked => widgets.any((element) => element.isLocked);

  void lock() {
    for (CreatorWidget widget in widgets) {
      if (!widget.isLocked) widget.lock();
      widget.updateListeners(WidgetChange.lock);
    }
  }

  void unlock() {
    for (CreatorWidget widget in widgets) {
      if (widget.isLocked) widget.unlock();
      widget.updateListeners(WidgetChange.lock);
    }
  }

  @override
  Widget widget(BuildContext context) => Stack(
    children: [
      ... List.generate(
        widgets.length,
        (index) => WidgetState(
          key: UniqueKey(),
          controller: widgets[index].stateCtrl,
          widget: widgets[index],
          page: page,
        )
      ),
    ],
  );

  @override
  void onPaletteUpdate() {
    widgets.forEach((widget) {
      widget.onPaletteUpdate();
    });
    super.onPaletteUpdate();
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'widgets': widgets.map((e) => e.toJSON(buildInfo: buildInfo)).toList(),
    '_group': _group.id,
  };

  @override
  void buildFromJSON(Map<String, dynamic> data, {required BuildInfo buildInfo}) {
    super.buildFromJSON(data, buildInfo: buildInfo);
    try {
      _group = Group(data['_group']);
      for (Map widgetData in data['widgets']) {
        CreatorWidget widget = CreatorWidget.fromJSON(widgetData, buildInfo: buildInfo, page: page);
        widgets.add(widget);
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
    }
  }

  @override
  void updateGrids({
    bool realtime = false,
    bool showGridLines = false,
    bool createGrids = true,
    bool snap = true,
    double? snapSensitivity,
    Offset? position
  }) {
    super.updateGrids(
      createGrids: false,
      showGridLines: showGridLines,
      snap: snap,
      snapSensitivity: snapSensitivity,
      position: position,
      realtime: realtime
    );
    if (!realtime) for (CreatorWidget widget in widgets) widget.updateGrids(
      createGrids: true,
      snap: false,
      showGridLines: false,
      realtime: realtime,
      position: Offset(this.position.dx + widget.position.dx, this.position.dy + widget.position.dy)
    );
  }

  @override
  void onDelete() { }
  
  @override
  Future<CreatorWidget?> duplicate() async {
    List<CreatorWidget> dWidgets = [];
    for (CreatorWidget widget in widgets) {
      Map data = widget.toJSON();
      data['uid'] = Constants.generateID();
      data['group'] = null;
      dWidgets.tryAdd(CreatorWidget.fromJSON(data, page: page, buildInfo: BuildInfo(buildType: BuildType.unknown)));
    }
    WidgetGroup? group = await WidgetGroup._createGroup(page: page, widgets: dWidgets);
    return group;
  }

}