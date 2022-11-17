import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

// TODO: Add image widget
class ImageWidget extends CreatorWidget {

  ImageWidget({required CreatorPage page, Map? data}) : super(page, data: data);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    ImageWidget image = ImageWidget(page: page);
    Asset? _asset = await Asset.pick(page.project, context: context, type: FileType.image, crop: true);
    if (_asset == null) return null;
    image.asset = _asset;
    await image.resizeByImage();
    page.addWidget(image);
  }

  // Inherited
  final String name = 'Image';
  @override
  final String id = 'image';

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
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight
  ];

  late Asset asset;

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Edit',
          onTap: (context) async {
            Asset? _asset = await Asset.pick(page.project, context: context, type: FileType.image, crop: true);
            if (_asset == null) return null;
            await asset.delete();
            asset = _asset;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.brush,
          tooltip: 'Edit Image'
        ),
        Option.button(
          icon: Icons.crop,
          title: 'Crop',
          tooltip: 'Tap to crop image',
          onTap: (context) async {
            File? cropped = await FilePicker.crop(context, file: asset.file);
            if (cropped == null) return;
            asset.updateFile(cropped);
            await resizeByImage();
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Radius',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab(
                type: EditorTabType.single,
                options: [
                  Option.slider(
                    value: borderRadius,
                    min: 0,
                    max: 100,
                    onChange: (value) {
                      borderRadius = value;
                      updateListeners(WidgetChange.misc);
                    },
                    onChangeEnd: (value) {
                      borderRadius = value;
                      updateListeners(WidgetChange.update);
                    },
                  )
                ],
                tab: 'Radius'
              )
            );
          },
          icon: Icons.rounded_corner,
          tooltip: 'Adjust Widget Border Radius'
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
      tab: 'Image',
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

  double borderRadius = 0;

  @override
  Widget widget(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: OctoImage(
      image: FileImage(asset.file),
    ),
  );

  Future<void> resizeByImage() async {
    Size? dimensions = await asset.dimensions;
    if (dimensions != null) {
      Size _size;
      if (dimensions.height > dimensions.width) _size = Size(size.height * dimensions.width/dimensions.height, size.height);
      else _size = Size(size.width, size.width * dimensions.height/dimensions.width);
      size = _size;
    }
  }

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
    'asset': asset.id,
    'radius': borderRadius,
  };

  @override
  void buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
    try {
      Asset? _asset = project.assetManager.get(json['asset']);
      if (_asset == null) throw WidgetCreationException('Could not build Image. File may have been deleted.');
      else asset = _asset;
      borderRadius = json['radius'] ?? 0;
    } catch (e) {
      print('Error building widget from JSON: $e');
      throw WidgetCreationException(
        'Error building widget',
        details: 'Error building widget: $e'
      );
    }
  }

}