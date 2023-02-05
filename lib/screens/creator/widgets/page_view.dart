import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../rehmat.dart';

class ProjectPageView extends StatefulWidget {

  const ProjectPageView({super.key, required this.project});

  final Project project;

  @override
  State<ProjectPageView> createState() => _ProjectPageViewState();
}

class _ProjectPageViewState extends State<ProjectPageView> {

  late final Project project;

  @override
  void initState() {
    project = widget.project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(RenderIcons.close)
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(6),
              sliver: SliverMasonryGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return CupertinoContextMenu(
                      actions: [
                        CupertinoContextMenuAction(
                          child: Text('Delete'),
                          onPressed: () {
                          },
                          isDestructiveAction: true,
                        )
                      ],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: FittedBox(
                          // scale: 1,
                          alignment: Alignment.center,
                          child: project.pages.pages[index].build(context, isInteractive: false),
                        ),
                      ),
                    );
                  },
                  childCount: project.pages.length
                ),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
            )
          ],
        ),
      ),
    );
  }

}