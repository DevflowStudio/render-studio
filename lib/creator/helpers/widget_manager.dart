import 'dart:ui';

import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../rehmat.dart';
import '../state.dart';

/// A class to manage and handle the widgets in the page.
class WidgetManager extends ChangeNotifier {

  late Map<String, CreatorWidget> _widgets;
  late String _background;

  final CreatorPage page;

  WidgetManager._({required List<CreatorWidget> widgets, required this.page}) {
    this._widgets = Map<String, CreatorWidget>.fromIterable(
      widgets,
      key: (widget) => widget.uid,
      value: (widget) {
        if (widget is BackgroundWidget) _background = widget.uid;
        return widget;
      }
    );
    updateSortedUIDs();
    _selections.add(background);
  }

  /// Creates a new instance of [WidgetManager] when a new page is created.
  factory WidgetManager.create(CreatorPage page, {
    Map<String, dynamic>? data
  }) {
    List<CreatorWidget> widgets = [];
    if (data != null) {
      for (Map map in data['widgets']) {
        try {
          CreatorWidget widget = CreatorWidget.fromJSON(page: page, Map<String, dynamic>.from(map));
          widgets.add(widget);
        } catch (e, stacktrace) {
          analytics.logError(e, cause: 'could not build widget', stacktrace: stacktrace);
          page.project.issues.add(Exception('${map['name']} failed to rebuild'));
        }
      }
    } else {
      widgets.add(BackgroundWidget(page: page));
    }
    WidgetManager manager = WidgetManager._(
      widgets: widgets,
      page: page,
    );
    manager.addListeners();
    return manager;
  }

  BackgroundWidget get background => _widgets[_background] as BackgroundWidget;

  List<CreatorWidget> _selections = [];
  int get nSelections => _selections.length;

  int get nWidgets => _widgets.length;

  bool _multiselect = false;

  bool get multiselect => _multiselect;
  set multiselect(bool multiselect) {
    _multiselect = multiselect;
    if (multiselect) _selections.remove(background);
    selections.forEach((element) {
      element.updateListeners(WidgetChange.misc);
    });
    _selections = [
      if (_selections.isNotEmpty) _selections.first,
    ];
    notifyListeners();
  }

  bool isSelected({
    CreatorWidget? widget,
    String? uid
  }) {
    assert(widget != null || uid != null);
    if (widget != null) return _selections.contains(widget);
    else return _selections.indexWhere((widget) => widget.uid == uid) != -1;
  }

  List<CreatorWidget> get selections => _selections;

  /// Selects the provided widget.
  /// 
  /// If [multiselect] is true, then the widget will be added to the selection.
  /// If [multiselect] is false, then the widget will be the only selected widget.
  /// 
  /// Incase the widget is a [BackgroundWidget], then the selection will be cleared and the widget will be the only selected widget.
  void select([CreatorWidget? widget]) {
    if (widget == null) widget = background;
    if (widget.uid == background.uid || widget is BackgroundWidget || widget is WidgetGroup) {
      multiselect = false;
      _selections.clear();
      _selections.add(background);
    } else {
      if (multiselect) {
        if (isSelected(widget: widget)) {
          _selections.remove(widget);
        } else if (widget.group != null) {
          // multiselect = false;
          // select(widget.group!.findGroup(widget));
          _selections.add(widget);
        } else {
          _selections.add(widget);
        }
      } else {
        _selections = [widget];
      }
    }
    updateGrids();
    page.updateListeners(PageChange.selection);
  }

  T? get<T extends CreatorWidget>(String uid) => _widgets[uid] as T?;

  Future<void> showAddWidgetModal(BuildContext context) async {
    String? id = await showModalBottomSheet(
      context: context,
      backgroundColor: Palette.of(context).background.withOpacity(0.5),
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddWidgetModal(),
      enableDrag: true
    );
    if (id == null) return;
    await CreatorWidget.create(context, id: id, page: page);
  }

  /// Adds the given widget to the page
  void add(CreatorWidget widget, {
    /// If true, then the widget will be added without calling `init()` on it.
    bool soft = false
  }) {
    // Add a listener for that widget here
    multiselect = false;
    _widgets[widget.uid] = widget;
    sortedUIDs.add(widget.uid);
    if (!soft) select(widget);
    rebuildListeners();
    if (!soft) page.history.log('Add widget');
    page.updateListeners(PageChange.misc);
  }

  void delete(String uid, {
    /// If true, then the widget will be deleted without calling `dispose()` on it.
    bool soft = false
  }) {
    if (!_widgets.containsKey(uid)) return;
    multiselect = false;
    CreatorWidget widget = _widgets[uid]!;
    if (!soft) widget.onDelete();
    _widgets.remove(widget.uid);
    sortedUIDs.remove(widget.uid);
    if (!soft) page.history.log('Delete widget');
    select();
    rebuildListeners();
    page.updateListeners(PageChange.misc);
  }

  void updateGrids() {
    page.gridState.clear();
    for (CreatorWidget widget in _widgets.values) {
      widget.updateGrids();
      widget.stateCtrl.update();
    }
  }

  void rebuildListeners() {
    removeListeners();
    addListeners();
  }

  /// Adds listener for every widget
  void addListeners() {
    for (CreatorWidget widget in _widgets.values) {
      widget.addListener(onWidgetUpdate, [WidgetChange.update]);
      widget.addListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Removes listener for every single widget
  void removeListeners() {
    for (CreatorWidget widget in _widgets.values) {
      widget.removeListener(onWidgetUpdate, [WidgetChange.update]);
      widget.removeListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Set the state of the page when a widget is updated.
  /// Also records history.
  void onWidgetUpdate() {
    // notifyListeners(PageChange.update);
    page.history.log();
  }

  /// This method is different from `onWidgetUpdate`.
  /// This is called when the widget is dragged, resized or rotated.
  /// This has to be separated because it does not record history.
  void onWidgetNotReallyUpdate() {
    // notifyListeners(PageChange.update);
  }

  void dispose() {
    removeListeners();
    super.dispose();
  }

  /// Generates a map with all the widgets in JSON format
  /// 
  /// See the example below for the use case of this method. (To be used in `CreatorPage.toJSON`)
  /// ```
  /// {
  ///   ..
  ///   ... widgetManager.toJSON()
  /// }
  /// ```
  Map<String, dynamic> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) {
    List<Map<String, dynamic>> widgetData = [];
    for (String uid in sortedUIDs) {
      CreatorWidget widget = _widgets[uid]!;
      widgetData.add(widget.toJSON(buildInfo: buildInfo));
    }
    return {
      'widgets': widgetData
    };
  }

  List<CreatorWidget> get widgets {
    return sortedUIDs.map((uid) {
      return _widgets[uid]!;
    }).toList();
  }

  List<String> sortedUIDs = [];
  void updateSortedUIDs() {
    sortedUIDs = List<String>.from(_widgets.values.map((widget) => widget.uid));
  }

  void reorder(String uid, int index, {
    /// Enables history logging of the reorder
    /// Use it when the slider of reorder calls `onChangeEnd` method
    bool log = false,
  }) {
    int oldIndex = sortedUIDs.indexOf(uid);
    if (oldIndex == index) return;
    sortedUIDs.removeAt(oldIndex);
    sortedUIDs.insert(index, uid);
    if (log) page.history.log('Reorder');
    page.updateListeners(PageChange.misc);
  }

  /// Use this method in `CreatorPage.build` to build material widgets.
  /// 
  /// See the example below for the use case of this method. (To be used in `CreatorPage.build`)
  /// ```dart
  /// Stack(
  ///  children: [
  ///   ... widgetManager.build(context),
  ///   ... other widgets
  /// ]
  /// ```
  List<Widget> build(BuildContext context, {
    bool isInteractive = true,
  }) {
    return [
      ... sortedUIDs.map((uid) => WidgetState(
        key: UniqueKey(),
        controller: _widgets[uid]!.stateCtrl,
        widget: _widgets[uid]!,
        page: page,
        isInteractive: isInteractive,
      )).toList(),
      _MultiselectDragOverlay(widgets: this)
    ];
  }

  /// This method rebuild all the widgets in the page from a previous state in the history.
  void restoreHistory(List<Map> data, {
    required String? version
  }) {
    page.gridState.clear();
    _widgets.clear();
    for (Map widgetData in data) try {
      CreatorWidget widget = CreatorWidget.fromJSON(
        widgetData,
        page: page,
        buildInfo: BuildInfo(buildType: BuildType.restore, version: version)
      );
      if (widget is BackgroundWidget) {
        _background = widget.uid;
      }
      this._widgets[widget.uid] = widget;
      updateSortedUIDs();
      widget.updateGrids();
      widget.updateListeners(WidgetChange.misc);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'could not restore history', stacktrace: stacktrace);
      page.project.issues.add(Exception('${widgetData['name']} failed to rebuild'));
    }
    _selections = [];
    _selections.add(background);
    page.updateListeners(PageChange.misc);
  }

  /// Runs a function on every widget in the page.
  void forEach(void Function(CreatorWidget widget) callback) => _widgets.values.forEach(callback);
  
}

class _AddWidgetModal extends StatelessWidget {

  _AddWidgetModal({Key? key}) : super(key: key);

  final Map<String, dynamic> widgets = {
    'text': {
      'title': 'Text',
      'icon': RenderIcons.text,
    },
    'qr_code': {
      'title': 'QR Code',
      'icon': RenderIcons.qr,
    },
    'design_asset': {
      'title': 'Design Asset',
      'icon': RenderIcons.design_asset,
    },
    'box': {
      'title': 'Box',
      'icon': RenderIcons.design_asset,
    },
    'image': {
      'title': 'Image',
      'icon': RenderIcons.image,
    },
    'shape': {
      'title': 'Shape',
      'icon': RenderIcons.shapes,
    },
    'progress': {
      'title': 'Progress',
      'icon': RenderIcons.progress,
    },
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GridView.builder(
          padding: EdgeInsets.only(
            left: 6,
            right: 6,
            top: 6,
            bottom: MediaQuery.of(context).padding.bottom
          ),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              Navigator.of(context).pop(widgets.keys.toList()[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Palette.of(context).surfaceVariant,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Palette.of(context).shadow.withOpacity(0.25),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              margin: EdgeInsets.all(6),
              child: Column(
                children: [
                  Spacer(flex: 3,),
                  Center(
                    child: Icon(
                      widgets.values.elementAt(index)['icon'],
                      size: 50,
                    ),
                  ),
                  Spacer(flex: 1,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      widgets.values.elementAt(index)['title'],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          itemCount: widgets.length,
        ),
      ),
    );
  }
}

class _MultiselectDragOverlay extends StatefulWidget {

  const _MultiselectDragOverlay({
    required this.widgets
  });

  final WidgetManager widgets;

  @override
  State<_MultiselectDragOverlay> createState() => __MultiselectDragOverlayState();
}

class __MultiselectDragOverlayState extends State<_MultiselectDragOverlay> {

  late WidgetManager widgets;

  Offset? _selectorStart;
  Offset? _selectorMiddle;
  Offset? _selectorEnd;

  void onMultiselectChange() => setState(() { });

  @override
  void initState() {
    widgets = widget.widgets;
    widgets.addListener(onMultiselectChange);
    super.initState();
  }

  @override
  void dispose() {
    widgets.removeListener(onMultiselectChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      behavior: HitTestBehavior.translucent,
      onPanStart: widgets.multiselect ? (details) {
        _selectorStart = _selectorEnd = details.localPosition - Offset(widgets.page.project.contentSize.width/2, widgets.page.project.contentSize.height/2);
        setState(() { });
      } : null,
      onPanUpdate: widgets.multiselect ? (details) {
        _selectorEnd = Offset(_selectorEnd!.dx + details.delta.dx, _selectorEnd!.dy + details.delta.dy);
        _selectorMiddle = Offset((_selectorStart!.dx + _selectorEnd!.dx)/2, (_selectorStart!.dy + _selectorEnd!.dy)/2);
        setState(() { });
      } : null,
      onPanEnd: widgets.multiselect ? (details) {
        Size _selectorSize = Size((_selectorEnd!.dx - _selectorStart!.dx).abs(), (_selectorEnd!.dy - _selectorStart!.dy).abs());
        Rect rect = _selectorMiddle!.translate(-_selectorSize.width/2, -_selectorSize.height/2) & _selectorSize;
        _selectorStart = _selectorMiddle = _selectorEnd = null;
        for (CreatorWidget widget in widgets.widgets) {
          if (widget is BackgroundWidget) continue;
          Rect intersect = widget.area.intersect(rect);
          bool isIntersecting = intersect.size.width > 0 && intersect.size.height > 0;
          if (isIntersecting) {
            if (widget is WidgetGroup) {
              for (CreatorWidget child in widget.widgets) {
                widgets.select(child);
              }
            } else {
              widgets.select(widget);
            }
          }
        }
        setState(() { });
      } : null,
      child: SizedBox.fromSize(
        size: widgets.page.project.contentSize,
        child: Stack(
          children: [
            if (_selectorStart != null && _selectorMiddle != null && _selectorEnd != null) AlignPositioned(
              dx: _selectorMiddle!.dx,
              dy: _selectorMiddle!.dy,
              child: ClipRRect(
                child: SizedBox(
                  width: (_selectorStart!.dx - _selectorEnd!.dx).abs(),
                  height: (_selectorStart!.dy - _selectorEnd!.dy).abs(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.of(context).background.withOpacity(0.25),
                      border: Border.all(
                        color: Palette.of(context).background,
                        width: 1,
                      ),
                    ),
                  )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}