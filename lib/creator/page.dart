import 'package:flutter/foundation.dart';
import 'package:render_studio/creator/helpers/history.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:render_studio/creator/helpers/widget_manager.dart';
import 'package:screenshot/screenshot.dart';

import '../rehmat.dart';

class CreatorPage extends PropertyChangeNotifier {

  CreatorPage({
    required this.project,
    Map<String, dynamic>? data
  }) {

    gridState = GridState(
      page: this
    );

    if (data == null) {
      widgets = WidgetManager.create(this, data: data);
      history = History.build(this, data: data);
    } else {
      history = History.build(this, data: data);
      widgets = WidgetManager.create(this, data: data);
    }
    
  }

  ScreenshotController screenshotController = ScreenshotController();
  
  final Project project;

  /// List of all the widgets in the page
  late WidgetManager widgets;

  late GridState gridState;

  ColorPalette palette = ColorPalette.defaultSet;

  void updatePalette(ColorPalette palette) {
    this.palette = palette;
    widgets.forEach((widget) => widget.onPaletteUpdate());
    notifyListeners();
  }

  // BackgroundWidget get properties => BackgroundWidget(project: project, page: this);

  Widget build(BuildContext context, {
    bool isInteractive = true,
  }) {
    return AbsorbPointer(
      absorbing: !isInteractive,
      child: SizedBox.fromSize(
        size: project.contentSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ... widgets.build(context, isInteractive: isInteractive),
            PageGridView(state: gridState)
          ],
        ),
      ),
    );
  }

  /// Shows a grid and then hides it
  void showTemporaryGrid(Grid grid, {
    Duration? duration
  }) {
    if (!gridState.visible.contains(grid)) gridState.visible.add(grid);
    notifyListeners(PageChange.misc);
    Future.delayed(duration ?? Constants.animationDuration, () {
      if (gridState.visible.contains(grid)) gridState.visible.remove(grid);
      notifyListeners(PageChange.misc);
    });
  }

  void updateListeners(PageChange change) {
    notifyListeners(change);
  }

  @override
  void dispose() {
    widgets.dispose();
    super.dispose();
  }

  late History history;

  /// Saves the page to a file and returns the file path
  /// 
  /// Enable [saveToGallery] to also save the exported image to the gallery
  Future<String?> save(BuildContext context, {
    bool saveToGallery = false,
    bool autoExportQuality = true,
  }) async {
    widgets.select();
    String? _path;
    try {
      DateTime _start = DateTime.now();
      Uint8List bytes = await screenshotController.captureFromWidget(
        Material(
          child: build(context),
        ),
        context: context,
        pixelRatio: autoExportQuality ? preferences.exportQuality.pixelRatio(context) : MediaQuery.of(context).devicePixelRatio
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

  Map<String, dynamic> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) => {
    'widgets': widgets.toJSON(buildInfo),
    'palette': palette.toJSON(),
  };

  /// Builds a page from scratch using the JSON data provided
  /// Returns a new `CreatorPage`
  /// Return `null` if the build fails. In this case, warn the user that this project has been corrupted
  static Future<CreatorPage?> fromJSON(
    Map<String, dynamic> data, {
    required Project project,
  }) async {
    try {
      CreatorPage page = CreatorPage(project: project, data: data);
      page.palette = ColorPalette.fromJSON(data['palette']);
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
  update,
  misc
}

class PageCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  PageCreationException(this.message, {this.details, this.code});

}