import 'package:flutter/material.dart';

import '../../rehmat.dart';

class ColorPalette {

  final String id;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;

  const ColorPalette({
    required this.id,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface
  });

  static ColorPalette generateFromSeed(Color seed) {
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: seed);
    return ColorPalette(
      id: Constants.generateID(),
      primary: colorScheme.primary,
      secondary: colorScheme.secondary,
      background: colorScheme.background,
      onBackground: colorScheme.onBackground,
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface
    );
  }

}