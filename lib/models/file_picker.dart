import 'package:universal_io/io.dart';
import 'package:file_picker/file_picker.dart' as filepicker;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../rehmat.dart';

/// Remove the FilePicker class and migrate to AssetManager

enum FileType {
  dynamic,
  image,
  video,
  svg
}

extension FileTypeString on FileType {

  String get type {
    switch (this) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.svg:
        return 'svg';
      default:
        return 'image';
    }
  }

  FileType fromString(String type) {
    switch (type) {
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'svg':
        return FileType.svg;
      default:
        return FileType.image;
    }
  }

}

class FilePicker {

  static Future<File?> pick({
    /// Type of file to select
    /// • image
    /// • video
    /// • svg
    FileType? type,
    bool crop = false,
    CropAspectRatio? cropRatio,
    BuildContext? context,
  }) async {
    final ImagePicker _picker = ImagePicker();
    XFile? xFile;
    File file;
    switch (type) {
      case FileType.image:
        xFile = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        break;
      case FileType.video:
        xFile = await _picker.pickVideo(
          source: ImageSource.gallery,
        );
        break;
      case FileType.svg:
        filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
          type: filepicker.FileType.custom,
          allowedExtensions: ['svg'],
        );
        if (result != null && result.files.isNotEmpty) {
          file = File(result.files.single.path!);
          return file;
        } else {
          return null;
        }
      default:
        return null;
    }
    if (xFile == null) return null;
    file = File(xFile.path);
    if (context != null && crop && type == FileType.image) {
      try {
        return await FilePicker.crop(context, file: file, ratio: cropRatio);
      } catch (e, stacktrace) {
        analytics.logError(e, cause: 'FilePicker.crop failed', stacktrace: stacktrace);
        return null;
      }
    } else {
      return file;
    }
    // filepicker.FileType fileType;
    // List<String>? allowedExtenstions;
    // switch (type) {
    //   case FileType.image:
    //     fileType = filepicker.FileType.image;
    //     break;
    //   case FileType.video:
    //     fileType = filepicker.FileType.video;
    //     break;
    //   case FileType.svg:
    //     fileType = filepicker.FileType.custom;
    //     allowedExtenstions = ['svg'];
    //     break;
    //   default:
    //     fileType = filepicker.FileType.custom;
    // }
    // filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
    //   allowCompression: false,
    //   type: fileType,
    //   allowedExtensions: allowedExtenstions
    // );
  }

  /// Shows a bottom sheet for options to select image from unsplash or pick from gallery
  static Future<File?> imagePicker(BuildContext context, {
    bool crop = false,
    CropAspectRatio? cropRatio,
  }) async {
    String? option = await Alerts.optionsBuilder(
      context,
      title: 'Image',
      options: [
        AlertOption(
          title: 'Unsplash',
          id: 'unsplash'
        ),
        AlertOption(
          title: 'Gallery',
          id: 'gallery'
        ),
      ]
    );
    if (option == null) return null;
    switch (option) {
      case 'unsplash':
        return await UnsplashImagePicker.getImage(context, crop: crop, cropRatio: cropRatio);
      case 'gallery':
        return await FilePicker.pick(
          context: context,
          crop: crop,
          cropRatio: cropRatio,
          type: FileType.image
        );
      default:
        return null;
    }
  }

  static Future<File?> crop(BuildContext context, {
    required File file,
    CropAspectRatio? ratio
  }) async {
    AndroidUiSettings uiSettings = AndroidUiSettings(
      backgroundColor: Theme.of(context).backgroundColor,
      cropFrameColor: Palette.of(context).primary,
      activeControlsWidgetColor: Palette.of(context).primary,
      toolbarColor: Theme.of(context).appBarTheme.backgroundColor,
      statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
      toolbarTitle: 'Crop Image',
    );
    CroppedFile? _croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        uiSettings
      ],
      aspectRatio: ratio,
    );
    if (_croppedFile != null) return File(_croppedFile.path);
    else return null;
  }

}