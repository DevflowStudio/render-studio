import 'package:flutter/material.dart';
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
          icon: Icons.palette,
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
        Option.button(
          icon: Icons.space_bar,
          title: 'Gapless',
          tooltip: 'Tap to toggle gapless property',
          onTap: (context) async {
            gapless = !gapless;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete asset',
          onTap: (context) async {
            page.delete(this);
          },
        ),
      ],
    )
  ];

  Color backgroundColor = Colors.white;
  Color dataColor = Colors.black;
  bool gapless = true;
  EdgeInsets padding = EdgeInsets.zero;

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
    // embeddedImage: AssetImage('assets/images/avatar.png'),
    // embeddedImageStyle: QrEmbeddedImageStyle(
    //   // color: Colors.red
    //   // size: Size(40, 40)
    // ),
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
  bool buildFromJSON(Map<String, dynamic> json) {
    if (super.buildFromJSON(json)) {
      try {
        data = json['data'];
        backgroundColor = HexColor.fromHex(json['backgroundColor']);
        dataColor = HexColor.fromHex(json['dataColor']);
        gapless = json['gapless'];
        padding = PaddingExtension.fromJSON(json['padding']);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else return false;
  }

}