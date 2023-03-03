import 'package:flutter/material.dart';

import '../../rehmat.dart';

class ShapeWidget extends CreatorWidget {

  ShapeWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page,
    String? shape
  }) async {
    shape ??= await _openShapeSelector(context);
    if (shape == null) return;
    ShapeWidget widget = ShapeWidget(page: page);
    widget.shape = shape;
    page.widgets.add(widget);
  }

  static Future<String?> _openShapeSelector(BuildContext context) => Alerts.modal(
    context,
    title: 'Shape',
    childBuilder: (context, setState) => SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => InkWellButton(
          onTap: () => Navigator.of(context).pop(RenderShapeAbstract.names[index]),
          radius: BorderRadius.circular(10),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: CreativeShape(
                    name: RenderShapeAbstract.names[index],
                    color: Palette.of(context).onSurfaceVariant
                  ),
                ),
              ),
            ),
          ),
        ),
        itemCount: RenderShapeAbstract.names.length,
      ),
    ),
  );

  @override
  void onInitialize() {
    color = page.palette.primary;
    super.onInitialize();
  }

  // Inherited
  final String name = 'Shape';
  @override
  final String id = 'shape';

  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  late Color color;

  late String shape;

  ShapeShadow? shadow;
  
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
            String? _shape = await _openShapeSelector(context);
            if (_shape == null) return;
            shape = _shape;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.replace
        ),
        Option.color(
          title: 'Color',
          tooltip: 'Tap to select asset color',
          palette: page.palette,
          onChange: (_color) async {
            if (_color == null) return;
            color = _color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
      tab: 'Shape',
    ),
    EditorTab.adjustTab(widget: this)
  ];

  @override
  Widget widget(BuildContext context) => CustomPaint(
    painter: CreativeShape(
      color: color,
      name: shape,
      shadow: shadow
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