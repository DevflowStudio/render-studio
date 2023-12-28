import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:render_studio/creator/helpers/universal_size_translator.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

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

  /// A TemplateX is a template that can be used to create posts using AI generated content
  late bool isTemplateX;

  late PostSize size;

  late Size deviceSize;

  late AssetManagerX assetManager;
  
  List<String> images = [];
  String? thumbnail;

  Map<String, dynamic>? data;

  List<Exception> issues = [];

  /// This is the actual size of the page
  /// and will be used to export the image
  Size get contentSize => getActualSizeFromPostSize(size, deviceSize);

  late UniversalSizeTranslator sizeTranslator;

  /// Renders and saves each of the page as a png file to the device gallery
  ///
  /// Returns false if an issue is encountered in any of the pages
  Future<void> saveToGallery(BuildContext context, {
    ExportQuality quality = ExportQuality.onex,
    bool saveToGallery = true,
  }) async {
    // Delete the thumbnails directory and recreate it
    String path = await pathProvider.generateRelativePath(imagesSavePath);
    Directory dir = Directory(path);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true); // Recreate the directory

    images.clear();
    for (CreatorPage page in pages.pages) {
      String? _image = await page.save(context, saveToGallery: saveToGallery, quality: quality, path: imagesSavePath);
      if (_image != null) images.add(_image);
    }
  }

  void resize(PostSize size) {
    for (CreatorPage page in pages.pages) {
      page.onSizeChange(this.size, size);
    }
    this.size = size;
    notifyListeners();
  }

  Future<void> save(BuildContext context, {
    /// The quality of the exported image. Only used if [saveToGallery] is true
    ExportQuality quality = ExportQuality.onex,
    /// If `true`, the assets and thumbnails will be uploaded to the cloud and the cloud url will be used instead of the file path
    bool publish = false,
  }) async {
    Map<String, dynamic> data = await getJSON(context: context, publish: publish, quality: quality);

    await manager.save(context, project: this, data: data);
  }

  Future<Map<String, dynamic>> getJSON({
    bool publish = false,
    BuildContext? context,
    ExportQuality? quality
  }) async {
    Future? gallerySaveFuture;
    if (context != null && quality != null) gallerySaveFuture = saveToGallery(context, quality: quality);
    
    Future<Map<String, dynamic>> assetsFuture = assetManager.getCompiled(upload: publish);

    if (gallerySaveFuture != null) {
      await Future.wait([gallerySaveFuture, assetsFuture]);
    } else {
      await assetsFuture;
    }

    thumbnail = images.firstOrNull;
    Map<String, dynamic> assets = await assetsFuture;

    List<Map<String, dynamic>> pageData = [];

    for (CreatorPage page in pages.pages) {
      pageData.add(page.toJSON(BuildInfo(buildType: BuildType.save)));
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'size': {
        'type': size.title,
        'height': size.size.height,
        'width': size.size.width,
      },
      'pages': pageData,
      'meta': metadata.toJSON(),
      'is-template': isTemplate,
      'is-template-x': isTemplateX,
      'assets': assets,
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  static Future<Project?> fromSave({
    required Map<String, dynamic> data,
    required BuildContext context,
    List<Map<String, dynamic>> variableValues = const []
  }) async {

    Project project = Project(context, fromSaves: true);

    project.id = data['id'];
    project.title = data['title'];
    project.description = data['description'];
    project.images = [];
    project.size = PostSize.custom(width: data['size']['width'], height: data['size']['height'],);
    project.thumbnail = null;
    project.data = data;
    project.metadata = ProjectMetadata.fromJSON(data['meta']);
    project.isTemplate = data['is-template'] ?? false;
    project.isTemplateX = data['is-template-x'] ?? false;
    project.sizeTranslator = UniversalSizeTranslator(project: project);

    project.assetManager = await AssetManagerX.fromCompiled(project, data: data['assets']);

    for (Map pageDate in data['pages']) {
      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageDate), project: project);
      if (page != null) project.pages.pages.add(page);
    }

    project.pages.updateListeners();

    if (variableValues.isNotEmpty) for (CreatorPage page in project.pages.pages) {
      page.widgets.readVariableValues(variableValues);
    }

    return project;
  }

  
  /// Create a new empty Project
  /// Requires a BuildContext to get the device size
  static Project create(BuildContext context, {
    required String title,
    PostSize? size,
    String? description,
    bool isTemplate = false,
    bool isTemplateX = false,
  }) {
    Project project = Project(context);
    project.size = size ?? PostSizePresets.square.toSize();
    project.metadata = ProjectMetadata.create();
    project.title = title;
    if (description != null) project.description = description;
    project.isTemplate = isTemplate;
    project.isTemplateX = isTemplateX;
    project.sizeTranslator = UniversalSizeTranslator(project: project);
    project.assetManager = AssetManagerX.create(project);
    return project;
  }

  Future<void> duplicate(BuildContext context, {
    String? title,
    String? description
  }) async {
    String _newID = Constants.generateID();

    Map<String, dynamic> newData = {
      ... data!,
      'id': _newID,
      'title': '${title ?? this.title ?? 'Unnamed'} (copy)',
      'description': description ?? this.description,
      'meta': ProjectMetadata.create().toJSON(),
    };

    // Duplicate the project directory
    String path = await pathProvider.generateRelativePath('/Render Projects/$id/');
    Directory dir = Directory(path);
    if (await dir.exists()) {
      String newPath = await pathProvider.generateRelativePath('/Render Projects/${_newID}/');
      Directory newDir = Directory(newPath);
      await newDir.create(recursive: true);
      await dir.copyTo(Directory(newPath));
    }

    Project? duplicate = await Project.fromSave(data: newData, context: context);
    if (duplicate == null) return;

    await manager.save(context, project: duplicate, data: newData);
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
    return await Project.fromSave(data: newData, context: context, variableValues: variableValues);
  }

  static void createNewProject(BuildContext context, PostSize size) async {
    AppRouter.push(context, page: ProjectMeta(size: size));
  }

  String get assetSavePath => '/Render Projects/$id/assets/';

  String get imagesSavePath => '/Render Projects/$id/images/';

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