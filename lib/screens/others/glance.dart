import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';
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
    return SafeArea(
      bottom: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(RenderIcons.close)
                )
              ],
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.translucent,
                child: SizedBox.expand(),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
                maxWidth: MediaQuery.of(context).size.width - 24
              ),
              child: Stack(
                children: [
                  Hero(
                    tag: 'project-${glance.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: OctoImage(
                        image: FileImage(File(glance.thumbnail!)),
                      ),
                    ),
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
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.translucent,
                child: SizedBox.expand(),
              ),
            ),
            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: ClipRRect(
                child: Container(
                  color: Palette.of(context).background.withOpacity(0.7),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: Constants.of(context).bottomPadding,
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
              ),
              secondChild: Padding(
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: Constants.of(context).bottomPadding,
                ),
                child: Center(
                  child: SpinKitThreeInOut(
                    color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey[800] : Colors.grey[200],
                    size: 20,
                  )
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
    AppRouter.replace(context, page: Studio(project: project!));
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
    setState(() {
      isLoading = true;
    });
    await createOriginalPost();
    await project!.duplicate(context);
    setState(() {
      isLoading = false;
    });
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
    setState(() {
      isLoading = true;
    });
    project = await glance.renderFullProject(context);
    setState(() {
      isLoading = false;
    });
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
        Alerts.showModal(context, child: ProjectAtGlanceModal(glance: glance));
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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