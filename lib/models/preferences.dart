import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Preferences preferences;

class Preferences extends ChangeNotifier {

  final SharedPreferences prefs;
  Preferences(this.prefs);

  static Future<Preferences> get instance async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Preferences(prefs);
  }

  ThemeMode get themeMode {
    String? themeModeString = prefs.getString('themeMode');
    if (themeModeString == null) {
      return ThemeMode.system;
    }
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  set themeMode(ThemeMode mode) {
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
    prefs.setString('theme-mode', themeModeString).then((value) => notifyListeners());
  }

  bool get snap => prefs.getBool('snap') ?? true;
  set snap(bool snap) => prefs.setBool('snap', snap).then((value) => notifyListeners());

  bool get vibrateOnSnap => prefs.getBool('vibrate-on-snap') ?? true;
  set vibrateOnSnap(bool vibrate) => prefs.setBool('vibrate-on-snap', vibrate).then((value) => notifyListeners());

  bool get debugMode => prefs.getBool('debug-mode') ?? false;
  set debugMode(bool debug) => prefs.setBool('debug-mode', debug).then((value) => notifyListeners());

  bool get allowAnalytics => prefs.getBool('allow-analytics') ?? true;
  set allowAnalytics(bool allow) => prefs.setBool('allow-analytics', allow).then((value) => notifyListeners());

  double get snapSensitivity => prefs.getDouble('snap-sensitivity') ?? 3;
  set snapSensitivity(double sensitivity) => prefs.setDouble('snap-sensitivity', sensitivity).then((value) => notifyListeners());

  double get nudgeSensitivity => prefs.getDouble('nudge-sensitivity') ?? 2;
  set nudgeSensitivity(double sensitivity) => prefs.setDouble('nudge-sensitivity', sensitivity).then((value) => notifyListeners());

  bool get showActionBar => prefs.getBool('show-action-bar') ?? false;
  set showActionBar(bool value) => prefs.setBool('show-action-bar', value).then((value) => notifyListeners());

}