import 'package:flutter/material.dart';

enum ExportQuality {
  extreme,
  high,
  auto,
}

extension ExportQualityExtension on ExportQuality {

  double pixelRatio(BuildContext context) {
    switch (this) {
      case ExportQuality.extreme:
        return MediaQuery.of(context).devicePixelRatio * 3;
      case ExportQuality.high:
        return MediaQuery.of(context).devicePixelRatio * 2;
      case ExportQuality.auto:
        return MediaQuery.of(context).devicePixelRatio;
      default:
        return MediaQuery.of(context).devicePixelRatio;
    }
  }

  static ExportQuality fromString(String? quality) {
    switch (quality) {
      case 'extreme':
        return ExportQuality.extreme;
      case 'high':
        return ExportQuality.high;
      case 'default':
        return ExportQuality.auto;
      default:
        return ExportQuality.auto;
    }
  }

  String get name {
    switch (this) {
      case ExportQuality.extreme:
        return 'extreme';
      case ExportQuality.high:
        return 'high';
      case ExportQuality.auto:
        return 'default';
      default:
        return 'default';
    }
  }

}