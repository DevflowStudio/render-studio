import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    try {
      app.info = await PackageInfo.fromPlatform();
      app.remoteConfig = await RemoteConfig.initialize(flavor: flavor);
      await initialize();
    } catch (e) { }
    return app;
  }

  static Future<void> initialize() async {
    DateTime start = DateTime.now();

    MobileAds.instance.initialize();

    // Add Rehmat's iPhone for testing
    // TODO: Remove this before publishing
    RequestConfiguration configuration = RequestConfiguration(testDeviceIds: ['6c8a2f17950b8ca93295b564b7439715']);
    MobileAds.instance.updateRequestConfiguration(configuration);

    await Hive.initFlutter();

    environment = await Environment.instance;
    device = await DeviceInfo.instance;
    preferences = await Preferences.instance;
    analytics = await Analytics.instance;
    manager = await ProjectManager.instance;
    paletteManager = await PaletteManager.instance;
    projectSaves = await ProjectSaves.instance;
    pathProvider = await PathProvider.instance;

    await Crashlytics.init();

    DateTime end = DateTime.now();

    Duration animationDuration = Duration(seconds: 1, milliseconds: 800);

    if (end.difference(start).inMilliseconds < animationDuration.inMilliseconds) {
      await Future.delayed(animationDuration - end.difference(start));
    }
  }

  /// Executes a list of async functions parallely and returns a list of their results
  static Future<List<T>> executeAsyncFunctions<T>(List<Future<T> Function()> asyncFunctions) async {
    var futures = asyncFunctions.map((asyncFunc) => asyncFunc()).toList();

    return await Future.wait(futures);
  }

}

enum Flavor {
  dev,
  beta,
  production
}