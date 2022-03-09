import 'dart:io';

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

  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  Color? color;

  late File asset;
  
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
    )
  ];

  @override
  Widget widget(BuildContext context) => SvgPicture.file(
    asset,
  );

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    return super.buildFromJSON(json);
  }

  static Future<CreatorDesignAsset> create({
    required CreatorPage page,
    required Project project
  }) async {
    CreatorDesignAsset designAsset = CreatorDesignAsset(page: page, project: project);
    File svg = await Constants.getImageFileFromAssets('test_svg.svg');
    designAsset.asset = svg;
    return designAsset;
  }

}