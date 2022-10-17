import 'dart:io';

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

  Future<bool> exists() async {
    return await file.exists();
  }

  static Future<Asset?> create(Project project, {
    FileType type = FileType.image,
    bool crop = false,
    CropAspectRatio? cropRatio,
    BuildContext? context
  }) async {
    File? _file = await FilePicker.pick(type: type, crop: crop, cropRatio: cropRatio, context: context);
    if (_file == null) return null;
    // Save the file to application's documents directory
    final Directory dir = await getApplicationDocumentsDirectory();
    Asset asset = Asset();
    asset.id = Constants.generateID(4);
    File _tempFile = await new File('${dir.path}/${project.id}/${asset.id}.${_file.path.split('/').last.split('.').last}').create(recursive: true);
    _tempFile.writeAsBytesSync(_file.readAsBytesSync());
    asset.file = await _tempFile;
    asset.project = project;
    asset.createdAt = DateTime.now();
    asset.extension = _file.path.split('/').last.split('.').last;
    asset.type = type;
    project.assetManager.add(asset);
    return asset;
  }

  // Future<String> _getSaveLocation() async {
  //   final Directory dir = await getApplicationDocumentsDirectory();
  //   return '${dir.path}/$id.json';
  // }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'path': file.path,
      'created-at': createdAt.millisecondsSinceEpoch,
      'extension': extension,
      'type': type.type,
    };
  }

  static Asset? fromJSON(Map data) {
    try {
      Asset asset = Asset();
      asset.id = data['id'];
      asset.file = File(data['path']);
      asset.createdAt = DateTime.fromMillisecondsSinceEpoch(data['created-at']);
      asset.extension = data['extension'];
      asset.type = FileType.dynamic.fromString(data['type']);
      return asset;
    } catch (e) {
      return null;
    }
  }

}