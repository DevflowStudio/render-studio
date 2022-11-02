import 'dart:math';
import 'package:flutter/material.dart';

extension ListsEntenstion<T> on List<T> {

  T getRandom() {
    int lth = length;
    int random = Random().nextInt(lth);
    return this[random];
  }

  List<T> maybeReverse([bool reverese = true]) {
    return reverese ? this.reversed.toList() : this;
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