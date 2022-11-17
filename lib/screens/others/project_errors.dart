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
          RenderAppBar(
            title: Text('Issues'),
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