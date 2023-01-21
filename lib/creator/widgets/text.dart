import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import '../../rehmat.dart';

class CreatorText extends CreatorWidget {

  CreatorText({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    page.widgets.add(CreatorText(page: page));
  }
  
  @override
  void onInitialize() {
    primaryStyle = CreativeTextStyle(widget: this);
    primaryStyle.color = page.palette.onBackground;
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
        Option.toggle(
          title: 'Auto Size',
          value: autoSize,
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
                  size = calculateSizeForTextStyle(text, style: style, page: page);
                  updateListeners(WidgetChange.misc);
                }
              )
            );
            updateListeners(WidgetChange.resize);
          },
          icon: RenderIcons.text_size
        ),
        ... defaultOptions,
      ],
    ),
    EditorTab(
      tab: 'Font',
      options: [
        Option.button(
          title: 'Search',
          onTap: (context) async {
            String? _font = await AppRouter.push<String>(context, page: const FontSelector());
            if (_font != null) fontFamily = _font;
            notifyListeners(WidgetChange.update);
          },
          icon: RenderIcons.search,
          tooltip: 'Search Fonts'
        ),
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
          isSelected: fontFamily == font,
          onFontSelect: (context, font) {
            this.fontFamily = font;
            updateListeners(WidgetChange.update);
          },
        ),
      ],
    ),
    EditorTab(
      tab: 'Style',
      options: [
        ... primaryStyle.options
      ],
    ),
    EditorTab(
      tab: 'Secondary Style',
      options: [
        Option.button(
          title: 'Info',
          onTap: (context) => Alerts.modalInfoBuilder(
            context,
            title: 'Secondary Style',
            message: 'Secondary style is used to apply a different style to a part of the text. For example, you can apply a different color to a part of the text. To apply a secondary style to a part of the text, enclose the text in asterisks (*). For example, "demo" in "Let\'s try with a *demo*" will be styled with the secondary style.',
          ),
          icon: RenderIcons.info
        ),
        if (secondaryStyle == null) Option.button(
          title: 'Add Secondary Style',
          onTap: (context) {
            secondaryStyle = CreativeTextStyle(widget: this);
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.add
        ) else ... [
          Option.button(
            title: 'Swap Styles',
            onTap: (context) {
              CreativeTextStyle temp = primaryStyle;
              primaryStyle = secondaryStyle!;
              secondaryStyle = temp;
              updateListeners(WidgetChange.update);
            },
            icon: RenderIcons.swap
          ),
          ... secondaryStyle!.options,
          Option.button(
            title: 'Remove Secondary Style',
            tooltip: 'Remove secondary style',
            onTap: (context) {
              secondaryStyle = null;
              updateListeners(WidgetChange.update);
            },
            icon: RenderIcons.remove
          )
        ]
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
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.border_radius,
          title: 'Radius',
          max: 0,
          min: 100,
          value: borderRadius,
          onChange: (value) {
            radius = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            radius = value;
            updateListeners(WidgetChange.update);
          },
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
          icon: RenderIcons.text_align_left
        ),
        Option.button(
          title: 'Center',
          tooltip: 'Align Text To Center',
          onTap: (context) async {
            align = TextAlign.center;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.text_align_center
        ),
        Option.button(
          title: 'Right',
          tooltip: 'Align Text To Right',
          onTap: (context) async {
            align = TextAlign.right;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.text_align_right
        ),
        Option.button(
          title: 'Justify',
          tooltip: 'Justify Text Alignment',
          onTap: (context) async {
            align = TextAlign.justify;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.text_align_justify
        ),
      ],
    ),
    EditorTab(
      tab: 'Effects',
      options: [
        Option.button(
          title: 'Shadow',
          onTap: (context) {
            if (shadows == null) shadows = [Shadow()];
            EditorTab.modal(
              context,
              tab: EditorTab.shadow<Shadow>(
                shadow: shadows!.first,
                onChange: (value) {
                  if (value == null) shadows = null;
                  else shadows = [value];
                  updateListeners(WidgetChange.misc);
                },
                onChangeEnd: (value) {
                  if (value == null) shadows = null;
                  else shadows = [value];
                  updateListeners(WidgetChange.update);
                },
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    shadows = null;
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
            primaryStyle.addStroke();
            secondaryStyle?.addStroke();
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.outline
        ),
        Option.button(
          title: 'Lifted',
          tooltip: 'Add a lifted effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 1 && shadows!.first.offset == Offset(0, 0) && shadows!.first.blurRadius == 30 && shadows!.first.color == Colors.black.withOpacity(0.5)) {
              shadows = null;
            } else shadows = [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 30,
                offset: Offset(0, 0)
              )
            ];
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.lifted
        ),
        Option.button(
          title: 'Echo',
          tooltip: 'Add echo effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 2 && shadows!.first.offset == Offset(5, 5) && shadows!.first.blurRadius == 2 && shadows![1].blurRadius == 4 && shadows![1].offset == Offset(10, 10)) {
              shadows = null;
            } else {
              secondaryStyle = null;
              shadows = [
                BoxShadow(
                  color: primaryStyle.color.withOpacity(0.4),
                  blurRadius: 2,
                  offset: Offset(5, 5)
                ),
                BoxShadow(
                  color: primaryStyle.color.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(10, 10)
                ),
              ];
            }
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.echo
        ),
        Option.button(
          title: 'Splice',
          tooltip: 'Add splice effect to text',
          onTap: (context) async {
            if (primaryStyle.stroke != null && (shadows?.length ?? 0) == 1 && shadows!.first.blurRadius == 2 && shadows!.first.offset == Offset(5, 5)) {
              if (primaryStyle.stroke != null) primaryStyle.addStroke();
              shadows = [];
            } else {
              secondaryStyle = null;
              if (primaryStyle.stroke == null) primaryStyle.addStroke();
              shadows = [
                BoxShadow(
                  color: primaryStyle.color.withOpacity(0.4),
                  blurRadius: 2,
                  offset: Offset(5, 5)
                ),
              ];
            }
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.splice
        ),
        Option.button(
          title: 'Glitch',
          tooltip: 'Add glitch effect to text',
          onTap: (context) async {
            if ((shadows?.length ?? 0) == 2 && shadows!.first.offset == Offset(-2, 0) && shadows![1].offset == Offset(2, 0)) {
              shadows = null;
            } else {
              shadows = [
                BoxShadow(
                  color: Colors.redAccent,
                  blurRadius: 3,
                  offset: Offset(-2, 0)
                ),
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 3,
                  offset: Offset(2, 0)
                ),
              ];
            }
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.textGlitch
        ),
      ],
    ),
    EditorTab.adjustTab(widget: this),
    EditorTab(
      tab: 'Spacing',
      type: EditorTabType.row,
      options: [
        Option.showSlider(
          icon: RenderIcons.spacing,
          tooltip: 'Adjust Letter Spacing',
          title: 'Letter',
          max: 20,
          min: -10,
          value: letterSpacing,
          onChange: (value) {
            letterSpacing = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            letterSpacing = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.word_spacing,
          tooltip: 'Adjust Word Spacing',
          title: 'Word',
          max: 20,
          min: -10,
          value: wordSpacing,
          onChange: (value) {
            wordSpacing = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            wordSpacing = value;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.showSlider(
          icon: RenderIcons.height,
          title: 'Height',
          tooltip: 'Change line height of the text',
          max: 2,
          min: 0.66,
          value: lineHeight,
          onChange: (value) {
            lineHeight = value;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (value) {
            lineHeight = value;
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
  
  /// BackgroundWidget Color
  Color textBackground = Colors.transparent;
  Color? decorationColor = Colors.black;

  String text = 'Double tap to edit text';

  bool autoSize = true;

  TextAlign align = TextAlign.left;

  double wordSpacing = 0;
  double letterSpacing = 1;

  Size size = const Size(200, 100);
  Size? minSize = const Size(10, 5);

  double fontSize = 100;

  String fontFamily = 'Inter';

  double radius = 10;

  double lineHeight = 1; // 0.77 alternative

  EdgeInsets padding = EdgeInsets.zero;

  List<Shadow>? shadows;

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
    secondaryStyle: secondaryTextStyle,
    maxFontSize: 200,
    presetFontSizes: [
      ... List.generate(500, (index) => index.toDouble()).reversed
    ],
    onFontSizeChanged: (fontSize) {
      this.fontSize = fontSize;
    },
    wrapWords: false,
    // softWrap: false,
  ) : CreativeTextWidget(
    text,
    textAlign: align,
    style: style,
    secondaryStyle: secondaryTextStyle,
  );

  late CreativeTextStyle primaryStyle;
  CreativeTextStyle? secondaryStyle;

  TextStyle get style => primaryStyle.style(
    font: fontFamily,
    lineHeight: lineHeight,
    decorationStyle: decorationStyle,
    shadows: shadows,
    wordSpacing: wordSpacing,
    letterSpacing: letterSpacing,
    fontSize: fontSize,
  );

  TextStyle? get secondaryTextStyle => secondaryStyle?.style(
    font: fontFamily,
    lineHeight: lineHeight,
    decorationStyle: decorationStyle,
    shadows: shadows,
    wordSpacing: wordSpacing,
    letterSpacing: letterSpacing,
    fontSize: fontSize
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
    // lineHeight = 1.0;
    updateListeners(WidgetChange.update);
  }

  @override
  void onResizeFinished(details, handler, {
    bool updateNotify = true
  }) {
    _removeExtraSpaceFromSize(handler);
    super.onResizeFinished(details, handler);
  }

  void _removeExtraSpaceFromSize([ResizeHandler? handler]) {
    if (textWidget is CreativeTextWidget) return;
    String _text = text.replaceAll('*', '');
    final span = TextSpan(
      style: (textWidget as AutoSizeText).style,
      text: _text,
    );
    final words = span.toPlainText().split(RegExp('\\s+'));
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: (textWidget as AutoSizeText).style,
      ),
      textAlign: align,
      maxLines: words.length,
      textDirection: TextDirection.ltr
    ) ..layout(minWidth: 0, maxWidth: size.width);
    Size _newSize = textPainter.size;
    Size __size = size;
    if (((_newSize.width - size.width)).abs() > 5) __size = Size(_newSize.width, __size.height);
    if (((_newSize.height - size.height)).abs() > 5) __size = Size(__size.width, _newSize.height);
    // if (__size < size) size = __size;
    _autoPositionAfterResize(oldSize: size, newSize: __size);
    size = __size;
  }
  
  /// Auto position after `_removeExtraSpaceFromSize()` has finished
  /// 
  /// Executing this provides a better experience when resizing the widget
  // ignore: unused_element
  void _autoPositionAfterResize({
    required Size newSize,
    required Size oldSize
  }) {
    double changeInX = 0;
    double changeInY = 0;

    bool isLeftCornerOutOfBounds = position.dx - newSize.width/2 < (-page.project.contentSize.width/2);
    bool isRightCornerOutOfBounds = position.dx + newSize.width/2 > (page.project.contentSize.width/2);

    if (isLeftCornerOutOfBounds || align == TextAlign.left) changeInX = (oldSize.width - newSize.width)/2;
    else if (isRightCornerOutOfBounds || align == TextAlign.right) changeInX = -(oldSize.width - newSize.width)/2;

    position = Offset(position.dx - changeInX, position.dy - changeInY);
  }

  @override
  void updateListeners(WidgetChange change, {bool removeGrids = false}) {
    super.updateListeners(change, removeGrids: removeGrids);
  }

  void onPaletteUpdate() {
    if (widgetColor != null) {
      widgetColor = page.palette.primary;
      primaryStyle.color = widgetColor!.computeTextColor();
    } else {
      primaryStyle.color = page.palette.onBackground;
    }
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
      'background': textBackground.toHex()
    },
    'primary-style': primaryStyle.toJSON(),
    'secondary-style': secondaryStyle?.toJSON(),
    'widget': {
      'color': widgetColor?.toHex(),
      'radius': radius,
    },
    'alignment': align.index,
    'shadows': shadows != null ? [
      for (Shadow shadow in shadows!) {
        'color': shadow.color.toHex(),
        'offset': {
          'dx': shadow.offset.dx,
          'dy': shadow.offset.dy
        },
        'blur': shadow.blurRadius
      }
    ] : null,
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

      textBackground = HexColor.fromHex(json['color']['background']);

      primaryStyle = CreativeTextStyle.fromJSON(json['primary-style'], widget: this);
      if (json['secondary-style'] != null) secondaryStyle = CreativeTextStyle.fromJSON(json['secondary-style'], widget: this);

      if (json['widget']['color'] != null) widgetColor = HexColor.fromHex(json['widget']['color']);
      radius = json['widget']['radius'];

      align = TextAlign.values.where((element) => element.index == json['alignment']).first;

      for (final shadowData in json['shadows'] ?? []) {
        if (shadows == null) shadows = [];
        shadows!.add(
          Shadow(
            blurRadius: shadowData['blur'],
            color: HexColor.fromHex(shadowData['color']),
            offset: Offset(shadowData['offset']['dx'], shadowData['offset']['dy'])
          )
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

class CreativeTextStyle {

  bool bold = false;
  bool italics = false;
  bool underline = false;
  bool strikethrough = false;
  bool overline = false;

  Paint? stroke;

  late Color color;

  final CreatorWidget widget;
  CreativeTextStyle({required this.widget}) {
    color = widget.page.palette.onBackground;
  }

  factory CreativeTextStyle.fromTextStyle(TextStyle style, {
    required CreatorWidget widget,
  }) {
    CreativeTextStyle creativeTextStyle = CreativeTextStyle(
      widget: widget,
    );
    creativeTextStyle.bold = style.fontWeight == FontWeight.bold;
    creativeTextStyle.italics = style.fontStyle == FontStyle.italic;
    creativeTextStyle.underline = style.decoration?.contains(TextDecoration.underline) ?? false;
    creativeTextStyle.strikethrough = style.decoration?.contains(TextDecoration.lineThrough) ?? false;
    creativeTextStyle.overline = style.decoration?.contains(TextDecoration.overline) ?? false;
    creativeTextStyle.color = style.color ?? widget.page.palette.onBackground;
    return creativeTextStyle;
  }

  factory CreativeTextStyle.fromJSON(Map data, {
    required CreatorWidget widget
  }) {
    final style = CreativeTextStyle(widget: widget);
    style.bold = data['bold'];
    style.italics = data['italics'];
    style.underline = data['underline'];
    style.strikethrough = data['strikethrough'];
    style.overline = data['overline'];
    style.color = HexColor.fromHex(data['color']);
    return style;
  }

  Map<String, dynamic> toJSON() => {
    'bold': bold,
    'italics': italics,
    'underline': underline,
    'strikethrough': strikethrough,
    'overline': overline,
    'color': color.toHex(),
  };

  void _updateStroke([bool isToggling = false]) {
    if ((isToggling && stroke == null) || (!isToggling && stroke != null)) {
      stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bold ? 2 : 1
        ..color = color;
      // if (isToggling) updateListeners(WidgetChange.update);
    } else if (isToggling && stroke != null) {
      stroke = null;
    }
  }

  void addStroke() {
    _updateStroke(true);
  }

  void refresh() {
    _updateStroke();
    color = widget.page.palette.onBackground;
  }

  TextStyle style({
    required String font,
    required double lineHeight,
    TextDecorationStyle? decorationStyle,
    List<Shadow>? shadows,
    double? wordSpacing,
    double? letterSpacing,
    double? fontSize,
  }) => GoogleFonts.getFont(font).copyWith(
    fontWeight: bold ? (stroke != null ? FontWeight.normal : FontWeight.bold) : FontWeight.normal,
    decoration: TextDecoration.combine([
      if (underline) TextDecoration.underline,
      if (strikethrough) TextDecoration.lineThrough,
      if (overline) TextDecoration.overline,
    ]),
    fontStyle: italics ? FontStyle.italic : FontStyle.normal,
    color: stroke == null ? color : null,
    fontSize: fontSize,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
    fontFeatures: [ ],
    shadows: [
      if (shadows != null) ... shadows
    ],
    foreground: stroke,
    decorationStyle: decorationStyle,
    decorationColor: stroke == null ? color : null,
    height: lineHeight,
  );

  List<Option> get options => [
    Option.color(
      tooltip: 'Tap to select text color',
      palette: widget.page.palette,
      selected: color,
      onChange: (_color) {
        if (_color == null) return;
        this.color = _color;
        if (stroke != null) _updateStroke();
        widget.updateListeners(WidgetChange.misc);
      },
      onChangeEnd: (color) {
        widget.updateListeners(WidgetChange.update);
      },
    ),
    Option.toggle(
      title: 'Bold',
      value: bold,
      onChange: (value) {
        bold = value;
        _updateStroke();
        widget.updateListeners(WidgetChange.update);
      },
      enabledIcon: RenderIcons.bold,
      disabledIcon: RenderIcons.bold,
      disabledTooltip: 'Add bold formatting',
      enabledTooltip: 'Remove bold formatting',
    ),
    Option.toggle(
      title: 'Italics',
      value: italics,
      onChange: (value) {
        italics = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.italic,
      enabledIcon: RenderIcons.italic,
      disabledTooltip: 'Add italics formatting',
      enabledTooltip: 'Remove italics formatting',
    ),
    Option.toggle(
      title: 'Underline',
      value: underline,
      onChange: (value) {
        underline = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.underline,
      enabledIcon: RenderIcons.underline,
      disabledTooltip: 'Add underline formatting',
      enabledTooltip: 'Remove underline formatting',
    ),
    Option.toggle(
      title: 'Strikethrough',
      value: strikethrough,
      onChange: (value) {
        strikethrough = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.strike,
      enabledIcon: RenderIcons.strike,
      disabledTooltip: 'Add strikethrough formatting',
      enabledTooltip: 'Remove strikethrough formatting',
    ),
    Option.toggle(
      title: 'Overline',
      value: overline,
      onChange: (value) {
        overline = value;
        widget.updateListeners(WidgetChange.update);
      },
      disabledIcon: RenderIcons.overline,
      enabledIcon: RenderIcons.overline,
      disabledTooltip: 'Add overline formatting',
      enabledTooltip: 'Remove overline formatting',
    ),
  ];

}

class CreativeTextWidget extends StatelessWidget {

  const CreativeTextWidget(this.text, {
    super.key,
    this.style,
    this.secondaryStyle,
    this.textAlign = TextAlign.center,
    this.strutStyle,
    this.textDirection,
    this.locale,
    this.softWrap = true,
    this.maxLines,
    this.semanticsLabel,
    this.overflow = TextOverflow.visible,
    this.textHeightBehavior
  });

  final String text;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final TextAlign? textAlign;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final int? maxLines;
  final String? semanticsLabel;
  final TextOverflow overflow;
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    return EasyRichText(
      text,
      defaultStyle: style,
      strutStyle: strutStyle,
      textAlign: textAlign ?? TextAlign.center,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap ?? true,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
      patternList: [
        EasyRichTextPattern(
          targetString: r'\*(.+?)\*',
          style: secondaryStyle ?? style,
          matchBuilder: (context, match) => TextSpan(
            text: match![0]!.replaceAll('*', ''),
            style: secondaryStyle ?? style,
          ),
        ),
      ],
    );
  }

}

Size calculateSizeForTextStyle(String text, {
  TextStyle? style,
  required CreatorPage page,
}) {
  final span = TextSpan(
    style: style,
    text: text,
  );
  final words = span.toPlainText().split(RegExp('\\s+'));
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: style,
    ),
    textAlign: TextAlign.left,
    maxLines: words.length,
    textDirection: TextDirection.ltr
  ) ..layout(minWidth: 0, maxWidth: page.project.contentSize.width - 20);
  return textPainter.size;
}