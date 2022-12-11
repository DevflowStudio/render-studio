import 'dart:ui';

import 'package:flutter/material.dart';

import '../../rehmat.dart';
import '../state.dart';

/// A class to manage and handle the widgets in the page.
class WidgetManager {

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
    _selections.add(background.uid);
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
      page: page
    );
    manager.addListeners();
    return manager;
  }

  BackgroundWidget get background => _widgets[_background] as BackgroundWidget;

  List<String> _selections = [];
  int get nSelections => _selections.length;

  int get nWidgets => _widgets.length;

  bool _multiselect = false;

  bool get multiselect => _multiselect;
  set multiselect(bool multiselect) {
    _multiselect = multiselect;
  }

  bool isSelected(CreatorWidget widget) {
    return _selections.contains(widget.uid);
  }

  List<CreatorWidget> get selections => _selections.map((uid) => _widgets[uid]!).toList();

  /// Selects the provided widget.
  /// 
  /// If [multiselect] is true, then the widget will be added to the selection.
  /// If [multiselect] is false, then the widget will be the only selected widget.
  /// 
  /// Incase the widget is a [BackgroundWidget], then the selection will be cleared and the widget will be the only selected widget.
  void select([CreatorWidget? widget]) {
    if (widget == null) widget = background;
    if (widget.uid == background.uid) {
      multiselect = false;
      _selections.clear();
      _selections.add(background.uid);
    } else {
      if (multiselect) {
        if (isSelected(widget)) {
          _selections.remove(widget.uid);
        } else {
          _selections.add(widget.uid);
        }
      } else {
        _selections = [widget.uid];
      }
    }
    updateGrids();
    page.updateListeners(PageChange.selection);
  }

  T? get<T extends CreatorWidget>(String uid) => _widgets[uid] as T;

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
  void add(CreatorWidget widget) {
    // Add a listener for that widget here
    multiselect = false;
    _widgets[widget.uid] = widget;
    sortedUIDs.add(widget.uid);
    select(widget);
    rebuildListeners();
    page.history.log('Add widget');
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
    page.history.log('Delete widget');
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
  }

  /// Generates a list with all the selected widgets in JSON format
  /// 
  /// See the example below for the use case of this method. (To be used in `CreatorPage.toJSON`)
  /// ```
  /// {
  ///   ...
  ///   "widgets": widgetManager.toJSON()
  /// }
  /// ```
  List<Map<String, dynamic>> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) {
    List<Map<String, dynamic>> widgetData = [];
    for (String uid in sortedUIDs) {
      CreatorWidget widget = _widgets[uid]!;
      widgetData.add(widget.toJSON(buildInfo: buildInfo));
    }
    return widgetData;
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
    return sortedUIDs.map((uid) => WidgetState(
      key: UniqueKey(),
      controller: _widgets[uid]!.stateCtrl,
      widget: _widgets[uid]!,
      page: page,
      isInteractive: isInteractive,
    )).toList();
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
    _selections.add(background.uid);
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