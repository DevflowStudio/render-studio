import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:render_studio/models/project/templatex.dart';
import 'package:sprung/sprung.dart';

import '../../../rehmat.dart';

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize()
    : super.fromHeight((kToolbarHeight));
}

class ProjectAppBar extends StatefulWidget implements PreferredSizeWidget {
  
  ProjectAppBar({
    Key? key,
    required this.project,
    required this.onLeadingPressed,
    required this.save,
    this.isLoading = false,
  }) : super(key: key);

  final Project project;

  final void Function() onLeadingPressed;

  final Future<bool> Function({ExportQuality quality, bool showSuccess}) save;

  final bool isLoading;

  @override
  State<ProjectAppBar> createState() => _AppBarState();
  
  @override
  Size get preferredSize => _PreferredAppBarSize();

}

class _AppBarState extends State<ProjectAppBar> {

  late Project project;

  void onProjectUpdate() => setState(() { });

  CreatorWidget? clipboard;

  @override
  void initState() {
    project = widget.project;
    project.addListener(onProjectUpdate);
    project.pages.addListener(onProjectUpdate);
    super.initState();
  }

  @override
  void dispose() {
    project.removeListener(onProjectUpdate);
    project.pages.removeListener(onProjectUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.isLoading ? Container() : Padding(
        padding: const EdgeInsets.all(6),
        child: FilledTonalIconButton(
          onPressed: widget.onLeadingPressed,
          icon: Icon(RenderIcons.arrow_back),
        ),
      ),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: MediaQuery.of(context).platformBrightness,
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: title,
      backgroundColor: Colors.transparent,
      actions: [
        _ActionsBuilder(
          project: project,
          save: widget.save,
          isLoading: widget.isLoading,
        ),
      ]
    );
  }

  Widget? get title {
    if (project.pages.current.widgets.nSelections >= 2) {
      return chip(
        text: 'Group',
        icon: RenderIcons.add,
        onTap: () {
          WidgetGroup.create(page: project.pages.current);
        }
      );
    }
    else if (project.pages.current.widgets.multiselect) {
      return chip(
        text: 'Multiselect',
        icon: RenderIcons.close,
        onTap: () {
          project.pages.current.widgets.multiselect = false;
          setState(() { });
        }
      );
    }
    return null;
  }

  Widget chip({
    required String text,
    required void Function()? onTap,
    required IconData icon
  }) {
    return FadeInDown(
      from: 10,
      duration: kAnimationDuration,
      child: InkWell(
        onTap: onTap != null ? () {
          TapFeedback.light();
          onTap();
        } : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Palette.of(context).outline,
              width: 1
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 9
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(width: 9),
              Icon(
                icon,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ActionsBuilder extends StatefulWidget {

  const _ActionsBuilder({
    required this.project,
    required this.save,
    this.isLoading = false,
  });

  final Future<bool> Function({ExportQuality quality, bool showSuccess}) save;

  final Project project;

  final bool isLoading;

  @override
  State<_ActionsBuilder> createState() => __ActionsBuilderState();
}

class __ActionsBuilderState extends State<_ActionsBuilder> {

  late final Project project;

  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    project = widget.project;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: (project.pages.pages.isNotEmpty && !widget.isLoading) ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Row(
        children: [
          IconButton(
            onPressed: project.pages.current.history.undo,
            icon: Icon(
              RenderIcons.undo,
            ),
            tooltip: project.pages.current.history.undoTooltip,
          ),
          IconButton(
            onPressed: project.pages.current.history.redo,
            icon: Icon(
              RenderIcons.redo,
            ),
            tooltip: project.pages.current.history.redoTooltip,
          ),
          // _SaveButton(
          //   isLoading: false,
          //   onSave: widget.onSave,
          // ),
          PullDownButton(
            key: key,
            itemBuilder: (context) => [
              if (project.title != null) PullDownMenuTitle(
                title: Text(
                  project.title! + (project.isTemplate && !project.isTemplateKit ? ' - Template' : '') + (project.isTemplateKit ? ' - Template Kit' : '')
                )
              ),
              PullDownMenuItem(
                title: 'Save',
                icon: RenderIcons.download,
                onTap: () async {
                  try {
                    await showPullDownMenu(
                      context: context,
                      items: [
                        const PullDownMenuTitle(title: Text('Choose Quality')),
                        for (final quality in ExportQuality.values) PullDownMenuItem(
                          title: quality.name,
                          subtitle: quality.getFinalSize(project.size.size),
                          onTap: () {
                            widget.save(quality: quality, showSuccess: true);
                          },
                        ),
                      ],
                      position: _getRect(context)
                    );
                  } catch (e) {
                    analytics.logError(e, cause: 'save error');
                    Alerts.dialog(
                      context,
                      title: 'Failed to Save',
                      content: 'Oh no! An error occurred while saving the project. Please try again later.'
                    );
                  }
                },
              ),
              PullDownMenuItem(
                title: 'Add Page',
                icon: RenderIcons.add,
                onTap: () {
                  if (project.isTemplateKit) {
                    Alerts.dialog(
                      context,
                      title: 'Coming Soon',
                      content: 'Multi-page templates are not yet supported. Stay tuned!',
                    );
                    return;
                  }
                  project.pages.add();
                  setState(() { });
                },
              ),
              PullDownMenuItem(
                title: 'Edit Metadata',
                icon: RenderIcons.info,
                onTap: () {
                  AppRouter.push(context, page: ProjectMeta(project: project));
                },
              ),
              PullDownMenuItem(
                title: 'Test Template Kit',
                onTap: () async {
                  print(project.id);
                  try {
                    var data = TemplateKit.buildTemplateData(project);
                    print(data);
                  } catch (e, stacktrace) {
                    Alerts.dialog(
                      context,
                      title: 'Error',
                      content: e.toString(),
                    );
                    print(e);
                    print(stacktrace);
                  }
                },
              ),
              PullDownMenuItem(
                title: 'Publish Template',
                icon: RenderIcons.upload,
                onTap: () async {
                  await TemplateKit.publish(context, project: project);
                },
              ),
              if (kDebugMode) PullDownMenuItem.selectable(
                onTap: () {
                  preferences.debugMode = !preferences.debugMode;
                  setState(() { });
                },
                selected: preferences.debugMode,
                title: 'Debug Mode',
              ),
              if (project.pages.current.widgets.nSelections > 1) PullDownMenuItem(
                title: 'Create Group',
                icon: RenderIcons.group,
                onTap: () {
                  WidgetGroup.create(page: project.pages.current);
                },
              ),
              PullDownMenuItem.selectable(
                onTap: () {
                  project.pages.current.widgets.multiselect = !project.pages.current.widgets.multiselect;
                  setState(() { });
                },
                selected: project.pages.current.widgets.multiselect,
                icon: RenderIcons.multiselect,
                title: 'Multiselect',
              ),
            ],
            buttonBuilder: (context, showMenu) => IconButton(
              onPressed: showMenu,
              icon: Icon(
                RenderIcons.more,
              ),
            ),
          )
        ],
      ),
      secondChild: Container(),
    );
  }

}

class _SaveButton extends StatefulWidget {

  const _SaveButton({
    required this.isLoading,
    required this.onSave,
  });

  final bool isLoading;

  final Function() onSave;

  @override
  State<_SaveButton> createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {

  bool isLoading = false;

  FlipCardController flipCtrl = FlipCardController();

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Sprung(),
      child: (isLoading) ? Container(
        decoration: BoxDecoration(
          color: Palette.of(context).surface,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Palette.of(context).outline,
            width: 1
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12
        ),
        child: FlipCard(
          controller: flipCtrl,
          direction: FlipDirection.VERTICAL,
          flipOnTouch: false,
          front: Row(
            children: [
              Spinner(
                strokeWidth: 2,
              ),
              SizedBox(width: 9),
              Text(
                'Saving',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          back: Row(
            children: [
              Icon(
                RenderIcons.done,
              ),
              SizedBox(width: 6),
              Text(
                'Done',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ) : IconButton(
        onPressed: onTap,
        icon: Icon(RenderIcons.download),
        tooltip: 'Save Project',
      ),
    );
  }

  Future<void> onTap() async {
    setState(() {
      isLoading = true;
    });
    await widget.onSave();
    flipCtrl.toggleCard();
    await Future.delayed(Duration(seconds: 1, milliseconds: 500));
    setState(() {
      isLoading = false;
    });
  }

}

Rect _getRect(BuildContext context) {
  final renderBoxContainer = context.findRenderObject()! as RenderBox;;
  final queryData = MediaQuery.of(context);
  final size = queryData.size;

  final rect = Rect.fromPoints(
    renderBoxContainer.localToGlobal(
      renderBoxContainer.paintBounds.topLeft,
    ),
    renderBoxContainer.localToGlobal(
      renderBoxContainer.paintBounds.bottomRight,
    ),
  );

  if (rect.size.height > size.height) {
    return _normalizeLargeRect(rect, size, queryData.padding);
  }

  return rect;
}

/// Apply some additional adjustments on [Rect] from [RectExtension.getRect] if
/// [rect] is bigger than [size].
Rect _normalizeLargeRect(
  Rect rect,
  Size size,
  EdgeInsets padding,
) {
  const minimumAllowedSize = kMinInteractiveDimensionCupertino * 2;

  final topIsNegative = rect.top.isNegative;
  final height = size.height;
  final rectBottom = rect.bottom;

  double? top;
  double? bottom;

  if (topIsNegative && rectBottom > height) {
    top = height * 0.65;
    bottom = height * 0.75;
  } else if (topIsNegative && rectBottom < height) {
    final diff = height - rectBottom - padding.bottom;

    if (diff < minimumAllowedSize) {
      top = rectBottom;
      bottom = height - padding.bottom;
    }
  } else {
    final diff = rect.top - padding.top;

    if (diff < minimumAllowedSize) {
      top = padding.top;
      bottom = rect.top;
    }
  }

  return Rect.fromLTRB(
    rect.left,
    top ?? rect.top,
    rect.right,
    bottom ?? rect.bottom,
  );
}