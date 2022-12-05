import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  PostSize? size;

  late Size deviceSize;
  
  List<String> images = [];
  String? thumbnail;

  late AssetManager assetManager;

  bool editorVisible = true;

  List<Exception> issues = [];

  /// Render Project: Canvas Size
  /// The interactive area as a whole is referred to as the canvas
  /// Canvas is larger than the actual project's content size
  /// i.e. the interactive area is more to enhance experience even though the content size will be smaller
  Size canvasSize(BuildContext context) {
    double height = size!.size.height;
    double width = size!.size.width;
    double ratio = width/height;

    double actualWidth = MediaQuery.of(context).size.width;
    double actualHeight = MediaQuery.of(context).size.width / ratio;

    Size actualSize = Size(actualWidth, actualHeight);

    double maxCanvasRatio = editorVisible ? 0.6 : 0.7;

    if (actualHeight > MediaQuery.of(context).size.height * maxCanvasRatio) {
      double _height = MediaQuery.of(context).size.height * maxCanvasRatio;
      actualSize = Size(_height * ratio, _height);
    }

    return actualSize;
  }

  /// This is the actual size of the page
  /// and will be used to export the image
  Size contentSize(BuildContext context) {
    double height = size!.size.height;
    double width = size!.size.width;
    double ratio = width/height;

    double actualWidth = MediaQuery.of(context).size.width;
    double actualHeight = MediaQuery.of(context).size.width / ratio;

    Size actualSize = Size(actualWidth, actualHeight);

    double maxCanvasRatio = editorVisible ? 0.6 : 0.7;

    if (actualHeight > MediaQuery.of(context).size.height * maxCanvasRatio) {
      double _height = MediaQuery.of(context).size.height * maxCanvasRatio;
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
        'type': size!.title,
        'height': size!.size.height,
        'width': size!.size.width,
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

  static Future<Project?> fromJSON(Map data, {
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

    for (Map pageDate in data['pages']) {
      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageDate), project: project);
      if (page != null) project.pages.pages.add(page);
    }

    project.pages.updateListeners();

    return project;
  }

  static Future<Project?> get(String id, {
    required BuildContext context,
  }) async {
    try {
      Box box = Hive.box('projects');
      Map json = Map.from(box.get(id));
      Project? project = await Project.fromJSON(json, context: context);
      return project;
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'project rendering error', stacktrace: stacktrace);
      return null;
    }
  }

  
  /// Create a new empty Project
  /// Requires a BuildContext to get the device size
  static void create(BuildContext context) async {
    Project project = Project(context);
    project.assetManager = await AssetManager.initialize(project, data: {});
    AppRouter.push(context, page: Information(project: project, isNewPost: true,));
  }

}

class ProjectCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  ProjectCreationException(this.message, {this.details, this.code});

}