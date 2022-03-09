import 'package:flutter/material.dart';

import '../../rehmat.dart';

class CreatorIcon extends CreatorWidget {

  CreatorIcon({required CreatorPage page, required Project project}) : super(page: page, project: project);

  // Inherited
  final String name = 'Icon';
  final String id = 'icon';

  bool isResizable = true;
  bool isDraggable = true;

  /// Icon Color
  Color color = Colors.black;

  /// CreatorPageProperties Color
  Color background = Colors.transparent;

  IconData icon = Icons.add;

  Size size = Size(50, 50);
  Size? minSize = Size(20, 20);
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.bottomRight
  ];

  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Edit',
          tooltip: 'Change Icon',
          onTap: (context) async {
            // await showEditTextModal(context);
          },
          icon: Icons.change_circle
        ),
        Option.button(
          icon: Icons.format_color_text,
          title: 'Color',
          tooltip: 'Tap to select icon color',
          onTap: (context) async {
            Color? _color = await Palette.showColorPicker(
              context: context,
              defaultColor: color,
              title: 'Select Text Color'
            );
            if (_color != null) color = _color;
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete Icon Widget',
          onTap: (context) async {
            page.delete(this);
          },
        ),
      ],
      tab: 'Icon',
    )
  ];

  Widget widget(BuildContext context) => Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: background,
    ),
    child: Icon(
      icon,
      color: color,
      size: size.height > size.width ? size.width - 20 : size.height - 20
    ),
  );

  @override
  void onResizeFinished(DragEndDetails details, {
    bool updateNotify = true
  }) {
    double __size = size.height < size.width ? size.height : size.width;
    size = Size(__size, __size);
    super.onResizeFinished(details);
  }

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    return super.buildFromJSON(json);
  }

}