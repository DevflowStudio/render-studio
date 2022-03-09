import 'package:flutter/material.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:supercharged/supercharged.dart';
import '../../rehmat.dart';


class CreatorWidget extends PropertyChangeNotifier<WidgetChange> {

  CreatorWidget({required this.page, required this.project}) {
    uid ??= Constants.generateUID(6);
    editor = Editor(
      tabs: tabs,
      project: project,
      page: page,
      widget: this
    );
    _defaultResizeHandlerSet = _resizeHandlers = resizeHandlers;
  }

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

  Size? previousSize;
  Size size = const Size(0, 0);
  Size? minSize;

  /// Set to `false` if you want the widget
  /// to not be resizeable.
  /// Defaults to `true`
  final bool isResizable = true;

  void onResizeStart({
    required DragStartDetails details,
    required ResizeHandler handler
  }) {
    _resizeHandlers = [handler];
  }

  /// This method is called when the resizing of the widget is finished
  void onResizeFinished(DragEndDetails details, {
    bool updateNotify = true
  }) {
    updateResizeHandlers();
    notifyListeners(WidgetChange.update);
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
    return (_size.width > ((minSize?.width) ?? 30) && _size.height > (minSize?.height ?? 30) && _size.width < (project.deviceSize.width - 40) && _size.height < (project.deviceSize.width - 40));
  }


  /// ### Drag

  Offset position = const Offset(0, 0);

  /// Set to `false` if you want the widget
  /// to not be draggable.
  /// Defaults to `true`
  final bool isDraggable = true;

  void updatePosition(Offset _position) {
    position = _position;
    updateGrids(showGridLines: true);
    updateListeners(WidgetChange.drag);
  }

  void onDragFinish() {
    // Update the listener to `update` changes. This will tell the parent to reload and save the change in history
    updateListeners(WidgetChange.update, removeGrids: true);
  }

  /// ###

  double opacity = 1.0;

  /// ###

  /// Build function of the widget
  /// All of the resizing, drag, tap and double tap related code is written here
  /// @override this method to disable drag, resizing, tapping and others
  Widget build(BuildContext context) {
    // updateResizeHandlers();
    return AlignPositioned(
      dy: position.dy,
      dx: position.dx,
      rotateDegrees: angle,
      touch: Touch.inside,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () => onDoubleTap(context),
        onTap: () {
          if (page.currentSelection.uid != uid) page.changeSelection(this);
        },
        onPanUpdate: isDraggable ? (details) {
          if (page.currentSelection != this) page.changeSelection(this);
          updatePosition(Offset(position.dx + details.delta.dx, position.dy + details.delta.dy));
        } : null,
        onPanEnd: isDraggable ? (details) {
          onDragFinish();
        } : null,
        child: SizedBox.fromSize(
          size: Size(size.width + 40, size.height + 40),
          child: (page.currentSelection == this && isResizable) ? Stack(
            clipBehavior: Clip.none,
            children: [
              
              Center(
                child: SizedBox.fromSize(
                  size: Size(size.width + 2, size.height + 2), // 2 for the border
                  child: Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      // color: Colors.red.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1
                      ),
                      boxShadow: const [ ]
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
      
              for (ResizeHandler handler in resizeHandlers) ResizeHandlerBall(
                type: handler,
                widget: this,
                onSizeChange: (Size size) {
                  this.size = size;
                  updateListeners(WidgetChange.resize);
                },
                onResizeEnd: onResizeFinished,
                onResizeStart: (details) => onResizeStart(details: details, handler: handler),
                isVisible: _resizeHandlers.contains(handler),
              ),
            ],
          ) : Center(
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
    if (removeGrids) page.visibleGrids.clear();
    notifyListeners(change);
  }

  /// Update all the grids present in the page for the current widget
  void updateGrids({
    bool showGridLines = false
  }) {
    double dx = position.dx;
    double dy = position.dy;

    List<Grid> _grids = [];

    page.grids.removeWhere((grid) => grid.widget == this);

    List<Grid> centerHorizontalGrids = page.grids.where((grid) => ((grid.position.dy - position.dy).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal)).toList();
    List<Grid> centerVerticalGrids = page.grids.where((grid) => ((grid.position.dx - position.dx).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical)).toList();
    List<Grid> topGrids = page.grids.where((grid) => ((grid.position.dy - (position.dy - size.height / 2)).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.top)).toList();
    List<Grid> leftGrids = page.grids.where((grid) => ((grid.position.dx - (position.dx - size.width / 2)).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.left)).toList();
    List<Grid> rightGrids = page.grids.where((grid) => ((grid.position.dx - (position.dx + size.width / 2)).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.right)).toList();
    List<Grid> bottomGrids = page.grids.where((grid) => ((grid.position.dy - (position.dy + size.height / 2)).isBetween(-Constants.snapSenstivity, Constants.snapSenstivity) && grid.gridWidgetPlacement == GridWidgetPlacement.bottom)).toList();

    if (centerHorizontalGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(0, position.dy),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.centerHorizontal);
    } else {
      Offset newPosition = centerHorizontalGrids.first.position;
      dy = newPosition.dy;
      if (!page.visibleGrids.contains(centerHorizontalGrids.first)) _grids.add(centerHorizontalGrids.first);
    }

    if (centerVerticalGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(position.dx, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.centerVertical
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.centerVertical);
    } else {
      Offset newPosition = centerVerticalGrids.first.position;
      dx = newPosition.dx;
      if (!page.visibleGrids.contains(centerVerticalGrids.first)) _grids.add(centerVerticalGrids.first);
    }

    if (topGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(0, position.dy - size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.top
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.top);
    } else {
      Offset newPosition = topGrids.first.position;
      dy = newPosition.dy + size.height / 2;
      if (!page.visibleGrids.contains(topGrids.first)) _grids.add(topGrids.first);
    }

    if (leftGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(position.dx - size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.left
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.left);
    } else {
      Offset newPosition = leftGrids.first.position;
      dx = newPosition.dx + size.width / 2;
      if (!page.visibleGrids.contains(leftGrids.first)) _grids.add(leftGrids.first);
    }

    if (rightGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(position.dx + size.width / 2, 0),
          color: Colors.red,
          layout: GridLayout.vertical,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.right
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.right);
    } else {
      Offset newPosition = rightGrids.first.position;
      dx = newPosition.dx - size.width / 2;
      if (!page.visibleGrids.contains(rightGrids.first)) _grids.add(rightGrids.first);
    }

    if (bottomGrids.isEmpty) {
      page.grids.add(
        Grid(
          position: Offset(0, position.dy + size.height / 2),
          color: Colors.blue,
          layout: GridLayout.horizontal,
          widget: this,
          project: project,
          gridWidgetPlacement: GridWidgetPlacement.bottom
        )
      );
      page.visibleGrids.removeWhere((grid) => grid.gridWidgetPlacement == GridWidgetPlacement.bottom);
    } else {
      Offset newPosition = bottomGrids.first.position;
      dy = newPosition.dy - size.height / 2;
      if (!page.visibleGrids.contains(bottomGrids.first)) _grids.add(bottomGrids.first);
    }

    if (showGridLines) {
      // Only snap if the user has enabled it in settings
      if (preferences.snap) position = Offset(dx, dy);
      page.visibleGrids.addAll(_grids);
      if (preferences.snap && preferences.vibrateOnSnap && _grids.isNotEmpty) {
        TapFeedback.normal();
      }
    }

  }

  /// Save the state of the widget in a json format
  Map<String, dynamic> toJSON() => {
    'id': id,
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

  bool buildFromJSON(Map<String, dynamic> json) {
    try {
      return buildPropertiesFromJSON(Map.from(json['properties']));
    } catch (e) {
      return false;
    }
  }

  bool buildPropertiesFromJSON(Map<String, dynamic> properties) {
    try {
      position = Offset(properties['position']['dx'], properties['position']['dy']);
      angle = properties['angle'];
      opacity = properties['opacity'];
      size = Size(properties['size']['width'], properties['size']['height']);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  bool operator == (Object other) {
    if (other is CreatorWidget && other.uid == uid) return true;
    return false;
  }

  @override
  int get hashCode => super.hashCode;

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