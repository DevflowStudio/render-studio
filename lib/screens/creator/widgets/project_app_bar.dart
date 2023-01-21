import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      actions: (project.pages.pages.isNotEmpty && !widget.isLoading) ? [
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
        IconButton(
          onPressed: () => AppRouter.push(context, page: Information(project: project)),
          icon: Icon(RenderIcons.info),
          tooltip: 'Meta',
        ),
        PopupMenuButton(
          tooltip: 'More',
          icon: Badge(
            badgeContent: Text(
              project.issues.length.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
            showBadge: preferences.debugMode && project.issues.isNotEmpty,
            animationType: BadgeAnimationType.fade,
            position: BadgePosition.topEnd(top: -6, end: -9),
            child: Icon(RenderIcons.more)
          ),
          itemBuilder: (context) => <PopupMenuEntry>[
            if (preferences.debugMode && project.issues.isNotEmpty) PopupMenuItem(
              value: 'issues',
              child: Badge(
                badgeContent: Text(
                  project.issues.length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                animationType: BadgeAnimationType.fade,
                child: Text('Issues')
              ),
            ),
            const PopupMenuItem(
              child: Text('Add Page'),
              value: 'page-add',
            ),
            PopupMenuItem(
              child: Text('${preferences.debugMode ? 'Disable' : 'Enable'} Debug Mode'),
              value: 'toggle-debug',
            ),
            PopupMenuItem(
              child: Text('${project.pages.current.widgets.multiselect ? 'Disable ' : ''}Multiselect'),
              value: 'toggle-multiselect',
            ),
            if (project.pages.current.widgets.nSelections > 1) PopupMenuItem(
              child: Text('Create Group'),
              value: 'create-group',
            ),
            const PopupMenuItem(
              child: Text('Save'),
              value: 'project-save',
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'issues':
                await AppRouter.push(context, page: ProjectIssues(project: project));
                setState(() { });
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
              case 'project-save':
                widget.onSave();
                break;
              case 'project-info':
                AppRouter.push(context, page: Information(project: project));
                break;
              default:
            }
          },
        )
      ] : [],
    );
  }

  String? get title {
    if (project.pages.current.widgets.multiselect) {
      return 'Multiselect';
    } else return null;
  }

}