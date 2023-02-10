import 'package:badges/badges.dart' as badge;
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    required this.onBackPressed,
    required this.onSave,
    this.isLoading = false
  }) : super(key: key);

  final Project project;

  final void Function() onBackPressed;

  final void Function() onSave;

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
          onPressed: widget.onBackPressed,
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
      title: title != null ? Container(
        decoration: BoxDecoration(
          color: Palette.of(context).surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Palette.of(context).outline,
            width: 2
          )
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12
        ),
        child: Text(
          title!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 0.66
          ),
        )
      ) : null,
      backgroundColor: Colors.transparent,
      actions: [
        _ActionsBuilder(
          project: project,
          onSave: widget.onSave,
          isLoading: widget.isLoading,
        ),
      ]
    );
  }

  String? get title {
    if (project.pages.current.widgets.multiselect) {
      return 'Multiselect';
    } else return null;
  }

}

class _ActionsBuilder extends StatefulWidget {

  const _ActionsBuilder({
    required this.project,
    required this.onSave,
    this.isLoading = false,
  });

  final void Function() onSave;

  final Project project;

  final bool isLoading;

  @override
  State<_ActionsBuilder> createState() => __ActionsBuilderState();
}

class __ActionsBuilderState extends State<_ActionsBuilder> {

  late final Project project;

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
          _SaveButton(
            isLoading: false,
            onSave: widget.onSave,
          ),
          PopupMenuButton(
            tooltip: 'More',
            icon: badge.Badge(
              badgeContent: Text(
                project.issues.length.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              showBadge: preferences.debugMode && project.issues.isNotEmpty,
              position: badge.BadgePosition.topEnd(top: -6, end: -9),
              child: Icon(RenderIcons.more)
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              if (preferences.debugMode && project.issues.isNotEmpty) PopupMenuItem(
                value: 'issues',
                child: badge.Badge(
                  badgeContent: Text(
                    project.issues.length.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                  child: Text('Issues')
                ),
              ),
              const PopupMenuItem(
                child: Text('Add Page'),
                value: 'page-add',
              ),
              const PopupMenuItem(
                child: Text('Edit Metadata'),
                value: 'meta',
              ),
              PopupMenuItem(
                child: Text('${preferences.debugMode ? 'Disable' : 'Enable'} Debug Mode'),
                value: 'toggle-debug',
              ),
              PopupMenuItem(
                child: Text('${project.pages.current.widgets.multiselect ? 'Disable ' : ''}Multiselect'),
                value: 'toggle-multiselect',
              ),
              if (project.pages.current.widgets.nSelections > 1) const PopupMenuItem(
                child: Text('Create Group'),
                value: 'create-group',
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'issues':
                  await AppRouter.push(context, page: ProjectIssues(project: project));
                  setState(() { });
                  break;
                case 'meta':
                  await AppRouter.push(context, page: Information(project: project));
                  break;
                case 'page-add':
                  project.pages.add();
                  setState(() { });
                  break;
                case 'toggle-debug':
                  preferences.debugMode = !preferences.debugMode;
                  setState(() { });
                  break;
                case 'create-group':
                  await WidgetGroup.create(page: project.pages.current);
                  break;
                case 'toggle-multiselect':
                  project.pages.current.widgets.multiselect = !project.pages.current.widgets.multiselect;
                  setState(() { });
                  break;
                case 'project-info':
                  AppRouter.push(context, page: Information(project: project));
                  break;
                default:
              }
            },
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
          front: Row(
            children: [
              Spinner(),
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