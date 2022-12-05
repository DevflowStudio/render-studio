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

  CreatorWidget? get(String uid) => _widgets[uid];

  /// Adds the given widget to the page
  void add(CreatorWidget widget) {
    // Add a listener for that widget here
    multiselect = false;
    _widgets[widget.uid] = widget;
    select(widget);
    rebuildListeners();
    page.history.log();
    page.updateListeners(PageChange.update);
  }

  void delete(CreatorWidget widget) {
    multiselect = false;
    widget.onDelete();
    _widgets.remove(widget.uid);
    page.history.log();
    select();
    rebuildListeners();
    page.updateListeners(PageChange.update);
  }

  void updateGrids() {
    page.gridState.reset();
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
  List<Map<String, dynamic>> toJSON() {
    List<Map<String, dynamic>> jsons = [];
    for (CreatorWidget widget in _widgets.values) {
      jsons.add(widget.toJSON());
    }
    return [
      ... jsons
    ];
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
  List<Widget> build(BuildContext context) => _widgets.values.map(
    (widget) => WidgetState(
      key: UniqueKey(),
      context: context,
      controller: widget.stateCtrl,
      creator_widget: widget,
      page: page
    )
  ).toList();

  /// This method rebuild all the widgets in the page from a previous state in the history.
  void restoreHistory(List<Map<String, dynamic>> data) {
    page.gridState.reset();
    _widgets.clear();
    for (Map widgetData in data) try {
      CreatorWidget widget = CreatorWidget.fromJSON(widgetData, page: page);
      if (widget is BackgroundWidget) {
        _background = widget.uid;
      }
      this._widgets[widget.uid] = widget;
      widget.updateGrids();
      widget.updateListeners(WidgetChange.misc);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'could not restore history', stacktrace: stacktrace);
      page.project.issues.add(Exception('${widgetData['name']} failed to rebuild'));
    }
    _selections = [];
    _selections.add(background.uid);
    page.updateListeners(PageChange.update);
  }

  /// Runs a function on every widget in the page.
  void forEach(void Function(CreatorWidget widget) callback) => _widgets.values.forEach(callback);
  
}