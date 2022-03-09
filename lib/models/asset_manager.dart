
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../rehmat.dart';

// TODO: Test
class ProjectAssetManager {

  ProjectAssetManager({required this.project});
  final Project project;

  /// List of paths to all the assets used in the project.
  /// Example:
  /// ```
  /// assets = [
  ///   {
  ///     "path": "0/data/android/app.render.studio/assets/aiwjd213f23.png"
  ///     "file-type": "png",
  ///     "extension": ".png",
  ///     "used-by": "image",
  ///     "saved-on": "1642504174",
  ///   },
  ///   ...
  /// ]
  /// ```
  late List<Map<String, dynamic>> assets;

  /// Returns `true` if the project uses files from the device storage
  bool get usesExternalAssets => assets.isNotEmpty;

  static ProjectAssetManager create(Project project) {
    ProjectAssetManager _manager = ProjectAssetManager(project: project);
    List<Map<String, dynamic>>? _assets = project.data!['assets'];
    _manager.assets = _assets ?? [];
    return _manager;
  }

  /// Returns `true` if all of the assets used in the project exist in the device storage
  Future<bool> assetsExist() async {
    bool exists = true;
    for (Map<String, dynamic> asset in assets) {
      File file = File(asset['path']);
      if (!(await file.exists())) exists = false;
    }
    return exists;
  }

  Future<void> addAsset(File file) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String extension = file.path.split('.').last;
    String path = '${directory.path}/${Constants.generateUID(4)}.$extension';
    try {
      await file.copy(path);
    } catch (e) {
      return;
    }
  }

}