import 'dart:io';
import 'package:file_picker/file_picker.dart' as filepicker;
import 'package:flutter/material.dart';

import '../rehmat.dart';

class FilePicker {

  static Future<File?> pick() async {
    filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
      allowCompression: false,
      type: filepicker.FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  static Future<List<File>> pickMultiple() async {
    filepicker.FilePickerResult? result = await filepicker.FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowCompression: false,
      type: filepicker.FileType.image,
    );
    List<File> files = [];
    if (result != null) {
      for (filepicker.PlatformFile file in result.files) {
        files.add(File(file.path!));
      }
    }
    return files;
  }

  static Future<File?> picker(BuildContext context) async => await showModalBottomSheet<File>(
    context: context,
    backgroundColor: Palette.of(context).surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Constants.borderRadius.bottomLeft)
    ),
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Label(label: 'Select Image'),
        ),
        ListTile(
          title: const Text('Unsplash'),
          onTap: () async {
            TapFeedback.light();
          },
        ),
        ListTile(
          title: const Text('Gallery'),
          onTap: () async {
            TapFeedback.light();
            File? file = await FilePicker.pick();
            Navigator.of(context).pop(file);
          },
        ),
        Container(height: 20,)
      ],
    ),
  );

}