import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/rendering.dart';

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
    'color': (color ?? Colors.black).toHex(),
    'asset': asset.id,
  };

  static Future<CreatorDesignAsset?> create({
    required CreatorPage page,
    required Project project
  }) async {
    CreatorDesignAsset designAsset = CreatorDesignAsset(page: page, project: project);
    Asset? _asset = await Asset.create(project, type: FileType.svg);
    if (_asset == null) return null;
    designAsset.asset = _asset;
    return designAsset;
  }

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    if (super.buildFromJSON(json)) {
      if (json.containsKey('color') && json.containsKey('asset')) {
        Asset? _asset = project.assetManager.get(json['asset']);
        if (_asset == null) return false;
        else asset = _asset;
        color = HexColor.fromHex(json['color']);
        return true;
      } else return false;
    } else return false;
  }

}



/// 


typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}