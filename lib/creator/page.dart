import 'package:flutter/foundation.dart';
import 'package:render_studio/creator/helpers/editor_manager.dart';
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
    Map<String, dynamic>? data,
    bool isFirstPage = false,
    bool addDefaultWidgets = true
  }) {

    gridState = GridState(
      page: this
    );

    void buildWidgets() {
      if (!isFirstPage) return;
      if (app.remoteConfig.showWatermark) RenderStudioWatermark.create(page: this);
      if (addDefaultWidgets) CreatorText.createDefaultWidget(page: this);
    }

    if (data == null) {
      assetManager = AssetManager.create(this);
      widgets = WidgetManager.create(this, data: data);
      editorManager = EditorManager.create(this);
      buildWidgets();
      history = History.create(this, data: data);
    } else {
      assetManager = AssetManager.fromJSON(this, data: data['assets']);
      history = History.create(this, data: data);
      widgets = WidgetManager.create(this, data: data);
      editorManager = EditorManager.create(this);
      buildWidgets();
    }
    
  }

  ScreenshotController screenshotController = ScreenshotController();
  
  final Project project;

  late AssetManager assetManager;

  /// List of all the widgets in the page
  late WidgetManager widgets;

  late EditorManager editorManager;

  late GridState gridState;

  ColorPalette palette = ColorPalette.defaultSet;

  void updatePalette(ColorPalette palette) {
    this.palette = palette;
    widgets.forEach((widget) => widget.onPaletteUpdate());
    notifyListeners();
  }

  // BackgroundWidget get properties => BackgroundWidget(project: project, page: this);

  double scale = 1;

  Widget build(BuildContext context, {
    bool isInteractive = true,
    bool isDimensionless = false,
  }) {
    return AbsorbPointer(
      absorbing: !isInteractive,
      child: _PageZoomableViewer(
        page: this,
        onScaleChange: (scale) {
          this.scale = scale;
          notifyListeners(PageChange.misc);
        },
        child: Center(
          child: widget(
            context,
            isInteractive: isInteractive,
            isDimensionless: isDimensionless
          ),
        ),
      ),
    );
  }

  Widget widget(BuildContext context, {
    bool isInteractive = true,
    bool isDimensionless = false,
  }) => Stack(
    children: [
      Center(
        child: widgets.buildWidgets(context, size: project.contentSize)
      ),
      ... widgets.buildHandlers(context, isInteractive: isInteractive),
      Center(
        child: PageGridView(state: gridState),
      )
    ],
  );

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
    double pixelRatio;
    if (autoExportQuality && preferences.exportQuality.name != 'default') {
      pixelRatio = preferences.exportQuality.pixelRatio(context);
    } else {
      pixelRatio = project.pixelRatio;
    }
    try {
      DateTime _start = DateTime.now();
      Uint8List bytes = await screenshotController.captureFromWidget(
        Material(
          child: SizedBox.fromSize(
            size: project.contentSize,
            child: widget(context)
          ),
        ),
        context: context,
        pixelRatio: pixelRatio
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

  void onSizeChange(PostSize oldSize, PostSize newSize) {
    for (CreatorWidget widget in widgets.widgets) {
      widget.onProjectSizeChange(oldSize, newSize);
    }
    notifyListeners(PageChange.update);
  }

  Map<String, dynamic> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) => {
    ... widgets.toJSON(buildInfo),
    'palette': palette.toJSON(),
    'assets': assetManager.toJSON(),
  };

  /// Builds a page from scratch using the JSON data provided
  /// Returns a new `CreatorPage`
  /// Return `null` if the build fails. In this case, warn the user that this project has been corrupted
  static Future<CreatorPage?> fromJSON(Map<String, dynamic> data, {
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

class _PageZoomableViewer extends StatefulWidget {

  const _PageZoomableViewer({
    required this.page,
    required this.child,
    this.onScaleChange,
  });

  final CreatorPage page;
  final Widget child;
  final Function(double scale)? onScaleChange;

  @override
  State<_PageZoomableViewer> createState() => __PageZoomableViewerState();
}

class __PageZoomableViewerState extends State<_PageZoomableViewer> {

  late CreatorPage page;

  void onMultiSelectChange() => setState(() { });

  bool get enableZoom => page.widgets.nSelections <= 1 && (page.widgets.selections.firstOrNull is BackgroundWidget || page.widgets.selections.isEmpty);

  double prevScale = 1;
  double scale = 1;

  @override
  void initState() {
    page = widget.page;
    page.widgets.addListener(onMultiSelectChange);
    super.initState();
  }

  @override
  void dispose() {
    page.widgets.removeListener(onMultiSelectChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: enableZoom,
      scaleEnabled: enableZoom,
      maxScale: 5,
      clipBehavior: Clip.antiAlias,
      onInteractionUpdate: (details) {
        if (details.pointerCount == 2) {
          scale = prevScale * details.scale;
        }
      },
      onInteractionEnd: (details) {
        if (scale < 1) {
          scale = 1;
          prevScale = 1;
        } else if (scale > 5) {
          scale = 5;
          prevScale = 5;
        } else {
          prevScale = scale;
        }
        widget.onScaleChange?.call(scale);
      },
      child: widget.child,
    );
  }

}