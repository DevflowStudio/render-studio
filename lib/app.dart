import 'package:universal_io/io.dart';
import 'package:device_info/device_info.dart';
import 'rehmat.dart';

late App app;

class App {

  App._({
    required this.flavor,
  });

  final Flavor flavor;
  AndroidDeviceInfo? android;
  IosDeviceInfo? iOS;

  late AuthState auth;

  bool get isEmulator {
    if (Platform.isAndroid) return !android!.isPhysicalDevice;
    else if (Platform.isIOS) return !iOS!.isPhysicalDevice;
    else return true;
  }

  bool get useFirebaseEmulator => flavor == Flavor.dev;

  static Future<App> build(Flavor flavor) async {
    App app = App._(flavor: flavor);
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    app.auth = AuthState.instance;
    if (Platform.isAndroid) app.android = await deviceInfo.androidInfo;
    else if (Platform.isIOS) app.iOS = await deviceInfo.iosInfo;
    else throw Exception('App running on an unsupported platform');
    return app;
  }

}

enum Flavor {
  dev,
  beta,
  production
}