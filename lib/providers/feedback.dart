import 'package:flutter/services.dart';

class TapFeedback {

  /// Provides a light feedback [vibration]
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Provides a normal feedback [vibration]
  static Future<void> normal() async {
    await HapticFeedback.mediumImpact();
  }

  /// Provides a high feedback [vibration]
  static Future<void> high() async {
    await HapticFeedback.heavyImpact();
  }

  /// Provides a vibration feedback of a tap
  static Future<void> tap() async {
    await HapticFeedback.selectionClick();
    // SystemSound.play(SystemSoundType.click);
  }

}