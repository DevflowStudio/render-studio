import 'package:align_positioned/align_positioned.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

import '../rehmat.dart';

class GridState extends ChangeNotifier {

  // final CreatorWidget page;
  final CreatorPage page;

  GridState({required this.page});

  List<Grid> grids = [];

  void clear() {
    grids.clear();
    // _addBackgroundGrids(
    //   page.widgets.background.type == BackgroundType.color
    //     ? page.palette.onBackground
    //     : Colors.white
    // );
  }

  void hideAll() {
    grids.forEach((grid) {
      grid.isVisible = false;
    });
    notifyListeners();
  }

}

class Grid {

  Grid({
    required this.position,
    required this.color,
    required this.layout,
    this.widget,
    required this.gridWidgetPlacement,
    required this.page,
    this.dotted = true,
    this.length
  }) {
    key = UniqueKey();
  }

  late Key key;

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

  final bool dotted;

  final double? length;

  bool isVisible = false;
  
  Widget build() {
    return layout.build(
      grid: this,
      color: color,
      page: page,
      dotted: dotted
    );
  }

  Size get size {
    return layout.getSize(
      grid: this,
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
    required Grid grid,
    required Color color,
    required CreatorPage page,
    bool dotted = true
  }) {
    switch (this) {
      case GridLayout.horizontal:
        return SizedBox(
          height: 3,
          width: grid.length ?? page.project.size.size.width,
          child: Center(
            child: DottedLine(
              direction: Axis.horizontal,
              dashColor: color,
              dashGapLength: dotted ? 3 : 0,
            ),
          ),
        );
      case GridLayout.vertical:
        return SizedBox(
          width: 3,
          height: grid.length ?? (page.project.contentSize.height * 1.5),
          child: DottedLine(
            direction: Axis.vertical,
            dashColor: color,
            dashGapLength: dotted ? 3 : 0,
          ),
        );
    }
  }

  Size getSize({
    required Grid grid,
    required CreatorPage page
  }) {
    switch (this) {
      case GridLayout.horizontal:
        return Size(grid.length ?? page.project.size.size.width, 3);
      case GridLayout.vertical:
        return Size(3, grid.length ?? (page.project.contentSize.height * 1.2));
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
      clipBehavior: Clip.none,
      children: [
        for (Grid grid in state.grids) AnimatedSwitcher(
          key: grid.key,
          duration: Duration.zero,
          switchInCurve: Sprung.overDamped,
          reverseDuration: Duration(milliseconds: 100),
          child: (grid.isVisible) ? AlignPositioned(
            key: UniqueKey(),
            dy: grid.position.dy,
            dx: grid.position.dx,
            childHeight: grid.size.height,
            childWidth: grid.size.width,
            child: grid.build()
          ) : null,
        )
      ],
    );
  }

  void onUpdate() => setState(() {});

}