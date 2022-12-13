import 'package:flutter/material.dart';

import '../../rehmat.dart';

class ShapeWidget extends CreatorWidget {

  ShapeWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    String? shape = await ShapeSelectorScreen.select(context);
    if (shape == null) return;
    ShapeWidget widget = ShapeWidget(page: page);
    widget.shape = shape;
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    color = page.palette.primary;
    super.onInitialize();
  }

  // Inherited
  final String name = 'Shape';
  @override
  final String id = 'shape';

  bool keepAspectRatio = false;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  late Color color;
  ShapeShadow? shadow;
  String shape = 'heart';
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ... ResizeHandler.values
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Replace',
          onTap: (context) async {
            String? _shape = await ShapeSelectorScreen.select(context);
            if (_shape == null) return;
            shape = _shape;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.replace
        ),
        Option.color(
          palette: page.palette,
          selected: color,
          onChange: (color) {
            if (color == null) return;
            this.color = color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) this.color = color;
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
      tab: 'Shape',
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
  Widget widget(BuildContext context) => Container(
    child: CustomPaint(
      painter: CreativeShape(
        color: color,
        name: shape,
        shadow: shadow
      ),
      child: SizedBox(
        width: size.width,
        height: size.height,
      ),
    ),
  );

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'color': color.toHex(),
    'shape': shape,
    'shadow': shadow?.toJSON(),
  };

  @override
  void onPaletteUpdate() {
    color = page.palette.primary;
    super.onPaletteUpdate();
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      color = HexColor.fromHex(json['color']);
      shape = json['shape'];
      if (shadow != null) shadow = ShapeShadow.fromJSON(json['shadow']);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to build widget from JSON', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}