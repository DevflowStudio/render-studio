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

  String get imagesRelativePath => pathProvider.generateRelativePath('/Render Projects/$id/images/');

  String get title => data['title'];

  String? get description => data['description'];

  String? get thumbnail => imagesRelativePath + data['thumbnail'];
  
  List<String> get images => data['images'].map<String>((image) => imagesRelativePath + image).toList();

  DateTime? get created => data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();

  DateTime? get edited => data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();

  PostSize get size => PostSize.fromJSON(data['size']);

  bool get isTemplate => data['is-template'] ?? false;

  int get nPages => data['pages'].length;

  Map<String, dynamic> get variables => data['variables'];

  /// This function renders full project from the lite (glance) version
  Future<Project?> renderFullProject(BuildContext context) async {
    try {
      Project? project = await Project.fromSave(data: data, context: context);
      return project;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project rendering error', stacktrace: stacktrace);
      return null;
    }
  }

}