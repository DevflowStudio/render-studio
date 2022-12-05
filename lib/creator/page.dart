import 'dart:ui';
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
      project: project
    );

    // Add the background to page
    widgets = WidgetManager.create(this, data: data);

    // Create an initial history
    List<Map<String, dynamic>>? _data;
    if (data != null) {
      _data = [];
      for (Map map in data['widgets']) {
        _data.add(Map<String, dynamic>.from(map));
      }
    }
    history = History.build(this, data: _data);
    
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

  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: project.canvasSize(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ... widgets.build(context),
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

  Map<String, dynamic> toJSON() => {
    'widgets': widgets.toJSON(),
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