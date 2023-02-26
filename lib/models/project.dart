import 'package:flutter/material.dart';

import '../rehmat.dart';

class Project extends ChangeNotifier {

  Project(BuildContext context, {
    this.id,
    this.fromSaves = false
  }) {
    pages = PageManager(this);
    id ??= Constants.generateID(6);
    deviceSize = MediaQuery.of(context).size;
  }

  late final PageManager pages;
  final bool fromSaves;

  late final ProjectMetadata metadata;

  String? id;

  /// Headline of the project
  String? title;

  /// Description of the project
  String? description;

  late PostSize size;

  late Size deviceSize;
  
  List<String> images = [];
  String? thumbnail;

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

    images.clear();
    for (CreatorPage page in pages.pages) {
      String? thumbnail = await page.save(context, saveToGallery: saveToGallery);
      if (thumbnail != null) images.add(thumbnail);
      else issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
    }
    thumbnail = images.firstOrNull;

    List<Map<String, dynamic>> pageData = [];
    for (CreatorPage page in pages.pages) {
      await page.assetManager.compile();
      pageData.add(page.toJSON(BuildInfo(buildType: BuildType.save)));
    }

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
      'meta': metadata.toJSON()
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
    project.thumbnail = data['thumbnail'];
    project.data = data;
    project.metadata = ProjectMetadata.fromJSON(data['meta']);

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
    project.metadata = ProjectMetadata.create();
    return project;
  }

  Future<void> duplicate(BuildContext context) async {
    await manager.save(context, data: {
      ... data!,
      'id': Constants.generateID(),
      'title': '$title (copy)',
      'meta': ProjectMetadata.create().toJSON()
    });
  }

  static void createNewProject(BuildContext context, PostSize size) async {
    Project project = await Project.create(context, size: size);
    String title;
    if (manager.projects.isEmpty) title = 'My First Project';
    else {
      int n = manager.projects.length + 1;
      title = 'Project ($n)';
      while (manager.projects.where((glance) => glance.title == title).isNotEmpty) {
        n++;
        title = 'Project ($n)';
      }
    }
    project.title = title;
    AppRouter.push(context, page: Information(project: project, isNewProject: true,));
  }

}

class ProjectCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  ProjectCreationException(this.message, {this.details, this.code});

}