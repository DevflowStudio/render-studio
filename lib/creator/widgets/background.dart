import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

class BackgroundWidget extends CreatorWidget {

  BackgroundWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  // Inherited
  final String name = 'Background';
  @override
  final String id = 'background';

  bool isResizable = false;
  bool isBackgroundWidget = true;
  bool isDraggable = false;

  @override
  bool allowClipboard = false;

  // New to BackgroundWidget

  /// Color of the page background
  Color color = Colors.white;

  List<Color>? gradient;
  BackgroundGradient gradientType = BackgroundGradient.type2;

  Asset? image;

  BackgroundType type = BackgroundType.color;

  @override
  Size get size => project.size!.size;
  
  @override
  List<EditorTab> get tabs => [
    EditorTab(
      tab: 'Page',
      options: [
        Option.button(
          icon: RenderIcons.add,
          title: 'Widget',
          tooltip: 'Add a new widget',
          onTap: (context) => page.showAddWidgetModal(context),
        ),
        Option.button(
          icon: RenderIcons.resize,
          title: 'Resize',
          tooltip: 'Tap to resize the project',
          onTap: (context) async {
            EditorTab.modal(
              context,
              tab: EditorTab.pickerBuilder(
                title: 'Resize Project',
                itemBuilder: (context, index) => Text('${PostSizePresets.values[index].title}'),
                childCount: PostSizePresets.values.length,
                onSelectedItemChanged: (index) {
                  project.size = PostSizePresets.values[index].toSize();
                  page.notifyListeners(PageChange.update);
                },
              )
            );
          },
        ),
        Option.button(
          icon: RenderIcons.palette,
          title: 'Palette',
          tooltip: 'Tap to shuffle palette',
          onTap: (context) async {
            await EditorTab.modal(
              context,
              tab: EditorTab.palette(
                page: page,
                onSelected: (palette) {
                  page.updatePalette(palette);
                  updateListeners(WidgetChange.misc);
                },
              ),
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 6,
                bottom: MediaQuery.of(context).padding.bottom
              )
            );
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: RenderIcons.delete,
          title: 'Delete Page',
          tooltip: 'Tap to delete this page',
          onTap: (context) async {
            if (project.pages.length == 1) {
              Alerts.snackbar(context, text: 'Cannot delete a single page');
              return;
            }
            bool delete = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Page?'),
                content: const Text('Are you sure you want to delete this page and all of it\'s content? This cannot be reverted.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel')
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete')
                  ),
                ],
              ),
            );
            if (delete) {
              project.pages.delete();
              Alerts.snackbar(context, text: 'Deleted page');
            }
          },
        ),
      ],
    ),
    EditorTab(
      tab: 'Background',
      options: [
        Option.button(
          title: 'Color',
          tooltip: 'Background Color',
          onTap: (context) async {
            await showModalBottomSheet<CreatorWidget>(
              context: context,
              backgroundColor: Palette.of(context).surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Constants.borderRadius.bottomLeft)
              ),
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Label(label: 'Background Color'),
                  ),
                  ListTile(
                    leading: const Icon(RenderIcons.color),
                    title: const Text('Color'),
                    tileColor: Palette.of(context).surface,
                    onTap: () async {
                      TapFeedback.light();
                      Navigator.of(context).pop();
                      Color? _color = await Palette.showColorPicker(
                        context,
                        selected: color,
                        palette: page.palette,
                      );
                      if (_color != null) {
                        changeBackgroundType(BackgroundType.color);
                        color = _color;
                        updateListeners(WidgetChange.update);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(RenderIcons.gradient),
                    title: const Text('Gradient'),
                    tileColor: Palette.of(context).surface,
                    onTap: () async {
                      TapFeedback.light();
                      Navigator.of(context).pop();
                      await EditorTab.modal(
                        context,
                        tab: EditorTab(
                          options: [
                            Option.button(
                              title: 'Style',
                              onTap: (_) async {
                                List<Color>? _gradients = await Navigator.of(context).push<List<Color>>(AppRouter(page: const GradientPicker()));
                                if (_gradients != null) {
                                  changeBackgroundType(BackgroundType.gradient);
                                  gradient = _gradients;
                                }
                                updateListeners(WidgetChange.misc);
                              },
                              tooltip: 'Select Gradient Color',
                              icon: RenderIcons.gradient,
                            ),
                            Option.button(
                              title: 'Rotate',
                              onTap: (_) async {
                                int i = BackgroundGradient.values.indexOf(gradientType);
                                i += 1;
                                if (i >= BackgroundGradient.values.length) i = 0;
                                gradientType = BackgroundGradient.values[i];
                                updateListeners(WidgetChange.misc);
                              },
                              tooltip: 'Select Gradient Color',
                              icon: RenderIcons.rotate,
                            ),
                          ],
                          tab: 'Background Gradient'
                        )
                      );
                      if (gradient == null) return;
                      if (gradient!.length < 2) {
                        changeBackgroundType(BackgroundType.color);
                        Alerts.snackbar(context, text: 'Gradient must have atleast 2 colors');
                      }
                      updateListeners(WidgetChange.update);
                    },
                  ),
                  Container(height: 20,)
                ],
              ),
            );
          },
          icon: RenderIcons.color
        ),
        Option.button(
          icon: RenderIcons.image,
          title: 'Image',
          tooltip: 'Tap to select an image as background',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: project.size!.cropRatio);
            if (file == null) return;
            Asset _asset = Asset.create(context, project: project, file: file, type: FileType.image);
            image = _asset;
            changeBackgroundType(BackgroundType.image);
            updateListeners(WidgetChange.update);
          },
        ),
      ]
    )
  ];

  @override
  Widget build(BuildContext context) => AlignPositioned(
    dx: position.dx,
    dy: position.dy,
    touch: Touch.inside,
    child: widget(context),
  );

  @override
  Widget widget(BuildContext context) {
    if (image == null) type = BackgroundType.color;
    return Center(
      child: SizedBox.fromSize(
        size: project.canvasSize(context),
        child: Container(
          decoration: BoxDecoration(
            color: type == BackgroundType.color ? color : Colors.white,
            image: type == BackgroundType.image ? DecorationImage(
              image: FileImage(image!.file),
              onError: (exception, stackTrace) {
                Alerts.snackbar(context, text: 'The background image could not be loaded. It might have been deleted.');
                changeBackgroundType(BackgroundType.color);
                updateListeners(WidgetChange.misc);
              },
            ) : null,
            gradient: (type == BackgroundType.gradient && gradient != null) ? LinearGradient(
              colors: gradient!,
              begin: gradientType.begin,
              end: gradientType.end,
            ) : null
          ),
        ),
      ),
    );
  }

  @override
  void updateGrids({
    bool showGridLines = false,
    bool snap = true,
    double? snapSensitivity,
  }) { }

  void changeBackgroundType(BackgroundType _type) {
    switch (_type) {
      case BackgroundType.color:
        image = null;
        gradient = null;
        break;
      case BackgroundType.image:
        gradient = null;
        break;
      case BackgroundType.gradient:
        image = null;
        break;
      default:
    }
    type = _type;
    updateListeners(WidgetChange.misc);
  }

  List<String>? _generateGradientsHex() {
    List<String> _generated = [];
    if (gradient == null) return null;
    for (Color color in gradient!) {
      _generated.add(color.toHex());
    }
    return _generated;
  }

  List<Color> _generateGradientsColor(List<String> hex) {
    List<Color> _generated = [];
    for (String h in hex) {
      _generated.add(HexColor.fromHex(h));
    }
    return _generated;
  }

  void onPaletteUpdate() {
    color = page.palette.background;
    updateListeners(WidgetChange.misc);
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'color': color.toHex(),
    'image': image?.id,
    'gradient': _generateGradientsHex()
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      color = HexColor.fromHex(json['color']);
      if (json['image'] != null) {
        image = project.assetManager.get(json['image']);
        type = BackgroundType.image;
      }
      if (json['gradient'] != null) {
        gradient = _generateGradientsColor(json['gradient']);
        type = BackgroundType.gradient;
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Error building background', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to create background widget',
        details: 'Error: $e'
      );
    }
  }

}

enum BackgroundType {
  color,
  gradient,
  image
}

enum BackgroundGradient {
  type1,
  type2,
  type3,
  type4,
}

extension BackgroundGradientExtension on BackgroundGradient {

  AlignmentGeometry get begin {
    switch (this) {
      case BackgroundGradient.type1:
        return Alignment.centerLeft;
      case BackgroundGradient.type2:
        return Alignment.topLeft;
      case BackgroundGradient.type3:
        return Alignment.topCenter;
      case BackgroundGradient.type4:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  AlignmentGeometry get end {
    switch (this) {
      case BackgroundGradient.type1:
        return Alignment.centerRight;
      case BackgroundGradient.type2:
        return Alignment.bottomRight;
      case BackgroundGradient.type3:
        return Alignment.bottomCenter;
      case BackgroundGradient.type4:
        return Alignment.bottomLeft;
      default:
        return Alignment.bottomRight;
    }
  }

}