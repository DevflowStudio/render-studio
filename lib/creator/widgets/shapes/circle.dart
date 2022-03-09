import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class CreatorCircleShape extends CreatorWidget {

  CreatorCircleShape({required CreatorPage page, required Project project}) : super(page: page, project: project);

  // Inherited
  final String name = 'Circle';
  final String id = 'circle-shape';

  bool isResizable = false;
  bool isDraggable = true;

  /// Shape Color
  Color color = Colors.black;

  IconData icon = Icons.add;

  Size size = Size(50, 50);

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

  Widget widget(BuildContext context) => CustomPaint(
    painter: CirclePainter(),
    // child: Container(
    //   width: 40,
    //   height: 40,
    //   color: color,
    // ),
  );

  @override
  void onResizeFinished(DragEndDetails details, {
    bool updateNotify = true
  }) { }

  @override
  Map<String, dynamic> toJSON() => {
    ... super.toJSON(),
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json) {
    return super.buildFromJSON(json);
  }

}

class CirclePainter extends CustomPainter {

  CirclePainter({
    this.paintingStyle = PaintingStyle.fill,
    this.strokeWidth = 1,
    this.color = Colors.teal,
    this.offset,
    this.radius = 100,
  });

  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final Color color;
  final Offset? offset;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    // Offset center = offset ?? Offset(size.width / 2, size.height / 2);

    // canvas.drawCircle(center, radius, paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}