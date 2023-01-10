import 'dart:math';
import 'package:flutter/material.dart';

extension ListsExtension<T> on List<T> {

  T getRandom() {
    int lth = length;
    int random = Random().nextInt(lth);
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

}

extension MapExtensions<T> on Map<T, num> {
  T getRandomWithProbabilities() {
    final total = values.fold(0.0, (sum, value) => (sum as num) + value);
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

}

extension DoubleExtension on double {

  double trimToDecimal([int place = 2]) {
    return double.tryParse(this.toStringAsFixed(place)) ?? 0;
  }
  
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

  static EdgeInsets fromJSON(Map<String, dynamic> json) {
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

  Size get half => Size(width/2, height/2);

  Size get double => Size(width*2, height*2);

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

}

extension BuildContextHelpers on BuildContext {

  bool get isDarkMode => MediaQuery.of(this).platformBrightness == Brightness.dark;

}