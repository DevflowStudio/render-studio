import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:render_studio/creator/helpers/image_provider.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';

class ImageWidget extends CreatorWidget {

  ImageWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page,
    File? file,
    AssetX? asset,
  }) async {
    ImageWidget image = ImageWidget(page: page);
    if (asset == null && file == null) {
      file = await FilePicker.imagePicker(context, crop: true, forceCrop: false);
      if (file == null) return;
      if (page.project.isTemplateKit) {
        String? matchedSize = await matchToRecommenedRatio(file);
        if (matchedSize == null) {
          file = await _templateKitCropper(context, file);
          matchedSize = await matchToRecommenedRatio(file);
        }
        image.imageVariableSize = matchedSize;
      }
    }
    if (asset == null) asset = await AssetX.create(file: file, project: page.project, buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));;
    image.provider = CreativeImageProvider.create(image);
    image.asset = asset;
    image.size = page.project.contentSize/2;
    await image.resizeByImage();
    page.widgets.add(image);
  }

  static Future<String?> matchToRecommenedRatio(File file) async {
    Size? size = await AssetX.getDimensions(file);
    if (size == null) return null;
    double ratio = size.width / size.height;
    Map<double, String> ratioMap = {
      1: '1024x1024',
      1024/1792: '1024x1792',
      1792/1024: '1792x1024'
    };
    if (ratioMap.containsKey(ratio)) return ratioMap[ratio];
    return null;
  }

  /// Used to suggest user to crop the image to ratio supported by AI Image Generators (DALL-E 3)
  static Future<File> _templateKitCropper(BuildContext context, File file) async {
    if (await matchToRecommenedRatio(file) != null) return file;
    Map<String, Map> options = {
      'Square': {
        'ratio': 1.0,
        'ex_size': '1024x1024'
      },
      'Portrait': {
        'ratio': 1024/1792,
        'ex_size': '1024x1792'
      },
      'Landscape': {
        'ratio': 1792/1024,
        'ex_size': '1792x1024'
      }
    };

    bool crop = await Alerts.showConfirmationDialog(
      context,
      title: 'Image Ratio',
      message: 'Render recommends square, tall or wide ratios for using images in Template Kit. AI generated images are only supported in these ratios. Using other ratios might result in chopped images.',
      cancelButtonText: 'Use Original',
      confirmButtonText: 'Crop'
    );
    if (!crop) return file;

    String? newRatioString = await Alerts.optionsBuilder(
      context,
      title: 'Image Ratio',
      options: [
        for (String key in options.keys) AlertOption(
          title: '$key (${options[key]!['ex_size']})',
          id: key
        )
      ]
    );
    if (newRatioString == null) return file;

    double newRatio = options[newRatioString]!['ratio'];
    File? cropped = await FilePicker.crop(context, file: file, forceCrop: true, ratio: CropAspectRatio(ratioX: newRatio, ratioY: 1));

    return cropped ?? file;
  }

  // Inherited
  @override
  final String name = 'Image';

  @override
  final String id = 'image';

  bool isVariableWidget = true;

  _ImageVariableType? imageVariableType;
  String? imageVariableSize;

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

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      name: 'Image',
      options: [
        Option.button(
          title: 'Replace',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(
              context,
              crop: true,
              forceCrop: false,
              cropRatio: CropAspectRatio(
                ratioX: size.width,
                ratioY: size.height
              ),
            );
            if (file == null) return;
            if (page.project.isTemplateKit) {
              file = await _templateKitCropper(context, file);
              imageVariableSize = await matchToRecommenedRatio(file);
            }
            asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            await resizeByImage();
            updateListeners(WidgetChange.update, historyMessage: 'Replace Image');
          },
          icon: RenderIcons.replace,
          tooltip: 'Replace Image'
        ),
        Option.button(
          title: 'Variable',
          tooltip: 'Change text variable type',
          onTap: (context) async {
            if (imageVariableType == null) {
              imageVariableType = _ImageVariableType.constant;
              isVariableWidget = false;
            }
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.pickerBuilder(
                title: 'Variability',
                childCount: _ImageVariableType.values.length,
                initialIndex: _ImageVariableType.values.indexOf(imageVariableType!),
                itemBuilder: (context, index) {
                  return Text(
                    _ImageVariableType.values[index].title,
                  );
                },
                onSelectedItemChanged: (index) {
                  imageVariableType = _ImageVariableType.values[index];
                },
              ),
              onDismiss: () {
                if (imageVariableType == _ImageVariableType.constant) {
                  isVariableWidget = false;
                  Alerts.snackbar(context, text: 'This widget has been updated to use static image, it will be excluded from project variables. Comment box disabled');
                } else isVariableWidget = true;
                updateListeners(WidgetChange.update, historyMessage: 'Change Variable Type');
                if (imageVariableType == _ImageVariableType.dynamic) Alerts.snackbar(context, text: 'AI generated image might be used for this widget, consider adding a comment to help the AI generate better images.');
              }
            );
          },
          icon: RenderIcons.variable
        ),
        Option.button(
          icon: RenderIcons.crop,
          title: 'Crop',
          tooltip: 'Tap to crop image',
          onTap: (context) async {
            if (asset!.assetType == AssetType.url) await asset!.convertToFileType();
            try {
              File? cropped = await FilePicker.crop(context, file: asset!.file!);
              if (cropped == null) return;
              asset!.logVersion(version: page.history.nextVersion ?? '', file: cropped);
              await resizeByImage();
              updateListeners(WidgetChange.update, historyMessage: 'Crop');
            } catch (e) {
            }
          },
        ),
        Option.showSlider(
          this,
          icon: RenderIcons.border_radius,
          title: 'Radius',
          max: 100,
          min: 0,
          value: borderRadius,
          onChange: (value) {
            borderRadius = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
        ),
        ... defaultOptions,
      ],
    ),
    provider.editor(
      asset!,
      onChange: (change, {historyMessage}) {
        updateListeners(change, historyMessage: historyMessage);
      },
      name: 'Edit'
    ),
    EditorTab.adjustTab(widget: this)
  ];

  double borderRadius = 0;

  late CreativeImageProvider provider;

  @override
  Widget widget(BuildContext context) {
    return SmoothClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      smoothness: 0.6,
      child: provider.build(
        asset!,
        size: size,
      )
    );
  }

  Future<void> resizeByImage() async {
    Size? dimensions = await asset!.dimensions;
    if (dimensions != null) {
      Size _size;
      if (dimensions.height > dimensions.width) _size = Size(size.height * dimensions.width/dimensions.height, size.height);
      else _size = Size(size.width, size.width * dimensions.height/dimensions.width);
      size = _size;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void loadVariables(Map<String, dynamic> variable) {
    super.loadVariables(variable);
    String? url = variable['url'];
    if (url != null) {
      this.asset = AssetX.create(
        project: page.project,
        url: url,
        fileType: FileType.image
      );
      provider = CreativeImageProvider.create(this);
    }
  }

  @override
  Map<String, dynamic> getVariables() {
    if (imageVariableType == null) throw 'Image variability not declared';
    return {
      ... super.getVariables(),
      'type': 'asset',
      'asset-type': 'image',
      'size': imageVariableSize ?? '1012x1024',
    };
  }

  @override
  List<String>? getFeatures() => imageVariableType != null && imageVariableType != _ImageVariableType.constant ? ['image'] : null;

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    double _borderRadius = this.borderRadius;
    if (buildInfo.buildType == BuildType.save) {
      _borderRadius = page.project.sizeTranslator.getUniversalValue(value: _borderRadius);
    }
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'radius': _borderRadius,
      'provider': provider.toJSON(),
      'variable-image-type': imageVariableType?.name,
    };
  }

  @override
  Future<void> onDuplicate() async {
    asset = await asset!.duplicate(buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));
    updateListeners(WidgetChange.misc);
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    bool isBuildingFromUniversalBuild = json['properties']['is-universal-build'] ?? false;
    if (asset == null) throw WidgetCreationException('Could not build Design Asset. File may have been deleted.');
    borderRadius = json['radius'] ?? 0;
    if (isBuildingFromUniversalBuild) {
      borderRadius = page.project.sizeTranslator.getLocalValue(value: borderRadius);
    }
    if (json['variable-image-type'] != null) {
      imageVariableType = _ImageVariableTypeHelpers.fromName(json['variable-image-type']);
    }
    provider = CreativeImageProvider.fromJSON(json['provider'] ?? {}, widget: this);
  }

}

/// Used by Template Kit AI to generate images for this widget, if the selected type is dynamic
enum _ImageVariableType {
  dynamic,
  constant
}

extension _ImageVariableTypeHelpers on _ImageVariableType {

  String get title {
    switch (this) {
      case _ImageVariableType.dynamic:
        return 'Dynamic';
      case _ImageVariableType.constant:
        return 'Constant';
    }
  }

  String get name {
    switch (this) {
      case _ImageVariableType.dynamic:
        return 'dynamic';
      case _ImageVariableType.constant:
        return 'constant';
    }
  }

  static _ImageVariableType fromName(String name) {
    switch (name) {
      case 'dynamic':
        return _ImageVariableType.dynamic;
      case 'constant':
        return _ImageVariableType.constant;
      default:
        throw ArgumentError('Invalid name');
    }
  }

}