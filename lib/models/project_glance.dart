import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';

import '../rehmat.dart';

/// Lite version of project to reduce load times and heavy calculations
class ProjectGlance {

  ProjectGlance(this.id, this.data);

  final String id;

  final Map data;

  late final String? title;

  late final String? description;

  late final List<String> thumbnails;

  late final DateTime? created;

  late final DateTime? edited;

  late PostSize size;

  static ProjectGlance? build({
    required String id,
    required Map<String, dynamic> data
  }) {
    try {
      ProjectGlance project = ProjectGlance(id, data);
      project.title = data['title'];
      project.description = data['description'];
      project.thumbnails = data['thumbnails'];
      project.created = data['meta']['created'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['created']) : DateTime.now();
      project.edited = data['meta']['edited'] != null ? DateTime.fromMillisecondsSinceEpoch(data['meta']['edited']) : DateTime.now();
      project.size = PostSize.custom(width: data['size']['width'], height: data['size']['height'],);
      return project;
    } catch (e) {
      return null;
    }
  }

  /// This function renders full project from the lite (glance) version
  Future<Project?> renderFullProject(BuildContext context) async {
    try {
      Project project = Project(context, id: id, fromSaves: true);
      bool pageError = false;
      project.assetManager = await AssetManager.initialize(project, data: data);
      project.title = title;
      project.description = description;
      project.thumbnails = thumbnails;
      project.created = created;
      project.edited = edited;
      project.size = size;
      for (dynamic pageDate in data['pages']) {
        CreatorPage? page = CreatorPage.buildFromJSON(Map.from(pageDate), project: project);
        if (page != null) {
          project.pages.pages.add(page);
        } else {
          if (!pageError) pageError = true; // Set page error to true if not already
        }
      }
      project.pages.updateListeners();
      // if (pageError) Alerts.snackbar(context, text: 'Some pages could not be built');
      return project;
    } catch (e) {
      return null;
    }
  }

}

class PostViewModal extends StatefulWidget {
  
  const PostViewModal({Key? key, required this.project}) : super(key: key);

  final ProjectGlance project;

  @override
  _PostViewModalState createState() => _PostViewModalState();
}

class _PostViewModalState extends State<PostViewModal> {

  late ProjectGlance project;

  Project? originalPost;

  List<String>? files;

  List<File> thumbnails = [];
  late Future<bool> fileExists;

  bool isLoading = true;

  bool savedToGallery = false;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    getThumbnails();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Palette.of(context).surface,
          // borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  child: ClipRRect(
                    borderRadius: Constants.borderRadius,
                    child: Builder(
                      builder: (context) {
                        if (isLoading) {
                          return Container();
                        } else if (thumbnails.isNotEmpty) {
                          return OctoImage(
                          image: FileImage(thumbnails.first),
                          fit: BoxFit.cover,
                        );
                        } else {
                          return const Center(
                          child: Icon(
                            Icons.warning,
                            color: Colors.yellow,
                            size: 50,
                          )
                        );
                        }
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headline6,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          description ?? 'This project does not contain any description. Tap on edit button to add one.',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(height: 15),
            Wrap(
              runSpacing: 5,
              spacing: 5,
              children: [
                TextIconButton(
                  text: 'Open',
                  icon: Icons.open_in_new,
                  onPressed: () async {
                    if (originalPost == null) await createOriginalPost();
                    if (originalPost != null) AppRouter.replace(context, page: Create(project: originalPost!));
                  }
                ),
                TextIconButton(
                  text: 'Delete',
                  icon: Icons.delete_outline,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Project'),
                        content: const Text('Are you sure you want to delete this project?'),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text('Cancel')
                          ),
                          TextButton(
                            onPressed: () async {
                              if (originalPost == null) await createOriginalPost();
                              await handler.delete(context, project: originalPost, id: project.id);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete')
                          )
                        ],
                      ),
                    );
                  }
                ),
                TextIconButton(
                  text: 'Share',
                  icon: Icons.share_outlined,
                  onPressed: share
                ),
                TextIconButton(
                  text: savedToGallery ? 'Saved' : 'Save to Gallery',
                  icon: savedToGallery ? Icons.download_done : Icons.save_alt,
                  onPressed: savedToGallery ? () { } : () async => await saveToGallery()
                )
              ],
            ),
            Container(height: 20,)
          ],
        ),
      ),
    );
  }

  String get title {
    if (project.title == null || project.title!.trim().isEmpty) {
      return 'Untitled Project';
    } else {
      return project.title!;
    }
  }

  String? get description {
    if (project.description == null || project.description!.trim().isEmpty) {
      return null;
    } else {
      return project.description!;
    }
  }

  Future<void> getThumbnails() async {
    for (String thumbnail in project.thumbnails) {
      File file = File(thumbnail);
      if (await file.exists()) thumbnails.add(file);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> share() async {
    if (files == null) await saveToGallery();
    await Share.shareFiles(
      files!,
      text: project.title,
      subject: project.description,
    );
  }

  Future<void> saveToGallery() async {
    files = [];
    if (originalPost == null) {
      await createOriginalPost();
      if (originalPost == null) return;
    }
    await Spinner.fullscreen(
      context,
      task: () async {
        for (CreatorPage page in originalPost!.pages.pages.reversed) {
          String? path = await page.save(context, saveToGallery: true);
          if (path != null) files!.add(path);
        }
      }
    );
    savedToGallery = true;
    if (files!.length < originalPost!.pages.length) {
      Alerts.snackbar(context, text: 'Some of the pages could not be saved');
    } else {
      Alerts.snackbar(context, text: 'Saved to your gallery.');
    }
    setState(() { });
  }

  Future<void> createOriginalPost() async {
    await Spinner.fullscreen(
      context,
      task: () async {
        originalPost = await project.renderFullProject(context);
      }
    );
    setState(() { });
  }

}

class ProjectAtGlance extends StatefulWidget {

  ProjectAtGlance({
    Key? key,
    required this.project,
  }) : super(key: key);

  final ProjectGlance project;

  @override
  State<ProjectAtGlance> createState() => _ProjectAtGlanceState();
}

class _ProjectAtGlanceState extends State<ProjectAtGlance> {

  late ProjectGlance project;

  Project? originalPost;

  List<String>? files;

  List<File> thumbnails = [];
  late Future<bool> fileExists;

  bool isLoading = true;

  bool savedToGallery = false;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    getThumbnails();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 24,
              height: MediaQuery.of(context).size.width - 24,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    // offset: const Offset(0, 0),
                  ),
                ],
                borderRadius: Constants.borderRadius,
              ),
              child: ClipRRect(
                borderRadius: Constants.borderRadius,
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return Container();
                    } else if (thumbnails.isNotEmpty) {
                      return OctoImage(
                      image: FileImage(thumbnails.first),
                      fit: BoxFit.cover,
                    );
                    } else {
                      return const Center(
                      child: Icon(
                        Icons.warning,
                        color: Colors.yellow,
                        size: 50,
                      )
                    );
                    }
                  },
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Wrap(
                  runSpacing: 6,
                  spacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    TextIconButton(
                      text: 'Open',
                      icon: Icons.open_in_new,
                      padding: EdgeInsets.zero,
                      color: Colors.transparent,
                      onPressed: () async {
                        if (originalPost == null) await createOriginalPost();
                        if (originalPost != null) AppRouter.replace(context, page: Create(project: originalPost!));
                      }
                    ),
                    TextIconButton(
                      text: 'Delete',
                      icon: Icons.delete_outline,
                      padding: EdgeInsets.zero,
                      color: Colors.transparent,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Project'),
                            content: const Text('Are you sure you want to delete this project?'),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Cancel')
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (originalPost == null) await createOriginalPost();
                                  await handler.delete(context, project: originalPost, id: project.id);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete')
                              )
                            ],
                          ),
                        );
                      }
                    ),
                    TextIconButton(
                      text: 'Share',
                      icon: Icons.share_outlined,
                      padding: EdgeInsets.zero,
                      color: Colors.transparent,
                      onPressed: share
                    ),
                    TextIconButton(
                      text: savedToGallery ? 'Saved' : 'Save to Gallery',
                      icon: savedToGallery ? Icons.download_done : Icons.save_alt,
                      onPressed: savedToGallery ? () { } : () async => await saveToGallery(),
                      padding: EdgeInsets.zero,
                      color: Colors.transparent,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get title {
    if (project.title == null || project.title!.trim().isEmpty) {
      return 'Untitled Project';
    } else {
      return project.title!;
    }
  }

  String? get description {
    if (project.description == null || project.description!.trim().isEmpty) {
      return null;
    } else {
      return project.description!;
    }
  }

  Future<void> getThumbnails() async {
    for (String thumbnail in project.thumbnails) {
      File file = File(thumbnail);
      if (await file.exists()) thumbnails.add(file);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> share() async {
    if (files == null) await saveToGallery();
    await Share.shareFiles(
      files!,
      text: project.title,
      subject: project.description,
    );
  }

  Future<void> saveToGallery() async {
    files = [];
    if (originalPost == null) {
      await createOriginalPost();
      if (originalPost == null) return;
    }
    await Spinner.fullscreen(
      context,
      task: () async {
        for (CreatorPage page in originalPost!.pages.pages.reversed) {
          String? path = await page.save(context, saveToGallery: true);
          if (path != null) files!.add(path);
        }
      }
    );
    savedToGallery = true;
    if (files!.length < originalPost!.pages.length) {
      Alerts.snackbar(context, text: 'Some of the pages could not be saved');
    } else {
      Alerts.snackbar(context, text: 'Saved to your gallery.');
    }
    setState(() { });
  }

  Future<void> createOriginalPost() async {
    await Spinner.fullscreen(
      context,
      task: () async {
        originalPost = await project.renderFullProject(context);
      }
    );
    setState(() { });
  }

}