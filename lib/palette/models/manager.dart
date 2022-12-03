import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../rehmat.dart';

late PaletteManager paletteManager;

class PaletteManager {

  final Box box;
  late List<ColorPalette> palettes;

  PaletteManager(this.box) {
    palettes = [];
    for (var _json in box.values.toList()) {
      var json = Map.from(_json);
      palettes.add(ColorPalette.fromJSON(json));
    }
  }

  static Future<PaletteManager> get instance async {
    Box box = await Hive.openBox('palettes');
    PaletteManager manager = PaletteManager(box);
    return manager;
  }

  Future<void> add(ColorPalette palette) async {
    if (palettes.contains(palette)) return;
    await box.put(palette.id, palette.toJSON());
    palettes.add(palette);
  }

  Future<void> delete(ColorPalette palette) async {
    await box.delete(palette.id);
    palettes.remove(palette);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaletteManager && listEquals(other.palettes, palettes);
  }

}