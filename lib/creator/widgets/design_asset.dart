import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import '../../rehmat.dart';

class CreatorDesignAsset extends CreatorWidget {

  CreatorDesignAsset({required CreatorPage page, required Project project}) : super(page: page, project: project);

  // Inherited
  final String name = 'Design Asset';
  @override
  final String id = 'design_asset';

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  Color? color;

  late Asset asset;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Replace',
          tooltip: 'Replace the asset file',
          onTap: (context) async { },
          icon: Icons.change_circle
        ),
        Option.button(
          icon: Icons.palette,
          title: 'Color',
          tooltip: 'Tap to select asset color',
          onTap: (context) async {
            Color? _color = await Palette.showColorPicker(
              context: context,
              defaultColor: Colors.white,
              title: 'Select Color'
            );
            color = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete asset',
          onTap: (context) async {
            page.delete(this);
          },
        ),
      ],
      tab: 'Design Asset',
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
  Widget widget(BuildContext context) => MeasureSize(
    onChange: (size) { },
    child: SvgPicture.file(
      asset.file,
      color: color,
    )
  );

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
    'color': color?.toHex(),
    'asset': asset.id,
  };

  static Future<CreatorDesignAsset?> create(BuildContext context, {
    required CreatorPage page,
    required Project project,
  }) async {
    CreatorDesignAsset designAsset = CreatorDesignAsset(page: page, project: project);
    Asset? _asset = await Asset.create(project, type: FileType.svg, context: context);
    print(_asset);
    if (_asset == null) return null;
    designAsset.asset = _asset;
    return designAsset;
  }

  @override
  void buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
    try {
      Asset? _asset = project.assetManager.get(json['asset']);
      if (_asset == null) throw WidgetCreationException('Could not build Design Asset. File may have been deleted.');
      else asset = _asset;
      if (json['color'] != null) color = HexColor.fromHex(json['color']);
    } catch (e) {
      print('Error building Design Asset from JSON: $e');
      throw WidgetCreationException(
        'Error building Design Asset.',
        details: 'Error building Design Asset from JSON: $e'
      );
    }
  }

  @override
  void onDelete() {
    project.assetManager.delete(asset);
  }

}