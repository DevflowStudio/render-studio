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

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
    '${alpha.toRadixString(16).padLeft(2, '0')}'
    '${red.toRadixString(16).padLeft(2, '0')}'
    '${green.toRadixString(16).padLeft(2, '0')}'
    '${blue.toRadixString(16).padLeft(2, '0')}';

  MaterialColor toMaterialColor() {
    Map<int, Color> swatch = {
      50:Color.fromRGBO(136,14,79, .1),
      100:Color.fromRGBO(136,14,79, .2),
      200:Color.fromRGBO(136,14,79, .3),
      300:Color.fromRGBO(136,14,79, .4),
      400:Color.fromRGBO(136,14,79, .5),
      500:Color.fromRGBO(136,14,79, .6),
      600:Color.fromRGBO(136,14,79, .7),
      700:Color.fromRGBO(136,14,79, .8),
      800:Color.fromRGBO(136,14,79, .9),
      900:Color.fromRGBO(136,14,79, 1),
    };
    return MaterialColor(this.value, swatch);
  }
}