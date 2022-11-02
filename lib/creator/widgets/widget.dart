import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:supercharged/supercharged.dart';
import '../../rehmat.dart';


abstract class CreatorWidget extends PropertyChangeNotifier<WidgetChange> {

  CreatorWidget({required this.page, required this.project, this.uid}) {
    uid ??= Constants.generateID(6);
    stateCtrl = WidgetStateController(this);
    editor = Editor(
      tabs: tabs,
      project: project,
      page: page,
      widget: this
    );
    _defaultResizeHandlerSet = _resizeHandlers = resizeHandlers;
    onPaletteUpdate();
  }

  late WidgetStateController stateCtrl;

  bool _firstBuildDont = false;

  void doFirstBuild() {
    // First build function is run once the rendering is over
    // Only once for the widget lifecycle
    _firstBuildDont = true;
    onFirstBuild();
  }

  void onFirstBuild() {}

  void onInitialize() {}

  String? uid;

  final CreatorPage page;

  final Project project;

  /// Bottom Navigation Bar with editing options
  late Editor editor;

  /// Tabs with editing options
  List<EditorTab> get tabs => [ ];

  /// Name of the widget
  final String name = 'Widget';

  /// ID of the widget
  /// Must be in lowercase letters
  final String id = 'widget';

  final bool allowClipboard = true;

  void onDoubleTap(BuildContext context) {}


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

  Size? previousSize;
  Size size = const Size(0, 0);
  Size? minSize;

  /// Setting this to `true` will allow
  /// resizing but only in the fixed aspect ratio
  final bool keepAspectRatio = false;

  /// Set to `false` if you want the widget
  /// to not be resizeable.
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
  void onResizeFinished(DragEndDetails details, {
    bool updateNotify = true
  }) {
    isResizing = false;
    updateResizeHandlers();
    notifyListeners(WidgetChange.update);
  }

  void resizeByScale(double scale) {
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
    if (_size.width > (project.deviceSize.width - 40)) return false;
    if (_size.height > (project.deviceSize.height - 40)) return false;
    return true;
  }


  /// ### Drag

  Offset position = const Offset(0, 0);

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// Defaults to `true`
  final bool isDraggable = true;

  void updatePosition(Offset _position) {
    position = _position;
    if (angle == 0) updateGrids(showGridLines: true);
    updateListeners(WidgetChange.drag);
  }

  void _onGestureUpdate(DragUpdateDetails details) {
    if (isDraggable && !page.multiselect) updatePosition(position + details.delta);
    updateListeners(WidgetChange.misc);
  }

  void _onGestureEnd(DragEndDetails details) {
    page.select(this);
    updatePosition(Offset(position.dx, position.dy));
    onDragFinish();
  }

  void onGestureStart() { }

  void onDragFinish() {
    // Update the listener to `update` changes. This will tell the parent to reload state and save the change in history
    updateListeners(WidgetChange.update, removeGrids: true);
  }

  bool isSelected() => page.isSelected(this);

  bool isOnlySelected() => page.isSelected(this) && page.selections.length == 1;

  /// ###

  double opacity = 1.0;

  /// ###

  /// Build function of the widget
  /// All of the resizing, drag, tap and double tap related code is written here
  /// @override this method to disable drag, resizing, tapping and others
  Widget build(BuildContext context) {
    // updateResizeHandlers();
    if (!_firstBuildDont) doFirstBuild();
    bool _isSelected = isSelected();
    bool _isOnlySelected = isOnlySelected();
    return SizedBox.fromSize(
      size: project.contentSize(context),
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          behavior: _isOnlySelected ? HitTestBehavior.translucent : HitTestBehavior.deferToChild,
          onPanStart: (details) => onGestureStart(),
          onPanUpdate: _onGestureUpdate,
          onPanEnd: _onGestureEnd,
          dragStartBehavior: DragStartBehavior.down,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              AlignPositioned(
                dx: position.dx,
                dy: position.dy,
                // rotateDegrees: angle,
                child: _isSelected ? GestureDetector(
                  onDoubleTap: () => onDoubleTap(context),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SizedBox.fromSize(
                        // size: Size(size.width + 4, size.height + 4), // 4 for the border
                        child: Container(
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            color: Colors.grey[400]!,
                            strokeWidth: 2,
                            dashPattern: [3, 0, 3],
                            radius: Radius.circular(5),
                            // padding: EdgeInsets.zero,
                            // decoration: BoxDecoration(
                            //   // color: Colors.red.withOpacity(0.3),
                            //   border: Border.all(
                            //     color: Colors.grey[400]!,
                            //     width: 1
                            //   ),
                            //   boxShadow: const [ ]
                            // ),
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
                    ),
                  ),
                ) : GestureDetector(
                  onTap: () => page.select(this),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(isBackgroundWidget ? 0 : 22),
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
          
                  if ((positionY + 15) > project.contentSize(context).height/2) {
                    positionY = dy - size.height - 15;
                  }
          
                  return AlignPositioned(
                    dy: positionY,
                    dx: positionX,
                    // rotateDegrees: angle,
                    child: DragHandler(
                      onPositionUpdate: _onGestureUpdate,
                      onPositionUpdateEnd: _onGestureEnd,
                      backgroundColor: page.palette.background.computeThemedTextColor(180),
                      iconColor: page.palette.background,
                    ),
                  );
                }
              ),
            
              if (isResizable && !locked && _isOnlySelected) AlignPositioned(
                dx: position.dx,
                dy: position.dy,
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
  }

  /// Update all the grids present in the page for the current widget
  void updateGrids({
    bool showGridLines = false
  }) {
    double dx = position.dx;
    double dy = position.dy;

    List<Grid> _grids = [];

    page.gridState.grids.removeWhere((grid) => grid.widget == this);

    List<Grid> centerHorizontalGrids = page.gridState.grids.where((grid) => ((grid.position.dy - position.dy).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal)).toList();
    List<Grid> centerVerticalGrids = page.gridState.grids.where((grid) => ((grid.position.dx - position.dx).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical)).toList();
    List<Grid> topGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (position.dy - size.height / 2)).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.top)).toList();
    List<Grid> leftGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (position.dx - size.width / 2)).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.left)).toList();
    List<Grid> rightGrids = page.gridState.grids.where((grid) => ((grid.position.dx - (position.dx + size.width / 2)).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.right)).toList();
    List<Grid> bottomGrids = page.gridState.grids.where((grid) => ((grid.position.dy - (position.dy + size.height / 2)).isBetween(-preferences.snapSensitivity, preferences.snapSensitivity) && grid.gridWidgetPlacement == GridWidgetPlacement.bottom)).toList();

    if (centerHorizontalGrids.isEmpty) {
      page.gridState.grids.add(
        Grid(
          position: Offset(0, position.dy),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          project: project,
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
          project: project,
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
          project: project,
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
          project: project,
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
          project: project,
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
          project: project,
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
      if (preferences.snap) position = Offset(dx, dy);
      page.gridState.visible.addAll(_grids);
      if (preferences.snap && preferences.vibrateOnSnap && _grids.isNotEmpty) {
        TapFeedback.normal();
      }
    }

  }

  /// Call this method when updating the palette of the project to change color of the widget
  /// Not required for widgets like image or design asset which do not require a color
  void onPaletteUpdate() { }

  /// Save the state of the widget in a json format
  Map<String, dynamic> toJSON() => {
    'id': id,
    'uid': uid,
    'name': name,
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

  // static CreatorWidget? fromJSON(dynamic data, {
  //   required CreatorPage page
  // }) {
  //   try {
  //     data = Map.from(data);
  //     CreatorWidget? widget;
  //     Project project = page.project;
  //     switch (data['uid']) {
  //       case 'background':
  //         widget = BackgroundWidget(page: page, project: project, uid: data['uid']);
  //         break;
  //       case 'box':
  //         widget = CreatorBoxWidget(page: page, project: project, uid: data['uid']);
  //         break;
  //       case 'text':
  //         widget = CreatorText(page: page, project: project);
  //         break;
  //       case 'design_asset':
  //         widget = CreatorDesignAsset(page: page, project: project);
  //         break;
  //       case 'qr_code':
  //         widget = QRWidget(page: page, project: project);
  //         break;
  //       default:
  //         return null;
  //     }
  //     return widget;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  void buildFromJSON(Map<String, dynamic> json) {
    try {
      uid = json['uid'];
      buildPropertiesFromJSON(Map.from(json['properties']));
      updateResizeHandlers();
      updateGrids();
      stateCtrl.update();
    } catch (e) {
      throw WidgetCreationException(
        'The widget could not be rebuilt due to some issues',
        details: 'Failed to build widget from JSON: $e',
      );
    }
  }

  void buildPropertiesFromJSON(Map<String, dynamic> properties) {
    try {
      position = Offset(properties['position']['dx'], properties['position']['dy']);
      angle = properties['angle'];
      opacity = properties['opacity'];
      size = Size(properties['size']['width'], properties['size']['height']);
      updateListeners(WidgetChange.misc);
    } catch (e) {
      throw WidgetCreationException(
        'The widget could not be built due to some issues',
        details: 'Failed to build widget properties from JSON: $e',
      );
    }
  }

  @override
  bool operator == (Object other) {
    if (other is CreatorWidget && other.uid == uid) return true;
    return false;
  }

  @override
  int get hashCode => super.hashCode;

  /// This method is called when the widget is deleted
  /// It should be used to clean up any resources that the widget is using
  void onDelete() {}

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