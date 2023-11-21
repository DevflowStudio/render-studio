import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../rehmat.dart';

late ProjectManager manager;

class ProjectManager extends ChangeNotifier {
  
  ProjectManager(this.box);
  final Box box;

  late List<ProjectGlance> projects;

  static Future<ProjectManager> get instance async {
    Box box = await Hive.openBox('projects');
    final manager = ProjectManager(box);
    manager.projects = manager._getProjects();
    return manager;
  }

  Future<void> save(BuildContext context, {
    Project? project,
    Map<String, dynamic>? data,
    bool saveToGallery = false
  }) async {
    assert(project != null || data != null);
    String id = project?.id ?? data!['id'];
    Map<String, dynamic> json = data ?? await project!.toJSON(context, saveToGallery: saveToGallery);
    await box.delete(id);
    await box.put(id, json);
    if (projects.indexWhere((element) => element.id == id) == -1) {
      projects.add(ProjectGlance.build(id: id, data: json)!);
    } else {
      projects[projects.indexWhere((element) => element.id == id)] = ProjectGlance.build(id: id, data: json)!;
    }
    _sortProjects();
    notifyListeners();
  }

  Future<void> delete(BuildContext context, {
    Project? project,
    String? id
  }) async {
    assert(project != null || id != null);
    await box.delete(project?.id ?? id);
    projects.removeWhere((element) => element.id == (project?.id ?? id));
    _sortProjects();
    notifyListeners();
  }

  List<ProjectGlance> _getProjects() {
    List<ProjectGlance> _glances = [];
    for (var id in box.keys) {
      ProjectGlance? glance = ProjectGlance.build(id: id, data: Map.from(box.get(id)));
      if (glance != null) _glances.add(glance);
    }
    _glances.sort((project, _project) {
      if (project.edited!.isBefore(_project.edited!)) {
        return 1;
      } else {
        return 0;
      }
    });
    return _glances;
  }

  Map<String, dynamic> getProjectData(String id) {
    return Map.from(box.get(id));
  }

  ProjectGlance getProjectGlance(String id) {
    return projects.firstWhere((element) => element.id == id);
  }
  
  void _sortProjects() {
    projects.sort((project, _project) {
      if (project.edited!.isBefore(_project.edited!)) {
        return 1;
      } else {
        return 0;
      }
    });
  }

}