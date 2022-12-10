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
  late Color onBackground;
  late Color surface;

  ColorPalette({
    required this.id,
    required this.colors
  }) {
    refresh(true);
  }

  factory ColorPalette.fromColors(String id, {
    required List<Color> colors
  }) {
    ColorPalette palette = ColorPalette(
      id: id,
      colors: colors
    );
    palette.refresh(true);
    return palette;
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

    ColorPalette _palette = ColorPalette.fromColors(
      'color-palette-${Constants.generateID()}',
      colors: _colors
    );
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
    int _bIndex = 0;
    if (!firstBuild) {
      _bIndex = _colors.indexOf(background) + 1;
      if (_bIndex >= _colors.length) _bIndex = 0;
    }
    background = _colors.removeAt(_bIndex);
    onBackground = background.findContrast(_colors);
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

  static ColorPalette get defaultSet => ColorPalette.fromColors(
    '#0000',
    colors: [
      HexColor.fromHex('#FFFFFF'),
      HexColor.fromHex('#FEE3C3'),
      HexColor.fromHex('#FFE6E7'),
      HexColor.fromHex('#838392'),
      HexColor.fromHex('#000000'),
    ]
  );

  static Map<String, List<ColorPalette>> collections = {
    'From Render': [
      ColorPalette.fromColors(
        '#0044',
        colors: [
          HexColor.fromHex('#FFEDEC'),
          HexColor.fromHex('#FEE3C3'),
          HexColor.fromHex('#ADAAAB'),
          HexColor.fromHex('#A68989'),
          HexColor.fromHex('#000000'),
        ]
      ),
      ColorPalette.fromColors(
        '#0061',
        colors: [
          HexColor.fromHex('#F5F1F3'),
          HexColor.fromHex('#F9A4AB'),
          HexColor.fromHex('#AACFE2'),
          HexColor.fromHex('#BDDE8F'),
          HexColor.fromHex('#42635C'),
        ]
      ),
      ColorPalette.fromColors(
        '#0057',
        colors: [
          HexColor.fromHex('#F0F4F7'),
          HexColor.fromHex('#D2DFFF'),
          HexColor.fromHex('#FFCDEA'),
          HexColor.fromHex('#838392'),
          HexColor.fromHex('#3A3560'),
        ]
      ),
      ColorPalette.fromColors(
        '#0054',
        colors: [
          HexColor.fromHex('#ECEAF6'),
          HexColor.fromHex('#D9D6DB'),
          HexColor.fromHex('#F5E3D2'),
          HexColor.fromHex('#423250'),
          HexColor.fromHex('#59B89D'),
        ]
      ),
      ColorPalette.fromColors(
        '#0048',
        colors: [
          HexColor.fromHex('#EBE4F4'),
          HexColor.fromHex('#FFE6E7'),
          HexColor.fromHex('#CDE9FF'),
          HexColor.fromHex('#6A5BE2'),
          HexColor.fromHex('#1F1F3A'),
        ]
      ),
      ColorPalette.fromColors(
        '#0041',
        colors: [
          HexColor.fromHex('#F3F3FF'),
          HexColor.fromHex('#C5DEFA'),
          HexColor.fromHex('#E1F0F4'),
          HexColor.fromHex('#FBC99C'),
          HexColor.fromHex('#353739'),
        ]
      ),
      ColorPalette.fromColors(
        '#0045',
        colors: [
          HexColor.fromHex('#E9F3FB'),
          HexColor.fromHex('#C3AED9'),
          HexColor.fromHex('#84A6D3'),
          HexColor.fromHex('#C35E9E'),
          HexColor.fromHex('#362360'),
        ]
      ),
      ColorPalette.fromColors(
        '#0032',
        colors: [
          HexColor.fromHex('#E6E3E4'),
          HexColor.fromHex('#BDD4F1'),
          HexColor.fromHex('#BAA287'),
          HexColor.fromHex('#7C8584'),
          HexColor.fromHex('#121B28'),
        ]
      ),
    ]
  };

}