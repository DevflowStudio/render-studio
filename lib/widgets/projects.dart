import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:octo_image/octo_image.dart';
import 'package:render_studio/rehmat.dart';
import 'package:universal_io/io.dart';

class ProjectsView extends StatefulWidget {

  const ProjectsView({
    Key? key,
    this.showWelcomeMessage = true,
    this.limit
  }) : super(key: key);

  /// When true, a welcome message will be shown if there are no projects.
  final bool showWelcomeMessage;

  /// Limit the number of projects displayed.
  final int? limit;

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {

  final Key key = GlobalKey();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    manager.addListener(onProjectsUpdate);
    super.initState();
  }

  @override
  void dispose() {
    manager.removeListener(onProjectsUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (manager.projects.isEmpty && widget.showWelcomeMessage) return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Create your first project',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Container(height: 10,),
            SecondaryButton(
              child: Text('Create Project'),
              onPressed: () => Project.create(context),
            )
          ],
        ),
      ),
    );
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      sliver: SliverMasonryGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProjectGlanceCard(glance: manager.projects[index]),
          childCount: count,
        ),
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Constants.of(context).crossAxisCount,
        ),
      ),
    );
  }

  int get count {
    if (widget.limit != null) {
      if (widget.limit! < manager.projects.length) widget.limit;
      else manager.projects.length;
    }
    return manager.projects.length;
  }

  void onProjectsUpdate() {
    if (mounted) setState(() {});
  }

}

class ProjectGlanceCard extends StatefulWidget {

  const ProjectGlanceCard({
    Key? key,
    required this.glance
  }) : super(key: key);

  final ProjectGlance glance;

  @override
  State<ProjectGlanceCard> createState() => _ProjectGlanceCardState();
}

class _ProjectGlanceCardState extends State<ProjectGlanceCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        TapFeedback.light();
        AppRouter.push(context, page: ProjectAtGlance(glance: widget.glance));
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Constants.borderRadius.topLeft),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width,
                  maxWidth: MediaQuery.of(context).size.width/2
                ),
                child: OctoImage(
                  image: FileImage(File(widget.glance.thumbnail ?? '')),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning),
                        SizedBox(height: 3),
                        const Text('404 - Not Found'),
                      ],
                    ),
                  ),
                  placeholderBuilder: (context) => Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Spinner(
                        strokeWidth: 2,
                        adaptive: true,
                      )
                    ),
                  ),
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
                    widget.glance.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    getTimeAgo(widget.glance.edited ?? widget.glance.created!),
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