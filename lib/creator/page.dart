import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:screenshot/screenshot.dart';

import '../rehmat.dart';

class CreatorPage extends PropertyChangeNotifier {

  CreatorPage({
    required this.project,
  }) {

    if (!initialisedBackground) {
      page = CreatorPageProperties(page: this, project: project);
      initialisedBackground = true;
    }

    // Add the background to page
    widgets = [
      page
    ];

    // Create an initial history
    history = [_getJSON()];

    // Change the selection to page's background
    _selected = page.uid!;
    
    updateListeners();

    grids.addAll([
      Grid(
        position: const Offset(0, 0),
        color: Colors.red,
        layout: GridLayout.vertical,
        widget: page,
        project: project,
        gridWidgetPlacement: GridWidgetPlacement.centerVertical
      ),
      Grid(
        position: const Offset(0, 0),
        color: Colors.red,
        layout: GridLayout.horizontal,
        widget: page,
        project: project,
        gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
      )
    ]);
  }

  ScreenshotController screenshotController = ScreenshotController();

  /// Background widget for the page
  late CreatorPageProperties page;
  bool initialisedBackground = false;
  
  final Project project;

  /// List of all the widgets in the page
  late List<CreatorWidget> widgets;

  late String _selected;

  /// Widget which is currently selected
  /// The currently selected widget has a border around it and some drag balls to resize
  CreatorWidget get currentSelection {
    List<CreatorWidget> _choices = widgets.where((widget) => widget.uid == _selected).toList();
    if (_choices.isEmpty) {
      return page;
    } else {
      return _choices.first;
    }
  }
  
  void changeSelection(CreatorWidget widget) {
    _selected = widget.uid!;
    grids.removeWhere((grid) => grid.widget is! CreatorPageProperties);
    for (var widget in widgets) {
      widget.updateGrids();
    }
    visibleGrids.clear();
    notifyListeners(PageChange.selection);
  }

  // CreatorPageProperties get properties => CreatorPageProperties(project: project, page: this);

  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: project.actualSize(context),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          ... List.generate(
            widgets.length,
            (index) => widgets[index].build(context)
          ),
          for (Grid grid in visibleGrids) AlignPositioned(
            dy: grid.position.dy,
            dx: grid.position.dx,
            child: grid.build(context)
          )
        ],
      ),
    );
  }

  List<Grid> grids = [];
  List<Grid> visibleGrids = [];

  /// Shows a grid and then hides it
  void showTemporaryGrid(Grid grid, {
    Duration? duration
  }) {
    if (!visibleGrids.contains(grid)) visibleGrids.add(grid);
    notifyListeners(PageChange.update);
    Future.delayed(duration ?? Constants.animationDuration, () {
      if (visibleGrids.contains(grid)) visibleGrids.remove(grid);
      notifyListeners(PageChange.update);
    });
  }

  /// Adds the given widget to the page
  void addWidget(CreatorWidget widget) {
    // Add a listener for that widget here
    widgets.add(widget);
    changeSelection(widget);
    updateListeners();
    _writeHistory();
    notifyListeners(PageChange.update);
  }

  /// Adds listener for every widget
  void addListeners() {
    for (CreatorWidget widget in widgets) {
      widget.addListener(onWidgetUpdate, [WidgetChange.update]);
      widget.addListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Removes listener for every single widget
  void removeListeners() {
    for (CreatorWidget widget in widgets) {
      widget.removeListener(onWidgetUpdate, [WidgetChange.update]);
      widget.removeListener(onWidgetNotReallyUpdate, [WidgetChange.resize, WidgetChange.drag, WidgetChange.rotate, WidgetChange.misc]);
    }
  }

  /// Updates listeners for all the widgets in the page.
  /// First all the listeners are removed and then new listeners are created
  void updateListeners() {
    removeListeners();
    addListeners();
  }

  /// Set the state of the page when a widget is updated.
  /// Also records history.
  void onWidgetUpdate() {
    notifyListeners(PageChange.update);
    _writeHistory();
  }

  /// This method is different from `onWidgetUpdate`.
  /// This is called when the widget is dragged, resized or rotated.
  /// This has to be separated because it does not record history.
  void onWidgetNotReallyUpdate() {
    notifyListeners(PageChange.update);
  }

  @override
  void dispose() {
    removeListeners();
    super.dispose();
  }

  /// Delete widget from page
  void delete(CreatorWidget widget) {
    widgets.remove(widget);
    _writeHistory();
    changeSelection(page);
    updateListeners();
    notifyListeners(PageChange.update);
  }

  // Undo Redo Functions

  int historyDate = 0;
  late List<List<Map<String, dynamic>>> history;

  bool get hasHistory => history.length > 1;

  bool get undoEnabled => historyDate > 0;

  bool get redoEnabled => history.length > historyDate + 1;

  Function()? get undoFuntion => undoEnabled ? _undo : null;
  Function()? get redoFuntion => redoEnabled ? _redo : null;

  void _undo() {
    changeSelection(page);
    historyDate -= 1;
    _doFromHistory(history[historyDate]);
    updateListeners();
    notifyListeners(PageChange.update);
  }

  void _redo() {
    changeSelection(page);
    historyDate += 1;
    _doFromHistory(history[historyDate]);
    updateListeners();
    notifyListeners(PageChange.update);
  }

  void _writeHistory() {
    if (history.length >= 20) history.removeAt(0);
    if (historyDate < history.length - 1) history.removeRange(historyDate + 1, history.length);
    List<Map<String, dynamic>> event = _getJSON();
    Function eq =  const DeepCollectionEquality().equals;
    if (!eq(event, history.last)) {
      history.add(event);
      historyDate = history.length - 1;
    }
  }

  List<Map<String, dynamic>> _getJSON() {
    List<Map<String, dynamic>> jsons = [];
    for (CreatorWidget widget in widgets) {
      jsons.add(widget.toJSON());
    }
    return jsons;
  }
  
  void _doFromHistory(List<Map<String, dynamic>> jsons) {
    List<CreatorWidget> _widgets = [];
    for (Map<String, dynamic> json in jsons) {
      CreatorWidget? widget = CreatorPage.createWidgetFromId(json['id'], page: this, project: project);
      if (widget != null) {
        widget.buildFromJSON(json);
        _widgets.add(widget);
      }
    }
    widgets = _widgets;
    page = widgets.where((element) => element.id == 'page').first as CreatorPageProperties;
    notifyListeners(PageChange.update);
  }

  static CreatorWidget? createWidgetFromId(String id, {
    required CreatorPage page,
    required Project project
  }) {
    switch (id) {
      case 'page':
        return CreatorPageProperties(page: page, project: project);
      case 'text':
        return CreatorText(page: page, project: project);
      default:
        return null;
    }
  }

  Future<String?> save(BuildContext context, {
    String? path,
    bool download = false
  }) async {
    changeSelection(page);
    String? _path;
    if (path != null) {
      _path = path;
    } else {
      _path = '${(await getApplicationDocumentsDirectory()).path}/Render Project ${project.id}/Thumbnail-${Constants.generateUID(4)}.png';
    }
    try {
      Uint8List data = await screenshotController.captureFromWidget(
        build(context),
        // delay: Duration(milliseconds: 50),
      );
      File file = await File(_path).create(recursive: true);
      _path = (await file.writeAsBytes(data)).path;
      if (download) await ImageGallerySaver.saveFile(_path);
    } catch (e) {
      return null;
    }
    return _path;
  }

  // Future<bool> saveToGallery(BuildContext context) async {
  //   try {
  //     Uint8List? image = await screenshotController.captureFromWidget(
  //       build(context),
  //       delay: Duration(milliseconds: 50),
  //     );
  //     final result = await ImageGallerySaver.saveImage(
  //       image,
  //       name: 'Render Project ${Constants.generateUID(5)}',
  //       quality: 100
  //     );
  //     if (result is Map && result['isSuccess'] == true) {
  //       return true;
  //     } else return false;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Map<String, dynamic> toJSON() {
    List<Map<String, dynamic>> _widgets = [];
    for (var widget in widgets) {
      _widgets.add(widget.toJSON());
    }
    Map<String, dynamic> data = {
      'widgets': _widgets,
    };
    return data;
  }

  /// Builds a page from scratch using the JSON data provided
  /// Returns a new `CreatorPage`
  /// Return `null` if the build fails. In this case, warn the user that this project has been corrupted
  static CreatorPage? buildFromJSON(
    Map<String, dynamic> json, {
    required Project project,
  }) {
    CreatorPage page = CreatorPage(project: project);
    List<CreatorWidget> widgets = [];
    bool success = true;
    json['widgets'].forEach((widget) {
      if (!success) return; // Don't continue if the build fails
      CreatorWidget? _widget = CreatorPage.createWidgetFromId(widget['id'], page: page, project: project);
      if (_widget == null) return;
      if (!_widget.buildFromJSON(Map.from(widget))) {
        // If the widget cannot be built, mark it as unsuccessful
        success = false;
      } else {
        widgets.add(_widget);
        // Updates the resize handlers and sorts them by size
        // All the unneccessary handlers will be removed if the widget is small in size
        _widget.updateResizeHandlers();
      }
    });
    if (!success) return null; // Return null because the build has failed
    page.widgets = widgets;
    page.page = widgets.where((element) => element.id == 'page').first as CreatorPageProperties;
    page.history = [page._getJSON()];
    page.addListeners();
    return page;
  }

}

enum PageChange {
  selection,
  update
}