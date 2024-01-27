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
      id = generateID();
      widgets = WidgetManager.create(this, data: data);
      editorManager = EditorManager.create(this);
      buildWidgets();
      history = History.create(this, data: data);
    } else {
      history = History.create(this, data: data);
      widgets = WidgetManager.create(this, data: data);
      editorManager = EditorManager.create(this);
      buildWidgets();
    }
    
  }

  ScreenshotController screenshotController = ScreenshotController();
  
  final Project project;

  late final String id;

  /// List of all the widgets in the page
  late WidgetManager widgets;

  late EditorManager editorManager;

  late GridState gridState;

  ColorPalette palette = ColorPalette.defaultSet;

  PageType? pageType;
  String? pageTypeComment;

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
    required String path,
    bool saveToGallery = false,
    ExportQuality quality = ExportQuality.onex,
  }) async {
    widgets.select();
    String _filename = 'page-${Constants.generateID(3)}.png';
    double pixelRatio = quality.pixelRatio(context, project);
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
      await pathProvider.saveToDocumentsDirectory(path + _filename, bytes: bytes);
      if (saveToGallery) await ImageGallerySaver.saveImage(bytes, quality: 100, name: project.title);
      DateTime _end = DateTime.now();
      analytics.logProcessingTime('page_export', duration: _end.difference(_start));
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to save page', stacktrace: stacktrace);
      return null;
    }
    notifyListeners(PageChange.selection);
    return _filename;
  }

  void onSizeChange(PostSize oldSize, PostSize newSize) {
    for (CreatorWidget widget in widgets.widgets) {
      widget.onProjectSizeChange(oldSize, newSize);
    }
    notifyListeners(PageChange.update);
  }

  Map<String, dynamic> toJSON([BuildInfo buildInfo = BuildInfo.unknown]) => {
    'id': id,
    ... widgets.toJSON(buildInfo),
    'palette': palette.toJSON(),
    'page-type': pageType?.name,
    'page-type-comment': pageTypeComment,
  };

  /// Builds a page from scratch using the JSON data provided
  /// Returns a new `CreatorPage`
  /// Return `null` if the build fails. In this case, warn the user that this project has been corrupted
  static Future<CreatorPage?> fromJSON(Map<String, dynamic> data, {
    required Project project,
  }) async {
    try {
      CreatorPage page = CreatorPage(project: project, data: data);
      if (data['id'] != null) page.id = data['id'];
      else page.id = generateID();
      page.palette = ColorPalette.fromJSON(data['palette']);
      if (data['page-type'] != null) page.pageType = PageTypeExtension.fromString(data['page-type']);
      page.pageTypeComment = data['page-type-comment'];
      return page;
    } on WidgetCreationException catch (e, stacktrace) {
      analytics.logError(e, cause: 'error building page', stacktrace: stacktrace);
      project.issues.add(Exception('Failed to build page.'));
      print('Failed to build page. Error: $e');
      return null;
    }
  }

  static String generateID() => 'page#${Constants.generateID(4)}';

}

enum PageChange {
  selection,
  update,
  misc,
  editor
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

/// The type of page, used in TemplateKit to help AI determine the type of content to generate for the page
enum PageType {
  introduction,
  content,
  contact,
  conclusion,
  image
}

extension PageTypeExtension on PageType {

  String get name {
    switch (this) {
      case PageType.introduction:
        return 'introduction';
      case PageType.content:
        return 'content';
      case PageType.contact:
        return 'contact';
      case PageType.conclusion:
        return 'conclusion';
      case PageType.image:
        return 'image';
    }
  }

  String get title {
    switch (this) {
      case PageType.introduction:
        return 'Introduction';
      case PageType.content:
        return 'Content';
      case PageType.contact:
        return 'Contact';
      case PageType.conclusion:
        return 'Conclusion';
      case PageType.image:
        return 'Image';
    }
  }

  static PageType? fromString(String type) {
    switch (type) {
      case 'introduction':
        return PageType.introduction;
      case 'content':
        return PageType.content;
      case 'contact':
        return PageType.contact;
      case 'conclusion':
        return PageType.conclusion;
      case 'image':
        return PageType.image;
      default:
        return null;
    }
  }

}