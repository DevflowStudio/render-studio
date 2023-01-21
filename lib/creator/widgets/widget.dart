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
      updateGrids();
      stateCtrl.update();
    } on WidgetCreationException catch (e) {
      analytics.logError(e, cause: 'could not build widget from JSON');
      throw WidgetCreationException(
        'The widget could not be rebuilt due to some issues',
        details: 'Failed to build widget from JSON: $e',
      );
    }
  }

  late WidgetStateController stateCtrl;

  late String uid;
  void regenerateUID() {
    uid = Constants.generateID(6);
  }

  final CreatorPage page;

  /// Bottom Navigation Bar with editing options
  late final Editor editor;

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
            CreatorWidget? duplicateW = await duplicate();
            if (duplicateW != null) page.widgets.add(duplicateW);
          },
        );
      },
    ),
    // Option.button(
    //   icon: RenderIcons.arrow_link,
    //   title: 'Arrow Link',
    //   tooltip: 'Make an arrow link to another widget',
    //   onTap: (context) async {
    //     // TODO: Arrow Link
    //   },
    // ),
    Option.toggle(
      disabledIcon: RenderIcons.unlock,
      enabledIcon: RenderIcons.lock,
      title: isLocked ? 'Unlock' : 'Lock',
      enabledTooltip: 'Unlock Widget',
      disabledTooltip: 'Lock Widget',
      value: isLocked,
      onChange: (value) {
        group != null ? group!.lock(this) : lock();
      },
    ),
    Option.button(
      icon: RenderIcons.delete,
      title: 'Delete',
      tooltip: 'Delete Text Widget',
      onTap: (context) async {
        delete();
      },
    ),
  ];

  /// Name of the widget
  final String name = 'Widget';

  /// ID of the widget
  /// Must be in lowercase letters
  final String id = 'widget';

  final bool allowClipboard = true;

  bool _locked = false;

  bool get isLocked => _locked;

  void lock() {
    _locked = true;
    if (group != null) {
      group!.findGroup(this).lock();
    } else {
      updateListeners(WidgetChange.lock);
    }
  }

  void unlock() {
    _locked = false;
    if (group != null) {
      group!.findGroup(this).unlock();
    } else {
      updateListeners(WidgetChange.lock);
    }
  }

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

  bool isResizing = false;
  ResizeHandler? _currentResizingHandler;

  Size size = const Size(0, 0);
  Size? minSize;

  /// Setting this to `true` will allow
  /// resizing but only in the fixed aspect ratio
  bool keepAspectRatio = false;

  /// Set to `false` if you want the widget
  /// to not be resizable.
  /// Defaults to `true`
  final bool isResizable = true;

  /// Set to `true` for widgets like background
  /// to make sure that effects like border are not applied
  final bool isBackgroundWidget = false;

  void onResizeStart({
    required DragStartDetails details,
    required ResizeHandler handler
  }) {
    isResizing = true;
    _currentResizingHandler = handler;
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
    _currentResizingHandler = null;
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

  List<ResizeHandler> _getResizeHandlersWRTSize() {
    List<ResizeHandler> __handlers = [];
    if (size.height.isBetween(0, 50)) {
      __handlers = [
        ResizeHandler.bottomRight
      ];
    } else if (size.height.isBetween(50, 95)) {
      __handlers = List.from(resizeHandlers.where((handler) => handler.type == ResizeHandlerType.corner));
    } else {
      __handlers = List.from(resizeHandlers);
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
  Offset _previousPosition = const Offset(0, 0);

  Rect get area => position.translate(-size.width/2, -size.height/2) & size;

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// 
  /// Defaults to `true`
  final bool isDraggable = true;

  bool isDragging = false;

  List<WidgetAlignment> get alignment => WidgetAlignmentExtension.fromPosition(this);

  void alignPositioned(WidgetAlignment alignment) {
    if (this.alignment.contains(alignment)) return;
    _previousPosition = position;
    position = alignment.getPosition(this);
    updateListeners(WidgetChange.update);
  }

  void updatePosition(DragUpdateDetails details) {
    if (!isDraggable) return;
    _previousPosition = position;
    position = position + details.delta;
    bool isDraggingFast = !details.delta.dx.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) || !details.delta.dy.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity);
    // bool isDraggingSlow = details.delta.dx.abs() < 0.2 || details.delta.dy.abs() < 0.2;
    if (angle == 0) updateGrids(realtime: true, showGridLines: true, snap: !isDraggingFast);
    updateListeners(WidgetChange.drag);
  }

  void _onGestureUpdate(DragUpdateDetails details, BuildContext context) {
    if (isDraggable) updatePosition(details);
    updateListeners(WidgetChange.misc);
  }

  void _onGestureEnd(DragEndDetails details, BuildContext context) {
    if (!page.widgets.multiselect && this is! WidgetGroup) page.widgets.select(this);
    isDragging = false;
    onDragFinish(context);
  }

  void onGestureStart() {
    isDragging = true;
  }

  void onDragFinish(BuildContext context) {
    // Update the listener to `update` changes. This will tell the parent to reload state and save the change in history
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
    updateGrids(showGridLines: true, snap: true);
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
    return AlignPositioned(
      key: ValueKey<String>(uid),
      dx: position.dx,
      dy: position.dy,
      childHeight: size.height + 40,
      childWidth: size.width + 40,
      child: rotatedWidget(
        child: GestureDetector(
          onDoubleTap: (_isSelected && this is! WidgetGroup) ? () => onDoubleTap(context) : null,
          onTap: (_isSelected && this is! WidgetGroup) ? null : () => page.widgets.select(this),
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
                  color: page.palette.onBackground,
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
                child: widget(context)
              )
            ),
          )
        ),
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
    if (change == WidgetChange.update) updateGrids();
    if (removeGrids) page.gridState.hideAll();
    notifyListeners(change);
    stateCtrl.update(change);
    if (change == WidgetChange.update && asset != null) {
      asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
    }
  }

  /// Update all the grids present in the page for the current widget
  void updateGrids({
    /// Set the `realtime` to `true` if this method is being called in realtime.
    /// Example use: When the widget is being dragged
    bool realtime = false,
    /// Settings this to `false` will not snap the widgets and not show the grid lines
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

    position ??= this.position;
    snapSensitivity ??= preferences.snapSensitivity;
    snap = snap && preferences.snap;

    double dx = position.dx;
    double dy = position.dy;

    double x0 = position.dx - size.width/2;
    double x = position.dx;
    double x1 = position.dx + size.width/2;

    double px0 = _previousPosition.dx - size.width/2;
    double px = _previousPosition.dx;
    double px1 = _previousPosition.dx + size.width/2;

    double y0 = position.dy - size.height/2;
    double y = position.dy;
    double y1 = position.dy + size.height/2;

    double py0 = _previousPosition.dy - size.height/2;
    double py = _previousPosition.dy;
    double py1 = _previousPosition.dy + size.height/2;

    bool isInSnapSensitiveArea(double x, double px, Grid grid) {
      double target = grid.position.dx;
      if (grid.layout == GridLayout.horizontal) target = grid.position.dy;
      double sensitivity = snapSensitivity!;

      double d = (x - target).abs();
      double pd = (px - target).abs();
      bool isMovingAway = d > pd;

      if (isMovingAway && realtime) sensitivity = sensitivity / 3;

      return x >= target - sensitivity && x <= target + sensitivity;
    }

    bool isWithinReachableDistance(Grid grid) {
      if (grid.widget == null || grid.length == null) return true;
      if (grid.layout == GridLayout.horizontal) return true;
      double md = grid.length! / 1.5;
      double d = (grid.position.dy - dy).abs();
      return d <= md;
    }

    if (showGridLines) {
      int nSnapGrids = 0;
      for (Grid grid in page.gridState.grids) {
        bool hasSnapped = false;
        
        if (grid.widget == this) continue;
        else if (nSnapGrids >= 2) continue;
        else if (this is WidgetGroup && (this as WidgetGroup).widgets.contains(grid.widget)) continue;

        if (grid.layout == GridLayout.vertical) {
          if (isInSnapSensitiveArea(x0, px0, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx + size.width/2;
            hasSnapped = true;
          } else if (isInSnapSensitiveArea(x, px, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx;
            hasSnapped = true;
          } else if (isInSnapSensitiveArea(x1, px1, grid) && isWithinReachableDistance(grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerVertical) {
            dx = grid.position.dx - size.width/2;
            hasSnapped = true;
          }
        } else if (grid.layout == GridLayout.horizontal) {
          if (isInSnapSensitiveArea(y0, py0, grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy + size.height/2;
            hasSnapped = true;
          } else if (isInSnapSensitiveArea(y, py, grid) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy;
            hasSnapped = true;
          } else if (isInSnapSensitiveArea(y1, py1, grid) && grid.gridWidgetPlacement != GridWidgetPlacement.centerHorizontal) {
            dy = grid.position.dy - size.height/2;
            hasSnapped = true;
          }
        }
        
        // Create a haptic feedback when the widget snaps to the grid
        // Other conditions in the if statement prevent the feedback from being created multiple times
        if (hasSnapped && !grid.isVisible && preferences.vibrateOnSnap && snap) TapFeedback.light();

        if (hasSnapped) grid.isVisible = true;
        else grid.isVisible = false;

        if (hasSnapped) nSnapGrids++;
      }
      if (snap) {
        _previousPosition = this.position;
        this.position = Offset(dx, dy);
      }
      page.gridState.notifyListeners();
    }

    List<Grid> newGrids = [];

    Grid _createGrid({
      required Offset position,
      required GridLayout layout,
      required GridWidgetPlacement gridWidgetPlacement,
    }) => Grid(
      position: position,
      color: page.palette.onBackground,
      layout: layout,
      gridWidgetPlacement: gridWidgetPlacement,
      page: page,
      widget: this,
      dotted: true,
      length: layout == GridLayout.horizontal ? null : (size.height < page.project.contentSize.height/3 ? size.height * 3 : page.project.contentSize.height/2),
    );

    bool hasSmallHeight = size.height < 20;
    bool hasSmallWidth = size.width < 40;

    if (createGrids && !realtime) {
      newGrids.addAll([
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x0 - snapSensitivity!, x0 + snapSensitivity)) < 0 && !hasSmallWidth) _createGrid(
          position: Offset(x0, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.left
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x - snapSensitivity!, x + snapSensitivity)) < 0) _createGrid(
          position: Offset(x, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.centerVertical
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dx.isBetween(x1 - snapSensitivity!, x1 + snapSensitivity)) < 0 && !hasSmallWidth) _createGrid(
          position: Offset(x1, y),
          layout: GridLayout.vertical,
          gridWidgetPlacement: GridWidgetPlacement.right
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y0 - snapSensitivity!, y0 + snapSensitivity)) < 0 && !hasSmallHeight) _createGrid(
          position: Offset(0, y0),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.top
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y - snapSensitivity!, y + snapSensitivity)) < 0) _createGrid(
          position: Offset(0, y),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
        ),
        if (page.gridState.grids.indexWhere((grid) => grid.position.dy.isBetween(y1 - snapSensitivity!, y1 + snapSensitivity)) < 0 && !hasSmallHeight) _createGrid(
          position: Offset(0, y1),
          layout: GridLayout.horizontal,
          gridWidgetPlacement: GridWidgetPlacement.bottom
        ),
      ]);
      page.gridState.grids.removeWhere((element) => element.widget == this);
      page.gridState.grids.addAll(newGrids);
    }

    page.gridState.notifyListeners();

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
  Future<CreatorWidget?> duplicate() async {
    if (group != null) {
      return group!.findGroup(this).duplicate();
    }
    CreatorWidget widget = CreatorWidget.fromJSON(toJSON(), page: page, buildInfo: BuildInfo(buildType: BuildType.unknown));
    widget.uid = Constants.generateID();
    widget.position = Offset(position.dx + 10, position.dy + 10);
    await widget.onDuplicate();
    widget._locked = false;
    return widget;
  }

  /// This method is called when a widget is duplicated from another
  /// Handle asset duplication here
  Future<void> onDuplicate() async {}

  void delete() {
    if (group != null) group!.deleteWidget(this);
    else page.widgets.delete(this.uid);
  }

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
      case 'progress':
        widget = CreativeProgressWidget(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'pie-chart':
        widget = CreativePieChart(page: page, data: data, buildInfo: buildInfo);
        break;
      case 'blob':
        widget = CreativeBlob(page: page, data: data, buildInfo: buildInfo);
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
      case 'progress':
        CreativeProgressWidget.create(context, page: page);
        break;
      case 'pie-chart':
        CreativePieChart.create(context, page: page);
        break;
      case 'blob':
        CreativeBlob.create(context, page: page);
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
  misc,
  lock
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

class WidgetHandlerBuilder extends StatefulWidget {

  const WidgetHandlerBuilder({
    super.key,
    required this.widget,
    this.isInteractive = true
  });

  final CreatorWidget widget;
  final bool isInteractive;

  @override
  State<WidgetHandlerBuilder> createState() => _WidgetHandlerBuilderState();
}

class _WidgetHandlerBuilderState extends State<WidgetHandlerBuilder> {

  late CreatorWidget creatorWidget;

  @override
  void initState() {
    super.initState();
    creatorWidget = widget.widget;
    creatorWidget.addListener(onWidgetChange);
  }

  @override
  void dispose() {
    creatorWidget.removeListener(onWidgetChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (creatorWidget != widget.widget) updateWidget();
    bool _isOnlySelected = widget.isInteractive && creatorWidget.isOnlySelected();
    bool _allowDrag = widget.isInteractive && creatorWidget.isDraggable && creatorWidget.group == null && _isOnlySelected && !creatorWidget.isLocked;
    return GestureDetector(
      behavior: _isOnlySelected ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
      onPanStart: _allowDrag ? (details) => creatorWidget.onGestureStart() : null,
      onPanUpdate: _allowDrag ? (details) => creatorWidget._onGestureUpdate(details, context) : null,
      onPanEnd: _allowDrag ? (details) => creatorWidget._onGestureEnd(details, context) : null,
      dragStartBehavior: DragStartBehavior.down,
      child: Stack(
        children: [
          Visibility(
            visible: (creatorWidget.isResizable && !creatorWidget.isLocked),
            child: AlignPositioned(
              dx: creatorWidget.position.dx,
              dy: creatorWidget.position.dy,
              childHeight: creatorWidget.size.height + 40,
              childWidth: creatorWidget.size.width + 40,
              // rotateDegrees: angle,
              child: SizedBox(
                width: creatorWidget.size.width + 40,
                height: creatorWidget.size.height + 40,
                child: creatorWidget.rotatedWidget(
                  child: Stack(
                    children: [
                      for (ResizeHandler handler in creatorWidget.resizeHandlers) ResizeHandlerBall(
                        type: handler,
                        widget: creatorWidget,
                        keepAspectRatio: creatorWidget.keepAspectRatio,
                        onSizeChange: creatorWidget.onResize,
                        onResizeEnd: creatorWidget.onResizeFinished,
                        isResizing: creatorWidget.isResizing,
                        onResizeStart: (details) => creatorWidget.onResizeStart(details: details, handler: handler),
                        isVisible: creatorWidget._getResizeHandlersWRTSize().contains(handler) || creatorWidget._currentResizingHandler == handler,
                        updatePosition: creatorWidget.angle == 0,
                        isMinimized: creatorWidget.isDragging,
                        // color: creatorWidget.page.palette.isLightBackground ? creatorWidget.page.palette.onBackground : creatorWidget.page.palette.onBackground.harmonizeWith(Colors.white),
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    
          if (creatorWidget._getResizeHandlersWRTSize().length == 1 && creatorWidget.isDraggable && !creatorWidget.isLocked) Builder(
            builder: (_) {
              double dy = creatorWidget.position.dy;
              double dx = creatorWidget.position.dx;
              double positionY = dy + creatorWidget.size.height/2 + 15 + 15;
              double positionX = dx;
      
              if ((positionY + 15) > creatorWidget.page.project.contentSize.height/2) {
                positionY = dy - creatorWidget.size.height - 15 - 15;
              }
      
              return AlignPositioned(
                dy: positionY,
                dx: positionX,
                child: DragHandler(
                  onPositionUpdate: (details) => creatorWidget._onGestureUpdate(details, context),
                  onPositionUpdateEnd: (details) => creatorWidget._onGestureEnd(details, context),
                ),
              );
            }
          ),
    
          Visibility(
            visible: creatorWidget._getResizeHandlersWRTSize().length > 1 && !creatorWidget.isDragging,
            child: Builder(
              builder: (_) {
                double dy = creatorWidget.position.dy;
                double dx = creatorWidget.position.dx;
                double positionY = dy + creatorWidget.size.height/2 + 20 + 15;
                double positionX = dx;
                
                if ((positionY + 15) > creatorWidget.page.project.contentSize.height/2) {
                  positionY = dy - creatorWidget.size.height/2 - 20 - 15;
                }
                
                return AlignPositioned(
                  dy: positionY,
                  dx: positionX,
                  child: WidgetActionButton(
                    widget: creatorWidget,
                  ),
                );
              }
            ),
          )
        ],
      ),
    );
  }

  void onWidgetChange() => setState(() {});

  void updateWidget() {
    creatorWidget.removeListener(onWidgetChange);
    creatorWidget = widget.widget;
    creatorWidget.addListener(onWidgetChange);
  }

}