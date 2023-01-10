import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';
import 'package:skeletons/skeletons.dart';
import '../../../rehmat.dart';

class ProjectAtGlanceModal extends StatefulWidget {

  const ProjectAtGlanceModal({
    super.key,
    required this.glance
  });

  final ProjectGlance glance;

  @override
  State<ProjectAtGlanceModal> createState() => _ProjectAtGlanceModalState();
}

class _ProjectAtGlanceModalState extends State<ProjectAtGlanceModal> {
  
  late final ProjectGlance glance;

  Project? project;

  List<String>? files;

  late Future<bool> fileExists;

  bool isLoading = true;

  bool savedToGallery = false;

  @override
  void initState() {
    super.initState();
    glance = widget.glance;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                  maxWidth: MediaQuery.of(context).size.width - 24
                ),
                child: Stack(
                  children: [
                    OctoImage(
                      image: FileImage(File(glance.thumbnail!))
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FadeOut(
                        delay: Duration(seconds: 3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Palette.of(context).background.withOpacity(0.2)
                              ),
                              child: Center(
                                child: Text(
                                  '${glance.nPages} Page${glance.nPages > 1 ? 's' : ''}',
                                )
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Spacer(),
            ClipRRect(
              child: Container(
                color: Palette.of(context).background.withOpacity(0.7),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        buildIconButton(
                          icon: RenderIcons.edit,
                          label: 'Edit',
                          onPressed: open,
                          tooltip: 'Edit Project'
                        ),
                        if (glance.images.isNotEmpty) buildIconButton(
                          icon: RenderIcons.share,
                          label: 'Share',
                          onPressed: share,
                          tooltip: 'Share Project'
                        ),
                        buildIconButton(
                          icon: RenderIcons.duplicate,
                          label: 'Duplicate',
                          onPressed: duplicate,
                          tooltip: 'Duplicate this Project'
                        ),
                        buildIconButton(
                          icon: RenderIcons.delete,
                          label: 'Delete',
                          onPressed: delete,
                          tooltip: 'Delete Project'
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String get title => glance.title;

  String? get description {
    if (glance.description == null || glance.description!.trim().isEmpty) {
      return null;
    } else {
      return glance.description!;
    }
  }

  Future<void> open() async {
    await createOriginalPost();
    AppRouter.replace(context, page: Create(project: project!));
  }

  Future<void> share() async {
    List<XFile> files = [];
    for (String path in glance.images) files.add(XFile(pathProvider.generateRelativePath(path)));
    ShareResult result = await Share.shareXFiles(
      files,
      subject: glance.title,
      text: glance.description
    );
    analytics.logShare(
      contentType: 'image',
      itemId: 'project',
      method: result.raw,
    );
  }

  Future<void> duplicate() async {
    await Spinner.fullscreen(
      context,
      task: () async {
        await createOriginalPost();
        await project!.duplicate(context);
      }
    );
    Navigator.of(context).pop();
  }

  Future<void> delete() async {
    bool delete = await Alerts.showConfirmationDialog(
      context,
      title: 'Delete Project',
      message: 'Are you sure you want to delete this project?',
      isDestructive: true
    );
    if (delete) {
      if (project == null) await createOriginalPost();
      await manager.delete(context, project: project, id: glance.id);
      Navigator.of(context).pop();
    }
  }

  Future<void> saveToGallery() async {
    files = [];
    await Spinner.fullscreen(
      context,
      task: () async {
        await createOriginalPost();
        savedToGallery = await project!.saveToGallery(context);
      }
    );
    setState(() { });
  }

  Future<void> createOriginalPost() async {
    if (project != null) return;
    await Spinner.fullscreen(
      context,
      task: () async {
        project = await glance.renderFullProject(context);
      }
    );
    setState(() { });
  }

  Widget buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String? tooltip
  }) => Expanded(
    child: GestureDetector(
      onTap: () {
        onPressed();
        TapFeedback.light();
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 12
        ),
        child: Tooltip(
          message: tooltip,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                SizedBox(height: 4,),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );

}

class ProjectAtGlance extends StatefulWidget {

  ProjectAtGlance({
    Key? key,
    required this.glance,
  }) : super(key: key);

  final ProjectGlance glance;

  @override
  State<ProjectAtGlance> createState() => _ProjectAtGlanceState();
}

class _ProjectAtGlanceState extends State<ProjectAtGlance> {

  late ProjectGlance glance;

  Project? originalPost;

  List<String>? files;

  late Future<bool> fileExists;

  bool isLoading = true;

  bool savedToGallery = false;

  @override
  void initState() {
    super.initState();
    glance = widget.glance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Project'),
            isExpandable: false,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 1,
                        // offset: const Offset(0, 0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    child: Hero(
                      tag: 'project-${glance.id}',
                      child: OctoImage(
                        image: FileImage(File(glance.thumbnail ?? '')),
                        errorBuilder: (context, error, stackTrace) => SizedBox(
                          height: MediaQuery.of(context).size.width - 24,
                          child: Container(
                            color: Palette.of(context).surfaceVariant,
                            child: Icon(
                              RenderIcons.warning,
                              color: Colors.yellow,
                              size: 50,
                            )
                          ),
                        ),
                        placeholderBuilder: (context) => SkeletonAvatar(),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 24,
                  bottom: 6,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                ),
                child: Text(
                  description ?? 'This project does not have any description.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Container(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                  child: Wrap(
                    runSpacing: 5,
                    spacing: 5,
                    children: [
                      TextIconButton(
                        text: 'Open',
                        icon: RenderIcons.open,
                        onPressed: () async {
                          if (originalPost == null) await createOriginalPost();
                          if (originalPost != null) AppRouter.replace(context, page: Create(project: originalPost!));
                        }
                      ),
                      TextIconButton(
                        text: 'Delete',
                        icon: RenderIcons.delete,
                        onPressed: () async {
                          bool delete = await Alerts.showConfirmationDialog(
                            context,
                            title: 'Delete Project',
                            message: 'Are you sure you want to delete this project?',
                            isDestructive: true
                          );
                          if (delete) {
                            if (originalPost == null) await createOriginalPost();
                            await manager.delete(context, project: originalPost, id: glance.id);
                            Navigator.of(context).pop();
                          }
                        }
                      ),
                      TextIconButton(
                        text: 'Share',
                        icon: RenderIcons.share,
                        onPressed: share
                      ),
                      TextIconButton(
                        text: savedToGallery ? 'Saved' : 'Save to Gallery',
                        icon: savedToGallery ? RenderIcons.done : RenderIcons.download,
                        onPressed: savedToGallery ? () { } : () async => await saveToGallery()
                      )
                    ],
                  ),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

  String get title => glance.title;

  String? get description {
    if (glance.description == null || glance.description!.trim().isEmpty) {
      return null;
    } else {
      return glance.description!;
    }
  }

  Future<void> share() async {
    // if (files == null) await saveToGallery();
    // await Share.shareFiles(
    //   files!,
    //   text: glance.title,
    //   subject: glance.description,
    // );
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
        savedToGallery = await originalPost!.saveToGallery(context);
      }
    );
    setState(() { });
  }

  Future<void> createOriginalPost() async {
    await Spinner.fullscreen(
      context,
      task: () async {
        originalPost = await glance.renderFullProject(context);
      }
    );
    setState(() { });
  }

}

class ProjectGlanceCard extends StatelessWidget {

  const ProjectGlanceCard({
    Key? key,
    required this.glance
  }) : super(key: key);

  final ProjectGlance glance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        TapFeedback.light();
        // AppRouter.push(context, page: ProjectAtGlance(glance: glance));
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          barrierColor: Palette.of(context).background.withOpacity(0.25),
          backgroundColor: Colors.transparent,
          builder: (context) => ProjectAtGlanceModal(glance: glance),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'project-${glance.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: OctoImage(
                  image: FileImage(File(glance.thumbnail ?? '')),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RenderIcons.warning),
                        SizedBox(height: 3),
                        const Text('404 - Not Found'),
                      ],
                    ),
                  ),
                  placeholderBuilder: (context) => LayoutBuilder(
                    builder: (context, constraints) {
                      Size parentSize = constraints.biggest;
                      return SizedBox(
                        width: parentSize.width,
                        height: parentSize.width / glance.size.size.aspectRatio,
                        child: Center(
                        ),
                      );
                    }
                  )
                ),
              ),
            ),
            Divider(
              height: 0,
              endIndent: 0,
              indent: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 9,
                bottom: 12,
                left: 12,
                right: 12
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    glance.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    getTimeAgo(glance.edited ?? glance.created!),
                    style: Theme.of(context).textTheme.caption?.copyWith(
                      color: Theme.of(context).colorScheme.secondary
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}