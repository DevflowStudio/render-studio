import 'package:flutter/material.dart';
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
    return InkWell(
      onTap: () {
        TapFeedback.light();
        // TODO: Create views for seeing all pages and editing them
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SmoothPageIndicator(
          controller: widget.project.pages.controller,
          count: widget.project.pages.length,
          effect: SwapEffect(
            activeDotColor: project.pages.current.palette.onBackground,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 4
          ),
        ),
      ),
    );
  }

}