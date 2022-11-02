import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../rehmat.dart';

class QRWidget extends CreatorWidget {

  QRWidget({required CreatorPage page, required Project project, this.data = ''}) : super(page: page, project: project);

  // Inherited
  final String name = 'QR Code';
  @override
  final String id = 'qr_code';

  String data;

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
          icon: Icons.edit
        ),
        Option.button(
          icon: Icons.palette,
          title: 'Color',
          tooltip: 'Tap to select the background color',
          onTap: (context) async {
            Color? _color = await Palette.showColorPicker(
              context: context,
              defaultColor: Colors.white,
              title: 'Background Color'
            );
            if (_color != null) backgroundColor = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: Icons.color_lens_outlined,
          title: 'Data Color',
          tooltip: 'Tap to select the data color',
          onTap: (context) async {
            Color? _color = await Palette.showColorPicker(
              context: context,
              defaultColor: Colors.white,
              title: 'Background Color'
            );
            if (_color != null) dataColor = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete Widget',
          onTap: (context) async {
            page.delete(this);
          },
        ),
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
          icon: Icons.padding_rounded
        ),
        Option.toggle(
          title: 'Gapless',
          valueBuilder: () {
            return (page.widgets.singleWhere((element) => element.uid == uid) as QRWidget).gapless;
          },
          onChange: (value) {
            gapless = value;
            updateListeners(WidgetChange.update);
          },
          enabledIcon: Icons.space_bar,
          disabledIcon: Icons.space_bar,
          enabledTooltip: 'Enable gapless rendering',
          disabledTooltip: 'Disable gapless rendering',
        ),
        Option.button(
          icon: Icons.photo_rounded,
          title: 'Image',
          tooltip: 'Tap to add embed an image',
          onTap: (context) async {
            embeddedImage = await Asset.create(
              project,
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
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
    'data': data,
    'backgroundColor': backgroundColor.toHex(),
    'dataColor': dataColor.toHex(),
    'gapless': gapless,
    'padding': padding.toJSON(),
  };

  static Future<QRWidget?> create(BuildContext context, {
    required CreatorPage page,
    required Project project,
    required String data,
  }) async {
    QRWidget designAsset = QRWidget(page: page, project: project, data: data);
    return designAsset;
  }

  @override
  void buildFromJSON(Map<String, dynamic> json) {
    super.buildFromJSON(json);

    try {
      data = json['data'];
      backgroundColor = HexColor.fromHex(json['backgroundColor']);
      dataColor = HexColor.fromHex(json['dataColor']);
      gapless = json['gapless'];
      padding = PaddingExtension.fromJSON(json['padding']);
    } catch (e) {
      print("QR Build Failed: $e");
      throw WidgetCreationException(
        'Failed to render QR Code',
        details: 'Failed to render QR Code: $e',
      );
    }
  }

}