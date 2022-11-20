import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreatorWidgetSyntax extends CreatorWidget {

  CreatorWidgetSyntax({required CreatorPage page, Map? data}) : super(page, data: data);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorWidgetSyntax widget = CreatorWidgetSyntax(page: page);
    page.addWidget(widget);
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
        Option.button(
          icon: RenderIcons.delete,
          title: 'Delete',
          tooltip: 'Delete asset',
          onTap: (context) async {
            page.delete(this);
          },
        ),
      ],
      tab: 'Example Widget',
    ),
    EditorTab(
      tab: 'Adjust',
      options: [
        Option.rotate(
          widget: this,
          project: project
        ),
        Option.scale(
          widget: this,
          project: project
        ),
        Option.opacity(
          widget: this,
          project: project
        ),
        Option.nudge(
          widget: this,
          project: project
        ),
      ]
    )
  ];

  @override
  Widget widget(BuildContext context) => Container();

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
  };

  @override
  void buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
    try {
      // Build properties from JSON here ...
    } catch (e) {
      analytics.logError(e, cause: 'Failed to build widget from JSON');
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}