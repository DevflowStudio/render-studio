import 'dart:ui';

import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreativeContainerProvider {

  CreativeContainerProvider._(this.widget);
  final CreatorWidget widget;

  factory CreativeContainerProvider.create(CreatorWidget widget) {
    return CreativeContainerProvider._(widget);
  }

  Color? color;

  List<Color>? gradient;
  BackgroundGradient gradientType = BackgroundGradient.type2;

  BackgroundType type = BackgroundType.color;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? shadow;

  double blur = 0;

  EdgeInsets padding = EdgeInsets.zero;

  EditorTab editor({
    required void Function(WidgetChange change) onChange,
    String name = 'Background',
    List<Option> options = const [],
  }) => EditorTab(
    tab: name,
    options: [
      Option.color(
        selected: color,
        palette: widget.page.palette,
        allowClear: true,
        onChange: (color) {
          this.color = color;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: (color) {
          onChange(WidgetChange.update);
        },
      ),
      Option.button(
        title: 'Shadow',
        onTap: (context) async {
          if (shadow == null) {
            shadow = BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 5)
            );
          }
          await EditorTab.modal(
            context,
            actions: [
              IconButton(
                onPressed: () {
                  shadow = null;
                  onChange(WidgetChange.update);
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab.shadow<BoxShadow>(
              shadow: shadow!,
              onChange: (value) {
                shadow = value;
                onChange(WidgetChange.misc);
              },
            )
          );
          onChange(WidgetChange.update);
        },
        icon: Icons.text_fields,
        tooltip: 'Customize shadow of box'
      ),
      Option.button(
        title: 'Border',
        onTap: (context) async {
          Size originalWidgetSize = widget.size;
          await EditorTab.modal(
            context,
            actions: [
              IconButton(
                onPressed: () {
                  borderColor = borderWidth = null;
                  onChange(WidgetChange.update);
                  Navigator.of(context).pop();
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab(
              type: EditorTabType.column,
              options: [
                Option.custom(
                  widget: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSlider(
                          value: borderWidth ?? 0,
                          min: 0,
                          max: 10,
                          label: 'Width',
                          onChange: (value) {
                            widget.size = Size(originalWidgetSize.width + value * 2, originalWidgetSize.height + value * 2);
                            if (borderColor == null) borderColor = color?.computeTextColor();
                            borderWidth = value;
                            onChange(WidgetChange.misc);
                          },
                          actions: [
                            ColorSelector(
                              title: 'Color',
                              palette: widget.page.palette,
                              onColorSelect: (color) {
                                if (borderWidth == null) borderWidth = 2;
                                borderColor = color;
                                onChange(WidgetChange.update);
                              },
                              size: const Size(30, 30),
                              color: borderColor ?? color?.computeTextColor() ?? widget.page.palette.primary,
                              tooltip: 'Border Color'
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        CustomSlider(
                          value: borderRadius,
                          min: 0,
                          max: widget.size.width / 2,
                          label: 'Radius',
                          onChange: (value) {
                            borderRadius = value;
                            onChange(WidgetChange.misc);
                          }
                        )
                      ],
                    ),
                  ),
                ),
              ],
              tab: 'Border'
            )
          );
          if ((borderWidth ?? 0) > 0 && borderColor == null) {
            borderColor = color?.computeTextColor() ?? widget.page.palette.primary;
          }
          onChange(WidgetChange.update);
        },
        icon: Icons.border_all,
        tooltip: 'Customize the border',
      ),
      Option.button(
        title: 'Padding',
        icon: RenderIcons.padding,
        tooltip: 'Add padding to the widget',
        onTap: (context) async {
          Size originalWidgetSize = widget.size;
          await EditorTab.modal(
            context,
            tab: (context, setState) => EditorTab.paddingEditor(
              padding: padding,
              onChange: (value) {
                widget.size = Size(originalWidgetSize.width + value.horizontal, originalWidgetSize.height + value.vertical);
                padding = value;
                onChange(WidgetChange.misc);
              },
              min: 0,
              max: 20,
            )
          );
        },
      ),
      Option.showSlider(
        title: 'Blur',
        icon: RenderIcons.blur,
        value: blur,
        min: 0,
        max: 20,
        onChange: (value) {
          blur = value;
          onChange(WidgetChange.misc);
        },
        onChangeEnd: () => onChange(WidgetChange.update),
        showValueEditor: true
      ),
      ... options
    ]
  );

  Widget build({
    required Widget child
  }) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        if (shadow != null) shadow!
      ],
    ),
    child: ClipRRect(
      clipBehavior: (shadow != null || blur > 0) ? Clip.hardEdge : Clip.none,
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: type == BackgroundType.color ? color : Colors.white,
            gradient: (type == BackgroundType.gradient && gradient != null) ? LinearGradient(
              colors: gradient!,
              begin: gradientType.begin,
              end: gradientType.end,
            ) : null,
            border: (borderWidth != null) ? Border.all(
              color: borderColor ?? color?.computeTextColor() ?? widget.page.palette.primary,
              width: borderWidth!
            ) : null,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
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

  Map<String, dynamic> toJSON() => {
    'color': color?.toHex(),
    'gradient': _generateGradientsHex(),
    'border-color': borderColor?.toHex(),
    'border-width': borderWidth,
    'border-radius': borderRadius,
    'blur': blur,
    'shadow': shadow == null ? null : {
      'color': shadow?.color.toHex(),
      'blur-radius': shadow?.blurRadius,
      'spread-radius': shadow?.spreadRadius,
      'offset-x': shadow?.offset.dx,
      'offset-y': shadow?.offset.dy,
    },
  };

  factory CreativeContainerProvider.fromJSON(Map data, {
    required CreatorWidget widget
  }) {
    CreativeContainerProvider provider = CreativeContainerProvider._(widget);
    try {
      if (data['color'] != null) provider.color = HexColor.fromHex(data['color']);
      if (data['gradient'] != null) {
        provider.gradient = provider._generateGradientsColor(data['gradient']);
        provider.type = BackgroundType.gradient;
      }

      if (data['border-color'] != null) provider.borderColor = HexColor.fromHex(data['border-color']);

      provider.borderWidth = data['border-width'];

      if (data['border-radius'] != null) provider.borderRadius = data['border-radius'];

      if (data['shadow'] != null) {
        provider.shadow = BoxShadow(
          color: HexColor.fromHex(data['shadow']['color']),
          blurRadius: data['shadow']['blur-radius'],
          spreadRadius: data['shadow']['spread-radius'],
          offset: Offset(
            data['shadow']['offset-x'],
            data['shadow']['offset-y'],
          )
        );
      }
      provider.blur = data['blur'] ?? 0;
    } catch (e) { }
    return provider;
  }

}

class CreatorBoxWidget extends CreatorWidget {

  CreatorBoxWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorBoxWidget widget = CreatorBoxWidget(page: page);
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    color = page.palette.secondary;
    super.onInitialize();
  }

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

  late Color color;

  List<Color>? gradient;
  BackgroundGradient gradientType = BackgroundGradient.type2;

  BackgroundType type = BackgroundType.color;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? shadow;

  double blur = 0;
  
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
        Option.color(
          selected: color,
          palette: page.palette,
          onChange: (color) {
            if (color != null) this.color = color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Shadow',
          onTap: (context) {
            if (shadow == null) {
              shadow = BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 5,
                offset: Offset(0, 5)
              );
            }
            EditorTab.modal(
              context,
              actions: [
                IconButton(
                  onPressed: () {
                    shadow = null;
                    updateListeners(WidgetChange.update);
                  },
                  icon: Icon(RenderIcons.delete)
                )
              ],
              tab: (context, setState) => EditorTab.shadow<BoxShadow>(
                shadow: shadow!,
                onChange: (value) {
                  shadow = value;
                  updateListeners(WidgetChange.update);
                },
              )
            );
          },
          icon: Icons.text_fields,
          tooltip: 'Customize shadow of box'
        ),
        ... defaultOptions,
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
              tab: (context, setState) => EditorTab(
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
          tooltip: 'Customize the border',
        ),
        Option.showSlider(
          title: 'Border Radius',
          icon: Icons.rounded_corner,
          tooltip: 'Adjust border radius',
          value: borderRadius,
          min: 0,
          max: 100,
          onChange: (value) {
            borderRadius = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
        )
      ],
    ),
    EditorTab(
      tab: 'Customize',
      options: [
        Option.showSlider(
          title: 'Blur',
          icon: RenderIcons.blur,
          value: blur,
          min: 0,
          max: 20,
          onChange: (value) {
            blur = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: () => updateListeners(WidgetChange.update),
          showValueEditor: true
        )
      ]
    ),
    EditorTab.adjustTab(widget: this)
  ];

  @override
  Widget widget(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        if (shadow != null) shadow!
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
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
          ),
        ),
      ),
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
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown,
  }) => {
    ... super.toJSON(),
    'color': color.toHex(),
    'gradient': _generateGradientsHex(),
    'border-color': borderColor?.toHex(),
    'border-width': borderWidth,
    'border-radius': borderRadius,
    'blur': blur,
    'shadow': shadow == null ? null : {
      'color': shadow?.color.toHex(),
      'blur-radius': shadow?.blurRadius,
      'spread-radius': shadow?.spreadRadius,
      'offset-x': shadow?.offset.dx,
      'offset-y': shadow?.offset.dy,
    },
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
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
      blur = json['blur'] ?? 0;
      return true;
    } catch (e) {
      return false;
    }
  }

}