import 'dart:ui';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:octo_image/octo_image.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'dart:math' as math;

class CreativeImageProvider {

  CreativeImageProvider._(this.widget);
  final CreatorWidget widget;

  factory CreativeImageProvider.create(CreatorWidget widget) {
    return CreativeImageProvider._(widget);
  }

  double brightness = 0;
  double contrast = 0;
  double exposure = 0;
  double saturation = 0;
  double visibility = 0;
  double? sepia;
  double hue = 0;

  bool flipHorizontal = false;
  bool flipVertical = false;

  ColorFilterGenerator? filter;

  List<double> get matrix {
    ColorFilterGenerator myFilter = ColorFilterGenerator(
      name: "Custom Filter",
      filters: [
        ColorFilterAddons.brightness(brightness),
        ColorFilterAddons.contrast(contrast),
        ColorFilterAddons.saturation(saturation),
        ColorFilterAddons.hue(hue),
        if (sepia != null) ColorFilterAddons.sepia(sepia!),
        if (filter != null) filter!.matrix,
        // PresetFilters.ludwig.opacity(0.20),
      ]
    );
    return myFilter.matrix;
  }
  
  Map<String, dynamic> toJSON() => {
    'brightness': brightness,
    'contrast': contrast,
    'exposure': exposure,
    'saturation': saturation,
    'visibility': visibility,
    'sepia': sepia,
    'hue': hue,
    'flipHorizontal': flipHorizontal,
    'flipVertical': flipVertical,
    'filter': filter?.matrix,
  };

  static CreativeImageProvider fromJSON(Map data, {
    required CreatorWidget widget
  }) {
    CreativeImageProvider provider = CreativeImageProvider._(widget);
    provider.brightness = data['brightness'] ?? 0;
    provider.contrast = data['contrast'] ?? 0;
    provider.exposure = data['exposure'] ?? 0;
    provider.saturation = data['saturation'] ?? 0;
    provider.visibility = data['visibility'] ?? 0;
    provider.sepia = data['sepia'];
    provider.hue = data['hue'] ?? 0;
    provider.flipHorizontal = data['flipHorizontal'] ?? false;
    provider.flipVertical = data['flipVertical'] ?? false;
    provider.filter = data['filter'] != null ? ColorFilterGenerator(
      name: "Custom Filter",
      filters: [
        if (data['filter'] != null) (data['filter'] as List).toDataType<double>(),
      ]
    ) : null;
    return provider;
  }

  EditorTab editor(AssetX asset, {
    required void Function(WidgetChange change) onChange,
    String name = 'Image',
    List<Option> options = const [],
  }) => EditorTab(
    tab: name,
    type: EditorTabType.row,
    options: [
      Option.showSlider(
        widget,
        icon: RenderIcons.brightness,
        title: 'Brightness',
        max: 0.25,
        min: -0.25,
        value: brightness,
        onChange: (value) {
          brightness = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.showSlider(
        widget,
        icon: RenderIcons.contrast,
        title: 'Contrast',
        max: 0.25,
        min: -0.25,
        value: contrast,
        onChange: (value) {
          contrast = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.showSlider(
        widget,
        icon: RenderIcons.exposure,
        title: 'Exposure',
        max: 1,
        min: -1,
        value: exposure,
        onChange: (value) {
          exposure = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.showSlider(
        widget,
        icon: RenderIcons.saturation,
        title: 'Saturation',
        max: 1,
        min: -1,
        value: saturation,
        onChange: (value) {
          saturation = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      // Option.showSlider(
      //   icon: RenderIcons.visibility,
      //   title: 'Visibility',
      //   max: 1,
      //   min: -1,
      //   value: visibility,
      //   onChange: (value) {
      //     visibility = value;
      //     updateListeners(WidgetChange.misc);
      //   },
      //   onChangeEnd: (value) {
      //     visibility = value;
      //     updateListeners(WidgetChange.update);
      //   },
      // ),
      Option.showSlider(
        widget,
        icon: RenderIcons.hue,
        title: 'Hue',
        max: 1,
        min: 0,
        value: hue,
        onChange: (value) {
          hue = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      Option.button(
        title: 'Filters',
        onTap: (context) {
          widget.page.editorManager.openModal(
            padding: EdgeInsets.zero,
            tab: (context, setState) => EditorTab(
              tab: 'Filters',
              type: EditorTabType.single,
              options: [
                Option.custom(
                  widget: (context) {
                    List<ColorFilterGenerator> filters = [
                      PresetFilters.none,
                      PresetFilters.addictiveBlue,
                      PresetFilters.addictiveRed,
                      PresetFilters.aden,
                      PresetFilters.amaro,
                      PresetFilters.ashby,
                      PresetFilters.brannan,
                      PresetFilters.brooklyn,
                      PresetFilters.charmes,
                      PresetFilters.clarendon,
                      PresetFilters.crema,
                      PresetFilters.dogpatch,
                      PresetFilters.earlybird,
                      PresetFilters.f1977,
                      PresetFilters.gingham,
                      PresetFilters.ginza,
                      PresetFilters.hefe,
                      PresetFilters.helena,
                      PresetFilters.hudson,
                      PresetFilters.inkwell,
                      PresetFilters.juno,
                      PresetFilters.kelvin,
                      PresetFilters.lark,
                      PresetFilters.loFi,
                      PresetFilters.ludwig,
                      PresetFilters.maven,
                      PresetFilters.mayfair,
                      PresetFilters.moon,
                      PresetFilters.nashville,
                      PresetFilters.perpetua,
                      PresetFilters.reyes,
                      PresetFilters.rise,
                      PresetFilters.sierra,
                      PresetFilters.skyline,
                      PresetFilters.slumber,
                      PresetFilters.stinson,
                      PresetFilters.sutro,
                      PresetFilters.toaster,
                      PresetFilters.toaster,
                      PresetFilters.valencia,
                      PresetFilters.vesper,
                      PresetFilters.walden,
                      PresetFilters.willow,
                      PresetFilters.xProII,
                    ];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: Constants.of(context).bottomPadding
                      ),
                      child: SizedBox(
                        height: 150,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (context, index) => SizedBox(width: 4),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              TapFeedback.light();
                              filter = filters[index];
                              onChange(WidgetChange.update);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 150,
                                maxHeight: 150,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _imageBuilder(
                                  asset,
                                  colorFilter: ColorFilter.matrix(filters[index].matrix),
                                ),
                              ),
                            ),
                          ),
                          itemCount: filters.length,
                        ),
                      ),
                    );
                  },
                )
              ]
            )
          );
        },
        icon: RenderIcons.filter
      ),
      Option.divider(),
      Option.toggle(
        title: 'Flip Vertical',
        value: flipVertical,
        onChange: (value) {
          flipVertical = !flipVertical;
          onChange(WidgetChange.update);
        },
        enabledIcon: RenderIcons.flip_vertical,
        disabledIcon: RenderIcons.flip_vertical,
        enabledTooltip: 'Flip Vertically',
        disabledTooltip: 'Flip Vertically',
      ),
      Option.toggle(
        title: 'Flip Horizontal',
        value: flipHorizontal,
        onChange: (value) {
          flipHorizontal = !flipHorizontal;
          onChange(WidgetChange.update);
        },
        enabledIcon: RenderIcons.flip_horizontal,
        disabledIcon: RenderIcons.flip_horizontal,
        enabledTooltip: 'Flip Horizontally',
        disabledTooltip: 'Flip Horizontally',
      ),
      if (options.isNotEmpty) Option.divider(),
      ... options
    ]
  );

  Widget _imageBuilder(AssetX asset, {
    required ColorFilter colorFilter,
    BoxFit fit = BoxFit.cover,
    Size? size
  }) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(flipHorizontal ? math.pi : 0)..rotateX(flipVertical ? math.pi : 0),
    child: ColorFiltered(
      colorFilter: colorFilter,
      child: OctoImage(
        fadeInCurve: Sprung.overDamped,
        fadeInDuration: Constants.animationDuration,
        image: FileImage(asset.file),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5)
            ),
            child: Center(
              child: Icon(
                RenderIcons.error,
                color: Colors.black
              ),
            ),
          );
        },
        placeholderBuilder: (context) => ClipRRect(
          child: Stack(
            children: [
              Container(
                // color: page.background.color.withOpacity(0.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.page.palette.background.withAlpha(180).withOpacity(0.5),
                      widget.page.palette.background.withOpacity(0.5),
                    ]
                  )
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: SizedBox.fromSize(
                    size: size,
                    child: Container(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Spinner(
                    adaptive: true,
                  )
                ),
              )
            ],
          ),
        ),
        fit: fit,
      )
    ),
  );

  Widget build(AssetX asset, {
    required Size size,
  }) => _imageBuilder(
    asset,
    colorFilter: ColorFilter.matrix(matrix),
    size: size
  );

}

class ImageWidget extends CreatorWidget {

  ImageWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page,
    File? file
  }) async {
    ImageWidget image = ImageWidget(page: page);
    file ??= await FilePicker.imagePicker(context, crop: true);
    if (file == null) return;
    AssetX _asset = await AssetX.create(file, project: page.project, buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));
    image.provider = CreativeImageProvider.create(image);
    image.asset = _asset;
    image.size = page.project.contentSize/2;
    await image.resizeByImage();
    page.widgets.add(image);
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

  @override
  List<EditorTab> get tabs => [
    EditorTab(
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
            asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            await resizeByImage();
            updateListeners(WidgetChange.update, historyMessage: 'Replace Image');
          },
          icon: RenderIcons.replace,
          tooltip: 'Replace Image'
        ),
        Option.button(
          icon: RenderIcons.crop,
          title: 'Crop',
          tooltip: 'Tap to crop image',
          onTap: (context) async {
            File? cropped = await FilePicker.crop(context, file: asset!.file);
            if (cropped == null) return;
            asset!.logVersion(version: page.history.nextVersion ?? '', file: cropped);
            await resizeByImage();
            updateListeners(WidgetChange.update, historyMessage: 'Crop');
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
      tab: 'Image',
    ),
    provider.editor(
      asset!,
      onChange: (change) {
        updateListeners(change);
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
      'provider': provider.toJSON()
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
    provider = CreativeImageProvider.fromJSON(json['provider'] ?? {}, widget: this);
  }

}