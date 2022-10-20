import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../rehmat.dart';

class CreatorText extends CreatorWidget {

  CreatorText({required CreatorPage page, required Project project}) : super(page: page, project: project);

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      tab: 'Text',
      options: [
        Option.button(
          title: 'Edit',
          tooltip: 'Edit text',
          onTap: (context) async {
            await showEditTextModal(context);
          },
          icon: Icons.keyboard_alt_outlined
        ),
        Option.button(
          icon: Icons.delete_rounded,
          title: 'Delete',
          tooltip: 'Delete Text Widget',
          onTap: (context) async {
            page.delete(this);
          },
        ),
        Option.button(
          title: 'Auto Size',
          tooltip: 'Auto size text when resizing the widget',
          onTap: (context) async {
            autoSize = !autoSize;
            _removeExtraSpaceFromSize();
            updateListeners(WidgetChange.misc);
          },
          icon: Icons.auto_awesome_rounded
        ),
        Option.button(
          title: 'Size',
          tooltip: 'Text size',
          onTap: (context) async {
            autoSize = false;
            updateListeners(WidgetChange.misc);
            await EditorTab.modal(
              context,
              tab: EditorTab.size(
                current: fontSize,
                min: 10,
                max: 200,
                onChange: (value) {
                  fontSize = value;
                  updateListeners(WidgetChange.misc);
                }
              )
            );
            updateListeners(WidgetChange.resize);
          },
          icon: Icons.format_size
        ),
        Option.button(
          icon: Icons.height_rounded,
          title: 'Height',
          tooltip: 'Change line height of the text',
          onTap: (context) async {
            List<double> _options = [0.6, 0.77, 0.85, 0.9, 1, 1.5, 2];
            await EditorTab.modal(
              context,
              tab: EditorTab.pickerBuilder(
                title: 'Line Height',
                itemBuilder: (context, index) => Text(_options[index].toString()),
                childCount: _options.length,
                initialIndex: _options.indexOf(lineHeight),
                onSelectedItemChanged: (index) {
                  lineHeight = _options[index];
                  updateListeners(WidgetChange.misc);
                },
              )
            );
            updateListeners(WidgetChange.update);
          },
        ),
      ],
    ),
    EditorTab(
      tab: 'Font',
      options: [
        for (String font in [
          'Roboto',
          'Poppins',
          'Abril Fatface',
          'Open Sans',
          'Montserrat',
          'Noto Sans',
          'Ubuntu',
          'Merriweather',
          'Playfair Display',
          'DM Sans'
        ]) Option.font(
          font: font,
          onFontSelect: (context, font) {
            this.fontFamily = font;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Search',
          onTap: (context) async {
            String? _font = await AppRouter.push<String>(context, page: const FontSelector());
            if (_font != null) fontFamily = _font;
            notifyListeners(WidgetChange.update);
          },
          icon: Icons.search,
          tooltip: 'Search Fonts'
        )
      ],
    ),
    EditorTab(
      tab: 'Colors',
      options: [
        Option.button(
          title: 'Color',
          icon: Icons.format_color_text,
          tooltip: 'Tap to select text color',
          onTap: (_) async {
            Color? _color = await Palette.showColorPicker(context: _, defaultColor: color);
            if (_color != null) {
              this.color = _color;
              if (stroke != null) _updateStroke();
              updateListeners(WidgetChange.update);
            }
          },
        ),
        Option.button(
          icon: Icons.format_color_fill,
          title: 'Background',
          tooltip: 'Tap to select text background color',
          onTap: (context) async {
            Color _color = await Palette.showColorPicker(
              context: context,
              defaultColor: color,
              title: 'Select Background Color'
            ) ?? Colors.transparent;
            textBackground = _color;
            updateListeners(WidgetChange.update);
          },
        ),
      ],
    ),
    EditorTab(
      tab: 'Formatting',
      options: [
        Option.button(
          title: 'Bold',
          tooltip: 'Add Bold Formatting',
          greyOut: !bold,
          onTap: (context) async {
            bold = !bold;
            if (stroke != null) _updateStroke();
            updateListeners(WidgetChange.update);
          },
          icon: Icons.format_bold
        ),
        Option.button(
          title: 'Italics',
          tooltip: 'Add Italics Formatting',
          greyOut: !italics,
          onTap: (context) async {
            italics = !italics;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.format_italic
        ),
        Option.button(
          title: 'Underline',
          tooltip: 'Add Underline Formatting',
          greyOut: !underline,
          onTap: (context) async {
            underline = !underline;
            overline = false;
            strikethrough = false;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.format_underline
        ),
        Option.button(
          title: 'Strikethrough',
          tooltip: 'Add Strikethrough Formatting',
          greyOut: !strikethrough,
          onTap: (context) async {
            underline = false;
            overline = false;
            strikethrough = !strikethrough;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.strikethrough_s
        ),
        Option.button(
          title: 'Overline',
          tooltip: 'Add Overline Formatting',
          greyOut: !overline,
          onTap: (context) async {
            underline = false;
            overline = !overline;
            strikethrough = false;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.maximize
        ),
        Option.button(
          title: 'Stroke',
          tooltip: 'Add a stroke to text',
          onTap: (context) async {
            _toggleStroke();
          },
          icon: Icons.maximize
        ),
      ],
    ),
    EditorTab(
      tab: 'Widget',
      options: [
        Option.button(
          title: 'Color',
          tooltip: 'Tap to select widget background color',
          onTap: (context) async {
            Color? _color = await Palette.showColorPicker(
              context: context,
              defaultColor: color,
              title: 'Select Background Color'
            );
            if (_color != null) widgetColor = _color;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.format_color_fill
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
                    value: radius,
                    min: -10,
                    max: 20,
                    onChange: (value) {
                      radius = value;
                      updateListeners(WidgetChange.misc);
                    },
                    onChangeEnd: (value) {
                      radius = value;
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
          title: 'Padding',
          onTap: (context) async {
            await EditorTab.modal(
              context,
              height: 200,
              tab: EditorTab.paddingEditor(
                padding: padding,
                onChange: (value) {
                  padding = value;
                  updateListeners(WidgetChange.misc);
                },
              )
            );
            print(padding);
            updateListeners(WidgetChange.update);
          },
          icon: Icons.padding_outlined,
          tooltip: 'Adjust Widget Border Radius'
        ),
      ],
    ),
    EditorTab(
      tab: 'Alignment',
      options: [
        Option.button(
          title: 'Left',
          tooltip: 'Align Text To Left',
          onTap: (context) async {
            align = TextAlign.left;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.align_horizontal_left
        ),
        Option.button(
          title: 'Center',
          tooltip: 'Align Text To Center',
          onTap: (context) async {
            align = TextAlign.center;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.align_horizontal_center
        ),
        Option.button(
          title: 'Right',
          tooltip: 'Align Text To Right',
          onTap: (context) async {
            align = TextAlign.right;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.align_horizontal_right
        ),
        Option.button(
          title: 'Justify',
          tooltip: 'Justify Text Alignment',
          onTap: (context) async {
            align = TextAlign.justify;
            updateListeners(WidgetChange.update);
          },
          icon: Icons.format_align_justify
        ),
      ],
    ),
    EditorTab(
      tab: 'Effects',
      options: [
        Option.button(
          title: 'Shadow',
          onTap: (context) {
            if (shadow == null) shadow = Shadow();
            EditorTab.modal(
              context,
              tab: EditorTab.shadow<Shadow>(
                shadow: shadow!,
                onChange: (value) {
                  shadow = value;
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  shadow = value;
                  updateListeners(WidgetChange.update);
                },
              )
            );
          },
          icon: Icons.blur_on,
          tooltip: 'Customize shadow of text'
        )
      ],
    ),
    EditorTab(
      options: [
        Option.button(
          title: 'Rotate',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab.rotate(
                angle: angle,
                onChange: (value) {
                  angle = value;
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  angle = value;
                  updateListeners(WidgetChange.update);
                },
              )
            );
          },
          icon: Icons.refresh,
          tooltip: 'Tap to open angle adjuster'
        ),
        Option.button(
          title: 'Scale',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab.scale(
                size: size,
                minSize: minSize ?? Size(20, 20),
                maxSize: project.contentSize(context),
                onChange: (value) {
                  // angle = value;
                  size  = value;
                  updateResizeHandlers();
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  // angle = value;
                  size  = value;
                  updateListeners(WidgetChange.update);
                },
              )
            );
          },
          icon: Icons.open_in_full_rounded,
          tooltip: 'Tap to scale the widget size'
        ),
        Option.button(
          title: 'Opacity',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab.opacity(
                opacity: opacity,
                onChange: (value) {
                  opacity = value;
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  opacity = value;
                  updateListeners(WidgetChange.update);
                },
              ),
            );
          },
          icon: Icons.opacity,
          tooltip: 'Opacity'
        ),
        Option.button(
          title: 'Nudge',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab.nudge(
                onDXchange: (dx) {
                  position = Offset(position.dx + dx, position.dy);
                  updateListeners(WidgetChange.update);
                },
                onDYchange: (dy) {
                  position = Offset(position.dx, position.dy + dy);
                  updateListeners(WidgetChange.update);
                },
              )
            );
          },
          icon: Icons.drag_indicator,
          tooltip: 'Nudge'
        ),
      ],
      tab: 'Adjust',
    ),
    EditorTab(
      tab: 'Spacing',
      type: EditorTabType.row,
      options: [
        Option.button(
          title: 'Letter',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab(
                type: EditorTabType.single,
                options: [
                  Option.slider(
                    value: letterSpacing,
                    min: -10,
                    max: 20,
                    onChange: (value) {
                      letterSpacing = value;
                      updateListeners(WidgetChange.misc);
                    },
                    onChangeEnd: (value) {
                      letterSpacing = value;
                      updateListeners(WidgetChange.update);
                    },
                  ),
                ],
                tab: 'Letter Spacing'
              )
            );
          },
          icon: Icons.space_bar,
          tooltip: 'Adjust Letter Spacing'
        ),
        Option.button(
          title: 'Word',
          onTap: (context) {
            EditorTab.modal(
              context,
              tab: EditorTab(
                type: EditorTabType.single,
                options: [
                  Option.slider(
                    value: wordSpacing,
                    min: -10,
                    max: 20,
                    onChange: (value) {
                      wordSpacing = value;
                      updateListeners(WidgetChange.misc);
                    },
                    onChangeEnd: (value) {
                      wordSpacing = value;
                      updateListeners(WidgetChange.update);
                    },
                  )
                ],
                tab: 'Word Spacing'
              )
            );
          },
          icon: Icons.space_bar,
          tooltip: 'Adjust Word Spacing'
        ),
      ],
    )
  ];

  // Inherited
  final String name = 'Text';
  final String id = 'text';

  bool isResizable = true;
  bool isDraggable = true;

  /// Text Color
  Color color = Colors.black;
  /// CreatorPageProperties Color
  Color widgetColor = Colors.transparent;
  Color textBackground = Colors.transparent;
  Color? decorationColor = Colors.black;

  String text = 'Double tap to edit text';

  bool autoSize = true;

  TextAlign align = TextAlign.center;

  bool bold = false;
  bool italics = false;
  bool underline = false;
  bool strikethrough = false;
  bool overline = false;

  double wordSpacing = 0;
  double letterSpacing = 0;

  Size size = const Size(200, 100);
  Size? minSize = const Size(100, 20);

  double fontSize = 100;

  String fontFamily = 'Abril Fatface';

  double radius = 10;

  double lineHeight = 0.77;

  EdgeInsets padding = EdgeInsets.zero;

  Shadow? shadow;

  Paint? stroke;

  TextDecorationStyle decorationStyle = TextDecorationStyle.solid;

  Widget widget(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: widgetColor,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: textWidget,
  );

  Widget get textWidget => autoSize ? AutoSizeText(
    text,
    textAlign: align,
    style: style,
    maxFontSize: 200,
    presetFontSizes: [
      ... List.generate(500, (index) => index.toDouble()).reversed
    ],
    onFontSizeChanged: (fontSize) {
      this.fontSize = fontSize;
    },
  ) : Text(
    text,
    textAlign: align,
    style: style,
  );

  TextStyle get style => GoogleFonts.getFont(fontFamily).copyWith(
    fontWeight: bold ? (stroke != null ? FontWeight.normal : FontWeight.bold) : FontWeight.normal,
    backgroundColor: textBackground,
    decoration: underline ? TextDecoration.underline : (strikethrough ? TextDecoration.lineThrough : (overline ? TextDecoration.overline : null)),
    fontStyle: italics ? FontStyle.italic : null,
    color: stroke == null ? color : null,
    fontSize: fontSize,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    fontFeatures: [ ],
    shadows: [
      if (shadow != null) shadow!
    ],
    foreground: stroke,
    decorationStyle: decorationStyle,
    decorationColor: stroke == null ? decorationColor : null,
    height: lineHeight,
  );

  @override
  void onDoubleTap(BuildContext context) async {
    await showEditTextModal(context);
  }

  Future<void> showEditTextModal(BuildContext context) async {
    String? text = await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: const Duration(
        milliseconds: 400,
      ), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        TextEditingController textCtrl = TextEditingController.fromValue(TextEditingValue(text: this.text));
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
    if (text != null && text.trim() != '') this.text = text;
    _removeExtraSpaceFromSize();
    updateListeners(WidgetChange.update);
  }

  @override
  void onResizeFinished(details, {
    bool updateNotify = true
  }) {
    _removeExtraSpaceFromSize();
    super.onResizeFinished(details);
  }

  void _removeExtraSpaceFromSize() {
    if (textWidget is Text) return;
    final span = TextSpan(
      style: (textWidget as AutoSizeText).style,
      text: text,
    );
    final words = span.toPlainText().split(RegExp('\\s+'));
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: (textWidget as AutoSizeText).style,
      ),
      textAlign: align,
      maxLines: words.length,
      textDirection: TextDirection.ltr
    ) ..layout(minWidth: 0, maxWidth: size.width);
    size = textPainter.size;
  }

  void _toggleStroke() {
    if (stroke == null) {
      _updateStroke();
    } else {
      stroke = null;
    }
    updateListeners(WidgetChange.update);
  }

  void _updateStroke() {
    stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bold ? 2 : 1
      ..color = color;
  }

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
    'text': {
      'text': text,
      'font': fontFamily,
      'auto-size': autoSize,
      'font-size': fontSize,
      'line-height': lineHeight
    },
    'color': {
      'text': color.toHex(),
      'background': textBackground.toHex()
    },
    'formatting': {
      'bold': bold,
      'italics': italics,
      'underline': underline,
      'strike-through': strikethrough,
      'overline': overline,
      'stroke': stroke != null
    },
    'widget': {
      'color': widgetColor.toHex(),
      'radius': radius,
    },
    'alignment': align.index,
    'shadow': shadow != null ? {
      'blurRadius': shadow!.blurRadius,
      'dx': shadow!.offset.dx,
      'dy': shadow!.offset.dy,
      'color': shadow!.color.toHex()
    } : null,
    'padding': padding.toJSON(),
    'spacing': {
      'word': wordSpacing,
      'letter': letterSpacing,
    },
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    if(!super.buildFromJSON(json)) return false;
    try {
      text = json['text']['text'];
      fontFamily = json['text']['font'];
      lineHeight = json['text']['line-height'];
      autoSize = json['text']['auto-size'];
      fontSize = json['text']['font-size'];

      color = HexColor.fromHex(json['color']['text']);
      textBackground = HexColor.fromHex(json['color']['background']);

      bold = json['formatting']['bold'];
      italics = json['formatting']['italics'];
      underline = json['formatting']['underline'];
      strikethrough = json['formatting']['strike-through'];
      overline = json['formatting']['overline'];
      if (json['formatting']['stroke'] == true) {
        _updateStroke();
      }

      widgetColor = HexColor.fromHex(json['widget']['color']);
      radius = json['widget']['radius'];

      align = TextAlign.values.where((element) => element.index == json['alignment']).first;

      if (json['shadow'] != null) {
        shadow = Shadow(
          blurRadius: json['shadow']['blurRadius'],
          color: HexColor.fromHex(json['shadow']['color']),
          offset: Offset(json['shadow']['dx'], json['shadow']['dy'])
        );
      }

      padding = PaddingExtension.fromJSON(json['padding']);

      letterSpacing = json['spacing']['letter'];
      wordSpacing = json['spacing']['word'];

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

}