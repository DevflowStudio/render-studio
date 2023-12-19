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
  Future<Map<String, dynamic>> getCompiled() async {
    List<Future<MapEntry<String, dynamic>>> futures = [];

    List<AssetX> usedAssets = _getUsedAssets();

    for (AssetX asset in usedAssets) {
      var future = asset.getCompiled()
        .then((compiled) => MapEntry(asset.id, compiled));
      futures.add(future);
    }

    List<MapEntry<String, dynamic>> results = await Future.wait(futures);

    // Filter out null values or handle them as needed
    results.removeWhere((entry) => entry.value == null);

    return Map.fromEntries(results);
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
            print(asset.file.path);
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