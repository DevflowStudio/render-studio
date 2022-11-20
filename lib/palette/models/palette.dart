import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_palette/flutter_palette.dart' as fpalette;
import '../../rehmat.dart';

class ColorPalette {

  final String id;
  final List<Color> colors;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color background;
  late Color surface;

  static ColorPalette get defaultSet {
    ColorScheme _colorScheme = ColorScheme.fromSeed(seedColor: [
      Colors.redAccent,
      Colors.indigoAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
    ].getRandom());
    ColorPalette palette = ColorPalette(
      id: 'default',
      colors: [
        _colorScheme.primary,
        _colorScheme.secondary,
        _colorScheme.tertiary,
        Colors.white,
        _colorScheme.surfaceVariant,
      ]
    );
    palette.primary = _colorScheme.primary;
    palette.secondary = _colorScheme.secondary;
    palette.tertiary = _colorScheme.tertiary;
    palette.background = Colors.white;
    palette.surface = _colorScheme.surfaceVariant;
    return palette;
  }

  ColorPalette({
    required this.id,
    required this.colors
  }) {
    refresh(true);
  }

  static Future<ColorPalette> generate() async {
    List<Color> _colors = [];
    try {
      Response response = await Dio().post(
        'http://colormind.io/api/',
        data: {
          "model":"default"
        }
      );
      Map result = jsonDecode(response.data);
      for (List color in result['result']) {
        _colors.add(Color.fromARGB(255, color[0], color[1], color[2]));
      }
    } catch (e) {
      fpalette.ColorPalette colorPalette = fpalette.ColorPalette.random(
        5,
        distributionVariability: 20,
        colorSpace: fpalette.ColorSpace.xyz,
        distributeHues: true,
        unique: false,
        clockwise: true
      );
      _colors = colorPalette.colors;
    }

    ColorPalette _palette = ColorPalette(
      id: 'color-palette-${Constants.generateID()}',
      colors: _colors
    );
    _palette.refresh(true);
    return _palette;
  }

  static ColorPalette offlineGenerator() {
    List<Color> _colors = [];
    fpalette.ColorPalette colorPalette = fpalette.ColorPalette.random(
      5,
      distributionVariability: 20,
      colorSpace: fpalette.ColorSpace.xyz,
      distributeHues: true,
      unique: false,
      clockwise: true
    );
    _colors = colorPalette.colors.map((e) => e.toColor()).toList();

    return ColorPalette(
      id: 'color-palette-${Constants.generateID()}',
      colors: _colors
    );
  }

  void refresh([bool firstBuild = false]) {
    List<Color> _colors = new List.from(colors);
    if (!firstBuild) { // Removes chances of same color being selected as background
      List<Color> __colors = new List.from(_colors);
      __colors.remove(background);
      background = __colors.getRandom();
      _colors.remove(background);
    } else {
      background = _colors.getRandom();
      _colors.remove(background);
    }
    primary = _colors.getRandom();
    _colors.remove(primary);
    secondary = _colors.getRandom();
    _colors.remove(secondary);
    tertiary = _colors.getRandom();
    _colors.remove(tertiary);
    surface = _colors.getRandom();
    _colors.remove(surface);
  }

  Map toJSON() {
    return {
      'id': id,
      'colors': colors.map((color) => color.toHex()).toList(),
      'primary': primary.toHex(),
      'secondary': secondary.toHex(),
      'tertiary': tertiary.toHex(),
      'background': background.toHex(),
      'surface': surface.toHex()
    };
  }

  static ColorPalette fromJSON(Map json) {
    List<Color> _colors = [];
    for (String color in json['colors']) {
      _colors.add(HexColor.fromHex(color));
    }
    ColorPalette colorPalette = ColorPalette(
      id: json['id'],
      colors: _colors,
    );
    colorPalette.primary = HexColor.fromHex(json['primary']);
    colorPalette.secondary = HexColor.fromHex(json['secondary']);
    colorPalette.tertiary = HexColor.fromHex(json['tertiary']);
    colorPalette.background = HexColor.fromHex(json['background']);
    colorPalette.surface = HexColor.fromHex(json['surface']);
    return colorPalette;
  }

  @override
  bool operator == (Object other) {
    if (other is ColorPalette && other.id == id) return true;
    return false;
  }

}