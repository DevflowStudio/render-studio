import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../rehmat.dart';

class QRWidget extends CreatorWidget {

  QRWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    QRWidget qr = QRWidget(page: page);
    String? _data = await showModalBottomSheet(
      context: context,
      backgroundColor: Palette.of(context).background.withOpacity(0.6),
      barrierColor: Colors.transparent,
      builder: (context) => QRCodeDataEditor(),
    );
    if (_data == null) return;
    qr.data = _data;
    page.widgets.add(qr);
  }

  // Inherited
  final String name = 'QR Code';
  @override
  final String id = 'qr_code';

  late String data;

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  
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
      tab: 'QR Code',
      options: [
        Option.button(
          title: 'Data',
          tooltip: 'Edit the data of QR Code',
          onTap: (context) async { },
          icon: RenderIcons.edit
        ),
        Option.color(
          title: 'Color',
          tooltip: 'Change the color of QR Code',
          onChange: (_color) {
            if (_color == null) return;
            backgroundColor = _color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        Option.color(
          icon: RenderIcons.color,
          title: 'Data Color',
          tooltip: 'Change the color of QR Data',
          onChange: (_color) {
            if (_color == null) return;
            dataColor = _color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
    ),
    EditorTab(
      tab: 'Customize',
      options: [
        Option.button(
          title: 'Padding',
          tooltip: 'Customize the padding of QR Code',
          onTap: (context) async {
            await EditorTab.modal(
              context,
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
          icon: RenderIcons.padding
        ),
        Option.toggle(
          title: 'Gapless',
          value: gapless,
          onChange: (value) {
            gapless = value;
            updateListeners(WidgetChange.update);
          },
          enabledIcon: RenderIcons.gap,
          disabledIcon: RenderIcons.gap,
          enabledTooltip: 'Enable gapless rendering',
          disabledTooltip: 'Disable gapless rendering',
        ),
        Option.button(
          icon: RenderIcons.image,
          title: 'Image',
          tooltip: 'Tap to add embed an image',
          onTap: (context) async {
            embeddedImage = await Asset.pick(
              page.project,
              cropRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
              context: context
            );
            updateListeners(WidgetChange.update);
          },
        ),
      ]
    ),
    EditorTab(
      tab: 'Adjust',
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
          icon: RenderIcons.refresh,
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
                maxSize: page.project.contentSize,
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
          icon: RenderIcons.scale,
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
          icon: RenderIcons.opacity,
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
          icon: RenderIcons.nudge,
          tooltip: 'Nudge'
        ),
      ],
    ),
  ];

  Color backgroundColor = Colors.white;
  Color dataColor = Colors.black;
  bool gapless = true;
  EdgeInsets padding = EdgeInsets.zero;

  Asset? embeddedImage;

  @override
  Widget widget(BuildContext context) => QrImage(
    data: data,
    backgroundColor: backgroundColor,
    eyeStyle: QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: dataColor,
    ),
    dataModuleStyle: QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: dataColor,
    ),
    gapless: gapless,
    padding: padding,
    embeddedImage: embeddedImage != null ? FileImage(embeddedImage!.file) : null,
    embeddedImageStyle: QrEmbeddedImageStyle(
      size: size/5
    ),
  );

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'data': data,
    'backgroundColor': backgroundColor.toHex(),
    'dataColor': dataColor.toHex(),
    'gapless': gapless,
    'padding': padding.toJSON(),
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);

    try {
      data = json['data'];
      backgroundColor = HexColor.fromHex(json['backgroundColor']);
      dataColor = HexColor.fromHex(json['dataColor']);
      gapless = json['gapless'];
      padding = PaddingExtension.fromJSON(json['padding']);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to build QR code', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to render QR Code',
        details: 'Failed to render QR Code: $e',
      );
    }
  }

}