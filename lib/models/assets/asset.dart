import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../../rehmat.dart';

class Asset {

  late String id;

  late Project project;

  late File? _file;

  File get file => _file!;

  late DateTime createdAt;

  late String extension;

  late FileType type;

  AssetLocation location = AssetLocation.local;

  Future<void> ensureExists() async {
    await file.exists();
    if (!(await file.exists())) {
      throw Exception("The supporting file for this asset does not exist");
    }
    if (location != AssetLocation.local) {
      throw Exception("This asset has not been downloaded from the cloud. Please re-sync the project.");
    }
  }

  void updateFile(File file) {
    _file = file;
  }

  // TODO: Download from cloud
  Future<void> download() async {}

  static Future<Asset?> create(BuildContext context, {
    required Project project,
    required File file,
    FileType type = FileType.image,
  }) async {
    final Directory dir = (await getApplicationDocumentsDirectory());
    Asset asset = Asset();
    asset.id = Constants.generateID(4);
    File _tempFile = await new File('${dir.path}/${project.id}/${asset.id}.${file.path.split('/').last.split('.').last}').create(recursive: true);
    _tempFile.writeAsBytesSync(file.readAsBytesSync());
    asset._file = await _tempFile;
    asset.project = project;
    asset.createdAt = DateTime.now();
    asset.extension = file.path.split('/').last.split('.').last;
    asset.type = type;
    asset.location = AssetLocation.local;
    project.assetManager.add(asset);
    return asset;
  }

  static Future<Asset?> pick(Project project, {
    required BuildContext context,
    FileType type = FileType.image,
    bool crop = false,
    CropAspectRatio? cropRatio,
  }) async {
    File? _file = await FilePicker.pick(type: type, crop: crop, cropRatio: cropRatio, context: context);
    if (_file == null) return null;
    Asset? asset = await Asset.create(context, project: project, file: _file);
    return asset;
  }

  Future<void> delete() async => await file.delete();

  // Future<String> _getSaveLocation() async {
  //   final Directory dir = await getApplicationDocumentsDirectory();
  //   return '${dir.path}/$id.json';
  // }

  Future<Size?> get dimensions async {
    try {
      var decodedImage = await decodeImageFromList(file.readAsBytesSync());
      return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'path': file.path,
      'created-at': createdAt.millisecondsSinceEpoch,
      'extension': extension,
      'type': type.type,
      'location': location.type,
    };
  }

  static Asset fromJSON(Map data) {
    Asset asset = Asset();
    asset.id = data['id'];
    asset.location = AssetLocationExtension.fromString(data['location']);
    asset._file = File(data['path']);
    asset.createdAt = DateTime.fromMillisecondsSinceEpoch(data['created-at']);
    asset.extension = data['extension'];
    asset.type = FileType.dynamic.fromString(data['type']);
    return asset;
  }

  static Stream<double> downloadAndCreateAsset(BuildContext context, {
    required Project project,
    required String url,
    Map<String, dynamic>? headers,
    required Function(Asset? asset) onDownloadComplete,
    String extension = 'jpg',
  }) async* {
    try {
      Response response = await Dio().get(
        url,
        options: Options(
          headers: headers,
        ),
        onReceiveProgress: (int received, int total) async* {
          print((received / total * 100).toStringAsFixed(0) + "%");
          yield received / total;
        }
      );
      if (response.statusCode == 200) {
        yield 1.0;
        print('download complete');
        var tempFilePath = await getTemporaryDirectory();
        String savePath = '${tempFilePath.path}/${Constants.generateID()}.$extension';
        File file = await new File(savePath).create(recursive: true);
        File _newFile = await file.writeAsString(response.data);
        Asset? asset = await Asset.create(context, project: project, file: _newFile);
        onDownloadComplete(asset);
      } else {
        yield 0.0;
      }
    } catch (e) {
      print(e);
      yield 0.0;
    }
  }

}

enum AssetLocation {
  local,
  remote,
}

extension AssetLocationExtension on AssetLocation {

  String get type {
    switch (this) {
      case AssetLocation.local:
        return 'local';
      case AssetLocation.remote:
        return 'remote';
      default:
        return 'local';
    }
  }

  static AssetLocation fromString(String type) {
    switch (type) {
      case 'local':
        return AssetLocation.local;
      case 'remote':
        return AssetLocation.remote;
      default:
        return AssetLocation.local;
    }
  }

}