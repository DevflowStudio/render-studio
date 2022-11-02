import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreatorBoxWidget extends CreatorWidget {

  CreatorBoxWidget({required CreatorPage page, required Project project, String? uid}) : super(page: page, project: project, uid: uid);

  // Inherited
  final String name = 'Box';
  @override
  final String id = 'box';

  bool keepAspectRatio = false;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 10);

  Color color = Colors.blue;

  List<Color>? gradient;
  BackgroundGradient gradientType = BackgroundGradient.type2;

  BackgroundType type = BackgroundType.color;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? shadow;
  
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
      tab: 'Box',
      options: [
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete asset',
          onTap: (context) async {
            page.delete(this);
          },
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
            if (_color != null) color = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Shadow',
          onTap: (context) {
            if (shadow == null) {
              shadow = const BoxShadow(
              blurRadius: 1,
              spreadRadius: 2,
              color: Colors.red,
            );
            }
            updateListeners(WidgetChange.misc);
            EditorTab.modal(
              context,
              height: 150,
              tab: EditorTab(
                type: EditorTabType.column,
                options: [
                  Option.custom(
                    widget: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ColorSelector(
                            title: 'Color',
                            onColorSelect: (color) {
                              shadow = BoxShadow(
                                blurRadius: shadow!.blurRadius,
                                color: color,
                                offset: shadow!.offset,
                                spreadRadius: shadow!.blurSigma
                              );
                              updateListeners(WidgetChange.update);
                            },
                            size: const Size(40, 40),
                            color: shadow!.color,
                            tooltip: 'Shadow Color'
                          ),
                          IconButton(
                            onPressed: () {
                              shadow = null;
                              updateListeners(WidgetChange.update);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.delete)
                          )
                        ],
                      ),
                    ),
                  ),
                  Option.custom(
                    widget: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          const Text('DX'),
                          Container(width: 10,),
                          Expanded(
                            child: CustomSlider(
                              value: shadow!.offset.dx,
                              min: -15,
                              max: 15,
                              onChangeEnd: (value) {
                                shadow = BoxShadow(
                                  blurRadius: shadow!.blurRadius,
                                  color: shadow!.color,
                                  offset: Offset(value, shadow!.offset.dy),
                                  spreadRadius: shadow!.blurSigma
                                );
                                updateListeners(WidgetChange.update);
                              },
                              onChange: (value) {
                                shadow = BoxShadow(
                                  blurRadius: shadow!.blurRadius,
                                  color: shadow!.color,
                                  offset: Offset(value, shadow!.offset.dy),
                                  spreadRadius: shadow!.blurSigma
                                );
                                updateListeners(WidgetChange.misc);
                              }
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Option.custom(
                    widget: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const Text('DY'),
                          Container(width: 10,),
                          Expanded(
                            child: CustomSlider(
                              value: shadow!.offset.dy,
                              min: -15,
                              max: 15,
                              onChangeEnd: (value) {
                                shadow = BoxShadow(
                                  blurRadius: shadow!.blurRadius,
                                  color: shadow!.color,
                                  offset: Offset(shadow!.offset.dx, value),
                                  spreadRadius: shadow!.blurSigma
                                );
                                updateListeners(WidgetChange.update);
                              },
                              onChange: (value) {
                                shadow = BoxShadow(
                                  blurRadius: shadow!.blurRadius,
                                  color: shadow!.color,
                                  offset: Offset(shadow!.offset.dx, value),
                                  spreadRadius: shadow!.blurSigma
                                );
                                updateListeners(WidgetChange.misc);
                              }
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                tab: 'Shadow'
              )
            );
          },
          icon: Icons.text_fields,
          tooltip: 'Customize shadow of box'
        ),
      ],
    ),
    EditorTab(
      tab: 'Border',
      options: [
        Option.button(
          title: 'Border',
          onTap: (context) {
            updateListeners(WidgetChange.misc);
            EditorTab.modal(
              context,
              height: 150,
              tab: EditorTab(
                type: EditorTabType.column,
                options: [
                  Option.custom(
                    widget: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ColorSelector(
                            title: 'Color',
                            onColorSelect: (color) {
                              if (borderWidth == null) {
                                borderWidth = 2;
                              }
                              borderColor = color;
                              updateListeners(WidgetChange.update);
                            },
                            size: const Size(40, 40),
                            color: borderColor ?? color.computeTextColor(),
                            tooltip: 'Border Color'
                          ),
                          IconButton(
                            onPressed: () {
                              borderColor = borderWidth = null;
                              updateListeners(WidgetChange.update);
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.delete)
                          )
                        ],
                      ),
                    ),
                  ),
                  Option.custom(
                    widget: (context) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          const Text('Border Width'),
                          Container(width: 10,),
                          Expanded(
                            child: CustomSlider(
                              value: borderWidth ?? 0,
                              min: 0,
                              max: 10,
                              onChangeEnd: (value) {
                                updateListeners(WidgetChange.update);
                              },
                              onChange: (value) {
                                if (borderColor == null) borderColor = color.computeTextColor();
                                borderWidth = value;
                                updateListeners(WidgetChange.misc);
                              }
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                tab: 'Border'
              )
            );
          },
          icon: Icons.border_all,
          tooltip: 'Customise the border',
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
                    max: size.width,
                    onChange: (value) {
                      borderRadius = value;
                      updateListeners(WidgetChange.misc);
                    },
                    onChangeEnd: (value) {
                      borderRadius = value;
                      updateListeners(WidgetChange.update);
                    },
                  ),
                ],
                tab: 'Border Radius'
              )
            );
          },
          icon: Icons.rounded_corner,
          tooltip: 'Adjust border radius'
        ),
      ],
    )
  ];

  @override
  Widget widget(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: type == BackgroundType.color ? color : Colors.white,
      gradient: (type == BackgroundType.gradient && gradient != null) ? LinearGradient(
        colors: gradient!,
        begin: gradientType.begin,
        end: gradientType.end,
      ) : null,
      border: (borderColor != null && borderWidth != null) ? Border.all(
        color: borderColor!,
        width: borderWidth!
      ) : null,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        if (shadow != null) shadow!
      ],
    ),
  );

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
    'gradient': _generateGradientsHex(),
    'border-color': borderColor?.toHex(),
    'border-width': borderWidth,
    'border-radius': borderRadius,
    'shadow': {
      'color': shadow?.color.toHex(),
      'blur-radius': shadow?.blurRadius,
      'spread-radius': shadow?.spreadRadius,
      'offset-x': shadow?.offset.dx,
      'offset-y': shadow?.offset.dy,
    },
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);
    try {
      color = HexColor.fromHex(json['color']);
      if (json['gradient'] != null) {
        gradient = _generateGradientsColor(json['gradient']);
        type = BackgroundType.gradient;
      }
      if (json['border-color'] != null) {
        borderColor = HexColor.fromHex(json['border-color']);
      }
      if (json['border-width'] != null) {
        borderWidth = json['border-width'];
      }
      if (json['border-radius'] != null) {
        borderRadius = json['border-radius'];
      }
      if (json['shadow'] != null) {
        shadow = BoxShadow(
          color: HexColor.fromHex(json['shadow']['color']),
          blurRadius: json['shadow']['blur-radius'],
          spreadRadius: json['shadow']['spread-radius'],
          offset: Offset(
            json['shadow']['offset-x'],
            json['shadow']['offset-y'],
          )
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

}