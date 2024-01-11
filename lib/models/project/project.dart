import 'package:flutter/material.dart';
import 'package:get/utils.dart';
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

  /// A Template Kit is a template that can be used to create posts using AI generated content
  late bool isTemplateKit;

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
  /// Saves the path of images to `images` list
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
    bool exportImages = true,
  }) async {
    Map<String, dynamic> data = await getJSON(context: context, quality: quality, exportImages: exportImages);

    await manager.save(context, project: this, data: data);
  }

  Future<Map<String, dynamic>> getJSON({
    bool publish = false,
    BuildContext? context,
    ExportQuality? quality,
    bool exportImages = true,
  }) async {
    Future? gallerySaveFuture;
    if (context != null && quality != null && exportImages) gallerySaveFuture = saveToGallery(context, quality: quality);

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
      'size': size.toJSON(),
      'pages': pageData,
      'meta': metadata.toJSON(),
      'is_template': isTemplate,
      'is_template_kit': isTemplateKit,
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
    project.size = PostSize.fromJSON(data['size']);
    project.thumbnail = null;
    project.data = data;
    project.metadata = ProjectMetadata.fromJSON(data['meta']);
    project.isTemplate = data['is_template'] ?? false;
    project.isTemplateKit = data['is_template_kit'] ?? false;
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

  static Future<Project?> fromTemplateKit({
    required Map<String, dynamic> data,
    required BuildContext context
  }) async {

    Project project = Project(context, fromSaves: true);

    project.id = Constants.generateID();
    project.title = data['title'];
    project.description = data['description'];
    project.images = List.from(data['images']).toDataType<String>();
    project.size = PostSize.fromJSON(data['size']);
    project.thumbnail = data['thumbnail'];
    project.data = data;
    project.metadata = ProjectMetadata.fromJSON(data['meta']);
    project.isTemplate = false;
    project.isTemplateKit = false;
    project.sizeTranslator = UniversalSizeTranslator(project: project);

    project.assetManager = await AssetManagerX.fromCompiled(project, data: data['assets']);

    for (Map pageKit in data['template-kit']['pages']) {
      String pageID = pageKit['id'];
      Map pageData = data['pages'].firstWhere((page) => page['id'] == pageID);

      CreatorPage? page = await CreatorPage.fromJSON(Map<String, dynamic>.from(pageData), project: project);
      if (page == null) continue;

      project.pages.pages.add(page);
    }

    for (CreatorPage page in project.pages.pages) {
      Map pageKit = data['template-kit']['pages'].firstWhere((pageKit) => pageKit['id'] == page.id);
      for (CreatorWidget widget in page.widgets.widgets) {
        if (widget is WidgetGroup) {
          for (CreatorWidget child in widget.widgets) {
            Map? variable = List.from(pageKit['variables']).firstWhereOrNull((variable) => variable['uid'] == child.uid);
            if (variable == null) continue;
            child.loadVariables(variable.toDataType<String, dynamic>());
          }
        } else {
          Map? variable = List.from(pageKit['variables']).firstWhereOrNull((variable) => variable['uid'] == widget.uid);
          if (variable == null) continue;
          widget.loadVariables(variable.toDataType<String, dynamic>());
        }
      }
    }

    project.pages.updateListeners();

    return project;
  }

  
  /// Create a new empty Project
  /// Requires a BuildContext to get the device size
  static Project create(BuildContext context, {
    required String title,
    PostSize? size,
    String? description,
    bool isTemplate = false,
    bool isTemplateKit = false,
  }) {
    Project project = Project(context);
    project.size = size ?? PostSizePresets.square.toSize();
    project.metadata = ProjectMetadata.create();
    project.title = title;
    if (description != null) project.description = description;
    project.isTemplate = isTemplate;
    project.isTemplateKit = isTemplateKit;
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
    required String id,
    required String title,
    String? description,
    List<Map<String, dynamic>> variableValues = const []
  }) async {
    ProjectGlance glance = manager.getProjectGlance(id);
    String _newID = Constants.generateID();

    String path = await pathProvider.generateRelativePath('/Render Projects/$id/');
    Directory dir = Directory(path);
    if (await dir.exists()) {
      String newPath = await pathProvider.generateRelativePath('/Render Projects/${_newID}/');
      Directory newDir = Directory(newPath);
      await newDir.create(recursive: true);
      await dir.copyTo(Directory(newPath));
    }

    Map<String, dynamic> newData = {
      ... glance.data,
      'id': _newID,
      'title': title,
      'description': description ?? glance.description,
      'meta': ProjectMetadata.create().toJSON(),
      'is-template': false,
      'is-template-kit': false,
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