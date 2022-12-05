import 'package:align_positioned/align_positioned.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class GridState extends ChangeNotifier {

  // final CreatorWidget page;
  final Project project;

  GridState({required this.project}) {
    _addBackgroundGrids();
  }
  

  List<Grid> grids = [];
  List<Grid> visible = [];

  void reset() {
    grids.clear();
    _addBackgroundGrids();
  }

  void _addBackgroundGrids() {
    grids.addAll([
      Grid(
        position: const Offset(0, 0),
        color: Colors.red,
        layout: GridLayout.vertical,
        project: project,
        gridWidgetPlacement: GridWidgetPlacement.centerVertical
      ),
      Grid(
        position: const Offset(0, 0),
        color: Colors.red,
        layout: GridLayout.horizontal,
        project: project,
        gridWidgetPlacement: GridWidgetPlacement.centerHorizontal
      )
    ]);
  }

}

class Grid {

  Grid({
    required this.position,
    required this.color,
    required this.layout,
    this.widget,
    required this.project,
    required this.gridWidgetPlacement
  });

  /// Position for the grid line
  /// Provide dx if it's a horizontal grid
  /// and dy if vertical
  final Offset position;

  /// Color of the grid
  final Color color;

  /// Type of layout for the grid
  /// * Horizontal
  /// * Vertical
  final GridLayout layout;

  /// The widget for which the grid has been created
  final CreatorWidget? widget;

  final Project project;

  final GridWidgetPlacement gridWidgetPlacement;
  
  Widget build(BuildContext context) {
    return layout.build(
      context,
      color: color,
      project: project
    );
  }

}

enum GridLayout {
  horizontal,
  vertical
}

enum GridWidgetPlacement {
  centerHorizontal,
  centerVertical,
  top,
  bottom,
  left,
  right
}

extension GridLayoutExtension on GridLayout {

  Widget build(BuildContext context, {
    required Color color,
    required Project project
  }) {
    switch (this) {
      case GridLayout.horizontal:
        return SizedBox(
          height: 3,
          width: project.size!.size.width,
          child: Center(
            child: DottedLine(
              direction: Axis.horizontal,
              dashColor: color,
            ),
          ),
        );
      case GridLayout.vertical:
        return SizedBox(
          width: 3,
          height: project.size!.size.height,
          child: Center(
            child: DottedLine(
              direction: Axis.vertical,
              dashColor: color,
            ),
          ),
        );
      default:
        return Container();
    }
  }

}

class PageGridView extends StatefulWidget {

  PageGridView({
    Key? key,
    required this.state
  }) : super(key: key);

  final GridState state;

  @override
  State<PageGridView> createState() => PageGridViewState();
}

class PageGridViewState extends State<PageGridView> {

  late GridState state;

  @override
  void initState() {
    state = widget.state;
    state.addListener(onUpdate);
    super.initState();
  }

  @override
  void dispose() {
    state.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (Grid grid in state.visible) AlignPositioned(
          dy: grid.position.dy,
          dx: grid.position.dx,
          child: grid.build(context)
        )
      ],
    );
  }

  void onUpdate() => setState(() {});

}