import 'package:flutter/material.dart';

import '../../rehmat.dart';
import '../state.dart';

class WidgetGroup extends CreatorWidget {

  WidgetGroup({required CreatorPage page, Map? data}) : super(page, data: data);

  // Inherited
  final String name = 'Group Widget';
  @override
  final String id = 'group';

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
      options: [
        Option.button(
          icon: Icons.delete,
          title: 'Delete',
          tooltip: 'Delete asset',
          onTap: (context) async {
            page.delete(this);
          },
        ),
      ],
      tab: 'Group',
    )
  ];

  List<CreatorWidget> widgets = [];

  @override
  Widget widget(BuildContext context) => Container(
    color: Colors.red.withOpacity(0.1),
    child: Stack(
      children: [
        ... List.generate(
          widgets.length,
          (index) => AbsorbPointer(
            child: WidgetState(
              key: UniqueKey(),
              context: context,
              controller: widgets[index].stateCtrl,
              creator_widget: widgets[index]
            ),
          )
        ),
      ],
    ),
  );

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
  };

  static Future<WidgetGroup?> create(BuildContext context, {
    required CreatorPage page,
    required Project project,
  }) async {
    if (page.selections.length < 2) {
      Alerts.snackbar(context, text: 'Select at least 2 widgets to group');
      return null;
    } else if (page.selections.length > 10) {
      Alerts.snackbar(context, text: 'You can only group up to 10 widgets');
      return null;
    }
    try {
      WidgetGroup group = WidgetGroup(page: page);
      List<CreatorWidget> _widgets = page.selections;
      List<Offset> _offsets = [];
      List<double> dy = [];
      List<double> dx = [];
      for (CreatorWidget widget in _widgets) {
        Offset topLeft;
        Offset topRight;
        Offset bottomLeft;
        Offset bottomRight;
        topLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy - widget.size.height/2);
        bottomLeft = Offset(widget.position.dx - widget.size.width/2, widget.position.dy + widget.size.height/2);
        topRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy - widget.size.height/2);
        bottomRight = Offset(widget.position.dx + widget.size.width/2, widget.position.dy + widget.size.height/2);
        _offsets.addAll([topLeft, topRight, bottomLeft, bottomRight]);
      }
      for (Offset offset in _offsets) {
        dy.add(offset.dy);
        dx.add(offset.dx);
      }
      dy.sort();
      double minDY = dy.first;
      double maxDY = dy.last;
      dx.sort();
      double minDX = dx.first;
      double maxDX = dx.last;

      Offset bottomRight = Offset(maxDX, maxDY);
      Offset topLeft = Offset(minDX, minDY);


      double width = bottomRight.dx - topLeft.dx;
      double height = bottomRight.dy - topLeft.dy;

      // if ((width + 20) < project.canvasSize(context).width) width += 20;
      // if ((height + 20) < project.canvasSize(context).height) height += 20;

      Size size = Size(width, height);

      Offset center = Offset((bottomRight.dx + topLeft.dx)/2, (bottomRight.dy + topLeft.dy)/2);
      
      group.position = center;
      group.size = size;

      for (CreatorWidget widget in _widgets) {
        group.widgets.add(widget);
        page.widgets.remove(widget);
      }

      return group;
    } catch (e) {
      Alerts.snackbar(context, text: 'Failed to group widgets');
      print(e);
      return null;
    }
  }

  @override
  void onDelete() { }

}