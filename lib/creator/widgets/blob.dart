import 'dart:math';

import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreativeBlob extends CreatorWidget {

  CreativeBlob({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreativeBlob widget = CreativeBlob(page: page);
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    color = page.palette.onBackground;
    blobData = BlobGenerator(
      edgesCount: 7,
      minGrowth: 4,
      size: Size(30, 30),
    ).generate();
    controller = BlobController();
    super.onInitialize();
  }

  // Inherited
  final String name = 'Blob';
  @override
  final String id = 'blob';

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  late Color color;

  late BlobData blobData;

  late BlobController controller;

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Random',
          onTap: (context) {
            blobData = BlobGenerator(
              id: '${[4, 5, 6, 7, 8, 9, 10].getRandom()}-${[4, 5, 10].getRandom()}-${Random().nextInt(10000)}',
              size: size,
            ).generate();
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.random
        ),
        Option.color(
          selected: color,
          palette: page.palette,
          onChange: (color) {
            if (color != null) this.color = color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) this.color = color;
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
      tab: 'Blob',
    ),
    EditorTab.adjustTab(widget: this)
  ];

  @override
  Widget widget(BuildContext context) => Blob.fromID(
    id: [blobData.id ?? '4-5-10'],
    controller: controller,
    debug: preferences.debugMode,
    size: size.width,
    styles: BlobStyles(
      color: color,
    ),
  );

  @override
  void onPaletteUpdate() {
    color = page.palette.onBackground;
    super.onPaletteUpdate();
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'color': color.toHex(),
    'blob-id': blobData.id,
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      color = HexColor.fromHex(json['color']);
      blobData = BlobGenerator(
        id: json['blob-id'] ?? '4-5-10',
        size: size,
      ).generate();
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}