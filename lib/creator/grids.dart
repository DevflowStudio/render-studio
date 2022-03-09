import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class Grid {

  Grid({
    required this.position,
    required this.color,
    required this.layout,
    required this.widget,
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
  final CreatorWidget widget;

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