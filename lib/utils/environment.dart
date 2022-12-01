import 'package:flutter_dotenv/flutter_dotenv.dart';

late Environment environment;

class Environment {

  static Future<Environment> get instance async {
    await dotenv.load(fileName: "assets/render.env");
    return Environment();
  }

  String get iconFinderToken => dotenv.env['ICON_FINDER_AUTH_TOKEN']!;

  String get unsplashAccessKey => dotenv.env['UNSPLASH_ACCESS_KEY']!;

  String get unsplashSecretKey => dotenv.env['UNSPLASH_SECRET_KEY']!;

}