// import 'package:flutter/material.dart';
// 
// import '../../rehmat.dart';
// 
// class AssetManager {
// 
//   AssetManager._({required this.page});
//   final CreatorPage page;
// 
//   Map<String, Asset> assets = {};
// 
//   static AssetManager create(CreatorPage page) => AssetManager._(page: page);
// 
//   /// Initialize the asset manager from a JSON object
//   static AssetManager fromJSON(CreatorPage page, {
//     required Map data
//   }) {
//     AssetManager _manager = AssetManager._(page: page);
//     for (Map _assetData in data.values) {
//       Asset asset = Asset.fromJSON(_assetData, page: page);
//       try {
//         _manager.assets[asset.id] = asset;
//       } catch (e, stacktrace) {
//         analytics.logError(e, cause: 'asset initialization error', stacktrace: stacktrace);
//         page.project.issues.add(AssetException('An asset file was missing or corrupted. Please re-add the asset.'));
//       }
//     }
//     return _manager;
//   }
// 
//   bool _hasPrecached = false;
//   bool canPrecache() {
//     if (_hasPrecached) return false;
//     return assets.isNotEmpty;
//   }
// 
//   Future<void> precache(BuildContext context) async {
//     for (Asset asset in assets.values) {
//       await asset.precache(context);
//     }
//     _hasPrecached = true;
//   }
// 
//   /// Add an asset to the project
//   void add(Asset asset) {
//     assets[asset.id] = asset;
//   }
// 
//   Future<void> delete(Asset asset) async {
//     assets.remove(asset.id);
//     await asset.delete();
//   }
// 
//   Asset? get(String id) {
//     return assets[id];
//   }
// 
//   Future<void> compile() async {
//     await _removeUnlinkedAssets();
//     for (Asset asset in assets.values) {
//       await asset.compile();
//     }
//   }
// 
//   Map<String, dynamic> toJSON() {
//     Map<String, dynamic> _assets = {};
//     for (Asset asset in assets.values) {
//       _assets[asset.id] = asset.toJSON();
//     }
//     return _assets;
//   }
// 
//   /// Checks for all the assets linked with the project and removes the ones that are not used
//   Future<void> _removeUnlinkedAssets() async {
//     List<String> unusedAssets = assets.keys.toList();
//     for (CreatorWidget widget in page.widgets.widgets) {
//       if (widget is WidgetGroup) {
//         for (CreatorWidget child in widget.widgets) {
//           if (child.asset != null && unusedAssets.contains(child.asset!.id)) unusedAssets.remove(child.asset!.id);
//         }
//       } else if (widget.asset != null && unusedAssets.contains(widget.asset!.id)) unusedAssets.remove(widget.asset!.id);
//     }
//     for (String id in unusedAssets) await delete(assets[id]!);
//   }
// 
// }