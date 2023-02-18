import 'package:flutter/material.dart';

import '../../rehmat.dart';

class RenderStudioWatermark extends CreatorWidget {

  RenderStudioWatermark({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create({
    required CreatorPage page
  }) async {
    RenderStudioWatermark widget = RenderStudioWatermark(page: page);
    widget.color = page.palette.onBackground;
    page.widgets.add(widget, soft: true);
  }

  @override
  void onInitialize() {
    style = CreativeTextStyle(widget: this);
    style.color = page.palette.onBackground;
    super.onInitialize();
  }

  // Inherited
  final String name = 'Watermark';
  @override
  final String id = 'watermark';

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  Color? color;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.font(
          fontFamily: fontFamily,
          onChange: (change, font) {
            if (font != null) fontFamily = font;
            updateListeners(change);
          },
        ),
        ... style.getOptions(
          showStrikethrough: false,
          allowColorOpacity: false
        ),
        if (app.remoteConfig.allowDeleteWatermark) Option.button(
          title: 'Delete',
          onTap: (context) {
            page.widgets.delete(uid);
          },
          icon: RenderIcons.delete
        )
      ],
      tab: 'Watermark',
    ),
  ];

  String fontFamily = 'Inter';

  late CreativeTextStyle style;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: page.widgets.background.padding.bottom - 2,
    left: 0,
    right: 0,
    child: GestureDetector(
      onTap: () => page.widgets.select(this),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 6
          ),
          decoration: BoxDecoration(
            border: isSelected() ? Border.all(
              color: (page.palette.isLightBackground && page.widgets.background.type != BackgroundType.image ? Colors.grey[300]! : Colors.white),
              width: 1,
            ) : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isSelected() ? 0 : 1
            ),
            child: Text(
              'Render Studio',
              style: style.style(
                font: fontFamily,
                lineHeight: 1.0,
                fontSize: 14,
              )
            ),
          ),
        ),
      ),
    ),
  );

  @override
  void updateGrids({bool realtime = false, bool showGridLines = false, bool createGrids = true, bool snap = true, double? snapSensitivity, Offset? position}) { }

  @override
  void onPaletteUpdate() {
    super.onPaletteUpdate();
    style.color = page.palette.onBackground;
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'style': style.toJSON(),
    'font-family': fontFamily,
  };

  @override
  void buildFromJSON(Map<String, dynamic> data, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(data, buildInfo: buildInfo);
    try {
      fontFamily = data['font-family'] ?? 'Inter';
      style = CreativeTextStyle.fromJSON(data['style'], widget: this);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}