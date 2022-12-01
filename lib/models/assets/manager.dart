import '../../rehmat.dart';

class AssetManager {

  AssetManager({required this.project});
  final Project project;

  Map<String, Asset> assets = {};

  /// Initialize the asset manager
  static Future<AssetManager> initialize(Project project, {
    required Map data
  }) async {
    AssetManager _manager = AssetManager(project: project);
    for (Map _assetData in (data['assets'] ?? {}).values) {
      Asset asset = Asset.fromJSON(_assetData, project: project);
      try {
        await asset.ensureExists();
        _manager.assets[asset.id] = asset;
      } catch (e, stacktrace) {
        analytics.logError(e, cause: 'asset initialization error', stacktrace: stacktrace);
        project.issues.add(AssetException('An asset file was missing or corrupted. Please re-add the asset.'));
      }
    }
    return _manager;
  }

  /// Add an asset to the project
  void add(Asset asset) {
    assets[asset.id] = asset;
  }

  Future<void> delete(Asset asset) async {
    assets.remove(asset.id);
    await asset.delete();
  }

  Asset? get(String id) {
    return assets[id];
  }

  Future<Map<String, dynamic>> toJSON() async {
    Map<String, dynamic> _assets = {};
    for (Asset asset in assets.values) {
      _assets[asset.id] = await asset.toJSON();
    }
    return _assets;
  }

}