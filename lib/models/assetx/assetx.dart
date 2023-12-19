import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../rehmat.dart';

class AssetX {

  final String id;

  late File file;

  final DateTime createdAt;

  final FileType type;

  AssetType assetType = AssetType.file;

  final Project project;

  Map<String, File> history = {};

  AssetX._({required this.id, required this.createdAt, required this.type, required this.file, required this.project});

  static AssetX create(File file, {
    required Project project,
    FileType type = FileType.image,
    BuildInfo buildInfo = BuildInfo.unknown,
    String? id,
  }) {
    AssetX asset = AssetX._(
      id: id ?? Constants.generateID(4),
      createdAt: DateTime.now(),
      type: type,
      file: file,
      project: project
    );
    if (buildInfo.version != null) asset.history = {buildInfo.version!: file};
    project.assetManager.add(asset);
    return asset;
  }

  /// Utilises [FilePicker.pick] to pick an asset from the device and convert it into an asset
  static Future<AssetX?> pick(BuildContext context, {
    required Project project,
    FileType type = FileType.image,
    bool crop = false,
    CropAspectRatio? cropRatio,
    BuildInfo buildInfo = BuildInfo.unknown
  }) async {
    File? _file = await FilePicker.pick(type: type, crop: crop, cropRatio: cropRatio, context: context);
    if (_file == null) return null;
    AssetX? asset = AssetX.create(_file, project: project, buildInfo: buildInfo);
    return asset;
  }
  
  /// Creates an asset from a URL
  /// Uses the [FilePicker.downloadFile] method to download the file and convert it into an asset
  static Future<AssetX> fromURL(String url, {
    required Project project,
    BuildContext? context,
    Map<String, dynamic>? headers,
    FileType type = FileType.image,
    String? id
  }) async {
    File file = await FilePicker.downloadFile(
      url,
      headers: headers,
      type: type,
      precache: true,
      context: context
    );
    return AssetX.create(file, project: project, id: id);
  }

  Future<void> delete() async => await file.delete();

  Future<Size?> get dimensions => getDimensions(file);

  static Future<Size?> getDimensions(File file) async {
    try {
      var decodedImage = await decodeImageFromList(file.readAsBytesSync());
      return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to get dimensions of image', stacktrace: stacktrace);
      return null;
    }
  }

  Future<AssetX> duplicate({
    BuildInfo buildInfo = BuildInfo.unknown
  }) async {
    String _id = Constants.generateID(4);
    File _file = await file.copy((await getTemporaryDirectory()).path + '/$_id.temp');
    AssetX asset = AssetX.create(_file, project: project, buildInfo: buildInfo, id: id);
    return asset;
  }

  void logVersion({
    required String version,
    required File file
  }) {
    history[version] = file;
    this.file = file;
  }

  void restoreVersion({
    required String version
  }) {
    if (history.containsKey(version)) {
      file = history[version]!;
    } else if (history.isNotEmpty) {
      file = history.values.last;
    } else {
      return;
    }
  }

  Future<bool> exists() => file.exists();

  Future<Map<String, dynamic>> getCompiled() async {
    String filename = '$id.${file.path.split('.').last}';
    file = await file.copy(await pathProvider.generateRelativePath(project.assetSavePath) + filename);

    return {
      'id': id,
      'file': filename,
      'url': null,
      'created-at': createdAt.millisecondsSinceEpoch,
      'type': type.type,
      'asset-type': assetType.toString().split('.').last
    };
  }

  static Future<AssetX> fromCompiled(Map data, {
    required Project project
  }) async {
    try {
      AssetType assetType = AssetTypeExtension.fromString(data['asset-type']);

      if (assetType == AssetType.url) {
        return await AssetX.fromURL(data['url'], project: project, id: data['id']);
      }

      String savePath = await pathProvider.generateRelativePath(project.assetSavePath + data['file']);
      File originalFile = File(savePath);

      File copiedFile = await originalFile.copy((await getTemporaryDirectory()).path + '/${Constants.generateID()}.temp');

      return AssetX._(
        id: data['id'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created-at']),
        type: FileType.dynamic.fromString(data['type']),
        file: copiedFile,
        project: project
      );
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to parse asset from JSON', stacktrace: stacktrace);
      throw WidgetCreationException('The linked asset file could not be found.');
    }
  }

}


class AssetXException implements Exception {

  final String? code;
  final String message;
  final String? details;

  AssetXException(this.message, {this.details, this.code});

}

enum AssetType { file, url }

extension AssetTypeExtension on AssetType {

  String get title {
    switch (this) {
      case AssetType.file:
        return 'file';
      case AssetType.url:
        return 'url';
    }
  }

  static AssetType fromString(String type) {
    switch (type) {
      case 'file':
        return AssetType.file;
      case 'url':
        return AssetType.url;
      default:
        return AssetType.file;
    }
  }

}