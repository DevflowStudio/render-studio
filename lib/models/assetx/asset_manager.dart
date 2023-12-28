import 'package:dio/dio.dart';
import 'package:render_studio/models/cloud.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

class AssetManagerX {

  final Project project;

  AssetManagerX._({required this.project});
  static AssetManagerX create(Project project) => AssetManagerX._(project: project);

  Map<String, AssetX> assets = {};

  void add(AssetX asset) {
    assets[asset.id] = asset;
  }

  AssetX? get(String id) {
    return assets[id];
  }

  /// Compiles each asset from the [assets] map into a JSON object, parallelly
  Future<Map<String, dynamic>> getCompiled({
    /// Uploads the assets to the cloud and returns the cloud url instead of the file path
    bool upload = false
  }) async {
    List<Future<MapEntry<String, dynamic>>> futures = [];

    List<AssetX> usedAssets = _getUsedAssets();

    // Delete the project assets folder before compiling
    // This is done to remove any previous assets
    // Saves space by deleting unused assets
    await deleteProjectAssets();

    if (upload) {
      Map<String, dynamic> formDataMap = {
        'id': project.id,
        'files': []
      };
      
      for (AssetX asset in usedAssets) {
        String filePath = (await asset.getFile()).path;
        String fileName = '${asset.id}';

        formDataMap['files'].add(await MultipartFile.fromFile(filePath, filename: fileName));
      }

      Response response = await Cloud.post('template/upload-assets', data: FormData.fromMap(formDataMap));
      print(response.data);
      for (String url in response.data['assets']) {
        String id = url.split('/').last.split('.').first;
        assets[id]!.url = url;
      }
    }

    for (AssetX asset in usedAssets) {
      var future = asset.getCompiled(returnFile: !upload)
        .then((compiled) => MapEntry(asset.id, compiled));
      futures.add(future);
    }

    List<MapEntry<String, dynamic>> results = await Future.wait(futures);

    // Filter out null values or handle them as needed
    results.removeWhere((entry) => entry.value == null);

    return Map.fromEntries(results);
  }

  Future<void> deleteProjectAssets() async {
    String path = await pathProvider.generateRelativePath(project.assetSavePath);
    Directory dir = Directory(path);
    if (await dir.exists()) await dir.delete(recursive: true);

    await dir.create(recursive: true); // Recreate the directory
  }

  /// Gets a list of all the assets that are used in the project
  /// This is used to filter out unused assets when compiling the project and saves space by not including them in the compiled project
  List<AssetX> _getUsedAssets() {
    List<AssetX> usedAssets = [];
    for (CreatorPage page in project.pages.pages) {
      for (CreatorWidget widget in page.widgets.widgets) {
        if (widget.asset != null) usedAssets.add(widget.asset!);
      }
    }
    return usedAssets;
  }

  /// Parallelly builds each asset from the it's compiled form
  static Future<AssetManagerX> fromCompiled(Project project, {
    required Map data
  }) async {
    AssetManagerX _manager = AssetManagerX._(project: project);
    List<Future<void>> futures = [];

    data.values.forEach((var _assetData) {
      futures.add(
        AssetX.fromCompiled(_assetData, project: project)
          .then((AssetX asset) {
            _manager.assets[asset.id] = asset;
          })
          .catchError((e, stacktrace) {
            analytics.logError(e, cause: 'asset initialization error', stacktrace: stacktrace);
            project.issues.add(AssetXException('An asset file was missing or corrupted. Please re-add the asset.'));
          })
      );
    });

    await Future.wait(futures);

    return _manager;
  }

}