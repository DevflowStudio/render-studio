import 'package:flutter/material.dart';

enum ExportQuality {
  extreme,
  high,
  medium,
  low,
}

extension ExportQualityExtension on ExportQuality {

  double pixelRatio(BuildContext context) {
    switch (this) {
      case ExportQuality.extreme:
        return MediaQuery.of(context).devicePixelRatio * 10;
      case ExportQuality.high:
        return MediaQuery.of(context).devicePixelRatio * 3;
      case ExportQuality.medium:
        return MediaQuery.of(context).devicePixelRatio;
      case ExportQuality.low:
        return MediaQuery.of(context).devicePixelRatio / 2;
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
      case 'medium':
        return ExportQuality.medium;
      case 'low':
        return ExportQuality.low;
      default:
        return ExportQuality.medium;
    }
  }

  String get name {
    switch (this) {
      case ExportQuality.extreme:
        return 'extreme';
      case ExportQuality.high:
        return 'high';
      case ExportQuality.medium:
        return 'medium';
      case ExportQuality.low:
        return 'low';
      default:
        return 'medium';
    }
  }

}