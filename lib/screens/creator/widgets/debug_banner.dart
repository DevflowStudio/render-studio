import 'package:flutter/material.dart';

import '../../../rehmat.dart';

class ProjectDebugBanner extends StatefulWidget {

  ProjectDebugBanner({
    Key? key,
    required this.project
  }) : super(key: key);

  final Project project;

  @override
  State<ProjectDebugBanner> createState() => __DebugModeWidgetState();
}

class __DebugModeWidgetState extends State<ProjectDebugBanner> {

  late Project project;
  late CreatorPage page;
  late CreatorWidget creatorWidget;

  @override
  void initState() {
    project = widget.project;
    page = project.pages.current;
    creatorWidget = page.widgets.selections.firstOrNull ?? page.widgets.background;
    project.pages.addListener(onPageChange);
    page.addListener(onProjectPageChange);
    creatorWidget.stateCtrl.addListener(onWidgetChange);
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onPageChange);
    page.removeListener(onProjectPageChange);
    creatorWidget.stateCtrl.removeListener(onWidgetChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: NoSpaceWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '[Debug Mode]',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),
            ),
            if (page.widgets.nSelections == 1) ... [
              Text(
                'Selection: ${creatorWidget.id} #${creatorWidget.uid}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                'Position: (${creatorWidget.position.dx.toStringAsFixed(2)}, ${creatorWidget.position.dy.toStringAsFixed(2)})',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Size: ${creatorWidget.size.width.toStringAsFixed(2)} x ${creatorWidget.size.height.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500
                ),
              ),
              Text(
                'Area: ${creatorWidget.area}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500
                ),
              ),
            ] else if (page.widgets.nSelections == 0) Text(
              'No Widget Selected',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),
            ) else Text(
              'Multiple Widgets Selected [${page.widgets.nSelections}] (${page.widgets.selections.map((e) => e.uid).join(', ')})',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        )
      ),
    );
  }

  void onPageChange() {
    page.removeListener(onProjectPageChange);
    creatorWidget.stateCtrl.removeListener(onWidgetChange);

    page = project.pages.current;
    creatorWidget = page.widgets.selections.firstOrNull ?? page.widgets.background;

    page.addListener(onProjectPageChange);
    creatorWidget.stateCtrl.addListener(onWidgetChange);
  }

  void onProjectPageChange() => setState(() { });

  void onWidgetChange() => setState(() { });

}