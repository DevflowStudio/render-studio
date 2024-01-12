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
    page.widgets.add(group, soft: true);
    page.history.log('Group Widgets');
    page.widgets.select(group.widgets.first);
  }

  static Future<WidgetGroup?> _createGroup({
    required CreatorPage page,
    List<CreatorWidget>? widgets
  }) async {
    try {
      WidgetGroup group = WidgetGroup(page: page);
      group._group = Group.create(group.uid);
      
      List<CreatorWidget> _widgets = widgets ?? page.widgets.selections;

      // Sorts the widgets in the local widget list by their z index order in the page.
      _widgets.sort((a, b) => page.widgets.sortedUIDs.indexOf(a.uid).compareTo(page.widgets.sortedUIDs.indexOf(b.uid)));
      
      // Do not allow grouping of groups if selected number is less than 2 or more than 10.
      if (_widgets.length < 2) {
        return null;
      } else if (_widgets.length > 10) {
        return null;
      }

      for (CreatorWidget widget in _widgets) {
        // Remove the widget from it's current group if it is already in one.
        if (widget.group != null) {
          widget.group!.ungroup(widget, soft: true);
        }
        widget.group = group._group;
        widget.verticalExpandDirection = VerticalExpandDirection.both;
        group.widgets.add(widget);
      }

      if (widgets == null) for (CreatorWidget widget in group.widgets) {
        page.widgets.delete(widget.uid, soft: true);
      }

      group._sizeGroup();

      return group;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to group widgets', stacktrace: stacktrace);
      return null;
    }
  }

  Map<String, List<CreatorWidget>> getRelativeWidgets(CreatorWidget widget, {
    required List<CreatorWidget> widgets,
    Offset? position,
    Size? size,
  }) {
    List<CreatorWidget> overlaps = [];
    List<CreatorWidget> above = [];
    List<CreatorWidget> below = [];
    List<CreatorWidget> left = [];
    List<CreatorWidget> right = [];

    Offset widget_position = position ?? widget.position;
    Size widget_size = size ?? widget.size;

    for (CreatorWidget _widget in widgets) {
      if (widget == _widget) continue;

      Offset center1 = this.position + widget_position;
      Rect widget1Area = Rect.fromCenter(
        center: center1,
        width: widget_size.width,
        height: widget_size.height,
      );

      Offset center2 = this.position + _widget.position;
      Rect widget2Area = Rect.fromCenter(
        center: center2,
        width: _widget.size.width,
        height: _widget.size.height,
      );

      if (widget1Area.overlaps(widget2Area)) {
        overlaps.add(_widget);
        continue;
      }
      
      Rect area1 = Rect.fromCenter(center: Offset(0, widget1Area.center.dy), width: double.infinity, height: widget1Area.height);
      Rect area2 = Rect.fromCenter(center: Offset(0, widget2Area.center.dy), width: double.infinity, height: widget2Area.height);
      bool isInSameRow = area1.overlaps(area2) || area2.overlaps(area1);

      if (isInSameRow) {
        if (_widget.position.dx < widget_position.dx) {
          left.add(_widget);
        } else {
          right.add(_widget);
        }
      } else {
        if (_widget.position.dy < widget_position.dy) {
          above.add(_widget);
        } else {
          below.add(_widget);
        }
      }
    }

    return {
      'overlaps': overlaps,
      'above': above,
      'below': below,
      'left': left,
      'right': right,
    };
  }

  void _sizeGroup() {
    Map result = _getGroupSizeFromWidgets();
    
    position = result['center'];
    size = result['size'];

    CreatorWidget topmostWidget = result['topmost'];
    CreatorWidget bottommostWidget = result['bottommost'];

    topmostWidget.verticalExpandDirection = VerticalExpandDirection.down;
    bottommostWidget.verticalExpandDirection = VerticalExpandDirection.up;

    for (CreatorWidget widget in widgets) {
      widget.position = Offset(widget.position.dx - position.dx, widget.position.dy - position.dy);
      if (widget == topmostWidget) continue;
      else if (widget == bottommostWidget) continue;
      else {
        widget.verticalExpandDirection = VerticalExpandDirection.both;
      }
    }

    updateListeners(WidgetChange.misc);
  }

  Map<String, dynamic> _getGroupSizeFromWidgets() {
    double minDY = double.infinity;
    double maxDY = double.negativeInfinity;
    double minDX = double.infinity;
    double maxDX = double.negativeInfinity;

    CreatorWidget topmostWidget = widgets.first;
    CreatorWidget bottommostWidget = widgets.first;

    for (CreatorWidget widget in widgets) {
      Offset topLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy - widget.size.height/2);
      Offset bottomLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy + widget.size.height/2);
      Offset topRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy - widget.size.height/2);
      Offset bottomRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy + widget.size.height/2);
      for (Offset offset in [topLeft, topRight, bottomLeft, bottomRight]) {
        if (offset.dy < minDY) {
          minDY = offset.dy;
          topmostWidget = widget;
        }
        if (offset.dy > maxDY) {
          maxDY = offset.dy;
          bottommostWidget = widget;
        }
        if (offset.dx < minDX) minDX = offset.dx;
        if (offset.dx > maxDX) maxDX = offset.dx;
      }
    }

    Offset bottomRight = Offset(maxDX, maxDY);
    Offset topLeft = Offset(minDX, minDY);

    double width = bottomRight.dx - topLeft.dx;
    double height = bottomRight.dy - topLeft.dy;

    Size _size = Size(width, height);
    Offset center = Offset((bottomRight.dx + topLeft.dx)/2, (bottomRight.dy + topLeft.dy)/2);

    return {
      'size': _size,
      'center': center,
      'topmost': topmostWidget,
      'bottommost': bottommostWidget,
    };
  }

  void onElementResize(CreatorWidget widget, {
    required Size prevSize,
    required Offset prevPosition,
  }) {
    Size currSize = widget.size;

    if (!widgets.contains(widget)) return;
    if (prevSize == currSize) return;

    Map<String, List<CreatorWidget>> relativeWidgets;
    List<CreatorWidget> overlaps;
    List<CreatorWidget> above;
    List<CreatorWidget> below;
    List<CreatorWidget> left;
    List<CreatorWidget> right;

    try {
      relativeWidgets = getRelativeWidgets(widget, widgets: widgets, position: prevPosition, size: prevSize);
      overlaps = relativeWidgets['overlaps']!;
      above = relativeWidgets['above']!;
      below = relativeWidgets['below']!;
      left = relativeWidgets['left']!;
      right = relativeWidgets['right']!;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to get relative widgets', stacktrace: stacktrace);
      return;
    }

    // double changeInWidth = newSize.width - oldSize.width;
    double changeInHeight = currSize.height - prevSize.height;

    Size _previousSize = size;
    size = Size(size.width, size.height + changeInHeight);

    double belowHeightDistribution = changeInHeight / 2;
    double aboveHeightDistribution = changeInHeight / 2;

    if (above.isEmpty) belowHeightDistribution = changeInHeight;
    if (below.isEmpty) aboveHeightDistribution = changeInHeight;

    for (CreatorWidget widget in above) {
      widget.position = Offset(widget.position.dx, widget.position.dy - aboveHeightDistribution);
    }

    for (CreatorWidget widget in below) {
      widget.position = Offset(widget.position.dx, widget.position.dy + belowHeightDistribution);
    }

    resizeBoundaries(previousSize: _previousSize);
  }

  void resizeBoundaries({Size? previousSize}) {
    double minDY = 0;
    double maxDY = 0;
    double minDX = 0;
    double maxDX = 0;
    for (CreatorWidget widget in widgets) {
      Offset topLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy - widget.size.height/2);
      Offset bottomLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy + widget.size.height/2);
      Offset topRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy - widget.size.height/2);
      Offset bottomRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy + widget.size.height/2);
      for (Offset offset in [topLeft, topRight, bottomLeft, bottomRight]) {
        if (offset.dy < minDY) minDY = offset.dy;
        if (offset.dy > maxDY) maxDY = offset.dy;
        if (offset.dx < minDX) minDX = offset.dx;
        if (offset.dx > maxDX) maxDX = offset.dx;
      }
    }

    Offset bottomRight = Offset(maxDX, maxDY);
    Offset topLeft = Offset(minDX, minDY);

    Size _newSize = Size(bottomRight.dx - topLeft.dx, bottomRight.dy - topLeft.dy);

    size = _newSize;

    double individualWidgetWidthChange = maxDX - (size.width/2);
    double individualWidgetHeightChange = maxDY - (size.height/2);

    for (CreatorWidget widget in widgets) {
      widget.position = Offset(widget.position.dx - individualWidgetWidthChange, widget.position.dy - individualWidgetHeightChange);
    }

    if (previousSize != null) position = CreatorWidget.autoPosition(position: position, newSize: _newSize, prevSize: previousSize, horizontalExpandDirection: horizontalExpandDirection, verticalExpandDirection: verticalExpandDirection);
    else position = Offset(position.dx + individualWidgetWidthChange, position.dy + individualWidgetHeightChange);

    updateListeners(WidgetChange.misc);
  }

  void ungroup(String uid, {
    bool soft = false,
  }) {
    if (widgets.length == 2) {
      delete(soft: soft);
      return;
    }
    CreatorWidget widget = widgets.firstWhere((element) => element.uid == uid);
    widget.position = Offset(widget.position.dx + position.dx, widget.position.dy + position.dy);
    widget.group = null;
    widgets.remove(widget);
    page.widgets.add(widget, soft: true);
    page.widgets.selectWithUID(widget.uid);
    resizeBoundaries();
    if (!soft) {
      page.history.log('Ungroup Widget');
      page.widgets.selectWithUID(widget.uid);
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
    page.widgets.delete(uid, soft: true);
    if (!soft) {
      page.widgets.select(_selected);
      page.history.log('Ungroup Widgets');
    }
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
  void onResize(Size size, {ResizeHandler? type, bool isScaling = false}) {
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
    super.onResize(size, type: type);
  }

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          icon: RenderIcons.delete,
          title: 'Ungroup',
          tooltip: 'Ungroup all the widgets',
          onTap: (context) async { },
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
    updateListeners(WidgetChange.lock);
  }

  void unlock() {
    for (CreatorWidget widget in widgets) {
      if (widget.isLocked) widget.unlock();
      widget.updateListeners(WidgetChange.lock);
    }
    updateListeners(WidgetChange.lock);
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
  }) {
    // Size universalSize = page.project.sizeTranslator.getUniversalSize(widget: this);
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'widgets': widgets.map((e) => e.toJSON(buildInfo: buildInfo)).toList(),
      '_group': _group.id,
    };
  }

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
    group?.position = Offset(position.dx + 10, position.dy + 10);
    return group;
  }

}