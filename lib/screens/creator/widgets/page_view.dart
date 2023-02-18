import 'dart:ui';
import 'package:animate_do/animate_do.dart';
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

  List<int> selections = [];

  @override
  void initState() {
    project = widget.project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.of(context).background.withOpacity(0.25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(RenderIcons.close)
                  ),
                  Spacer(),
                  if (selections.length == 1) IconButton(
                    onPressed: () {
                      setState(() {
                        project.pages.duplicate(selections.first);
                      });
                      selections.clear();
                    },
                    icon: Icon(RenderIcons.duplicate)
                  ),
                  if (selections.length > 0) IconButton(
                    onPressed: () async {
                      bool delete = await Alerts.showConfirmationDialog(
                        context,
                        title: 'Delete ${selections.length} page${selections.length > 1 ? 's' : ''}?',
                        message: 'Do you want to delete ${selections.length} page${selections.length > 1 ? 's' : ''} and ${selections.length > 1 ? 'their' : 'its'} content from this project? This action cannot be undone.',
                        isDestructive: true,
                        confirmButtonText: 'Delete'
                      );
                      if (delete) {
                        setState(() {
                          project.pages.delete(selections);
                        });
                        selections.clear();
                      }
                    },
                    icon: Icon(RenderIcons.delete)
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(6),
              sliver: SliverMasonryGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Stack(
                      children: [
                        InkWellButton(
                          radius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              if (selections.contains(index)) selections.remove(index);
                              else selections.add(index);
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                )
                              ],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: FittedBox(
                                // scale: 1,
                                alignment: Alignment.center,
                                child: project.pages.pages[index].build(context, isInteractive: false),
                              ),
                            ),
                          ),
                        ),
                        if (selections.contains(index)) Positioned(
                          top: 12,
                          right: 12,
                          child: FadeInUp(
                            from: 20,
                            duration: Duration(milliseconds: 150),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Palette.of(context).primary,
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: SizedBox(
                                width: 25,
                                height: 25,
                                child: Center(
                                  child: Icon(
                                    RenderIcons.done,
                                    color: Palette.of(context).onPrimary,
                                    size: 15,
                                  ),
                                ),
                              )
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  childCount: project.pages.length
                ),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: Constants.of(context).bottomPadding
              ),
            ),
          ],
        ),
      ),
    );
  }

}