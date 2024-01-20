import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:smooth_corner/smooth_corner.dart';

import '../../../rehmat.dart';

class GeneratedTemplatesView extends StatefulWidget {

  const GeneratedTemplatesView({
    super.key,
    required this.templates
  });

  final List<Project> templates;

  @override
  State<GeneratedTemplatesView> createState() => _GeneratedTemplatesViewState();
}

class _GeneratedTemplatesViewState extends State<GeneratedTemplatesView> {

  late final List<Project> projects;

  PageController controller = PageController();

  @override
  void initState() {
    projects = widget.templates;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: NewBackButton(
          confirm: true,
          confirmTitle: 'Discard',
          confirmMessage: 'Are you sure you want to discard these templates?',
        ),
        title: Text('Templates'),
      ),
      body: PageView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => SmoothClipRRect(
          borderRadius: BorderRadius.circular(12),
          smoothness: 0.6,
          child: SizedBox(
            width: projects[index].contentSize.width,
            height: projects[index].contentSize.height,
            child: CreatorView(project: projects[index]),
          ),
        ),
        itemCount: projects.length,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Palette.of(context).surfaceVariant,
          border: Border(
            top: BorderSide(
              color: Palette.of(context).onBackground.withOpacity(0.1),
              width: 0.5
            )
          )
        ),
        padding: EdgeInsets.only(
          bottom: Constants.of(context).bottomPadding,
          top: 12,
          left: 12,
          right: 12
        ),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {},
              tooltip: 'Save to gallery',
              icon: Icon(
                RenderIcons.download,
              ),
            ),
            PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: 'Report',
                  icon: RenderIcons.flag,
                  onTap: () {
                    
                  },
                ),
                PullDownMenuItem(
                  title: 'Delete',
                  icon: RenderIcons.delete,
                  isDestructive: true,
                  onTap: () {
                    
                  },
                ),
              ],
              buttonBuilder: (context, showMenu) {
                return IconButton.filledTonal(
                  onPressed: showMenu,
                  tooltip: 'View more options',
                  icon: Icon(
                    RenderIcons.more,
                  ),
                );
              }
            ),
            Spacer(),
            IntrinsicHeight(
              child: PrimaryButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12
                ),
                child: Row(
                  children: [
                    Text(
                      'Edit',
                    )
                  ],
                ),
                onPressed: () {
                  try {
                    Project project = projects[controller.page!.round()];
                    AppRouter.push(context, page: Studio(project: project));
                  } catch (e) {
                    print(e);
                    Alerts.dialog(
                      context,
                      title: 'Error',
                      content: 'Failed to edit template. Please try again later'
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}