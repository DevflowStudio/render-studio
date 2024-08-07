import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:render_studio/rehmat.dart';

class RemoteConfig {

  RemoteConfig._(this._firebaseConfig);
  final FirebaseRemoteConfig _firebaseConfig;

  static Future<RemoteConfig> initialize({
    required Flavor flavor
  }) async {
    final firebaseConfig = FirebaseRemoteConfig.instance;
    await firebaseConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: flavor == Flavor.dev ? const Duration(minutes: 15) : const Duration(hours: 3),
      )
    );
    _setDefaults(firebaseConfig);
    try {
      await firebaseConfig.fetchAndActivate();
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'remote config fetch error', stacktrace: stacktrace);
    }
    return RemoteConfig._(firebaseConfig);
  }

  static Future<void> _setDefaults(FirebaseRemoteConfig config) async {
    await config.setDefaults({
      'app_available': false,
      'app_title': {
        'Render': 0.70,
        'Studio': 0.05,
        'Render Studio': 0.20,
        'This one\'s rare': 0.01,
        'Hey!': 0.01,
        'Let\'s design': 0.01,
        'Studio Render': 0.02,
      }.getRandomWithProbabilities(),
      'create_project_banner_title': [
        'Create Project',
        'New Project',
        'Get Started',
        'Start a Project',
        'Start a New Project',
        'Start Creating',
        'Unleash Your Creativity',
      ].getRandom(),
      'allow_create_project': true,
      'enable_studio_ads': false,
      'enable_home_screen_ads': false,
      'enable_unsplash': true,
      'enable_icon_finder': true,
      'minimum_version': 'unavailable',
      'show_watermark': false,
      'allow_delete_watermark': true,
      'enable_template_kit': true,
      'enable_anonymous_login': true,
    });
  }

  /// Returns true if the app is available for use
  /// Maybe false if the app is under maintenance or kill switch has been activated
  bool get isAppAvailable => _firebaseConfig.getBool('app_available');

  bool get isAppOutdated {
    final minimumVersion = _firebaseConfig.getString('minimum_version');
    final currentVersion = app.info.version;
    return !checkVersionCompatibility(
      minimumVersion: minimumVersion,
      currentVersion: currentVersion,
    );
  }

  /// Gets the app title from the remote config
  /// Use this as app title and home screen title
  String get appTitle => _firebaseConfig.getString('app_title');

  /// Gets the title for the create project banner
  String get createProjectBannerTitle => _firebaseConfig.getString('create_project_banner_title');
  
  /// Returns false if the create project button should be hidden
  bool get allowCreateProject => _firebaseConfig.getBool('allow_create_project');

  /// Returns true if ads should be shown
  bool get showStudioScreenAds => _firebaseConfig.getBool('enable_studio_ads');

  /// Returns true if ads should be shown
  bool get showHomeScreenAds => _firebaseConfig.getBool('enable_home_screen_ads');

  /// Returns true if analytics should be enabled
  bool get enableAnalytics => _firebaseConfig.getBool('enable_analytics');

  /// Returns false if the unsplash integration should be disabled
  bool get enableUnsplash => _firebaseConfig.getBool('enable_unsplash');

  /// Returns false if the icon finder integration should be disabled
  bool get enableIconFinder => _firebaseConfig.getBool('enable_icon_finder');

  /// Returns true if the watermark should be shown
  bool get showWatermark => _firebaseConfig.getBool('show_watermark');

  /// Returns false if the watermark should be hidden
  bool get allowDeleteWatermark => _firebaseConfig.getBool('allow_delete_watermark');

  /// Returns true if the template kit should be enabled
  bool get enableTemplateKit => _firebaseConfig.getBool('enable_template_kit');

  /// Returns true if the anonymous login should be enabled
  bool get enableAnonymousLogin => _firebaseConfig.getBool('enable_anonymous_login');

}

/// Returns true if the `currentVersion` is greater than or equal to the `minimumVersion`
bool checkVersionCompatibility({
  String? minimumVersion,
  required String currentVersion,
}) {
  if (minimumVersion == 'unavailable') return true;
  final current = currentVersion.split('.').map(int.parse).toList();
  final minimum = minimumVersion!.split('.').map(int.parse).toList();
  for (int i = 0; i < current.length; i++) {
    if (current[i] > minimum[i]) return true;
    if (current[i] < minimum[i]) return false;
  }
  return true;
}