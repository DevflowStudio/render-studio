import 'package:flutter/material.dart';

import '../rehmat.dart';

class Project extends ChangeNotifier {

  Project(BuildContext context, {
    this.id,
    this.fromSaves = false
  }) {
    pages = PageManager(this);
    id ??= Constants.generateID(6);
    created ??= DateTime.now();
    edited ??= DateTime.now(); // if (edited == null) edited = DateTime.now();
    deviceSize = MediaQuery.of(context).size;
  }

  late final PageManager pages;
  final bool fromSaves;

  String? id;

  DateTime? created;

  DateTime? edited;

  /// Headline of the project
  String? title;

  /// Description of the project
  String? description;

  late PostSize size;

  late Size deviceSize;
  
  List<String> images = [];
  String? thumbnail;

  late AssetManager assetManager;

  Map<String, dynamic>? data;

  List<Exception> issues = [];

  /// This is the actual size of the page
  /// and will be used to export the image
  Size get contentSize {
    double height = size.size.height;
    double width = size.size.width;
    double ratio = width/height;

    double actualWidth = deviceSize.width;
    double actualHeight = deviceSize.width / ratio;

    Size actualSize = Size(actualWidth, actualHeight);

    double maxCanvasRatio = 0.6;

    if (actualHeight > deviceSize.height * maxCanvasRatio) {
      double _height = deviceSize.height * maxCanvasRatio;
      actualSize = Size(_height * ratio, _height);
    }

    return actualSize;
  }

  /// Renders and saves each of the page as a png file to the device gallery
  ///
  /// Returns false if an issue is encountered in any of the pages
  Future<bool> saveToGallery(BuildContext context) async {
    images.clear();
    for (CreatorPage page in pages.pages) {
      try {
        String? _image = await page.save(context, saveToGallery: true);
        if (_image != null) images.add(_image);
      } catch (e, stacktrace) {
        issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
        analytics.logError(e, cause: 'Failed to render page ${pages.pages.indexOf(page) + 1}', stacktrace: stacktrace);
      }
    }
    return issues.isEmpty;
  }

  Future<Map<String, dynamic>> toJSON(BuildContext context, {
    bool saveToGallery = false
  }) async {

    List<Map<String, dynamic>> pageData = [];
    for (var page in pages.pages) {
      pageData.add(await page.toJSON());
    }

    images.clear();
    for (CreatorPage page in pages.pages) {
      String? thumbnail = await page.save(context, saveToGallery: saveToGallery);
      if (thumbnail != null) images.add(thumbnail);
      else issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
    }
    thumbnail = images.first;

    Map<String, dynamic> json = {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'thumbnail': thumbnail,
      'size': {
        'type': size.title,
        'height': size.size.height,
        'width': size.size.width,
      },
      'pages': pageData,
      'meta': {
        'created': created?.millisecondsSinceEpoch,
        'edited': DateTime.now().millisecondsSinceEpoch,
      },
      'assets': await assetManager.toJSON(),
    };

    return json;
  }

  static Future<Project?> fromJSON(Map<String, dynamic> data, {
    required BuildContext context
  }) async {

    Project project = Project(context, fromSaves: true);

    project.id = data['id'];
    project.title = data['title'];
    project.description = data['description'];
    project.images = List<String>.from(data['images']);
    project.size = PostSize.custom(width: data['size']['width'], height: data['size']['height'],);
    project.created = DateTime.fromMillisecondsSinceEpoch(data['meta']['created']);
    project.edited = DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']);
    project.assetManager = await AssetManager.initialize(project, data: data);
    project.thumbnail = data['thumbnail'];
    project.data = data;

    for (Map pageDate in data['pages']) {
      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageDate), project: project);
      if (page != null) project.pages.pages.add(page);
    }

    project.pages.updateListeners();

    // await project.assetManager.precache(context);

    return project;
  }

  
  /// Create a new empty Project
  /// Requires a BuildContext to get the device size
  static Future<Project> create(BuildContext context, {
    PostSize? size
  }) async {
    Project project = Project(context);
    project.size = size ?? PostSizePresets.square.toSize();
    project.assetManager = await AssetManager.initialize(project, data: {});
    return project;
  }

  Future<void> duplicate(BuildContext context) async {
    await manager.save(context, data: {
      ... data!,
      'id': Constants.generateID(),
      'title': '$title (copy)',
      'meta': {
        ... data!['meta'],
        'created': DateTime.now().millisecondsSinceEpoch,
        'edited': DateTime.now().millisecondsSinceEpoch,
      }
    });
  }

}

class ProjectCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  ProjectCreationException(this.message, {this.details, this.code});

}