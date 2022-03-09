import 'dart:math';

extension ListsEntenstion<T> on List<T> {
  T getRandom() {
    int lth = length;
    int random = Random().nextInt(lth);
    return this[random];
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