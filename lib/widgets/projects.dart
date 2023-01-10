import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:render_studio/rehmat.dart';

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
              'Welcome',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'You have no projects yet.',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Container(height: 10,),
            PrimaryButton(
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
          (context, index) => ProjectGlanceCard(
            key: ValueKey(manager.projects[index].id),
            glance: manager.projects[index]
          ),
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