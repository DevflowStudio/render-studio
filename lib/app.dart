import 'package:package_info_plus/package_info_plus.dart';

import 'rehmat.dart';

late App app;

class App {

  App._({
    required this.flavor,
  });

  final Flavor flavor;

  late AuthState auth;

  late PackageInfo info;

  late RemoteConfig remoteConfig;

  bool get useFirebaseEmulator => flavor == Flavor.dev;

  static Future<App> build(Flavor flavor) async {
    App app = App._(flavor: flavor);
    app.auth = AuthState.instance;
    app.info = await PackageInfo.fromPlatform();
    app.remoteConfig = await RemoteConfig.initialize(flavor: flavor);
    return app;
  }

}

enum Flavor {
  dev,
  beta,
  production
}