import 'package:dio/dio.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import '../../rehmat.dart';

class Asset {

  late String id;

  late Project project;

  late File file;

  late DateTime createdAt;

  late String extension;

  late FileType type;

  Future<void> Function(File file)? onCompile;

  Map<String, File> history = {};

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

  Future<void> ensureExists() async {
    if (!(await file.exists())) {
      throw Exception("The supporting file for this asset does not exist");
    }
  }

  static Asset create({
    required Project project,
    required File file,
    FileType type = FileType.image,
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    Asset asset = Asset();
    asset.id = Constants.generateID(4);
    asset.file = file;
    asset.project = project;
    asset.createdAt = DateTime.now();
    asset.extension = file.path.split('/').last.split('.').last;
    asset.type = type;
    if (buildInfo.version != null) asset.history = {
      buildInfo.version!: file
    };
    project.assetManager.add(asset);
    return asset;
  }

  static Future<Asset?> pick(Project project, {
    required BuildContext context,
    FileType type = FileType.image,
    bool crop = false,
    CropAspectRatio? cropRatio,
    BuildInfo buildInfo = BuildInfo.unknown
  }) async {
    File? _file = await FilePicker.pick(type: type, crop: crop, cropRatio: cropRatio, context: context);
    if (_file == null) return null;
    Asset? asset = Asset.create(project: project, file: _file, buildInfo: buildInfo);
    return asset;
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

  Future<void> precache(BuildContext context) => precacheImage(FileImage(file), context);

  Future<String> compile() async {
    try {
      await onCompile?.call(file);
      String _path = '/Render Projects/${project.id}/Assets/${id}.${file.path.split('/').last.split('.').last}';
      file = await pathProvider.saveToDocumentsDirectory(_path, bytes: file.readAsBytesSync());
      return _path;
    } catch (e, stacktrace) {
      project.issues.add(AssetException('Failed to compile asset', code: 'asset-missing'));
      analytics.logError(e, cause: 'Failed to compile asset', stacktrace: stacktrace);
      throw Exception('Failed to compile asset');
    }
  }

  Future<Map<String, dynamic>> toJSON() async {
    return {
      'id': id,
      'path': await compile(),
      'created-at': createdAt.millisecondsSinceEpoch,
      'extension': extension,
      'type': type.type,
    };
  }

  static Asset fromJSON(Map data, {
    required Project project
  }) {
    try {
      Asset asset = Asset();
      asset.id = data['id'];
      asset.file = File(pathProvider.generateRelativePath(data['path']));
      asset.createdAt = DateTime.fromMillisecondsSinceEpoch(data['created-at']);
      asset.extension = data['extension'];
      asset.type = FileType.dynamic.fromString(data['type']);
      asset.project = project;
      return asset;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to parse asset from JSON', stacktrace: stacktrace);
      throw WidgetCreationException('The linked asset file could not be found.');
    }
  }

  Future<Asset> duplicate({
    BuildInfo buildInfo = BuildInfo.unknown
  }) async {
    File _file = await file.copy('${file.path.split('/').sublist(0, file.path.split('/').length - 1).join('/')}/${Constants.generateID()}.${file.path.split('/').last.split('.').last}');
    Asset asset = Asset.create(project: project, file: _file, buildInfo: buildInfo);
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
          yield received / total;
        }
      );
      if (response.statusCode == 200) {
        yield 1.0;
        var tempFilePath = await getTemporaryDirectory();
        String savePath = '${tempFilePath.path}/${Constants.generateID()}.$extension';
        File file = await new File(savePath).create(recursive: true);
        File _newFile = await file.writeAsString(response.data);
        Asset? asset = await Asset.create(project: project, file: _newFile);
        onDownloadComplete(asset);
      } else {
        yield 0.0;
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to download asset', stacktrace: stacktrace);
      yield 0.0;
    }
  }

  static Stream<double> downloadFile(BuildContext context, {
    required String url,
    Map<String, dynamic>? headers,
    required Function(File? file) onDownloadComplete,
    String? extension,
  }) async* {
    try {
      Response response = await Dio().get(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return (status ?? 200) < 500;
          }
        ),
        onReceiveProgress: (int received, int total) async* {
          yield received / total;
        }
      );
      if (response.statusCode == 200) {
        yield 1.0;
        var tempFilePath = await getTemporaryDirectory();
        String savePath = '${tempFilePath.path}/${Constants.generateID()}.$extension';
        File file = await new File(savePath).create(recursive: true);
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        onDownloadComplete(file);
      } else {
        yield 0.0;
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Failed to download asset', stacktrace: stacktrace);
      yield 0.0;
    }
  }

}


class AssetException implements Exception {

  final String? code;
  final String message;
  final String? details;

  AssetException(this.message, {this.details, this.code});

}