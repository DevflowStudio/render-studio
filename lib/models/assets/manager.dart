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
      Asset? asset = Asset.fromJSON(_assetData);
      try {
        await asset.ensureExists();
        _manager.assets[asset.id] = asset;
      } catch (e) {
        analytics.logError(e, cause: 'asset initialization error');
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

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> _assets = {};
    for (Asset asset in assets.values) {
      _assets[asset.id] = asset.toJSON();
    }
    return _assets;
  }

}