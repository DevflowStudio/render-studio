import 'package:flutter/material.dart';

import '../../rehmat.dart';

/// Lite version of project to reduce load times and heavy calculations
class ProjectGlance {

  final Map<String, dynamic> data;

  late final ProjectMetadata metadata;

  ProjectGlance._(this.data) {
    metadata = ProjectMetadata.fromJSON(data['meta']);
  }

  factory ProjectGlance.from(Map<String, dynamic> data) {
    ProjectGlance glance = ProjectGlance._(Map.of(data));;
    return glance;
  }

  String get id => data['id'];

  String get title => data['title'];

  String? get description => data['description'];

  String? get thumbnail => pathProvider.generateRelativePath(data['thumbnail'] ?? '');
  
  List<String> get images => List.from(data['images']);

  DateTime? get created => data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();

  DateTime? get edited => data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();

  PostSize get size => PostSize.custom(width: data['size']['width'], height: data['size']['height'],);

  bool get isTemplate => data['is-template'] ?? false;

  int get nPages => data['pages'];

  Map<String, dynamic> get variables => data['variables'];

  String? get savePath => data['save-path'];

  Future<void> duplicateProject() async {
    // TODO
  }

  /// This function renders full project from the lite (glance) version
  Future<Project?> renderFullProject(BuildContext context) async {
    try {
      Project? project = await Project.fromSave(path: savePath, context: context);
      return project;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project rendering error', stacktrace: stacktrace);
      return null;
    }
  }

}