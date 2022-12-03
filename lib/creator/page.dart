import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:render_studio/creator/helpers/history.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/state.dart';
import 'package:screenshot/screenshot.dart';

import '../rehmat.dart';

class CreatorPage extends PropertyChangeNotifier {

  CreatorPage({
    required this.project,
    Map<String, dynamic>? data
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
    List<Map<String, dynamic>>? _data;
    if (data != null) {
      _data = [];
      for (Map map in data['widgets']) {
        _data.add(Map<String, dynamic>.from(map));
      }
    }
    history = History.build(this, data: _data);

    // Change the selection to page's background
    _selections = [backround.uid!];
    
    rebuildListeners();

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
    return SizedBox.fromSize(
      size: project.canvasSize(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ... List.generate(
            widgets.length,
            (index) => WidgetState(
              key: UniqueKey(),
              context: context,
              controller: widgets[index].stateCtrl,
              creator_widget: widgets[index],
              page: this
            )
          ),
          PageGridView(state: gridState)
        ],
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
      isScrollControlled: true,
      builder: (context) => _AddWidgetModal(),
      enableDrag: true
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
    rebuildListeners();
    history.log();
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
  void rebuildListeners() {
    removeListeners();
    addListeners();
  }

  void updateListeners(PageChange change) {
    notifyListeners(change);
  }

  /// Set the state of the page when a widget is updated.
  /// Also records history.
  void onWidgetUpdate() {
    // notifyListeners(PageChange.update);
    history.log();
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
    history.log();
    select(backround);
    rebuildListeners();
    notifyListeners(PageChange.update);
  }

  late History history;

  /// Saves the page to a file and returns the file path
  /// 
  /// Enable [saveToGallery] to also save the exported image to the gallery
  Future<String?> save(BuildContext context, {
    bool saveToGallery = false,
    bool autoExportQualtiy = true,
  }) async {
    multiselect = false;
    select(backround);
    String? _path;
    try {
      DateTime _start = DateTime.now();
      Uint8List bytes = await screenshotController.captureFromWidget(
        Material(
          child: build(context),
        ),
        context: context,
        pixelRatio: autoExportQualtiy ? preferences.exportQuality.pixelRatio(context) : MediaQuery.of(context).devicePixelRatio
      );
      _path = '/Render Projects/${project.id}/page-${Constants.generateID(3)}.png';
      await pathProvider.saveToDocumentsDirectory(_path, bytes: bytes);
      if (saveToGallery) await ImageGallerySaver.saveFile(pathProvider.generateRelativePath(_path));
      DateTime _end = DateTime.now();
      analytics.logProcessingTime('page_export', duration: _end.difference(_start));
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to save page', stacktrace: stacktrace);
      return null;
    }
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

  Future<Map<String, dynamic>> toJSON() async {
    List<Map<String, dynamic>> _widgets = [];
    for (var widget in widgets) {
      _widgets.add(await widget.toJSON());
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
  static Future<CreatorPage?> fromJSON(
    Map<String, dynamic> data, {
    required Project project,
  }) async {
    try {
      CreatorPage page = CreatorPage(project: project, data: data);
      List<CreatorWidget> widgets = [];
      data['widgets'].forEach((json) {
        try {
          BuildInfo info = BuildInfo(buildType: BuildType.restore);
          CreatorWidget _widget = CreatorWidget.fromJSON(json, page: page, buildInfo: info);
          widgets.add(_widget);
        } on WidgetCreationException catch (e, stacktrace) {
          project.issues.add(e);
          analytics.logError(e, cause: 'failed to restore widget', stacktrace: stacktrace);
        }
      });
      page.widgets = widgets;
      page.backround = widgets.where((element) => element.id == 'background').first as BackgroundWidget;
      page.palette = ColorPalette.fromJSON(data['palette']);
      // page.history = History.build(page);
      page.addListeners();
      page.select(page.backround);
      return page;
    } on WidgetCreationException catch (e, stacktrace) {
      analytics.logError(e, cause: 'error building page', stacktrace: stacktrace);
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