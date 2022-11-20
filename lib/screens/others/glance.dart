import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_io/io.dart';
import 'package:skeletons/skeletons.dart';
import '../../../rehmat.dart';

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
      appBar: AppBar(
        leading: NewBackButton(),
      ),
      body: ListView(
        children: [
          SizedBox(height: 12,),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 24,
              height: MediaQuery.of(context).size.width - 24,
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
                borderRadius: BorderRadius.circular(30),
                child: OctoImage(
                  image: FileImage(File(glance.thumbnail ?? '')),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Palette.of(context).surfaceVariant,
                    child: Icon(
                      RenderIcons.warning,
                      color: Colors.yellow,
                      size: 50,
                    )
                  ),
                  placeholderBuilder: (context) => SkeletonAvatar(),
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
                                await manager.delete(context, project: originalPost, id: glance.id);
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
    if (files == null) await saveToGallery();
    await Share.shareFiles(
      files!,
      text: glance.title,
      subject: glance.description,
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
        savedToGallery = await originalPost!.saveToGallery();
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