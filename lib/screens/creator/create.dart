import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
import 'package:flutter/services.dart';
import '../../../rehmat.dart';

class Create extends StatefulWidget {

  Create({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {

  late Project project;

  DateTime? _lastSaved;

  bool isLoading = false;

  late final Widget creator;

  @override
  void initState() {
    project = widget.project;
    if (project.pages.pages.isEmpty) project.pages.add(silent: true);
    creator = CreatorView(project: project);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      fn();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (project.assetManager.canPrecache()) {
      isLoading = true;
      project.assetManager.precache(context).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
    return WillPopScope(
      onWillPop: canPagePop,
      child: Scaffold(
        appBar: _AppBar(
          project: project,
          isLoading: isLoading,
          onBackPressed: () async {
            if (await canPagePop()) Navigator.of(context).pop();
          },
          onSave: () async {
            await save();
          },
        ),
        body: GestureDetector(
          onTap: () => project.pages.current.widgets.select(project.pages.current.widgets.background),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (preferences.debugMode) Align(
                  alignment: Alignment.topLeft,
                  child: _DebugModeWidget(project: project),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      creator,
                      AnimatedSwitcher(
                        duration: kAnimationDuration,
                        child: isLoading ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SizedBox.expand(
                            child: Container(
                              color: Palette.of(context).background.withOpacity(0.25),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Palette.of(context).background,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Spinner()
                                ),
                              ),
                            ),
                          ),
                        ) : const SizedBox.shrink(),
                      )
                    ],
                  ),
                ),
                // spacer(project.editorVisible ? 1 : 2),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _BottomNavBuilder(project: project)
        ),
      ),
    );
  }

  Future<bool> canPagePop() async {
    bool _hasHistory = project.pages.pages.where((page) => page.history.hasHistory).isNotEmpty;
    bool recentlySaved = _lastSaved != null && DateTime.now().difference(_lastSaved!).inMinutes < 1;
  
    if (!_hasHistory) return true;
    else if (_hasHistory && recentlySaved) return true;
    
    bool discard = await Alerts.showConfirmationDialog(
      context,
      title: 'Saved Project?',
      message: 'You have unsaved changes. Do you want to discard them? This action cannot be undone.',
      cancelButtonText: 'Back',
      confirmButtonText: 'Discard',
    );
    return discard;
  }

  Future<void> save({
    bool export = false
  }) async {
    setState(() {
      isLoading = true;
    });
    await manager.save(context, project: project, saveToGallery: true);
    _lastSaved = DateTime.now();
    // await Future.delayed(const Duration(seconds: 3));
    setState(() {
      isLoading = false;
    });
    Alerts.snackbar(
      context,
      text: 'Saved to Gallery',
    );
  }

}

class _BottomNavBuilder extends StatefulWidget {

  _BottomNavBuilder({
    Key? key,
    required this.project,
  }) : super(key: key);

  final Project project;

  @override
  State<_BottomNavBuilder> createState() => __BottomNavBuilderState();
}

class __BottomNavBuilderState extends State<_BottomNavBuilder> {

  late Project project;

  void onUpdate() => setState(() { });

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onUpdate);
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return project.pages.current.widgets.nSelections > 1
      ? project.pages.current.widgets.background.editor
      : (project.pages.current.widgets.selections.firstOrNull ?? project.pages.current.widgets.background).editor;
  }

}

class _DebugModeWidget extends StatefulWidget {

  _DebugModeWidget({
    Key? key,
    required this.project
  }) : super(key: key);

  final Project project;

  @override
  State<_DebugModeWidget> createState() => __DebugModeWidgetState();
}

class __DebugModeWidgetState extends State<_DebugModeWidget> {

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

class _PreferredAppBarSize extends Size {
  _PreferredAppBarSize()
    : super.fromHeight((kToolbarHeight));
}

class _AppBar extends StatefulWidget implements PreferredSizeWidget {
  
  _AppBar({
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
  State<_AppBar> createState() => _AppBarState();
  
  @override
  Size get preferredSize => _PreferredAppBarSize();

}

class _AppBarState extends State<_AppBar> {

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
      leading: widget.isLoading ? Container() : IconButton(
        onPressed: widget.onBackPressed,
        icon: Icon(CupertinoIcons.arrow_turn_up_left),
        iconSize: 20,
      ),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: MediaQuery.of(context).platformBrightness,
      ),
      centerTitle: false,
      title: title != null ? Chip(
        label: Text(title!)
      ) : null,
      backgroundColor: Colors.transparent,
      toolbarHeight: MediaQuery.of(context).size.height * 0.07, // Toolbar can cover a maximum of 5% of the screen area
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
          tooltip: 'Redo',
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
            showBadge: project.issues.isNotEmpty,
            animationType: BadgeAnimationType.fade,
            position: BadgePosition.topEnd(top: -6, end: -9),
            child: Icon(RenderIcons.more)
          ),
          itemBuilder: (context) => <PopupMenuEntry>[
            if (project.issues.isNotEmpty) PopupMenuItem(
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

class _ProjectIssuesButton extends StatefulWidget {

  _ProjectIssuesButton({
    Key? key,
    required this.project
  }) : super(key: key);

  final Project project;

  @override
  State<_ProjectIssuesButton> createState() => __ProjectIssuesButtonState();
}

class __ProjectIssuesButtonState extends State<_ProjectIssuesButton> {

  late Project project;

  void onProjectUpdate() => setState(() { });

  @override
  void initState() {
    project = widget.project;
    project.addListener(onProjectUpdate);
    super.initState();
  }

  @override
  void dispose() {
    project.removeListener(onProjectUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await AppRouter.push(context, page: ProjectIssues(project: project,));
        setState(() { });
      },
      icon: Badge(
        badgeContent: Text(
          project.issues.length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        animationType: BadgeAnimationType.slide,
        position: BadgePosition.topEnd(top: -12, end: -9),
        child: Icon(
          RenderIcons.warning,
        ),
      )
    );
  }

}