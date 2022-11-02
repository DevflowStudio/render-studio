import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class ProjectIssues extends StatefulWidget {

  ProjectIssues({
    Key? key,
    required this.project
  }) : super(key: key);

  final Project project;

  @override
  State<ProjectIssues> createState() => _ProjectIssuesState();
}

class _ProjectIssuesState extends State<ProjectIssues> {

  late Project project;

  @override
  void initState() {
    project = widget.project;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: NewBackButton(),
            pinned: true,
            centerTitle: false,
            expandedHeight: Constants.appBarExpandedHeight,
            flexibleSpace: RenderFlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              title: Text(
                'Issues',
                // style: AppTheme.flexibleSpaceBarStyle
              ),
              titlePaddingTween: EdgeInsetsTween(
                begin: const EdgeInsets.only(
                  left: 12.0,
                  bottom: 16
                ),
                end: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 15
                )
              ),
              stretchModes: const [
                StretchMode.fadeTitle,
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => setState(() {
                  project.issues.clear();
                }),
                child: Text('Clear All')
              )
            ],
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                Exception exception = project.issues[index];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      height: 0,
                      indent: 0,
                      endIndent: 0,
                    ),
                    if (exception is WidgetCreationException) ListTile(
                      title: Text('Rendering Error'),
                      subtitle: Text(exception.message),
                    ) else ListTile(
                      title: Text('[Unknown Issues]'),
                      subtitle: Text(exception.toString()),
                    )
                  ],
                );
              },
              childCount: project.issues.length
            )
          )
        ],
      ),
    );
  }

}