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
      'vertical': vertical,
      'horizontal': horizontal
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