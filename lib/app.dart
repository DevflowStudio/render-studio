import 'dart:io';

import 'package:device_info/device_info.dart';

enum Flavor {
  dev,
  beta,
  production
}

late App app;

class App {

  App({
    required this.flavor,
  });

  final Flavor flavor;
  AndroidDeviceInfo? android;
  IosDeviceInfo? iOS;

  bool get isEmulator {
    if (Platform.isAndroid) return !android!.isPhysicalDevice;
    else if (Platform.isIOS) return !iOS!.isPhysicalDevice;
    else return true;
  }

  bool get useFirebaseEmulator => flavor == Flavor.dev;

  static Future<App> build(Flavor flavor) async {
    App app = App(flavor: flavor);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) app.android = await deviceInfo.androidInfo;
    else if (Platform.isIOS) app.iOS = await deviceInfo.iosInfo;
    else throw Exception('App running on an unsupported platform');
    return app;
  }

}