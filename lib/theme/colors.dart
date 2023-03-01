import 'package:flutter/material.dart';
import '../rehmat.dart';

abstract class Palette {

  static ColorScheme of(BuildContext context) => Theme.of(context).colorScheme;

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Future<Color?> showColorPicker(BuildContext context, {
    required Color selected,
    ColorPalette? palette
  }) => ColorTool.openTool(context, palette: palette, selection: selected);
  
}