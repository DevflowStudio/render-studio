import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../rehmat.dart';

late ProjectSaves projectSaves;

class ProjectSaves {

  ProjectSaves(this.box);
  final Box box;

  static Future<ProjectSaves> get instance async {
    Box box = await Hive.openBox('projects');
    return ProjectSaves(box);
  }
  
  List<ProjectGlance> get projects {
    List<ProjectGlance> _projects = [];
    for (var id in box.keys) {
      try {
        ProjectGlance? project = ProjectGlance.from(Map.from(box.get(id)));
        _projects.add(project);
      } catch (e) {
        analytics.logError(e, cause: 'project glance error');
      }
    }
    _projects.sort((project, _project) {
      if (project.edited!.isBefore(_project.edited!)) {
        return 1;
      } else {
        return 0;
      }
    });
    return _projects;
  }
  
  ValueListenable<Box> get stream => box.listenable();

}