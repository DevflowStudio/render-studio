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
    this.context = context;
  }

  late final PageManager pages;
  final bool fromSaves;

  late final BuildContext context;

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
  Future<bool> saveToGallery() async {
    images.clear();
    for (CreatorPage page in pages.pages) {
      try {
        images.add((await page.save(context, saveToGallery: true))!);
      } catch (e) {
        issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
      }
    }
    return issues.isEmpty;
  }

  Future<Map<String, dynamic>> toJSON(BuildContext context) async {

    List<Map<String, dynamic>> pageData = [];
    for (var page in pages.pages) {
      pageData.add(page.toJSON());
    }

    thumbnail = await pages.pages.first.save(context, saveToGallery: true, autoExportQualtiy: false);

    images.clear();
    for (CreatorPage page in pages.pages) {
      String? thumbnail = await page.save(context, saveToGallery: false);
      if (thumbnail != null) images.add(thumbnail);
      else issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
    }

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
      'assets': assetManager.toJSON(),
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

    for (dynamic pageDate in data['pages']) {
      CreatorPage? page = CreatorPage.fromJSON(Map.from(pageDate), project: project);
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
    } catch (e) {
      analytics.logError(e, cause: 'project rendering error');
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