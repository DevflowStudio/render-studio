import 'package:align_positioned/align_positioned.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class GridState extends ChangeNotifier {

  // final CreatorWidget page;
  final CreatorPage page;

  GridState({required this.page}) {
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
        page: page,
        gridWidgetPlacement: GridWidgetPlacement.centerVertical
      ),
      Grid(
        position: const Offset(0, 0),
        color: Colors.red,
        layout: GridLayout.horizontal,
        page: page,
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
    required this.gridWidgetPlacement,
    required this.page
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

  final CreatorPage page;

  final GridWidgetPlacement gridWidgetPlacement;
  
  Widget build() {
    return layout.build(
      color: color,
      page: page
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

  Widget build({
    required Color color,
    required CreatorPage page
  }) {
    switch (this) {
      case GridLayout.horizontal:
        return SizedBox(
          height: 3,
          width: page.project.size!.size.width,
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
          height: page.project.size!.size.height,
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
          child: grid.build()
        )
      ],
    );
  }

  void onUpdate() => setState(() {});

}