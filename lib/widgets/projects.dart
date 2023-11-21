import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:render_studio/rehmat.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 24
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Your design journey starts here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextButton.icon(
              onPressed: () async {
                PostSizePresets preset = PostSizePresets.square;
                await Alerts.picker(
                  context,
                  children: [
                    for (PostSizePresets preset in PostSizePresets.values) Text(preset.title)
                  ],
                  onSelectedItemChanged: (value) {
                    preset = PostSizePresets.values[value];
                  },
                );
                Project.createNewProject(context, preset.toSize());
              },
              icon: Icon(RenderIcons.arrow_right_2),
              label: Text('Get Started')
            )
          ],
        ),
      ),
    );
    return MultiSliver(
      children: [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 6,
            right: 6,
            bottom: 9
          ),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Projects',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1,
                color: Palette.of(context).onSurfaceVariant
              )
            )
          ),
        ),
        SliverPadding(
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
        ),
      ],
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