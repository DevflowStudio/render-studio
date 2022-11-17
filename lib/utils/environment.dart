import 'package:flutter_dotenv/flutter_dotenv.dart';

late Environment environment;

class Environment {

  static Future<Environment> get instance async {
    await dotenv.load(fileName: "assets/render.env");
    return Environment();
  }

  String get iconFinderToken => dotenv.env['ICON_FINDER_AUTH_BEARER']!;

}