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

  late bool isTemplate;

  late PostSize size;

  late Size deviceSize;
  
  List<String> images = [];
  String? thumbnail;

  Map<String, dynamic>? data;

  List<Exception> issues = [];

  /// This is the actual size of the page
  /// and will be used to export the image
  Size get contentSize => getActualSizeFromPostSize(size, deviceSize);

  double get pixelRatio => size.size.width / contentSize.width;

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

  void resize(PostSize size) {
    for (CreatorPage page in pages.pages) {
      page.onSizeChange(this.size, size);
    }
    this.size = size;
    notifyListeners();
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
    List<Map<String, dynamic>> variables = [];

    for (CreatorPage page in pages.pages) {
      await page.assetManager.compile();
      pageData.add(page.toJSON(BuildInfo(buildType: BuildType.save)));
      variables.addAll(page.widgets.getVariables());
    }

    print(variables);

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
      'meta': metadata.toJSON(),
      'is-template': isTemplate,
      'variables': variables,
    };

    return json;
  }

  static Future<Project?> fromJSON(Map<String, dynamic> data, {
    required BuildContext context,
    List<Map<String, dynamic>> variableValues = const []
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
    project.isTemplate = data['is-template'] ?? false;

    for (Map pageDate in data['pages']) {
      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageDate), project: project);
      if (page != null) project.pages.pages.add(page);
    }

    project.pages.updateListeners();

    if (variableValues.isNotEmpty) for (CreatorPage page in project.pages.pages) {
      page.widgets.readVariableValues(variableValues);
    }

    // await project.assetManager.precache(context);

    return project;
  }

  
  /// Create a new empty Project
  /// Requires a BuildContext to get the device size
  static Project create(BuildContext context, {
    required String title,
    PostSize? size,
    String? description,
    bool isTemplate = false,
  }) {
    Project project = Project(context);
    project.size = size ?? PostSizePresets.square.toSize();
    project.metadata = ProjectMetadata.create();
    project.title = title;
    if (description != null) project.description = description;
    project.isTemplate = isTemplate;
    return project;
  }

  Future<void> duplicate(BuildContext context, {
    String? title,
    String? description
  }) async {
    await manager.save(context, data: {
      ... data!,
      'id': Constants.generateID(),
      'title': '$title (copy)',
      'meta': ProjectMetadata.create().toJSON(),
      'is-template': data!['is-template'] ?? false,
    });
  }

  static Future<Project?> fromTemplate(BuildContext context, {
    required String uid,
    String? title,
    String? description,
    List<Map<String, dynamic>> variableValues = const []
  }) async {
    ProjectGlance glance = manager.getProjectGlance(uid);
    Map<String, dynamic> newData = {
      ... glance.data,
      'id': Constants.generateID(),
      'title': title ?? '${glance.title} (copy)',
      'description': description ?? glance.description,
      'meta': ProjectMetadata.create().toJSON(),
      'is-template': false,
    };
    return await Project.fromJSON(newData, context: context, variableValues: variableValues);
  }

  static void createNewProject(BuildContext context, PostSize size) async {
    AppRouter.push(context, page: ProjectMeta(size: size));
  }

}

class ProjectCreationException implements Exception {

  final String? code;
  final String message;
  final String? details;

  ProjectCreationException(this.message, {this.details, this.code});

}

Size getActualSizeFromPostSize(PostSize size, Size deviceSize) {
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