import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:render_studio/rehmat.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProjectsView extends StatefulWidget {

  const ProjectsView({
    Key? key,
    this.showWelcomeMessage = true,
    this.limit,
    this.showOnlyTemplates = false
  }) : super(key: key);

  /// When true, a welcome message will be shown if there are no projects.
  final bool showWelcomeMessage;

  final bool showOnlyTemplates;

  /// Limit the number of projects displayed.
  final int? limit;

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {

  final Key key = GlobalKey();
  final ScrollController scrollController = ScrollController();
  late bool isShowingOnlyTemplates;

  @override
  void initState() {
    manager.addListener(onProjectsUpdate);
    super.initState();
    isShowingOnlyTemplates = widget.showOnlyTemplates;
  }

  @override
  void dispose() {
    manager.removeListener(onProjectsUpdate);
    super.dispose();
  }

  didUpdateWidget(ProjectsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showOnlyTemplates != widget.showOnlyTemplates) {
      setState(() {
        isShowingOnlyTemplates = widget.showOnlyTemplates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ProjectGlance> projects = manager.projects;
    if (isShowingOnlyTemplates) {
      projects = projects.where((glance) => glance.isTemplate).toList();
    }

    int count;
    if (widget.limit != null) {
      if (widget.limit! < projects.length) count = widget.limit!;
      else count = projects.length;
    } else count = projects.length;

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
            Text(
              'Your design journey starts here.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // TextButton.icon(
            //   onPressed: () => AppRouter.push(context, page: CreateProject()),
            //   icon: Icon(RenderIcons.arrow_right_2),
            //   label: Text(
            //     'Get Started',
            //     style: TextStyle(
            //     )
            //   )
            // )
            SizedBox(height: 6),
            PrimaryButton(
              onPressed: () => AppRouter.push(context, page: CreateProject()),
              child: Text('Get Started'),
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12
              ),
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
              isShowingOnlyTemplates ? 'Templates' : 'Projects',
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
                key: ValueKey(projects[index].id),
                glance: projects[index]
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

  void onProjectsUpdate() {
    if (mounted) setState(() {});
  }

}