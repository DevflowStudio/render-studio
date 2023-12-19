import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:render_studio/creator/helpers/universal_size_translator.dart';
import 'package:render_studio/models/encryptor.dart';
import 'package:supercharged/supercharged.dart';
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

  Future<void> save(BuildContext context, {
    bool saveToGallery = false,
    /// The quality of the exported image. Only used if [saveToGallery] is true
    ExportQuality quality = ExportQuality.onex,
  }) async {

    DateTime startTime, endTime;

    images.clear();

    startTime = DateTime.now();
    for (CreatorPage page in pages.pages) {
      String? thumbnail = await page.save(context, saveToGallery: saveToGallery, quality: quality);
      if (thumbnail != null) images.add(thumbnail);
      else issues.add(Exception('Failed to render page ${pages.pages.indexOf(page) + 1}'));
    }
    endTime = DateTime.now();
    print('Time for page rendering: ${endTime.difference(startTime).inMilliseconds} ms');

    thumbnail = images.firstOrNull;

    List<Map<String, dynamic>> pageData = [];
    List<Map<String, dynamic>> variables = [];

    for (CreatorPage page in pages.pages) {
      pageData.add(page.toJSON(BuildInfo(buildType: BuildType.save)));
      variables.addAll(page.widgets.getVariables());
    }

    startTime = DateTime.now();
    Map<String, dynamic> assets = await assetManager.getCompiled();
    endTime = DateTime.now();
    print('Time for asset compilation: ${endTime.difference(startTime).inMilliseconds} ms');

    print(variables);

    Map<String, dynamic> data = {
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
      'variables': variables,
    };

    startTime = DateTime.now();
    String jsonStr = json.encode(data);
    final encryptedData = Encryptor.encryptAES(jsonStr);
    endTime = DateTime.now();
    print('Time for encryption: ${endTime.difference(startTime).inMilliseconds} ms');

    Map<String, dynamic> projectData = {
      'rsProj': encryptedData,
      'assets': assets,
    };
    final projectJson = projectData.toJSON();

    startTime = DateTime.now();
    String savePath = '/Render Projects/$title.rsproj';
    await pathProvider.saveToDocumentsDirectory(savePath, text: projectJson);
    endTime = DateTime.now();
    print('Time for file saving: ${endTime.difference(startTime).inMilliseconds} ms');

    Map<String, dynamic> glance = {
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
      'pages': pages.length,
      'meta': metadata.toJSON(),
      'is-template': isTemplate,
      'variables': variables,
      'save-path': savePath,
    };

    startTime = DateTime.now();
    await manager.save(context, project: this, glance: glance);
    endTime = DateTime.now();
    print('Time for project saving: ${endTime.difference(startTime).inMilliseconds} ms');
    
  }

  static Future<Project?> fromSave({
    File? file,
    String? path,
    Map<String, dynamic>? data,
    required BuildContext context,
    List<Map<String, dynamic>> variableValues = const []
  }) async {
    assert(file != null || path != null || data != null);

    DateTime startTime, endTime;

    Map<String, dynamic> projectData;

    if (path != null && file == null) {
      startTime = DateTime.now();
      file = File(await pathProvider.generateRelativePath(path));
      endTime = DateTime.now();
      print('Time for file/path processing: ${endTime.difference(startTime).inMilliseconds} ms');
    }

    if (data == null) {
      startTime = DateTime.now();
      String dataString = await file!.readAsString();
      data = json.decode(dataString);
      endTime = DateTime.now();
      print('Time for file reading: ${endTime.difference(startTime).inMilliseconds} ms');
    }

    startTime = DateTime.now();
    String decryptedData = Encryptor.decryptAES(data!['rsProj']);
    projectData = json.decode(decryptedData);
    endTime = DateTime.now();
    print('Time for decryption: ${endTime.difference(startTime).inMilliseconds} ms');

    Project project = Project(context, fromSaves: true);

    project.id = projectData['id'];
    project.title = projectData['title'];
    project.description = projectData['description'];
    project.images = [];
    project.size = PostSize.custom(width: projectData['size']['width'], height: projectData['size']['height'],);
    project.thumbnail = null;
    project.data = projectData;
    project.metadata = ProjectMetadata.fromJSON(projectData['meta']);
    project.isTemplate = projectData['is-template'] ?? false;
    project.sizeTranslator = UniversalSizeTranslator(project: project);

    startTime = DateTime.now();
    project.assetManager = await AssetManagerX.fromCompiled(project, data: data['assets']);
    endTime = DateTime.now();

    startTime = DateTime.now();
    for (Map pageDate in projectData['pages']) {
      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageDate), project: project);
      if (page != null) project.pages.pages.add(page);
    }
    endTime = DateTime.now();
    print('Time for page building: ${endTime.difference(startTime).inMilliseconds} ms');

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
    project.sizeTranslator = UniversalSizeTranslator(project: project);
    project.assetManager = AssetManagerX.create(project);
    return project;
  }

  Future<void> duplicate(BuildContext context, {
    String? title,
    String? description
  }) async {
    // TODO: Recreate this function
    // await manager.save(context, data: {
    //   ... data!,
    //   'id': Constants.generateID(),
    //   'title': '${title ?? this.title ?? 'Unnamed'} (copy)',
    //   'description': description ?? this.description,
    //   'meta': ProjectMetadata.create().toJSON(),
    //   'is-template': data!['is-template'] ?? false,
    // });
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