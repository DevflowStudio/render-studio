import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:render_studio/creator/widgets/qr.dart';

import '../../rehmat.dart';

class CreatorPageProperties extends CreatorWidget {

  CreatorPageProperties({required CreatorPage page, required Project project, uid}) : super(page: page, project: project, uid: uid);

  // Inherited
  final String name = 'Page';
  @override
  final String id = 'page';

  bool isResizable = false;
  bool isBackgroundWidget = true;
  bool isDraggable = false;

  @override
  bool allowClipboard = false;

  // New to CreatorPageProperties

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
          icon: Icons.add,
          title: 'Add',
          tooltip: 'Add a new widget',
          onTap: (context) async {
            CreatorWidget? widget = await showModalBottomSheet<CreatorWidget>(
              context: context,
              backgroundColor: Palette.of(context).surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Constants.borderRadius.bottomLeft)
              ),
              isScrollControlled: true,
              builder: (context) {
                Map<String, Map<String, dynamic>> _options = {
                  'Text': {
                    'icon': FontAwesomeIcons.font,
                    'onTap': () async {
                      Navigator.of(context).pop(CreatorText(page: page, project: project));
                    }
                  },
                  'Icon': {
                    'icon': FontAwesomeIcons.icons,
                    'onTap': () async { }
                  },
                  'Box': {
                    'icon': FontAwesomeIcons.shapes,
                    'onTap': () async {
                      Navigator.of(context).pop(CreatorBoxWidget(page: page, project: project));
                    }
                  },
                  'Design Asset': {
                    'icon': FontAwesomeIcons.compassDrafting,
                    'onTap': () async {
                      Navigator.of(context).pop(await CreatorDesignAsset.create(context, page: page, project: project));
                    }
                  },
                  'QR Code': {
                    'icon': FontAwesomeIcons.qrcode,
                    'onTap': () async {
                      String? _data = await showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        transitionDuration: const Duration(
                          milliseconds: 400,
                        ), // how long it takes to popup dialog after button click
                        pageBuilder: (_, __, ___) {
                          TextEditingController textCtrl = TextEditingController();
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Container(
                                color: Palette.of(context).surface.withOpacity(0.5),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: Column(
                                      children: [
                                        SafeArea(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                onPressed: Navigator.of(context).pop,
                                                icon: const Icon(Icons.cancel)
                                              ),
                                              IconButton(
                                                onPressed: () => Navigator.of(context).pop(textCtrl.text),
                                                icon: const Icon(Icons.check_circle)
                                              )
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        TextFormField(
                                          controller: textCtrl,
                                          decoration: const InputDecoration(
                                            filled: false,
                                            hintText: 'Type something ...',
                                            border: InputBorder.none,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: const TextStyle(
                                            fontSize: 30,
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                      if (_data != null) Navigator.of(context).pop(await QRWidget.create(context, page: page, project: project, data: _data));
                      else Navigator.of(context).pop();
                    }
                  }
                };
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      child: Label(label: 'Add Widget'),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) => SizedBox(
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.width/2,
                        child: InteractiveCard(
                          onTap: _options.values.toList()[index]['onTap'],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  _options.values.toList()[index]['icon'],
                                  size: 50,
                                ),
                                // Text(
                                //   _options.keys.toList()[index],
                                //   style: Theme.of(context).textTheme.subtitle1,
                                // )
                              ],
                            ),
                          )
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
            if (widget != null) page.addWidget(widget);
          },
        ),
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
                    leading: const Icon(Icons.color_lens),
                    title: const Text('Color'),
                    tileColor: Palette.of(context).surface,
                    onTap: () async {
                      TapFeedback.light();
                      Navigator.of(context).pop();
                      Color? _color = await Palette.showColorPicker(
                        context: context,
                        defaultColor: color
                      );
                      if (_color != null) {
                        changeBackgroundType(BackgroundType.color);
                        color = _color;
                        updateListeners(WidgetChange.update);
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.gradient),
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
                              icon: Icons.gradient,
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
                              icon: Icons.rotate_left,
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
          icon: Icons.palette
        ),
        Option.button(
          icon: Icons.image,
          title: 'Image',
          tooltip: 'Tap to select an image as background',
          onTap: (context) async {
            Asset? _asset = await Asset.create(project, context: context, type: FileType.image, crop: true, cropRatio: project.size!.cropRatio);
            if (_asset != null) {
              image = _asset;
              changeBackgroundType(BackgroundType.image);
              updateListeners(WidgetChange.update);
            }
          },
        ),
        Option.button(
          icon: Icons.delete,
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
    )
  ];

  @override
  Widget widget(BuildContext context) {
    if (image == null) type = BackgroundType.color;
    return Center(
      child: SizedBox.fromSize(
        size: project.contentSize(context),
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
    bool showGridLines = false
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

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
    'color': color.toHex(),
    'image': image?.id,
    'gradient': _generateGradientsHex()
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
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
      return true;
    } catch (e) {
      return false;
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