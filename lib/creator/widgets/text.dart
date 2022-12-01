import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../rehmat.dart';

class CreatorText extends CreatorWidget {

  CreatorText({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    page.addWidget(CreatorText(page: page));
  }
  
  @override
  void onInitialize() {
    color = page.palette.background.computeTextColor();
    super.onInitialize();
  }

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
          icon: RenderIcons.keyboard
        ),
        Option.button(
          icon: RenderIcons.delete,
          title: 'Delete',
          tooltip: 'Delete Text Widget',
          onTap: (context) async {
            page.delete(this);
          },
        ),
        Option.color(
          tooltip: 'Tap to select text color',
          palette: () => page.palette,
          selected: () => color,
          onChange: (_color) {
            if (_color == null) return;
            this.color = _color;
            if (stroke != null) _updateStroke();
            updateListeners(WidgetChange.update);
          },
        ),
        Option.toggle(
          title: 'Auto Size',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).autoSize;
          },
          onChange: (value) {
            autoSize = value;
            updateListeners(WidgetChange.update);
          },
          enabledIcon: RenderIcons.auto_size,
          disabledIcon: RenderIcons.auto_size_off,
          enabledTooltip: 'Disabled auto-size text',
          disabledTooltip: 'Enable auto-size text',
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
          icon: RenderIcons.text_size
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
          icon: RenderIcons.search,
          tooltip: 'Search Fonts'
        )
      ],
    ),
    EditorTab(
      tab: 'Formatting',
      options: [
        Option.toggle(
          title: 'Bold',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).bold;
          },
          onChange: (value) {
            bold = value;
            _updateStroke();
            updateListeners(WidgetChange.update);
          },
          enabledIcon: RenderIcons.bold,
          disabledIcon: RenderIcons.bold,
          disabledTooltip: 'Add bold formatting',
          enabledTooltip: 'Remove bold formatting',
        ),
        Option.toggle(
          title: 'Italics',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).italics;
          },
          onChange: (value) {
            italics = value;
            updateListeners(WidgetChange.update);
          },
          disabledIcon: RenderIcons.italic,
          enabledIcon: RenderIcons.italic,
          disabledTooltip: 'Add italics formatting',
          enabledTooltip: 'Remove italics formatting',
        ),
        Option.toggle(
          title: 'Underline',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).underline;
          },
          onChange: (value) {
            underline = value;
            overline = false;
            strikethrough = false;
            updateListeners(WidgetChange.update);
          },
          disabledIcon: RenderIcons.underline,
          enabledIcon: RenderIcons.underline,
          disabledTooltip: 'Add underline formatting',
          enabledTooltip: 'Remove underline formatting',
        ),
        Option.toggle(
          title: 'Strikethough',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).strikethrough;
          },
          onChange: (value) {
            strikethrough = value;
            updateListeners(WidgetChange.update);
          },
          disabledIcon: RenderIcons.strike,
          enabledIcon: RenderIcons.strike,
          disabledTooltip: 'Add strikethrough formatting',
          enabledTooltip: 'Remove strikethrough formatting',
        ),
        Option.toggle(
          title: 'Overline',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as CreatorText).overline;
          },
          onChange: (value) {
            overline = value;
            underline = false;
            strikethrough = false;
            updateListeners(WidgetChange.update);
          },
          disabledIcon: RenderIcons.overline,
          enabledIcon: RenderIcons.overline,
          disabledTooltip: 'Add overline formatting',
          enabledTooltip: 'Remove overline formatting',
        ),
      ],
    ),
    EditorTab(
      tab: 'Background',
      options: [
        Option.button(
          icon: RenderIcons.remove,
          title: 'Remove Text Background',
          tooltip: '',
          onTap: (context) async {
            // page.delete(this);
          },
        ),
        Option.color(
          icon: RenderIcons.color,
          title: 'Color',
          tooltip: 'Tap to select background color',
          onChange: (color) async {
            if (color != null) widgetColor = color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Shadow',
          onTap: (context) {
            if (boxShadow == null) boxShadow = BoxShadow();
            EditorTab.modal(
              context,
              tab: EditorTab.shadow<BoxShadow>(
                shadow: shadow!,
                onChange: (value) {
                  boxShadow = value;
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  boxShadow = value;
                  updateListeners(WidgetChange.update);
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    boxShadow = null;
                    updateListeners(WidgetChange.update);
                  },
                  icon: Icon(RenderIcons.delete),
                  iconSize: 20,
                )
              ]
            );
          },
          icon: RenderIcons.shadow,
          tooltip: 'Customize shadow of background'
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
                    min: 0,
                    max: 100,
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
          icon: RenderIcons.border_radius,
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
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.padding,
          tooltip: 'Adjust Padding'
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
          icon: RenderIcons.align_left
        ),
        Option.button(
          title: 'Center',
          tooltip: 'Align Text To Center',
          onTap: (context) async {
            align = TextAlign.center;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.align_center
        ),
        Option.button(
          title: 'Right',
          tooltip: 'Align Text To Right',
          onTap: (context) async {
            align = TextAlign.right;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.align_right
        ),
        Option.button(
          title: 'Justify',
          tooltip: 'Justify Text Alignment',
          onTap: (context) async {
            align = TextAlign.justify;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.align_justify
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
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    shadow = null;
                    updateListeners(WidgetChange.update);
                  },
                  icon: Icon(RenderIcons.delete),
                  iconSize: 20,
                )
              ]
            );
          },
          icon: RenderIcons.shadow,
          tooltip: 'Customize shadow of text'
        ),
        Option.button(
          title: 'Outline',
          tooltip: 'Add an outline to text',
          onTap: (context) async {
            _updateStroke(true);
          },
          icon: RenderIcons.outline
        ),
      ],
    ),
    EditorTab(
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
          project: project,
        ),
        Option.nudge(
          widget: this,
          project: project
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
          icon: RenderIcons.spacing,
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
          icon: RenderIcons.word_spacing,
          tooltip: 'Adjust Word Spacing'
        ),
        Option.button(
          icon: RenderIcons.height,
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
    )
  ];

  // Inherited
  final String name = 'Text';
  final String id = 'text';

  bool isResizable = true;
  bool isDraggable = true;

  /// Text Color
  late Color color;
  
  /// BackgroundWidget Color
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

  double lineHeight = 0.77; // 0.77 alternative

  EdgeInsets padding = EdgeInsets.zero;

  Shadow? shadow;

  Paint? stroke;

  TextDecorationStyle decorationStyle = TextDecorationStyle.solid;

  Color? widgetColor;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? boxShadow;

  Widget widget(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: widgetColor,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Center(child: textWidget),
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
    // decorationColor: stroke == null ? decorationColor : null,
    decorationColor: stroke == null ? color : null,
    height: lineHeight,
  );

  @override
  void onDoubleTap(BuildContext context) async {
    await showEditTextModal(context);
  }

  Future<void> showEditTextModal(BuildContext context) async {
    String? text = await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          TextEditingController textCtrl = TextEditingController(text: this.text);
          textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.length);
          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Palette.of(context).surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  spreadRadius: 0,
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NewBackButton(
                          size: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            'Edit Text',
                            style: Theme.of(context).textTheme.subtitle1!.copyWith(),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(textCtrl.text);
                      },
                      icon: Icon(RenderIcons.done)
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 24),
                  child: TextFormField(
                    autofocus: true,
                    controller: textCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type something ...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none
                      )
                    ),
                    minLines: 6,
                    maxLines: 7,
                  ),
                )
              ],
            )
          );
        },
      ),
    );
    if (text != null && text.trim() != '') this.text = text;
    if (autoSize) _removeExtraSpaceFromSize();
    lineHeight = 1.0;
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
    ) ..layout(minWidth: 0, maxWidth: size.width - (padding.left * 2));
    Size _newSize = textPainter.size;
    Size __size = size;
    if (((_newSize.width - size.width)).abs() > 5) __size = Size(_newSize.width, __size.height);
    if (((_newSize.height - size.height)).abs() > 5) __size = Size(__size.width, _newSize.height);
    // if (__size < size) size = __size;
    size = __size;
  }

  void _updateStroke([bool isToggling = false]) {
    if ((isToggling && stroke == null) || (!isToggling && stroke != null)) {
      stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bold ? 2 : 1
        ..color = color;
      if (isToggling) updateListeners(WidgetChange.update);
    } else if (isToggling && stroke != null) {
      stroke = null;
      updateListeners(WidgetChange.update);
    }
  }

  @override
  void updateListeners(WidgetChange change, {bool removeGrids = false}) {
    _updateStroke();
    super.updateListeners(change, removeGrids: removeGrids);
  }

  void onPaletteUpdate() {
    if (widgetColor != null) {
      widgetColor = page.palette.primary;
      color = widgetColor!.computeTextColor();
    } else {
      color = page.palette.background.computeTextColor();
    }
    _updateStroke();
    updateListeners(WidgetChange.misc);
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
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
      'color': widgetColor?.toHex(),
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
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
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

      if (json['widget']['color'] != null) widgetColor = HexColor.fromHex(json['widget']['color']);
      radius = json['widget']['radius'];

      align = TextAlign.values.where((element) => element.index == json['alignment']).first;

      if (json['shadow'] != null) {
        shadow = Shadow(
          blurRadius: json['shadow']['blurRadius'],
          color: HexColor.fromHex(json['shadow']['color']),
          offset: Offset(json['shadow']['dx'], json['shadow']['dy'])
        );
      }

      padding = PaddingExtension.fromJSON(Map.from(json['padding']));

      letterSpacing = json['spacing']['letter'];
      wordSpacing = json['spacing']['word'];

    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to render text', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to build text widget',
        details: 'Failed to build text widget from JSON: $e',
      );
    }
  }

}