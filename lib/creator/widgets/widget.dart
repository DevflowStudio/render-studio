import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:supercharged/supercharged.dart';
import '../../rehmat.dart';


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
    if (page.widgets.nWidgets >= 3) Option.openReorderTab(
      page: page,
      widget: this,
    ),
    Option.button(
      icon: RenderIcons.delete,
      title: 'Delete',
      tooltip: 'Delete Text Widget',
      onTap: (context) async {
        page.widgets.delete(this.uid);
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
  void scale(double scale) {
    Size _size = Size(size.width * scale, size.height * scale);
    if (allowResize(_size)) size = _size;
    updateListeners(WidgetChange.misc);
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

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// Defaults to `true`
  final bool isDraggable = true;

  void updatePosition(DragUpdateDetails details) {
    if (!isDraggable) return;
    position = position + details.delta;
    bool snap = details.delta.dx.isBetween(-preferences.snapSensitivity, preferences.snapSensitivity);
    if (angle == 0) updateGrids(showGridLines: true, snap: snap);
    updateListeners(WidgetChange.drag);
  }

  void _onGestureUpdate(DragUpdateDetails details, BuildContext context) {
    if (isDraggable) updatePosition(details);
    updateListeners(WidgetChange.misc);
  }

  void _onGestureEnd(DragEndDetails details, BuildContext context) {
    if (!page.widgets.multiselect) page.widgets.select(this);
    // updatePosition(Offset(position.dx, position.dy));
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

  bool isSelected() => page.widgets.isSelected(this);

  bool isOnlySelected() => page.widgets.isSelected(this) && page.widgets.selections.length == 1;

  /// ###

  double opacity = 1.0;

  /// ###

  /// Build function of the widget
  /// All of the resizing, drag, tap and double tap related code is written here
  /// @override this method to disable drag, resizing, tapping and others
  Widget build(BuildContext context, {
    bool isInteractive = true,
  }) {
    // updateResizeHandlers();
    if (!_firstBuildDone) doFirstBuild();
    bool _isSelected = isInteractive && isSelected();
    bool _isOnlySelected = isInteractive && isOnlySelected();
    return Transform.rotate(
      key: ValueKey<String>(uid),
      angle: angle,
      child: GestureDetector(
        behavior: _isOnlySelected ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
        onPanStart: (details) => onGestureStart(),
        onPanUpdate: (details) => _onGestureUpdate(details, context),
        onPanEnd: (details) => _onGestureEnd(details, context),
        dragStartBehavior: DragStartBehavior.down,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AlignPositioned(
              dx: position.dx,
              dy: position.dy,
              childHeight: size.height + 40,
              childWidth: size.width + 40,
              // rotateDegrees: angle,
              child: _isSelected ? GestureDetector(
                onDoubleTap: () => onDoubleTap(context),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Container(
                      // borderType: BorderType.RRect,
                      // color: Colors.grey[400]!,
                      // strokeWidth: 2,
                      // dashPattern: [3, 0, 3],
                      // radius: Radius.circular(5),
                      // padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
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
                      ),
                      child: SizedBox.fromSize(
                        size: size,
                        child: Opacity(
                          opacity: opacity,
                          child: widget(context)
                        )
                      )
                    ),
                  ),
                ),
              ) : GestureDetector(
                onTap: () => page.widgets.select(this),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(isBackgroundWidget ? 0 : 20),
                    child: SizedBox.fromSize(
                      size: size,
                      child: Opacity(
                        opacity: opacity,
                        child: widget(context)
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
                child: Stack(
                  children: [
                    for (ResizeHandler handler in resizeHandlers) ResizeHandlerBall(
                      type: handler,
                      widget: this,
                      onSizeChange: (Size size) {
                        this.size = size;
                        updateListeners(WidgetChange.resize);
                      },
                      onResizeEnd: onResizeFinished,
                      isResizing: isResizing,
                      onResizeStart: (details) => onResizeStart(details: details, handler: handler),
                      isVisible: _resizeHandlers.contains(handler),
                    ),
                  ],
                ),
              ),
            )
        
          ],
        ),
      ),
    );
  }


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
    bool showGridLines = false,
    /// Snap the widget to the grid
    /// 
    /// Both `this.snap` and `preferences.snap` are required to be true for the widget to snap
    bool snap = true,
    double? snapSensitivity,
  }) {
    double dx = position.dx;
    double dy = position.dy;

    List<Grid> _grids = [];

    page.gridState.grids.removeWhere((grid) => grid.widget == this);

    double _snapSensitivity = snapSensitivity ?? preferences.snapSensitivity;

    List<Grid> centerHorizontalGrids = page.gridState.grids.where((grid) => ((grid.position.dy - position.dy).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal)).toList();
    List<Grid> centerVerticalGrids = page.gridState.grids.where((grid) => ((grid.position.dx - position.dx).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical)).toList();
    List<Grid> topGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (position.dy - size.height / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.top)).toList();
    List<Grid> leftGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (position.dx - size.width / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.left)).toList();
    List<Grid> rightGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (position.dx + size.width / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.right)).toList();
    List<Grid> bottomGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (position.dy + size.height / 2)).isBetween(-_snapSensitivity, _snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.bottom)).toList();

    if (centerHorizontalGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(0, position.dy),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal);
    } else {
      Offset newPosition = centerHorizontalGrids.first.position;
      dy = newPosition.dy;
      if (!page.gridState.visible.contains(centerHorizontalGrids.first)) _grids.add(centerHorizontalGrids.first);
    }

    if (centerVerticalGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(position.dx, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.centerVertical
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical);
    } else {
      Offset newPosition = centerVerticalGrids.first.position;
      dx = newPosition.dx;
      if (!page.gridState.visible.contains(centerVerticalGrids.first)) _grids.add(centerVerticalGrids.first);
    }

    if (topGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(0, position.dy - size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.top
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.top);
    } else {
      Offset newPosition = topGrids.first.position;
      dy = newPosition.dy + size.height / 2;
      if (!page.gridState.visible.contains(topGrids.first)) _grids.add(topGrids.first);
    }

    if (leftGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(position.dx - size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.left
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.left);
    } else {
      Offset newPosition = leftGrids.first.position;
      dx = newPosition.dx + size.width / 2;
      if (!page.gridState.visible.contains(leftGrids.first)) _grids.add(leftGrids.first);
    }

    if (rightGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(position.dx + size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.right
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.right);
    } else {
      Offset newPosition = rightGrids.first.position;
      dx = newPosition.dx - size.width / 2;
      if (!page.gridState.visible.contains(rightGrids.first)) _grids.add(rightGrids.first);
    }

    if (bottomGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(0, position.dy + size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          page: page,
          gridWidgetPlacement: GridWidgetPlacement.bottom
        )
      );
      page.gridState.visible.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.bottom);
    } else {
      Offset newPosition = bottomGrids.first.position;
      dy = newPosition.dy - size.height / 2;
      if (!page.gridState.visible.contains(bottomGrids.first)) _grids.add(bottomGrids.first);
    }

    if (showGridLines) {
      page.gridState.notifyListeners();
      // Only snap if the user has enabled it in settings
      if (preferences.snap && snap) position = Offset(dx, dy);
      if (preferences.snap && snap && preferences.vibrateOnSnap && _grids.isNotEmpty) {
        TapFeedback.light();
      }
      page.gridState.visible.addAll(_grids);
    }

  }

  /// This method is called when the palette is updated for the parent page
  /// 
  /// Here, write the code to update colors used within the widget
  void onPaletteUpdate() { }

  /// This method is called when the widget is deleted
  /// 
  /// It should be used to clean up any resources that the widget is using
  void onDelete() {}

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