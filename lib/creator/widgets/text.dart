import 'dart:ui';
import 'package:flutter/cupertino.dart';
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
    containerProvider = CreativeContainerProvider.create(this);
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
        Option(
          widget: (context) => ButtonWithIcon(
            title: 'Font',
            onTap: (context) async {
              await EditorTab.modal(
                context,
                height: 170,
                actions: [
                  IconButton(
                    onPressed: () async {
                      String? _font = await AppRouter.push<String>(context, page: const FontSelector());
                      if (_font != null) fontFamily = _font;
                      updateListeners(WidgetChange.misc);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(RenderIcons.search)
                  )
                ],
                tab: (context, setState) {
                  List<String> fonts = [
                    'Roboto',
                    'Inter',
                    'Poppins',
                    'Abril Fatface',
                    'Open Sans',
                    'Alegreya',
                    'Montserrat',
                    'Noto Sans',
                    'Ubuntu',
                    'Merriweather',
                    'Lato',
                    'Raleway',
                    'Oswald',
                    'Lora',
                    'Nunito',
                    'Playfair Display',
                    'PT Sans',
                    'PT Serif',
                    'Roboto Slab',
                    'Source Sans Pro',
                    'Fira Sans',
                    'Work Sans',
                    'Barlow Condensed',
                  ];
                  if (!fonts.contains(fontFamily)) fonts.insert(0, fontFamily);
                  return EditorTab(
                    tab: 'Fonts',
                    type: EditorTabType.hGrid,
                    options: [
                      for (String font in fonts) Option.custom(
                        widget: (context) => SizedBox(
                          height: 80,
                          width: 80,
                          child: InkWell(
                            onTap: () {
                              fontFamily = font;
                              updateListeners(WidgetChange.misc);
                              setState(() { });
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: font == fontFamily ? Palette.of(context).surfaceVariant : null,
                                border: font == fontFamily ? Border.all(
                                  color: Palette.of(context).outline,
                                  width: 2
                                ) : null,
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Aa',
                                    style: GoogleFonts.getFont(font).copyWith(
                                      fontSize: 40,
                                      color: Theme.of(context).textTheme.bodySmall?.color,
                                    ),
                                  ),
                                  AutoSizeText(
                                    font,
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    wrapWords: false,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      height: 0.77,
                                      color: Constants.getThemedObject(context, light: Colors.grey, dark: Colors.grey[400])
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              );
              updateListeners(WidgetChange.update);
            },
            child: Text(
              'Aa',
              style: GoogleFonts.getFont(fontFamily).copyWith(
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                color: Palette.of(context).onSecondaryContainer,
              ),
            ),
            tooltip: 'Select Font',
          )
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
              tab: (context, setState) => EditorTab.size(
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
    // EditorTab(
    //   tab: 'Font',
    //   options: [
    //     Option.button(
    //       title: 'Search',
    //       onTap: (context) async {
    //         String? _font = await AppRouter.push<String>(context, page: const FontSelector());
    //         if (_font != null) fontFamily = _font;
    //         notifyListeners(WidgetChange.update);
    //       },
    //       icon: RenderIcons.search,
    //       tooltip: 'Search Fonts'
    //     ),
    //     for (String font in [
    //       'Roboto',
    //       'Poppins',
    //       'Abril Fatface',
    //       'Open Sans',
    //       'Montserrat',
    //       'Noto Sans',
    //       'Ubuntu',
    //       'Merriweather',
    //       'Playfair Display',
    //       'DM Sans'
    //     ]) Option.font(
    //       font: font,
    //       isSelected: fontFamily == font,
    //       onFontSelect: (context, font) {
    //         this.fontFamily = font;
    //         updateListeners(WidgetChange.update);
    //       },
    //     ),
    //   ],
    // ),
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
    containerProvider.editor(
      onChange: (change) {
        updateListeners(change);
      },
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
          onTap: (context) async {
            if (shadows == null) shadows = [Shadow()];
            await EditorTab.modal(
              context,
              tab: (context, setState) => EditorTab.shadow<Shadow>(
                shadow: shadows!.first,
                onChange: (value) {
                  if (value == null) shadows = null;
                  else shadows = [value];
                  updateListeners(WidgetChange.misc);
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
            updateListeners(WidgetChange.update);
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

  bool keepAspectRatio = false;
  
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

  double lineHeight = 0.77; // 0.77 alternative

  EdgeInsets padding = EdgeInsets.zero;

  List<Shadow>? shadows;

  TextDecorationStyle decorationStyle = TextDecorationStyle.solid;

  Color? widgetColor;

  Color? borderColor;
  double? borderWidth;

  double borderRadius = 0;

  BoxShadow? boxShadow;

  late CreativeContainerProvider containerProvider;

  Widget widget(BuildContext context) => containerProvider.build(
    child: Center(child: textWidget),
  );

  Widget get textWidget => autoSize ? AutoSizeText(
    text,
    textAlign: align,
    style: style,
    secondaryStyle: secondaryTextStyle,
    maxFontSize: 200,
    presetFontSizes: [
      ... 5.0.upTo(200, stepSize: 0.01).reversed
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
    TextEditingController textCtrl = TextEditingController(text: this.text);
    textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.length);
    TextAlign align = this.align;
    var focusNode = FocusNode();
    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return SizedBox(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: 6,
                  right: 6,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 6,
                ),
                decoration: BoxDecoration(
                  color: Palette.of(context).background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: textCtrl,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Type something ...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none
                        ),
                        filled: false,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9
                        ),
                      ),
                      minLines: 4,
                      maxLines: 8,
                      textAlign: align,
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 20
                      ),
                      contextMenuBuilder: (BuildContext context, EditableTextState editableTextState) {
                        return AdaptiveTextSelectionToolbar(
                          anchors: editableTextState.contextMenuAnchors,
                          children: [
                            if (!editableTextState.currentTextEditingValue.selection.isCollapsed) Container(
                              color: Constants.getThemedBlackAndWhite(context),
                              child: TextButton(
                                onPressed: () {
                                  String text = editableTextState.currentTextEditingValue.selection.textInside(textCtrl.text);
                                  textCtrl.text = textCtrl.text.replaceFirst(text, '*$text*');
                                  textCtrl.selection = TextSelection.collapsed(offset: textCtrl.text.indexOf('*$text*') + text.length + 1);
                                },
                                child: Text(
                                  'Style',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Constants.getThemedBlackAndWhite(context).isDark ? Colors.white : Colors.black,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                            ... editableTextState.contextMenuButtonItems.map((ContextMenuButtonItem buttonItem) {
                              return Container(
                                color: Constants.getThemedBlackAndWhite(context),
                                child: TextButton(
                                  onPressed: buttonItem.onPressed,
                                  child: Text(
                                    CupertinoTextSelectionToolbarButton.getButtonLabel(context, buttonItem),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Constants.getThemedBlackAndWhite(context).isDark ? Colors.white : Colors.black,
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              );
                            }).toList()
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              List<TextAlign> alignments = [
                                TextAlign.left,
                                TextAlign.center,
                                TextAlign.right,
                                TextAlign.justify,
                              ];
                              int index = alignments.indexOf(align);
                              setState(() {
                                align = alignments[alignments.nextIndex(index)];
                              });
                              updateListeners(WidgetChange.misc);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Palette.of(context).outline,
                                  width: 1
                                ),
                                borderRadius: BorderRadius.circular(6)
                              ),
                              child: Text(
                                'Align: ${align.toString().split('.').last.toTitleCase()}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(
                      height: 0,
                      endIndent: 0,
                      indent: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Palette.of(context).surfaceVariant,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              focusNode.hasFocus ? RenderIcons.close_keyboard : RenderIcons.keyboard,
                            ),
                            onPressed: () {
                              if (MediaQuery.of(context).viewInsets.bottom > 0) {
                                focusNode.unfocus();
                              } else {
                                focusNode.requestFocus();
                              }
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Done')
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
            ),
          );
        },
      ),
    );
    bool logHistory = this.text != textCtrl.text || align != this.align;
    this.align = align;
    String text = textCtrl.text;
    if (text.trim() != '') this.text = text;
    if (autoSize) _removeExtraSpaceFromSize(limitSize: true);
    if (logHistory) updateListeners(WidgetChange.update);
    else updateListeners(WidgetChange.misc);
    if (_containsSecondaryStyle(text) && secondaryStyle == null) Alerts.snackbar(
      context,
      text: 'Please add a secondary style to apply new style to the selected text'
    );
  }

  @override
  void onResizeFinished({
    DragEndDetails? details,
    ResizeHandler? handler,
    bool updateNotify = true
  }) {
    _removeExtraSpaceFromSize(handler: handler);
    super.onResizeFinished(details: details, handler: handler, updateNotify: updateNotify);
  }

  void _removeExtraSpaceFromSize({
    ResizeHandler? handler,
    bool limitSize = false
  }) {
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
    List lines = textPainter.computeLineMetrics();
    if (lines.length > 1) {
      double _lineHeight = 1.0;
      for (int i = 0; i < lines.length; i++) {
        if (i == 0) continue;
        _lineHeight += lines[i].height / lines[i - 1].height;
      }
      _lineHeight /= lines.length;
      lineHeight = _lineHeight;
    }
    Size wantedSize = textPainter.size + Offset(containerProvider.padding.horizontal, containerProvider.padding.vertical);
    Size adjustedSize = size;
    if (((wantedSize.width - size.width)).abs() > 5) adjustedSize = Size(wantedSize.width, adjustedSize.height);
    if (((wantedSize.height - size.height)).abs() > 5) adjustedSize = Size(adjustedSize.width, wantedSize.height);
    if (limitSize && adjustedSize.height >= page.project.contentSize.height * 0.75) adjustedSize = Size(adjustedSize.width, page.project.contentSize.height * 0.75);
    if (limitSize && adjustedSize.width >= page.project.contentSize.width * 0.75) adjustedSize = Size(page.project.contentSize.width * 0.75, adjustedSize.height);
    _autoPositionAfterResize(oldSize: size, newSize: adjustedSize);
    size = adjustedSize;
  }
  
  /// Auto position after `_removeExtraSpaceFromSize()` has finished
  /// 
  /// Executing this provides a better experience when resizing the widget
  void _autoPositionAfterResize({
    required Size newSize,
    required Size oldSize
  }) {
    double changeInX = 0;
    double changeInY = 0;

    bool isLeftCornerOutOfBounds = position.dx - newSize.width/2 < (-page.project.contentSize.width/2);
    bool isRightCornerOutOfBounds = position.dx + newSize.width/2 > (page.project.contentSize.width/2);

    int nWords = text.split(' ').length;

    if (align == TextAlign.center || align == TextAlign.justify || nWords < 2);
    else if (isLeftCornerOutOfBounds || align == TextAlign.left) changeInX = (oldSize.width - newSize.width)/2;
    else if (isRightCornerOutOfBounds || align == TextAlign.right) changeInX = -(oldSize.width - newSize.width)/2;

    position = Offset(position.dx - changeInX, position.dy - changeInY);
  }

  bool _containsSecondaryStyle(String text) {
    // return true if the string contains words enclosed in asterisks
    return text.contains(RegExp(r'\*.*\*'));
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
    'container-provider': containerProvider.toJSON(),
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

      if (json['container-provider'] != null) {
        containerProvider = CreativeContainerProvider.fromJSON(json['container-provider'], widget: this);
      }

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