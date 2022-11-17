import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:universal_io/io.dart';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:screenshot/screenshot.dart';

import '../rehmat.dart';

class CreatorPage extends PropertyChangeNotifier {

  CreatorPage({
    required this.project,
  }) {

    if (!initialisedBackground) {
      backround = BackgroundWidget(page: this);
      initialisedBackground = true;
    }

    // Add the background to page
    widgets = [
      backround
    ];

    // Create an initial history
    history = [_getJSON()];

    // Change the selection to page's background
    _selections = [backround.uid!];
    
    updateListeners();

    gridState = GridState(
      page: backround,
      project: project
    );
    
  }

  ScreenshotController screenshotController = ScreenshotController();

  /// Background widget for the page
  late BackgroundWidget backround;
  bool initialisedBackground = false;
  
  final Project project;

  /// List of all the widgets in the page
  late List<CreatorWidget> widgets;

  late GridState gridState;

  /// Display any important information as a chip
  // String? info = 'Multiselect Enabled';

  /// List of uid(s) of selected widgets
  late List<String> _selections;

  bool multiselect = false;

  bool locked = false;

  ColorPalette palette = ColorPalette.defaultSet;

  void updatePalette(ColorPalette palette) {
    this.palette = palette;
    for (CreatorWidget widget in widgets) {
      widget.onPaletteUpdate();
    }
    notifyListeners();
  }

  void toggleMultiselect() {
    if (multiselect) {
      // Disable
      _selections = [backround.uid!];
      multiselect = false;
    } else {
      // Enable
      if (selections.firstWhereOrNull((element) => element is BackgroundWidget) != null) _selections.clear();
      multiselect = true;
    }
    notifyListeners();
  }

  /// Widget which is currently selected
  /// The currently selected widget has a border around it and some drag balls to resize
  List<CreatorWidget> get selections {
    List<CreatorWidget> _results = widgets.where((widget) => _selections.contains(widget.uid)).toList();
    if (_results.isEmpty) {
      return [];
    } else {
      return _results;
    }
  }

  bool isSelected(CreatorWidget widget) {
    return _selections.contains(widget.uid);
  }
  
  void select(CreatorWidget widget) {
    if (multiselect) {
      if (widget is BackgroundWidget) {
        _selections = [widget.uid!];
        multiselect = false;
      } else {
        if (isSelected(widget)) {
          _selections.remove(widget.uid);
        } else {
          _selections.add(widget.uid!);
        }
      }
    } else {
      _selections = [widget.uid!];
    }
    gridState.grids.removeWhere((grid) => grid.widget is! BackgroundWidget);
    for (var widget in widgets) {
      widget.updateGrids();
    }
    gridState.visible.clear();
    widget.stateCtrl.update();
    notifyListeners(PageChange.selection);
  }

  // BackgroundWidget get properties => BackgroundWidget(project: project, page: this);

  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: locked,
      child: Screenshot(
        controller: screenshotController,
        child: SizedBox.fromSize(
          size: project.canvasSize(context),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              ... List.generate(
                widgets.length,
                (index) => WidgetState(
                  key: UniqueKey(),
                  context: context,
                  controller: widgets[index].stateCtrl,
                  creator_widget: widgets[index]
                )
              ),
              PageGridView(state: gridState)
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a grid and then hides it
  void showTemporaryGrid(Grid grid, {
    Duration? duration
  }) {
    if (!gridState.visible.contains(grid)) gridState.visible.add(grid);
    notifyListeners(PageChange.update);
    Future.delayed(duration ?? Constants.animationDuration, () {
      if (gridState.visible.contains(grid)) gridState.visible.remove(grid);
      notifyListeners(PageChange.update);
    });
  }

  Future<void> showAddWidgetModal(BuildContext context) async {
    String? id = await showModalBottomSheet(
      context: context,
      backgroundColor: Palette.of(context).background.withOpacity(0.5),
      barrierColor: Colors.transparent,
      // isScrollControlled: true,
      builder: (context) => _AddWidgetModal(),
    );
    if (id == null) return;
    await CreatorWidget.create(context, id: id, page: this);
  }

  /// Adds the given widget to the page
  void addWidget(CreatorWidget widget) {
    // Add a listener for that widget here
    multiselect = false;
    widgets.add(widget);
    select(widget);
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
    // notifyListeners(PageChange.update);
    _writeHistory();
  }

  /// This method is different from `onWidgetUpdate`.
  /// This is called when the widget is dragged, resized or rotated.
  /// This has to be separated because it does not record history.
  void onWidgetNotReallyUpdate() {
    // notifyListeners(PageChange.update);
  }

  @override
  void dispose() {
    removeListeners();
    super.dispose();
  }

  /// Delete widget from page
  void delete(CreatorWidget widget) {
    multiselect = false;
    widget.onDelete();
    widgets.remove(widget);
    _writeHistory();
    select(backround);
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
    multiselect = false;
    select(backround);
    historyDate -= 1;
    _doFromHistory(history[historyDate]);
    updateListeners();
    notifyListeners(PageChange.update);
  }

  void _redo() {
    multiselect = false;
    select(backround);
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
    notifyListeners(PageChange.update);
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
    for (Map<String, dynamic> json in jsons) try {
      CreatorWidget widget = CreatorWidget.fromJSON(json, page: this);
      _widgets.add(widget);
      print('added widget ${widget.id} #${widget.uid}');
    } on WidgetCreationException catch (e) {
      print(e.message);
      project.issues.add(Exception('${json['name']} failed to rebuild'));
    }
    widgets = _widgets;
    backround = _widgets.where((element) => element.id == 'background').first as BackgroundWidget;
    gridState.reset();
    widgets.forEach((widget) {
      widget.updateGrids();
      widget.updateListeners(WidgetChange.misc);
      // widget.stateCtrl.renewKey();
    });
    multiselect = false;
    select(backround);
    notifyListeners(PageChange.update);
  }

  /// Saves the page to a file and returns the file path
  /// 
  /// Enable [saveToGallery] to also save the exported image to the gallery
  Future<String?> save(BuildContext context, {
    String? path,
    bool saveToGallery = false,
    bool autoExportQualtiy = true,
  }) async {
    multiselect = false;
    locked = true;
    select(backround);
    String? _path;
    if (path != null) {
      _path = path;
    } else {
      _path = '${(await getApplicationDocumentsDirectory()).path}/Render Project ${project.id}/Thumbnail-${Constants.generateID(4)}.png';
    }
    try {
      Uint8List? data = await screenshotController.capture(
        pixelRatio: autoExportQualtiy ? preferences.exportQuality.pixelRatio(context) : MediaQuery.of(context).devicePixelRatio
      );
      if (data == null) return null;
      File file = await File(_path).create(recursive: true);
      _path = (await file.writeAsBytes(data)).path;
      if (saveToGallery) await ImageGallerySaver.saveFile(_path);
    } catch (e) {
      print("Save Failed: $e");
      return null;
    }
    locked = false;
    notifyListeners(PageChange.selection);
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
      'palette': palette.toJSON(),
    };
    return data;
  }

  /// Builds a page from scratch using the JSON data provided
  /// Returns a new `CreatorPage`
  /// Return `null` if the build fails. In this case, warn the user that this project has been corrupted
  static CreatorPage? fromJSON(
    Map<String, dynamic> json, {
    required Project project,
  }) {
    try {
      CreatorPage page = CreatorPage(project: project);
      List<CreatorWidget> widgets = [];
      json['widgets'].forEach((json) {
        try {
          CreatorWidget _widget = CreatorWidget.fromJSON(json, page: page);
          widgets.add(_widget);
        } on WidgetCreationException catch (e) {
          project.issues.add(e);
        }
      });
      page.widgets = widgets;
      page.backround = widgets.where((element) => element.id == 'background').first as BackgroundWidget;
      page.palette = ColorPalette.fromJSON(json['palette']);
      page.history = [page._getJSON()];
      page.addListeners();
      page.select(page.backround);
      return page;
    } on WidgetCreationException catch (e) {
      print('Error building page: ${e.message}');
      project.issues.add(Exception('Failed to build page.'));
      return null;
    }
  }

}

enum PageChange {
  selection,
  update
}

class PageCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  PageCreationException(this.message, {this.details, this.code});

}

class _AddWidgetModal extends StatelessWidget {

  _AddWidgetModal({Key? key}) : super(key: key);

  final Map<String, dynamic> widgets = {
    'text': {
      'title': 'Text',
      'icon': Icons.text_fields,
    },
    'qr_code': {
      'title': 'QR Code',
      'icon': Icons.qr_code,
    },
    'design_asset': {
      'title': 'Design Asset',
      'icon': Icons.design_services,
    },
    'image': {
      'title': 'Image',
      'icon': FontAwesomeIcons.image,
    },
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: GridView.builder(
              shrinkWrap: false,
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
        ),
      ),
    );
  }
}