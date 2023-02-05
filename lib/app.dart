import 'rehmat.dart';

late App app;

class App {

  App._({
    required this.flavor,
  });

  final Flavor flavor;

  late AuthState auth;

  bool get useFirebaseEmulator => flavor == Flavor.dev;

  static Future<App> build(Flavor flavor) async {
    App app = App._(flavor: flavor);
    app.auth = AuthState.instance;
    return app;
  }

}

enum Flavor {
  dev,
  beta,
  production
}