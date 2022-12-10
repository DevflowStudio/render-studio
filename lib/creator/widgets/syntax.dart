import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreatorWidgetSyntax extends CreatorWidget {

  CreatorWidgetSyntax({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorWidgetSyntax widget = CreatorWidgetSyntax(page: page);
    page.widgets.add(widget);
  }

  // Inherited
  final String name = 'Example Widget';
  @override
  final String id = 'example';

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
        ... defaultOptions,
      ],
      tab: 'Example Widget',
    ),
    EditorTab(
      tab: 'Adjust',
      options: [
        Option.rotate(
          widget: this,
        ),
        Option.scale(
          widget: this,
        ),
        Option.opacity(
          widget: this,
        ),
        Option.nudge(
          widget: this,
        ),
      ]
    )
  ];

  @override
  Widget widget(BuildContext context) => Container();

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      // Build properties from JSON here ...
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}