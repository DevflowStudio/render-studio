import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences sharedPreferences;

Preferences preferences = Preferences.instance;

class Preferences {
  
  bool snap = true;

  bool vibrateOnSnap = true;

  double snapSensitivity = 2;

  bool allowAnalytics = true;

  bool showDebugBorder = false;

  static Preferences get instance {
    Preferences preferences = Preferences();
    preferences.allowAnalytics = sharedPreferences.getBool('allow-analytics') ?? true;
    preferences.snap = sharedPreferences.getBool('snap') ?? true;
    preferences.vibrateOnSnap = sharedPreferences.getBool('vibrate-on-snap') ?? true;
    return preferences;
  }
  
  Future<void> update({
    bool? snap,
    bool? vibrateOnSnap,
    bool? allowAnalytics
  }) async {
    if (allowAnalytics != null) {
      await sharedPreferences.setBool('allow-analytics', allowAnalytics);
      this.allowAnalytics = allowAnalytics;
    }
    if (vibrateOnSnap != null) {
      await sharedPreferences.setBool('vibrate-on-snap', vibrateOnSnap);
      this.vibrateOnSnap = vibrateOnSnap;
    }
    if (snap != null) {
      await sharedPreferences.setBool('snap', snap);
      this.snap = snap;
    }
  }

}