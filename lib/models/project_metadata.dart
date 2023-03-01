import 'package:render_studio/rehmat.dart';

class ProjectMetadata {

  final String version;

  final DateTime created;
  final DateTime edited;

  /// Project version that is created by the current version of the app
  static final String currentVersion = '1.1';

  /// Project version that is the least supported by the current version of the app
  static final String minVersion = '1.1';

  ProjectMetadata._({
    required this.version,
    required this.created,
    required this.edited,
  });

  factory ProjectMetadata.unknown({
    String? version,
    DateTime? created,
    DateTime? edited,
  }) => ProjectMetadata._(
    version: version ?? 'unknown',
    created: created ?? DateTime.now(),
    edited: edited ?? DateTime.now(),
  );

  factory ProjectMetadata.create() {
    return ProjectMetadata._(
      version: currentVersion,
      created: DateTime.now(),
      edited: DateTime.now(),
    );
  }

  factory ProjectMetadata.fromJSON(Map data) {
    DateTime created = DateTime.now();
    DateTime edited = DateTime.now();
    try {
      created = DateTime.fromMillisecondsSinceEpoch(data['created']);
      edited = DateTime.fromMillisecondsSinceEpoch(data['edited']);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project metadata parsing error', stacktrace: stacktrace);
      return ProjectMetadata.unknown();
    }
    return ProjectMetadata._(
      version: data['version'] ?? 'unknown',
      created: created,
      edited: edited,
    );
  }

  Map<String, dynamic> toJSON() => {
    'version': version,
    'created': created.millisecondsSinceEpoch,
    'edited': edited.millisecondsSinceEpoch,
  };

  bool get isCompatible => version != 'unknown' && checkVersionCompatibility(currentVersion: version, minimumVersion: minVersion);

}