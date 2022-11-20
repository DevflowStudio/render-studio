import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import '../../rehmat.dart';

class CreatorDesignAsset extends CreatorWidget {

  CreatorDesignAsset({required CreatorPage page, Map? data}) : super(page, data: data);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorDesignAsset designAsset = CreatorDesignAsset(page: page);
    Asset? _asset = await CreatorDesignAsset.buildOptionsForAsset(context, page: page);
    if (_asset == null) return null;
    designAsset.asset = _asset;
    page.addWidget(designAsset);
  }

  // Inherited
  String name = 'Design Asset';
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
          onTap: (context) async {
            Asset? _asset = await CreatorDesignAsset.buildOptionsForAsset(context, page: page);
            if (_asset == null) return null;
            await asset.delete();
            asset = _asset;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.replace
        ),
        Option.color(
          title: 'Color',
          tooltip: 'Tap to select asset color',
          onChange: (_color) async {
            if (_color == null) return;
            color = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: RenderIcons.delete,
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

  @override
  void buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
    try {
      Asset? _asset = project.assetManager.get(json['asset']);
      if (_asset == null) throw WidgetCreationException('Could not build Design Asset. File may have been deleted.');
      else asset = _asset;
      if (json['color'] != null) color = HexColor.fromHex(json['color']);
    } catch (e) {
      analytics.logError(e, cause: 'error building design asset from json');
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

  static Future<Asset?> buildOptionsForAsset(BuildContext context, {
    required CreatorPage page
  }) async {
    String? option = await Alerts.optionsBuilder(
      context,
      title: 'Design Asset',
      options: [
        AlertOption(title: 'Choose SVG', id: 'svg'),
        AlertOption(title: 'IconFinder', id: 'iconfinder'),
      ]
    );
    Asset? asset;
    switch (option) {
      case 'svg':
        asset = await Asset.pick(page.project, type: FileType.svg, context: context);
        break;
      case 'iconfinder':
        asset = await AppRouter.push(context, page: IconFinderScreen(project: page.project,));
        break;
      default:
    }
    return asset;
  }

}