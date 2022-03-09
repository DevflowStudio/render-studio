import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class App {

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

  static Color textColorFromBackground(Color background) => background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  
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
  'Decemeber'
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