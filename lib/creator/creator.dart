import 'package:flutter/material.dart';

import '../rehmat.dart';

export 'page.dart';
export 'widgets/widgets.dart';
export 'grids.dart';
export 'helpers/helpers.dart';

class CreatorView extends StatefulWidget {

  const CreatorView({
    super.key,
    required this.project
  });

  final Project project;

  @override
  State<CreatorView> createState() => CreatorViewState();
}

class CreatorViewState extends State<CreatorView> {

  late Project project;

  void onProjectUpdate() => setState(() {});

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
    else {
      analytics.logError(
        Exception('Memory leak detected in CreatorView'),
        cause: 'There were some memory leaks in CreatorView.'
      );
    }
  }

  @override
  void initState() {
    project = widget.project;
    if (project.pages.pages.isEmpty) project.pages.add(silent: true);
    project.pages.pages.forEach((page) {
      page.widgets.rebuildListeners();
    });
    project.pages.addListener(onProjectUpdate, [PageViewChange.page, PageViewChange.update]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: project.pages.controller,
      physics: (project.pages.current.widgets.nSelections == 1 && project.pages.current.widgets.selections.single is BackgroundWidget) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      onPageChanged: (value) {
        project.pages.changePage(value);
      },
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          project.pages.current.widgets.select(widget.project.pages.current.widgets.background);
        },
        child: Center(
          child: ClipRRect(
            child: project.pages.pages[index].build(context)
          ),
        ),
      ),
      itemCount: project.pages.length,
    );
  }
}