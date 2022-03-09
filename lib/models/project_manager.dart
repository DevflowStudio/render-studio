import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../rehmat.dart';

late ProjectManager handler;

class ProjectManager {
  
  ProjectManager(this.projects);
  final Box projects;

  static Future<ProjectManager> get instance async {
    Box box = await Hive.openBox('projects');
    return ProjectManager(box);
  }

  Future<void> save(BuildContext context, {
    required Project project
  }) async {
    Map<String, dynamic> json = await project.toJSON(context);
    await projects.put(project.id, json);
  }

  Future<void> delete(BuildContext context, {
    Project? project,
    String? id
  }) async {
    assert(project != null || id != null);
    await projects.delete(project?.id ?? id);
    if (project != null) {
      Alerts.snackbar(
        context,
        text: 'Deleted Project',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            Map<String, dynamic> json = await project.toJSON(context, restoring: true, updateThumbnails: false);
            await projects.put(project.id, json);
          },
        )
      );
    }
  }

}