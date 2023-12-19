import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_io/io.dart';
import '../../rehmat.dart';

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
    required Project project,
    required Map<String, dynamic> data,
  }) async {

    String id = project.id!;

    await box.delete(id);
    await box.put(id, data);

    ProjectGlance _glance;

    try {
      _glance = ProjectGlance.from(data);
    } catch (e) {
      analytics.logError(e, cause: 'project glance error');
      rethrow;
    }

    if (projects.indexWhere((element) => element.id == id) == -1) {
      try {
        projects.add(_glance);
      } catch (e) {
        analytics.logError(e, cause: 'project glance error');
      }
    } else {
      projects[projects.indexWhere((element) => element.id == id)] = _glance;
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
    _deleteProjectDirectory(project?.id! ?? id!);
    _sortProjects();
    notifyListeners();
  }

  Future<void> _deleteProjectDirectory(String id) async {
    String path = await pathProvider.generateRelativePath('/Render Studio/$id/');
    Directory dir = Directory(path);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  List<ProjectGlance> _getProjects() {
    List<ProjectGlance> _glances = [];
    for (var id in box.keys) {
      try {
        ProjectGlance? glance = ProjectGlance.from(Map.from(box.get(id)));
        _glances.add(glance);
      } catch (e) {
        analytics.logError(e, cause: 'project glance error');
      }
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