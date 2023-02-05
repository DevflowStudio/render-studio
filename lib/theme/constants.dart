import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../rehmat.dart';

class Constants {

  Constants(this.context);
  final BuildContext context;

  static BorderRadius get borderRadius => BorderRadius.circular(kBorderRadius);

  Size get gridSize {
    Size size = Size(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.width / 2);
    if ((MediaQuery.of(context).size.width / 2) > 300) {
      size = const Size(305, 305);
    }
    return size;
  }

  int get crossAxisCount {
    if ((MediaQuery.of(context).size.width / 2) > 300) {
      return 5;
    }
    return 2;
  }

  static Constants of(BuildContext context) => Constants(context);

  static double get horizontalPadding => 15;

  static double get cardHorizontalPadding => 11;

  static Duration get animationDuration => const Duration(milliseconds: 200);

  // static double get snapSensitivity => 5;

  static double get nudgeSensitivity => 2;

  static double get appBarExpandedHeight => 150;

  static Future<Map> get device async {
    DeviceInfo deviceInfo = await DeviceInfo.instance;
    return {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'brand': deviceInfo.brand,
      'model': deviceInfo.model,
      'version': deviceInfo.version,
      'device': deviceInfo.device,
      'emulator': deviceInfo.isEmulator,
      'os': deviceInfo.os,
    };
  }

  static T getThemedObject<T>(BuildContext context, {
    required T light,
    required T dark
  }) {
    if (MediaQuery.of(context).platformBrightness == Brightness.light) {
      return light;
    } else {
      return dark;
    }
  }

  static Color getThemedBlackAndWhite(BuildContext context) {
    return getThemedObject<Color>(context, light: Colors.black, dark: Colors.white);
  }
  
  static String convertNumberToFormat(int number) {
    if (number > 999 && number < 99999) {
      return "${(number / 1000).toStringAsFixed(1)} K";
    } else if (number > 99999 && number < 999999) {
      return "${(number / 1000).toStringAsFixed(0)} K";
    } else if (number > 999999 && number < 999999999) {
      return "${(number / 1000000).toStringAsFixed(1)} M";
    } else if (number > 999999999) {
      return "${(number / 1000000000).toStringAsFixed(1)} B";
    } else {
      return number.toString();
    }
  }

  static String generateID([int length = 6]) {
    String result = '';
    for (var i = 0; i <= length; i++) {
      var randomLetter = _randomIDlist.getRandom();
      result = '${result}${randomLetter}';
    }
    return result;
  }

  static String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

}

final List<String> months = [
  'Unknown Month', // DateTime months start from 1. So 0 cannot be accessed
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

String getTimeAgo(DateTime date, {bool includeHour = false}) {
  String timeAgo = timeago.format(date);

  int timestamp = date.millisecondsSinceEpoch;

  if (DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch >
      timestamp) {
    // More than a month ago
    timeAgo = getFormattedDate(date, includeHour: includeHour);
  }

  return timeAgo;
}

String getFormattedDate(DateTime date, {bool includeHour = false}) {
  return "${date.day} ${months[date.month]}${date.year != DateTime.now().year ? ' ' + date.year.toString() : ''}" +
      (includeHour ? (" at ${date.hour}.${date.minute}") : "");
}

List<String> _randomIDlist = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  'a',
  'b',
  'c',
  'd',
  'e',
  'f',
  'g',
  'h',
  'i',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'v',
  'w',
  'x',
  'y',
  'z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
];