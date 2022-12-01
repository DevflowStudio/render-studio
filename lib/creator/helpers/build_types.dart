/// Build types for widgets in a page
/// 
/// These build types can be used by widgets to judge how they should be built
/// 
/// For example, a widget may want to build differently when it is being restored from a date in history
/// than being saved or exported to an image
enum BuildType {
  /// The widget is being exported to an image,
  /// finalise the widget and remove any temporary data or history
  save,
  /// The widget is being restored from JSON
  /// maybe when the project is opened or when the widget is restored from history
  restore,
  /// The widget is being rebuilt from a date in history
  history,
  /// Unknown build type
  unknown,
}

class BuildInfo {

  final BuildType buildType;
  final String? version;

  const BuildInfo({
    required this.buildType,
    this.version,
  });

  static const BuildInfo unknown = BuildInfo(buildType: BuildType.unknown);

  @override
  String toString() {
    return 'BuildInfo(buildType: $buildType, version: $version)';
  }

}