import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// import '../rehmat.dart';

class Palette {

  static ColorScheme of(BuildContext context) => Theme.of(context).colorScheme;

  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Future<Color?> showColorPicker({
    required BuildContext context,
    String title = 'Choose Color',
    String okButton = 'Done',
    /// Default color
    required Color defaultColor,
    PaletteType type = PaletteType.hsl
  }) async {
    Color? color;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(top: 20),
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: defaultColor,
              onColorChanged: (value) {
                color = value;
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: type,
            ),
          ),
          actions: [
            TextButton(
              child: Text(okButton),
              onPressed: () => Navigator.of(context).pop()
            )
          ],
        );
      },
    );
    return color;
  }
  
}