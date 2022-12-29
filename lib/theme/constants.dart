import 'package:universal_io/io.dart';
import 'package:device_info/device_info.dart';
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
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> info = {
      'os': Platform.operatingSystem,
      // 'token': tokenManager.token,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      info.addAll({
        'version': androidInfo.version.baseOS,
        'model': androidInfo.model,
        'device': androidInfo.device,
        'emulator': !androidInfo.isPhysicalDevice,
        'manufacturer': androidInfo.manufacturer,
        'identifier': androidInfo.androidId
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      info.addAll({
        'version': iosInfo.systemVersion,
        'device': iosInfo.utsname.machine,
        'model': iosInfo.localizedModel,
        'emulator': !iosInfo.isPhysicalDevice,
        'manufacturer': 'Apple',
        'identifier': iosInfo.identifierForVendor
      });
    }
    return info;
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

  static Future<Map> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String _model;
    String _version;
    String _brand;
    String _device;
    bool _isEmulator;
    String _id;
    String _manufacturer;
    
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _id = androidInfo.androidId;
      _model = androidInfo.model;
      _device = androidInfo.device;
      _version = androidInfo.version.release;
      _brand = androidInfo.brand;
      _manufacturer = androidInfo.manufacturer;
      _isEmulator = !androidInfo.isPhysicalDevice;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      _id = iosInfo.identifierForVendor;
      _model = iosInfo.model;
      _device = iosInfo.utsname.machine;
      _version = iosInfo.systemVersion;
      _brand = 'Apple';
      _manufacturer = 'Apple';
      _isEmulator = !iosInfo.isPhysicalDevice;
    }

    return {
      'model': _model,
      'version': _version,
      'brand': _brand,
      'device': _device,
      'isEmulator': _isEmulator,
      'id': _id,
      'manufacturer': _manufacturer,
    };

  }

  static String generateID([int length = 6]) {
    String result = '';
    for (var i = 0; i <= length; i++) {
      var randomLetter = _randomIDlist.getRandom();
      result = '${result}${randomLetter}';
    }
    return result;
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