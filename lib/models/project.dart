import 'package:flutter/material.dart';

import '../rehmat.dart';

class Project {

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
  
  List<String> thumbnails = [];

  late AssetManager assetManager;

  bool editorVisible = true;

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

  Future<Map<String, dynamic>> toJSON(BuildContext context, {
    bool restoring = false,
    bool updateThumbnails = true
  }) async {

    List<Map<String, dynamic>> pageData = [];
    for (var page in pages.pages) {
      pageData.add(page.toJSON());
    }

    // Before saving the project, create thumbnails for all the pages and save them
    if (updateThumbnails) {
      thumbnails.clear();
      for (CreatorPage page in pages.pages) {
        if (!restoring) pages.controller.animateToPage(pages.pages.indexOf(page), duration: Constants.animationDuration, curve: Curves.easeInOut);
        String? thumbnail = await page.save(context);
        if (thumbnail != null) thumbnails.add(thumbnail);
      }
    }

    Map<String, dynamic> json = {
      'id': id,
      'title': title,
      'description': description,
      'thumbnails': thumbnails,
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

  // static Project? build({
  //   required String id,
  //   required Map<String, dynamic> data
  // }) {
  //   try {
  //     Project project = Project(id: id,fromSaves: true);
  //     bool pageError = false;
  //     project.data = data;
  //     project.title = data['title'];
  //     project.description = data['description'];
  //     project.thumbnails = data['thumbnails'];
  //     project.created = data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();
  //     project.edited = data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();
  //     project.size = PostSize.custom(width: data['size']['width'], height: data['size']['height'],);
  //     for (dynamic pageDate in data['pages']) {
  //       CreatorPage? page = CreatorPage.buildFromJSON(Map.from(pageDate), project: project);
  //       if (page != null) {
  //         project.pages.pages.add(page);
  //       } else {
  //         if (!pageError) pageError = true; // Set page error to true if not already
  //       }
  //     }
  //     project.pages.updateListeners();
  //     // if (pageError) Alerts.snackbar(context, text: 'Some pages could not be built');
  //     return project;
  //   } catch (e) { }
  // }

  static void create(BuildContext context) async {
    Project project = Project(context);
    project.assetManager = await AssetManager.initialize(project, data: {});
    AppRouter.push(context, page: Information(project: project, isNewPost: true,));
  }

}