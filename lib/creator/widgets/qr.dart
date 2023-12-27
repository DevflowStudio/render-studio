import 'package:cached_network_image/cached_network_image.dart';
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
    String? _data = await openQRDataEditor(context);
    if (_data == null) return;
    qr.data = _data;
    page.widgets.add(qr);
  }

  static Future<String?> openQRDataEditor(BuildContext context) async {
    TextEditingController _controller = TextEditingController();
    await Alerts.modal(
      context,
      title: 'QR Code',
      actionButton: [
        FilledTonalIconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(RenderIcons.done),
        )
      ],
      childBuilder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12
        ),
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Enter data',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            )
          ),
        ),
      )
    );
    if (_controller.text.isEmpty) return null;
    return _controller.text;
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
          onTap: (context) async {
            String? _data = await openQRDataEditor(context);
            if (_data == null) return;
            data = _data;
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.edit
        ),
        Option.color(
          this,
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
          this,
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
            page.editorManager.openModal(
              tab: (context, setState) => EditorTab.paddingEditor(
                padding: padding,
                onChange: (value) {
                  padding = value;
                  updateListeners(WidgetChange.misc);
                },
              ),
              onDismiss: () => updateListeners(WidgetChange.update),
            );
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
            embeddedImage = await AssetX.pick(
              context,
              project: page.project,
              cropRatio: CropAspectRatio(ratioX: 1, ratioY: 1)
            );
            updateListeners(WidgetChange.update);
          },
        ),
      ]
    ),
    EditorTab.adjustTab(widget: this)
  ];

  Color backgroundColor = Colors.white;
  Color dataColor = Colors.black;
  bool gapless = true;
  EdgeInsets padding = EdgeInsets.zero;

  AssetX? embeddedImage;

  @override
  Widget widget(BuildContext context) => QrImageView(
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
    embeddedImage: embeddedImage != null ? ((embeddedImage!.assetType == AssetType.file ? FileImage(embeddedImage!.file!) : CachedNetworkImageProvider(embeddedImage!.url!)) as ImageProvider) : null,
    embeddedImageStyle: QrEmbeddedImageStyle(
      size: size/5
    ),
  );

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    EdgeInsets _padding = padding;
    if (buildInfo.buildType == BuildType.save) {
      _padding = page.project.sizeTranslator.getUniversalPadding(padding: _padding);
    }
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'data': data,
      'backgroundColor': backgroundColor.toHex(),
      'dataColor': dataColor.toHex(),
      'gapless': gapless,
      'padding': _padding.toJSON(),
    };
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    bool isBuildingFromUniversalBuild = json['properties']['is-universal-build'] ?? false;

    try {
      data = json['data'];
      backgroundColor = HexColor.fromHex(json['backgroundColor']);
      dataColor = HexColor.fromHex(json['dataColor']);
      gapless = json['gapless'];
      padding = PaddingExtension.fromJSON(json['padding']);
      if (isBuildingFromUniversalBuild) {
        padding = page.project.sizeTranslator.getLocalPadding(padding: padding);
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'failed to build QR code', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to render QR Code',
        details: 'Failed to render QR Code: $e',
      );
    }
  }

}