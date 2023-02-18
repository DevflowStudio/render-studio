import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/widgets/page_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../rehmat.dart';

class PageIndicator extends StatefulWidget {

  const PageIndicator({
    Key? key,
    required this.project,
  }) : super(key: key);

  final Project project;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {

  late final Project project;

  void onPageChange() => setState(() { });

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onPageChange);
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onPageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (project.pages.length > 1) return InkWell(
      onTap: () {
        TapFeedback.light();
        Alerts.showModal(context, child: ProjectPageView(project: project));
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SmoothPageIndicator(
          controller: widget.project.pages.controller,
          count: widget.project.pages.length,
          effect: SwapEffect(
            activeDotColor: Palette.of(context).onBackground,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 4
          ),
        ),
      ),
    );
    else return Container();
  }

}