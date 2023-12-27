import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../rehmat.dart';

class AssetX {

  final String id;

  File? file;

  String? url;

  final DateTime createdAt;

  final FileType fileType;

  AssetType assetType = AssetType.file;

  final Project project;

  Map<String, AssetHistory> history = {};

  AssetX._({required this.id, required this.createdAt, required this.fileType, this.file, this.url, required this.project}) {
    if (file != null) assetType = AssetType.file;
    else assetType = AssetType.url;
  }

  static AssetX create({
    required Project project,
    File? file,
    String? url,
    FileType fileType = FileType.image,
    BuildInfo buildInfo = BuildInfo.unknown,
    String? id,
  }) {
    assert(file != null || url != null, 'Either file or url must be provided');
    AssetX asset = AssetX._(
      id: id ?? Constants.generateID(4),
      createdAt: DateTime.now(),
      fileType: fileType,
      file: file,
      url: url,
      project: project
    );
    if (buildInfo.version != null) asset.history = {buildInfo.version!: AssetHistory(version: buildInfo.version!, file: file, url: url, type: asset.assetType)};
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
    AssetX? asset = AssetX.create(file: _file, project: project, buildInfo: buildInfo);
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
    return AssetX.create(file: file, project: project, id: id);
  }

  Future<Size?> get dimensions => file != null ? getDimensions(file!) : getDimensionsFromUrl(url!);

  static Future<Size?> getDimensions(File file) async {
    try {
      var decodedImage = await decodeImageFromList(file.readAsBytesSync());
      return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to get dimensions of image', stacktrace: stacktrace);
      return null;
    }
  }

  static Future<Size?> getDimensionsFromUrl(String imageUrl) async {
    try {
      Completer<Size> completer = Completer();
      ImageStreamListener listener;

      // Define an ImageStreamListener
      listener = ImageStreamListener((ImageInfo info, bool _) {
        var myImage = info.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
      });

      // Load the image
      var image = Image.network(imageUrl);
      image.image.resolve(const ImageConfiguration()).addListener(listener);

      return completer.future;
    } catch (e) {
      return null;
    }
  }

  Future<AssetX> duplicate({
    BuildInfo buildInfo = BuildInfo.unknown
  }) async {
    String _id = Constants.generateID(4);
    AssetX asset;
    File? _file;
    if (file != null) {
      _file = await file!.copy((await getTemporaryDirectory()).path + '/$_id.temp');
    }
    asset = AssetX.create(file: _file, url: url, project: project, buildInfo: buildInfo, id: id);
    return asset;
  }

  void logVersion({
    required String version,
    File? file,
    String? url
  }) {
    if (file == null && url == null) return;

    if (file != null) assetType = AssetType.file;
    else assetType = AssetType.url;

    this.file = file;
    this.url = url;

    history[version] = AssetHistory(
      version: version,
      file: file,
      url: url,
      type: assetType
    );
  }

  void restoreVersion({
    required String version
  }) {
    if (history.containsKey(version)) {
      file = history[version]!.file;
      url = history[version]!.url;
    } else if (history.isNotEmpty) {
      file = history.values.last.file;
      url = history.values.last.url;
    } else {
      return;
    }
  }

  // Future<bool> exists() => file.exists();

  Future<Map<String, dynamic>> getCompiled() async {
    await convertToFileType();

    String filename = '$id.${file!.path.split('.').last}';
    file = await file!.copy(await pathProvider.generateRelativePath(project.assetSavePath) + filename);

    return {
      'id': id,
      'file': filename,
      'url': url,
      'created-at': createdAt.millisecondsSinceEpoch,
      'file-type': fileType.type,
      'asset-type': assetType.toString().split('.').last
    };
  }

  Future<void> convertToFileType() async {
    if (assetType == AssetType.file) return;
    file = await FilePicker.downloadFile(url!, type: fileType, precache: true);
    // replace all previous versions with the new file
    for (String version in history.keys) {
      if (history[version]!.type == AssetType.url && history[version]!.url == url) {
        history[version]!.file = file;
        history[version]!.type = AssetType.file;
      }
    }
    assetType = AssetType.file;
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
        fileType: FileTypeExtension.fromString(data['file-type']),
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

class AssetHistory {

  final String version;

  File? file;

  String? url;

  AssetType type;

  AssetHistory({
    required this.version,
    this.file,
    this.url,
    required this.type
  });

}