import 'package:flutter/material.dart';

import '../rehmat.dart';

/// Lite version of project to reduce load times and heavy calculations
class ProjectGlance {

  ProjectGlance(this.id, this.data);

  final String id;

  final Map data;

  String get title => data['title'];

  String? get description => data['description'];

  String? get thumbnail => pathProvider.generateRelativePath(data['thumbnail'] ?? '');
  
  List<String> get images => List.from(data['images']);

  DateTime? get created => data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();

  DateTime? get edited => data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();

  PostSize get size => PostSize.custom(width: data['size']['width'], height: data['size']['height'],);

  static ProjectGlance? build({
    required String id,
    required Map<String, dynamic> data
  }) {
    try {
      ProjectGlance glance = ProjectGlance(id, Map.from(data));;
      return glance;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project glance rendering error', stacktrace: stacktrace);
      return null;
    }
  }

  /// This function renders full project from the lite (glance) version
  Future<Project?> renderFullProject(BuildContext context) async {
    try {
      Project? project = await Project.fromJSON(data, context: context);
      return project;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project rendering error', stacktrace: stacktrace);
      return null;
    }
  }

}