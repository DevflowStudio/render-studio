import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:supercharged/supercharged.dart';
import '../../rehmat.dart';
import 'dart:math' as math;

abstract class CreatorWidget extends PropertyChangeNotifier<WidgetChange> {

  @override
  bool operator == (Object other) {
    if (other is CreatorWidget && other.uid == uid) return true;
    return false;
  }

  @override
  int get hashCode => super.hashCode;

  CreatorWidget(this.page, {
    Map? data,
    BuildInfo buildInfo = BuildInfo.unknown,
  }) {
    uid = Constants.generateID(6);
    _defaultResizeHandlerSet = _resizeHandlers = resizeHandlers;
    stateCtrl = WidgetStateController(this);
    onInitialize();
    onPaletteUpdate();
    editor = Editor(
      key: ValueKey(uid),
      widget: this
    );
    if (data != null) try {
      uid = data['uid'];
      buildFromJSON(Map.from(data), buildInfo: buildInfo);
      updateResizeHandlers();
      updateGrids();
      stateCtrl.update();
    } on WidgetCreationException catch (e) {
      analytics.logError(e, cause: 'could not build widget from JSON');
      throw WidgetCreationException(
        'The widget could not be rebuilt due to some issues',
        details: 'Failed to build widget from JSON: $e',
      );
    }
    updateResizeHandlers();
  }

  late WidgetStateController stateCtrl;

  late String uid;

  final CreatorPage page;

  /// Bottom Navigation Bar with editing options
  late Editor editor;

  Asset? asset;

  /// Tabs with editing options
  List<EditorTab> get tabs => [ ];

  List<Option> get defaultOptions => [
    if (group != null) Option.button(
      icon: RenderIcons.ungroup,
      title: 'Ungroup',
      tooltip: 'Remove this widget from the group',
      onTap: (context) {
        group!.ungroup(this);
      },
    ),
    if (group != null) Option.button(
      icon: RenderIcons.deleteGroup,
      title: 'Ungroup All',
      tooltip: 'Tap to ungroup all the widgets',
      onTap: (context) {
        group!.delete(this);
      },
    ),
    if (allowClipboard) Option.button(
      icon: RenderIcons.duplicate,
      title: 'Duplicate',
      tooltip: 'Duplicate this widget',
      onTap: (context) {
        Spinner.fullscreen(
          context,
          task: () async {
            page.widgets.add(await duplicate());
          },
        );
      },
    ),
    Option.button(
      icon: RenderIcons.delete,
      title: 'Delete',
      tooltip: 'Delete Text Widget',
      onTap: (context) async {
        if (group != null) group!.deleteWidget(this);
        else page.widgets.delete(this.uid);
      },
    ),
  ];

  /// Name of the widget
  final String name = 'Widget';

  /// ID of the widget
  /// Must be in lowercase letters
  final String id = 'widget';

  final bool allowClipboard = true;

  bool _firstBuildDone = false;

  void doFirstBuild() {
    // First build function is run once the rendering is over
    // Only once for the widget lifecycle
    _firstBuildDone = true;
    onFirstBuild();
  }

  void onFirstBuild() {}

  void onInitialize() {}

  /// ### Rotate


  /// Rotation angle of the widget
  double angle = 0;


  /// ### Resize
  
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  late List<ResizeHandler> _resizeHandlers;
  /// List of resize handlers available;
  late List<ResizeHandler> _defaultResizeHandlerSet;
  bool isResizing = false;

  Size size = const Size(0, 0);
  Size? minSize;

  /// Setting this to `true` will allow
  /// resizing but only in the fixed aspect ratio
  final bool keepAspectRatio = false;

  /// Set to `false` if you want the widget
  /// to not be resizable.
  /// Defaults to `true`
  final bool isResizable = true;
  
  bool locked = false;

  /// Set to `true` for widgets like background
  /// to make sure that effects like border are not applied
  final bool isBackgroundWidget = false;

  void onResizeStart({
    required DragStartDetails details,
    required ResizeHandler handler
  }) {
    isResizing = true;
    // _resizeHandlers = [handler];
  }

  void onResize(Size size) {
    this.size = size;
    updateListeners(WidgetChange.resize);
  }

  /// This method is called when the resizing of the widget is finished
  void onResizeFinished(DragEndDetails details, ResizeHandler type, {
    bool updateNotify = true
  }) {
    isResizing = false;
    updateResizeHandlers();
    updateListeners(WidgetChange.update);
  }

  /// Use this method to resize the widget using scale factor
  /// 
  /// For example, to resize the widget by 10%,
  /// use `scale(1.1)`
  bool scale(double scale) {
    Size _size = Size(size.width * scale, size.height * scale);
    if (allowResize(_size)) {
      size = _size;
      return true;
    } else return false;
  }

  void updateResizeHandlers() {
    _resizeHandlers = resizeHandlers = _getResizeHandlersWRTSize();
    updateListeners(WidgetChange.misc);
  }

  List<ResizeHandler> _getResizeHandlersWRTSize() {
    List<ResizeHandler> __handlers = [];
    if (size.height.isBetween(0, 50)) {
      __handlers = [
        ResizeHandler.bottomRight
      ];
    } else if (size.height.isBetween(50, 95)) {
      __handlers = List.from(_defaultResizeHandlerSet.where((handler) => handler.type == ResizeHandlerType.corner));
    } else {
      __handlers = List.from(_defaultResizeHandlerSet);
    }
    return __handlers;
  }

  bool allowResize(Size _size) {
    if (_size.width < (minSize?.width ?? 10)) return false;
    if (_size.height < (minSize?.height ?? 10)) return false;
    if (_size.width > ((page.project.deviceSize.width * 1.4) - 40)) return false;
    if (_size.height > ((page.project.deviceSize.height * 1.4) - 40)) return false;
    return true;
  }


  /// ### Drag

  Offset position = const Offset(0, 0);

  Rect get area => position.translate(-size.width/2, -size.height/2) & size;

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// 
  /// Defaults to `true`
  final bool isDraggable = true;

  List<WidgetAlignment> get alignment => WidgetAlignmentExtension.fromPosition(this);

  void alignPositioned(WidgetAlignment alignment) {
    if (this.alignment.contains(alignment)) return;
    position = alignment.getPosition(this);
    updateListeners(WidgetChange.update);
  }

  void updatePosition(DragUpdateDetails details) {
    if (!isDraggable) return;
    position = position + details.delta;
    bool snap = details.delta.dx.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity);
    if (angle == 0) updateGrids(realtime: true, showGridLines: true, snap: snap);
    updateListeners(WidgetChange.drag);
  }

  void _onGestureUpdate(DragUpdateDetails details, BuildContext context) {
    if (isDraggable) updatePosition(details);
    updateListeners(WidgetChange.misc);
  }

  void _onGestureEnd(DragEndDetails details, BuildContext context) {
    if (!page.widgets.multiselect && this is! WidgetGroup) page.widgets.select(this);
    onDragFinish(context);
  }

  void onGestureStart() { }

  void onDragFinish(BuildContext context) {
    // Update the listener to `update` changes. This will tell the parent to reload state and save the change in history
    updateGrids(showGridLines: true, snap: true, snapSensitivity: 2);
    double dx = position.dx;
    double dy = position.dy;
    double minDX = -(page.project.contentSize.width/2) - size.width/4;
    double minDY = -(page.project.contentSize.height/2) - size.height/4;
    double maxDX = page.project.contentSize.width/2 + size.width/4;
    double maxDY = page.project.contentSize.height/2 + size.height/4;
    if (dx < minDX) dx = minDX;
    if (dy < minDY) dy = minDY;
    if (dx > maxDX) dx = maxDX;
    if (dy > maxDY) dy = maxDY;
    // Prevent the widget from going out of the safe area
    position = Offset(dx, dy);
    updateListeners(WidgetChange.update, removeGrids: true);
  }

  void onDoubleTap(BuildContext context) {}

  Group? group;

  /// Finds the group of the widget if it is a part of a group, else returns the widget itself
  /// 
  /// Use cases:
  /// - When building adjust editor tabs for the widget.
  /// You would not want to nudge the widget within the group, so returns the parent group to nudge
  CreatorWidget get widgetOrGroup {
    try {
      if (group != null) return group!.findGroup(this);
    } catch (e, stacktrace) {
      analytics.logError(e, stacktrace: stacktrace, cause: 'error finding group of widget');
    }
    return this;
  }

  bool isSelected() => page.widgets.isSelected(widget: this);

  bool isOnlySelected() => page.widgets.isSelected(widget: this) && page.widgets.selections.length == 1 && group == null;

  /// ###

  double opacity = 1.0;

  /// ###

  /// Build function of the widget
  /// All of the resizing, drag, tap and double tap related code is written here
  /// @override this method to disable drag, resizing, tapping and others
  Widget build(BuildContext context, {
    bool isInteractive = true,
  }) {
    if (!_firstBuildDone) doFirstBuild();
    bool _isSelected = isSelected();
    bool _isOnlySelected = isInteractive && isOnlySelected();
    bool _allowDrag = isInteractive && isDraggable && group == null;
    return GestureDetector(
      key: ValueKey<String>(uid),
      behavior: _isOnlySelected ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
      onPanStart: _allowDrag ? (details) => onGestureStart() : null,
      onPanUpdate: _allowDrag ? (details) => _onGestureUpdate(details, context) : null,
      onPanEnd: _allowDrag ? (details) => _onGestureEnd(details, context) : null,
      dragStartBehavior: DragStartBehavior.down,
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          AlignPositioned(
            dx: position.dx,
            dy: position.dy,
            childHeight: size.height + 40,
            childWidth: size.width + 40,
            child: rotatedWidget(
              child: GestureDetector(
                onDoubleTap: _isSelected ? () => onDoubleTap(context) : null,
                onTap: () => _isSelected ? null : page.widgets.select(this),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    // borderType: BorderType.RRect,
                    // color: Colors.grey[400]!,
                    // strokeWidth: 2,
                    // dashPattern: [3, 0, 3],
                    // radius: Radius.circular(5),
                    // padding: EdgeInsets.zero,
                    decoration: _isSelected ? BoxDecoration(
                      border: Border.all(
                        color: page.palette.background.computeThemedTextColor(180),
                        width: 0
                      ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     blurStyle: BlurStyle.outer,
                      //     color: Colors.black.withOpacity(0.25),
                      //     blurRadius: 10,
                      //     spreadRadius: 0,
                      //     offset: Offset(0, 0),
                      //   ),
                      // ],
                    ) : null,
                    child: SizedBox.fromSize(
                      size: size,
                      child: Opacity(
                        opacity: opacity,
                        child: widget(context)
                      )
                    )
                  ),
                )
              ),
            ),
          ),
      
          if (resizeHandlers.length == 1 && isDraggable && _isOnlySelected) Builder(
            builder: (_) {
              double dy = position.dy;
              double dx = position.dx;
              double positionY = dy + size.height + 15;
              double positionX = dx;
      
              if ((positionY + 15) > page.project.contentSize.height/2) {
                positionY = dy - size.height - 15;
              }
      
              return AlignPositioned(
                dy: positionY,
                dx: positionX,
                child: DragHandler(
                  onPositionUpdate: (details) => _onGestureUpdate(details, context),
                  onPositionUpdateEnd: (details) => _onGestureEnd(details, context),
                  backgroundColor: page.palette.background.computeThemedTextColor(180),
                  iconColor: page.palette.background,
                ),
              );
            }
          ),
        
          if (isResizable && !locked && _isOnlySelected) AlignPositioned(
            dx: position.dx,
            dy: position.dy,
            childHeight: size.height + 40,
            childWidth: size.width + 40,
            // rotateDegrees: angle,
            child: SizedBox(
              width: size.width + 40,
              height: size.height + 40,
              child: rotatedWidget(
                child: Stack(
                  children: [
                    for (ResizeHandler handler in resizeHandlers) ResizeHandlerBall(
                      type: handler,
                      widget: this,
                      onSizeChange: onResize,
                      onResizeEnd: onResizeFinished,
                      isResizing: isResizing,
                      onResizeStart: (details) => onResizeStart(details: details, handler: handler),
                      isVisible: _resizeHandlers.contains(handler),
                      updatePosition: angle == 0,
                    ),
                  ],
                ),
              ),
            ),
          )
      
        ],
      ),
    );
  }

  Widget rotatedWidget({required Widget child}) => Transform.rotate(
    angle: angle * math.pi / 180,
    child: child
  );

  /// This is the main widget of the widget
  Widget widget(BuildContext context) {
    return Container();
  }

  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false
  }) {
    updateGrids();
    if (removeGrids) page.gridState.visible.clear();
    if (change == WidgetChange.update) notifyListeners(change);
    stateCtrl.update(change);
    if (change == WidgetChange.update && asset != null) {
      asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
    }
  }

  /// Update all the grids present in the page for the current widget
  void updateGrids({
    bool realtime = false,
    bool showGridLines = false,
    /// Settings this to false will only match the widget to the grid, but not create new ones
    bool createGrids = true,
    /// Snap the widget to the grid
    /// 
    /// Both `this.snap` and `preferences.snap` are required to be true for the widget to snap
    bool snap = true,
    double? snapSensitivity,
    Offset? position
  }) {

    Offset _position = position ?? this.position;

    double dx = _position.dx;
    double dy = _position.dy;

    List<Grid> _newVisibleGrids = [];
    List<Grid> _newGrids = [];
    List<GridWidgetPlacement> _toRemoveVisibleGrids = [];

    page.gridState.grids.removeWhere((grid) {
      if (this is WidgetGroup) {
        return (grid.widget == this || ((this as WidgetGroup).widgets.contains(grid.widget)));
      } else return (grid.widget == this);
    });

    double _snapSensitivity = snapSensitivity ?? preferences.snapSensitivity;

    List<Grid> centerHorizontalGrids = page.gridState.grids.where((grid) => ((grid.position.dy - _position.dy).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal)).toList();
    List<Grid> centerVerticalGrids = page.gridState.grids.where((grid) => ((grid.position.dx - _position.dx).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical)).toList();
    List<Grid> topGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (_position.dy - size.height / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.top)).toList();
    List<Grid> leftGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (_position.dx - size.width / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.left)).toList();
    List<Grid> rightGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (_position.dx + size.width / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.right)).toList();
    List<Grid> bottomGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (_position.dy + size.height / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.bottom)).toList();

    if (centerHorizontalGrids.isNotEmpty) {
      Offset newPosition = centerHorizontalGrids.first.position;
      dy = newPosition.dy;
      if (!page.gridState.visible.contains(centerHorizontalGrids.first)) _newVisibleGrids.add(centerHorizontalGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(0, _position.dy),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.centerHorizontal);
    }

    if (centerVerticalGrids.isNotEmpty) {
      Offset newPosition = centerVerticalGrids.first.position;
      dx = newPosition.dx;
      if (!page.gridState.visible.contains(centerVerticalGrids.first)) _newVisibleGrids.add(centerVerticalGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(_position.dx, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.centerVertical
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.centerVertical);
    }

    if (topGrids.isNotEmpty) {
      Offset newPosition = topGrids.first.position;
      dy = newPosition.dy + size.height / 2;
      if (!page.gridState.visible.contains(topGrids.first)) _newVisibleGrids.add(topGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(0, _position.dy - size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.top
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.top);
    }

    if (leftGrids.isNotEmpty) {
      Offset newPosition = leftGrids.first.position;
      dx = newPosition.dx + size.width / 2;
      if (!page.gridState.visible.contains(leftGrids.first)) _newVisibleGrids.add(leftGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(_position.dx - size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.left
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.left);
    }

    if (rightGrids.isNotEmpty) {
      Offset newPosition = rightGrids.first.position;
      dx = newPosition.dx - size.width / 2;
      if (!page.gridState.visible.contains(rightGrids.first)) _newVisibleGrids.add(rightGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(_position.dx + size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.right
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.right);
    }

    if (bottomGrids.isNotEmpty) {
      Offset newPosition = bottomGrids.first.position;
      dy = newPosition.dy - size.height / 2;
      if (!page.gridState.visible.contains(bottomGrids.first)) _newVisibleGrids.add(bottomGrids.first);
    } else {
      _newGrids.add(
        Grid(
          position: Offset(0, _position.dy + size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.bottom
        )
      );
      _toRemoveVisibleGrids.add(GridWidgetPlacement.bottom);
    }

    if (createGrids) page.gridState.grids.addAll(_newGrids);

    if (showGridLines) {
      page.gridState.visible.removeWhere((grid) => _toRemoveVisibleGrids.contains(grid.gridWidgetPlacement));
      if (preferences.snap && snap) this.position = Offset(dx, dy);
      if (preferences.snap && snap && preferences.vibrateOnSnap && _newVisibleGrids.isNotEmpty) TapFeedback.light();
      page.gridState.visible.addAll(_newVisibleGrids);
      page.gridState.notifyListeners();
    }

  }

  /// This method is called when the palette is updated for the parent page
  /// 
  /// Here, write the code to update colors used within the widget
  void onPaletteUpdate() { }

  /// This method is called when the widget is deleted
  /// 
  /// It should be used to clean up any resources that the widget is using
  void onDelete() {
  }

  /// Called when the widget is disposed from the tree
  /// Use this function to dispose of any resources that the widget is using
  /// 
  /// Usage:
  /// 
  /// ```dart
  /// @override
  /// void dispose() {
  ///  super.dispose();
  ///   // Dispose of any resources here
  ///   controller.dispose();
  /// }
  /// ```
  void dispose() {
    super.dispose();
  }

  /// Duplicate Widget
  /// 
  /// Returns the widget with same properties but new uid and altered position
  Future<CreatorWidget> duplicate() async {
    CreatorWidget widget = CreatorWidget.fromJSON(toJSON(), page: page, buildInfo: BuildInfo(buildType: BuildType.unknown));
    widget.uid = Constants.generateID();
    widget.position = Offset(position.dx + 10, position.dy + 10);
    await widget.onDuplicate();
    return widget;
  }

  /// This method is called when a widget is duplicated from another
  /// Handle asset duplication here
  Future<void> onDuplicate() async {}

  /// Convert the state and properties of the widget to JSON
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    if (buildInfo.version != null && asset != null) {
      asset!.logVersion(version: buildInfo.version!, file: asset!.file);
    }
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'asset': asset?.id,
      'group': group?.id,
      'properties': {
        'position': {
          'dx': position.dx,
          'dy': position.dy
        },
        'angle': angle,
        'opacity': opacity,
        'size': {
          'width': size.width,
          'height': size.height
        }
      }
    };
  }

  /// Create the widget from JSON
  /// 
  /// This method automatically detects the type of widget and returns the appropriate widget
  static CreatorWidget fromJSON(dynamic data, {
    required CreatorPage page,
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    data = Map.from(data);
    CreatorWidget? widget;
    switch (data['id']) {
      case 'background':
        widget = BackgroundWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'text':
        widget = CreatorText(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'design_asset':
        widget = CreatorDesignAsset(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'qr_code':
        widget = QRWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'image':
        widget = ImageWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'box':
        widget = CreatorBoxWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'shape':
        widget = ShapeWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'group':
        widget = WidgetGroup(page: page, data: data, buildInfo: buildInfo);
        break;
      default:
        throw WidgetCreationException('Failed to build widget ${data['name']}');
    }
    return widget;
  }

  /// Create new widget by ID
  static Future<void> create(BuildContext context, {
    required CreatorPage page,
    /// ID of the widget to create
    required String id
  }) async {
    switch (id) {
      case 'text':
        CreatorText.create(context, page: page);
        break;
      case 'design_asset':
        CreatorDesignAsset.create(context, page: page);
        break;
      case 'qr_code':
        QRWidget.create(context, page: page);
        break;
      case 'image':
        ImageWidget.create(context, page: page);
        break;
      case 'box':
        CreatorBoxWidget.create(context, page: page);
        break;
      case 'shape':
        ShapeWidget.create(context, page: page);
        break;
      default:
        break;
    }
  }

  void buildFromJSON(Map<String, dynamic> data, {
    required BuildInfo buildInfo
  }) {
    position = Offset(data['properties']['position']['dx'], data['properties']['position']['dy']);
    angle = data['properties']['angle'];
    opacity = data['properties']['opacity'];
    size = Size(data['properties']['size']['width'], data['properties']['size']['height']);
    if (data['group'] != null) group = Group(data['group']);
    if (data['asset'] != null) asset = page.project.assetManager.get(data['asset']);
    if (asset?.history.isEmpty ?? false) {
      asset!.history[page.history.dates.first.version ?? ''] = asset!.file;
    }
    if (buildInfo.version != null && asset != null) asset!.restoreVersion(version: buildInfo.version!);
    updateListeners(WidgetChange.misc);
  }

}


/// The type of widget change when the listener is notified
enum WidgetChange {
  drag,
  resize,
  rotate,
  update,
  misc
}

/// The types of scale/resize options available to widget
enum ScaleType {
  /// Adding this option to scale types will enable increasing width only
  dx,
  /// Adding this option to scale types will enable increasing height only
  dy,
  /// Adding this option to scale types will enable a shared button to increase width and height
  dxy
}

class WidgetCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  WidgetCreationException(this.message, {this.details, this.code});

}