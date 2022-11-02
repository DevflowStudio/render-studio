import 'package:flutter/material.dart';

import '../rehmat.dart';

/// Lite version of project to reduce load times and heavy calculations
class ProjectGlance {

  ProjectGlance(this.id, this.data);

  final String id;

  final Map data;

  late final String title;

  late final String? description;

  late final List<String> thumbnails;

  late final DateTime? created;

  late final DateTime? edited;

  late PostSize size;

  static ProjectGlance? build({
    required String id,
    required Map<String, dynamic> data
  }) {
    try {
      ProjectGlance glance = ProjectGlance(id, Map.from(data));
      glance.title = data['title'];
      glance.description = data['description'];
      glance.thumbnails = data['thumbnails'];
      glance.created = data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();
      glance.edited = data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();
      glance.size = PostSize.custom(width: data['size']['width'], height: data['size']['height'],);
      return glance;
    } catch (e) {
      return null;
    }
  }

  /// This function renders full project from the lite (glance) version
  Future<Project?> renderFullProject(BuildContext context) async {
    try {
      Project? project = await Project.fromJSON(data, context: context);
      return project;
    } catch (e) {
      print(e);
      return null;
    }
  }

}