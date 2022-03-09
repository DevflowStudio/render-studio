import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  
  List<ProjectGlance> get posts {
    List<ProjectGlance> _projects = [];
    for (var id in box.keys) {
      ProjectGlance? project = ProjectGlance.build(id: id, data: Map.from(box.get(id)));
      if (project != null) _projects.add(project);
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

  Future<void> clear(BuildContext context) async {
    bool delete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Posts'),
        content: const Text('Warning! This will delete all of your saved posts. This action cannot be reverted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Delete')
          ),
        ],
      ),
    ) ?? false;
    if (delete) box.clear();
  }
  
  ValueListenable<Box> get stream => box.listenable();

}