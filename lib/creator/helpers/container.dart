import 'dart:ui';

import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreativeContainerProvider {

  CreativeContainerProvider._(this.widget);
  final CreatorWidget widget;

  factory CreativeContainerProvider.create(CreatorWidget widget, {
    Color? color
  }) {
    return CreativeContainerProvider._(widget) .. color = color;
  }

  Color? color;

  BackgroundType type = BackgroundType.color;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? shadow;

  double blur = 0;

  CreativeGradient? gradient;

  EdgeInsets padding = EdgeInsets.zero;

  EditorTab editor({
    required void Function(WidgetChange change) onChange,
    String name = 'Background',
    List<Option> options = const [],
    bool showBorder = true,
    bool showShadow = true,
    bool showPadding = true,
    bool showBlur = true,
    bool showColor = true,
  }) => EditorTab(
    tab: name,
    options: [
      if (showColor) Option.color(
        widget,
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
        title: 'Gradient',
        onTap: (context) async {
          gradient ??= CreativeGradient.fromPalette(palette: widget.page.palette);
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  gradient = null;
                  dismiss();
                },
                icon: Icon(RenderIcons.delete)
              ),
            ],
            tab: (context, setState) => gradient!.getEditor(
              widget: widget,
              palette: widget.page.palette,
              onChange: (change) {
                setState(() {});
                onChange(change);
              },
            ),
            onDismiss: () {
              onChange(WidgetChange.update);
            }
          );
        },
        icon: RenderIcons.gradient
      ),
      if (showShadow) Option.button(
        title: 'Shadow',
        onTap: (context) async {
          if (shadow == null) {
            shadow = BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 5,
              offset: Offset(0, 5)
            );
          }
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  shadow = null;
                  onChange(WidgetChange.update);
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab.shadow<BoxShadow>(
              widget: widget,
              shadow: shadow!,
              onChange: (value) {
                shadow = value;
                onChange(WidgetChange.misc);
              },
            ),
            onDismiss: () {
              onChange(WidgetChange.update);
            }
          );
        },
        icon: Icons.text_fields,
        tooltip: 'Customize shadow of box'
      ),
      if (showBorder) Option.button(
        title: 'Border',
        onTap: (context) async {
          Size originalWidgetSize = widget.size;
          widget.page.editorManager.openModal(
            actions: (dismiss) => [
              IconButton(
                onPressed: () {
                  borderColor = borderWidth = null;
                  onChange(WidgetChange.update);
                  dismiss();
                },
                icon: Icon(RenderIcons.delete)
              )
            ],
            tab: (context, setState) => EditorTab(
              type: EditorTabType.single,
              options: [
                Option.custom(
                  widget: (context) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                              widget: widget,
                              title: 'Color',
                              palette: widget.page.palette,
                              onColorSelect: (color) {
                                if (borderWidth == null) borderWidth = 2;
                                borderColor = color;
                                onChange(WidgetChange.update);
                              },
                              size: const Size(30, 30),
                              color: borderColor ?? color?.computeTextColor() ?? widget.page.palette.primary,
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
            ),
            onDismiss: () {
              if ((borderWidth ?? 0) > 0 && borderColor == null) {
                borderColor = color?.computeTextColor() ?? widget.page.palette.primary;
              }
              onChange(WidgetChange.update);
            },
          );
        },
        icon: Icons.border_all,
        tooltip: 'Customize the border'
      ),
      if (showPadding) Option.button(
        title: 'Padding',
        icon: RenderIcons.padding,
        tooltip: 'Add padding to the widget',
        onTap: (context) async {
          Size originalWidgetSize = widget.size;
          widget.page.editorManager.openModal(
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
      if (showBlur) Option.showSlider(
        widget,
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
            gradient: gradient?.gradient,
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

  Map<String, dynamic> toJSON() => {
    'color': color?.toHex(),
    'gradient': gradient?.toJSON(),
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

      if (data['gradient'] != null) try {
        provider.gradient = CreativeGradient.fromJSON(data['gradient']);
      } catch (e) {}

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