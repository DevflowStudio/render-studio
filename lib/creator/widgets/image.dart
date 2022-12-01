import 'dart:ui';

import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:on_image_matrix/on_image_matrix.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'dart:math' as math;

class ImageWidget extends CreatorWidget {

  ImageWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    ImageWidget image = ImageWidget(page: page);
    File? file = await FilePicker.imagePicker(context, crop: true);
    if (file == null) return;
    Asset _asset = await Asset.create(context, project: page.project, file: file, buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));
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
          title: 'Replace',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(context, crop: true);
            if (file == null) return;
            asset.logVersion(version: page.history.nextVersion ?? '', file: file);
            await resizeByImage();
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.replace,
          tooltip: 'Replace Image'
        ),
        Option.button(
          icon: RenderIcons.crop,
          title: 'Crop',
          tooltip: 'Tap to crop image',
          onTap: (context) async {
            File? cropped = await FilePicker.crop(context, file: asset.file);
            if (cropped == null) return;
            asset.logVersion(version: page.history.nextVersion ?? '', file: cropped);
            await resizeByImage();
            updateListeners(WidgetChange.update);
            // asset.updateFile(cropped);
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
          icon: RenderIcons.border_radius,
          tooltip: 'Adjust Widget Border Radius'
        ),
        Option.toggle(
          title: 'Flip Vertical',
          valueBuilder: () => flipVertical,
          onChange: (value) {
            flipVertical = value;
            updateListeners(WidgetChange.update);
          },
          enabledIcon: RenderIcons.flip_vertical,
          disabledIcon: RenderIcons.flip_vertical,
          enabledTooltip: 'Flip Vertically',
          disabledTooltip: 'Flip Vertically',
        ),
        Option.toggle(
          title: 'Flip Horizontal',
          valueBuilder: () => flipHorizontal,
          onChange: (value) {
            flipHorizontal = value;
            updateListeners(WidgetChange.update);
          },
          enabledIcon: RenderIcons.flip_horizontal,
          disabledIcon: RenderIcons.flip_horizontal,
          enabledTooltip: 'Flip Horizontally',
          disabledTooltip: 'Flip Horizontally',
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
      tab: 'Image',
    ),
    EditorTab(
      tab: 'Properties',
      options: [
        Option.showSlider(
          icon: RenderIcons.brightness,
          title: 'Brightness',
          max: 0.25,
          min: -0.25,
          value: brightness,
          onChange: (value) {
            brightness = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            brightness = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.contrast,
          title: 'Contrast',
          max: 0.25,
          min: -0.25,
          value: contrast,
          onChange: (value) {
            contrast = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            contrast = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.exposure,
          title: 'Exposure',
          max: 1,
          min: -1,
          value: exposure,
          onChange: (value) {
            exposure = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            exposure = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.saturation,
          title: 'Saturation',
          max: 1,
          min: -1,
          value: saturation,
          onChange: (value) {
            saturation = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            saturation = value;
            updateListeners(WidgetChange.update);
          },
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
          icon: RenderIcons.hue,
          title: 'Hue',
          max: 1,
          min: 0,
          value: hue,
          onChange: (value) {
            hue = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            hue = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Filters',
          onTap: (context) {
            EditorTab.modal(
              context,
              padding: EdgeInsets.zero,
              tab: EditorTab(
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
                          bottom: MediaQuery.of(context).padding.bottom
                        ),
                        child: SizedBox(
                          height: 150,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (context, index) => SizedBox(width: 4),
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                TapFeedback.light();
                                filter = filters[index];
                                updateListeners(WidgetChange.update);
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 150,
                                  maxHeight: 150,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _imageBuilder(
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
        )
      ]
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

  OnImageController controller = OnImageController();

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

  @override
  Widget widget(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: _imageBuilder(colorFilter: ColorFilter.matrix(matrix))
  );

  Widget _imageBuilder({
    required ColorFilter colorFilter,
    BoxFit fit = BoxFit.cover,
  }) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(flipHorizontal ? math.pi : 0)..rotateX(flipVertical ? math.pi : 0),
    child: ColorFiltered(
      colorFilter: colorFilter,
      child: OctoImage(
        fadeInCurve: Sprung(),
        fadeInDuration: Constants.animationDuration,
        image: FileImage(asset.file),
        placeholderBuilder: (context) => ClipRRect(
          child: Stack(
            children: [
              Container(
                // color: page.backround.color.withOpacity(0.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      page.palette.background.withAlpha(180).withOpacity(0.5),
                      page.palette.background.withOpacity(0.5),
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
  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false
  }) {
    if (change == WidgetChange.update) {
      asset.logVersion(version: page.history.nextVersion ?? '', file: asset.file);
    }
    super.updateListeners(change, removeGrids: removeGrids);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'asset': asset.id,
    'radius': borderRadius,
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

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    Asset? _asset = project.assetManager.get(json['asset']);
    if (_asset == null) throw WidgetCreationException('Could not build Image. File may have been deleted.');
    else asset = _asset;
    if (asset.history.isEmpty) {
      asset.history[page.history.dates.first.version ?? ''] = asset.file;
    }
    if (buildInfo.version != null) asset.restoreVersion(version: buildInfo.version!);
    borderRadius = json['radius'] ?? 0;
    brightness = json['brightness'] ?? 0;
    contrast = json['contrast'] ?? 0;
    exposure = json['exposure'] ?? 0;
    saturation = json['saturation'] ?? 0;
    visibility = json['visibility'] ?? 0;
    sepia = json['sepia'];
    hue = json['hue'] ?? 0;
    flipHorizontal = json['flipHorizontal'] ?? false;
    flipVertical = json['flipVertical'] ?? false;
    filter = json['filter'] != null ? ColorFilterGenerator(
      name: "Custom Filter",
      filters: [
        if (json['filter'] != null) json['filter'],
      ]
    ) : null;
  }

}