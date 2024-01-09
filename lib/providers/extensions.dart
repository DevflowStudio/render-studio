import 'dart:math';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';
import 'package:path/path.dart' as path;

extension ListsExtension<T> on List<T> {

  void tryAdd(T? item) {
    if (item != null) this.add(item);
  }

  T getRandom({T? avoid}) {
    int lth = length;
    int random = Random().nextInt(lth);
    if (avoid != null && this[random] == avoid) return getRandom(avoid: avoid);
    return this[random];
  }

  List<T> maybeReverse([bool reverse = true]) {
    return reverse ? this.reversed.toList() : this;
  }

  T? indexOrNull(int index) =>  index + 1 <= this.length ? this[index] : null;

  T? get firstOrNull => this.isEmpty ? null : this.first;

  T? get lastOrNull => this.isEmpty ? null : this.last;

  T get middle {
    int lth = this.length;
    if (lth == 0) throw Exception('List is empty');
    if (lth == 1) return this.first;
    if (lth % 2 == 0) {
      return this[lth ~/ 2];
    } else {
      return this[(lth - 1) ~/ 2];
    }
  }

  num findClosestNumber(num target) {
    assert(this is List<num>);
    num closest = first as num;
    num minDiff = (target - (first as num)).abs();
    for (num n in (this as List<num>)) {
      num diff = (target - n).abs();
      if (diff < minDiff) {
        closest = n;
        minDiff = diff;
      }
    }
    return closest;
  }

  int nextIndex(int current) {
    int lth = this.length;
    if (lth == 0) throw Exception('List is empty');
    if (lth == 1) return 0;
    if (current + 1 >= lth) {
      return 0;
    } else {
      return current + 1;
    }
  }

  List<T> toDataType<T>() => this.map((e) => e as T).toList();

}

extension MapExtension<T, V> on Map<T, V> {

  Map<T, V> getRange(int start, int end) {
    Map<T, V> updated = Map<T, V>.from(this);
    updated.removeWhere((key, value) {
      int index = keys.toList().indexOf(key);
      if (index < start || index >= end) {
        return true;
      } else {
        return false;
      }
    });
    return updated;
  }

  Map<X, Y> toDataType<X, Y>() => this.map((key, value) => MapEntry(key as X, value as Y));

}

extension MapExtensions<T> on Map<T, num> {
  T getRandomWithProbabilities() {
    final total = values.fold(0.0, (sum, value) => sum + value);
    final random = Random().nextDouble() * total;
    double cumulative = 0.0;
    for (var key in keys) {
      cumulative += this[key] as num;
      if (random < cumulative) {
        return key;
      }
    }
    return keys.first;
  }
}

extension IntExtension on int {

  int limit({
    required int max
  }) {
    if (this > max) {
      return max;
    } else {
      return this;
    }
  }

  List<int> upTo(int maxInclusive, {int stepSize = 1}) => [for (int i = this; i <= maxInclusive; i += stepSize) i];

}

extension DoubleExtension on double {

  double trimToDecimal([int place = 2]) {
    return double.tryParse(this.toStringAsFixed(place)) ?? 0;
  }

  List<double> upTo(double maxInclusive, {double stepSize = 1}) => [for (double i = this; i <= maxInclusive; i += stepSize) i];
  
}


extension PaddingExtension on EdgeInsets {

  Map<String, double> toJSON({bool symmetric = true}) {
    if (symmetric) return {
      'vertical': vertical/2,
      'horizontal': horizontal/2
    }; else return {
      'top': top,
      'bottom': bottom,
      'left': left,
      'right': right
    };
  }

  static EdgeInsets fromJSON(Map json) {
    if (json.containsKey('vertical') && json.containsKey('horizontal')) return EdgeInsets.symmetric(
      vertical: json['vertical'],
      horizontal: json['horizontal']
    ); else if (json.containsKey('top') && json.containsKey('bottom') && json.containsKey('left') && json.containsKey('right')) return EdgeInsets.fromLTRB(
      json['left'],
      json['top'],
      json['right'],
      json['bottom']
    ); else return EdgeInsets.zero;
  }

}

extension ColorExtension on Color {

  Color computeTextColor() => computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Color computeThemedTextColor(int alpha) => computeTextColor().withAlpha(alpha);

  bool get isLight => computeLuminance() > 0.5;

  bool get isDark => computeLuminance() <= 0.5;

}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String? hexString, {
    /// The default color to use if [hexString] is null or empty or can't be parsed.
    Color? defaultColor,
  }) {
    try {
      if (hexString == null || hexString.isEmpty) {
        if (defaultColor != null) return defaultColor;
        throw Exception('Hex string is empty');
      }
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      if (defaultColor != null) return defaultColor;
      rethrow;
    }
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

  /// Finds the color with the highest contrast to the given color.
  Color findContrast(List<Color> colors) {
    Map<Color, double> contrasts = {};
    for (Color _color in colors) {
      contrasts[_color] = _color.computeLuminance();
    }
    var sortedKeys = contrasts.keys.toList(growable:false)..sort((k1, k2) => contrasts[k1]!.compareTo(contrasts[k2]!));
    if (this.computeLuminance() > 0.5) {
      return sortedKeys.first;
    } else {
      return sortedKeys.last;
    }
  }

}

extension StringExtension on String {

  String toTitleCase() {
    return this.split(' ').map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
  }

  String toCamelCase() {
    return this.split(' ').map((str) => str[0].toUpperCase() + str.substring(1)).join();
  }

}

extension SizeExtension on Size {

  // Size get half => Size(width/2, height/2);

  // Size get double => Size(width*2, height*2);

  bool operator >(Object other) {
    if (other is Size) {
      return this.width > other.width && this.height > other.height;
    } else {
      return false;
    }
  }

  bool operator <(Object other) {
    if (other is Size) {
      return this.width < other.width && this.height < other.height;
    } else {
      return false;
    }
  }

  static Size fromJSON(Map json) {
    double width = _convertToDouble(json['width']);
    double height = _convertToDouble(json['height']);
    return Size(width, height);
  }

  static double _convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    } else {
      throw ArgumentError('Value must be an int or a String');
    }
  }

}

extension BuildContextHelpers on BuildContext {

  bool get isDarkMode => MediaQuery.of(this).platformBrightness == Brightness.dark;

}

extension DirectoryHelper on Directory {

  /// Copies the directory to the destination directory, syncronously
  void copyToSync(
    final Directory destination, {
    final List<String> ignoreDirList = const [],
    final List<String> ignoreFileList = const [],
  }) => listSync().forEach((final entity) {
    if (entity is Directory) {
      if (ignoreDirList.contains(path.basename(entity.path))) {
        return;
      }
      final newDirectory = Directory(
        path.join(destination.absolute.path, path.basename(entity.path)),
      )..createSync();
      entity.absolute.copyToSync(newDirectory);
    } else if (entity is File) {
      if (ignoreFileList.contains(path.basename(entity.path))) {
        return;
      }
      entity.copySync(
        path.join(destination.path, path.basename(entity.path)),
      );
    }
  });

  Future<void> copyTo(Directory destination) async {
    await for (var entity in list(recursive: false)) {
      if (entity is Directory) {
        var newDirectory = Directory(path.join(destination.absolute.path, path.basename(entity.path)));
        await newDirectory.create();
        await entity.copyTo(newDirectory);
      } else if (entity is File) {
        await entity.copy(path.join(destination.path, path.basename(entity.path)));
      }
    }
  }

  Future<void> printAllFilenames() async {
    await for (var entity in list(recursive: true)) {
      if (entity is File) {
        print('File: ${entity.path}');
      } else if (entity is Directory) {
        print('Directory: ${entity.path}');
        entity.printAllFilenames();
      }
    }
  }

}