import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart';
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

  void onProjectUpdate() {
    setState(() {});
  }

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onProjectUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onProjectUpdate);
    super.dispose();
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
    return WillPopScope(
      onWillPop: canPagePop,
      child: Scaffold(
        appBar: _AppBar(
          project: project,
          onBackPressed: () async {
            if (await canPagePop()) Navigator.of(context).pop();
          },
          onSave: () async {
            await save();
          },
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (preferences.debugMode) Align(
                alignment: Alignment.topLeft,
                child: _DebugModeWidget(project: project),
              ),
              Expanded(
                child: project.pages.pages.isEmpty
                  ? const Center(
                    child: Spinner(),
                  )
                  : PageView.builder(
                    controller: project.pages.controller,
                    physics: (project.pages.current.selections.length == 1 && project.pages.current.selections.single is BackgroundWidget) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) {
                      project.pages.changePage(value);
                    },
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        project.pages.current.select(widget.project.pages.current.backround);
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            if (info != null) Align(
                              alignment: Alignment.topCenter,
                              child: Chip(
                                label: Text(info!)
                              ),
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 3,
                                      offset: const Offset(0, 0),
                                    ),
                                  ]
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: project.pages.pages[index].build(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    itemCount: project.pages.length,
                  )
              ),
              // spacer(project.editorVisible ? 1 : 2),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _BottomNavBuilder(project: project)
        ),
      ),
    );
  }

  String? get info {
    if (project.pages.current.multiselect) return 'Multiselect (${project.pages.current.selections.length})';
    else return null;
  }

  // Widget spacer([int? flex]) => Expanded(
  //   flex: flex ?? 1,
  //   child: GestureDetector(
  //     behavior: HitTestBehavior.translucent,
  //     onTap: () {
  //       project.pages.current.select(project.pages.current.backround);
  //     },
  //     child: Container(
  //       color: Colors.transparent
  //     )
  //   ),
  // );

  Future<bool> canPagePop() async {
    bool _hasHistory = project.pages.pages.where((page) => page.history.hasHistory).isNotEmpty;
    bool recentlySaved = _lastSaved != null && DateTime.now().difference(_lastSaved!).inMinutes < 1;
  
    if (!_hasHistory) return true;
    else if (_hasHistory && recentlySaved) return true;
    
    bool? discard = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Project?'),
        content: const Text('Make sure to save your project before leaving. This action cannot be reverted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard')
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> save({
    bool export = false
  }) async {
    await Spinner.linearFullscreen(
      context,
      message: 'Exporting...',
      task: () async {
        await manager.save(context, project: project, saveToGallery: true);
        // await Future.delayed(const Duration(seconds: 3));
      }
    );
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
    if (project.pages.pages.isEmpty) project.pages.add();
    project.pages.pages.forEach((page) {
      page.rebuildListeners();
    });
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return project.editorVisible
      ? (
          project.pages.current.selections.length > 1
            ? project.pages.current.backround.editor.build
            : (project.pages.current.selections.firstOrNull ?? project.pages.current.backround).editor.build
        )
      : Container();
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
    creatorWidget = page.selections.firstOrNull ?? page.backround;
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
            if (page.selections.length == 1) ... [
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
            ] else if (page.selections.isEmpty) Text(
              'No Widget Selected',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),
            ) else Text(
              'Multiple Widgets Selected',
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
    creatorWidget = page.selections.firstOrNull ?? page.backround;

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
  }) : super(key: key);

  final Project project;

  final void Function() onBackPressed;

  final void Function() onSave;

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
    super.initState();
  }

  @override
  void dispose() {
    project.removeListener(onProjectUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: widget.onBackPressed,
        icon: Icon(CupertinoIcons.arrow_turn_up_left),
        iconSize: 20,
      ),
      centerTitle: true,
      elevation: 0,
      toolbarHeight: MediaQuery.of(context).size.height * 0.07, // Toolbar can cover a maximum of 5% of the screen area
      actions: [
        IconButton(
          onPressed: project.pages.current.history.undo,
          icon: Icon(
            RenderIcons.undo,
          ),
          tooltip: 'Undo',
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
              child: Text('${project.pages.current.multiselect ? 'Disable ' : ''}Multiselect'),
              value: 'toggle-multiselect',
            ),
            if (project.pages.current.selections.length > 1) PopupMenuItem(
              child: Text('Create Group'),
              value: 'create-group',
            ),
            if (project.pages.current.selections.length == 1 && project.pages.current.selections.single.allowClipboard) ... [
              const PopupMenuItem(
                child: Text('Duplicate'),
                value: 'duplicate-widget',
              ),
              const PopupMenuItem(
                child: Text('Copy'),
                value: 'copy-widget',
              ),
              const PopupMenuItem(
                child: Text('Cut'),
                value: 'cut-widget',
              ),
            ],
            PopupMenuItem(
              child: const Text('Paste'),
              enabled: clipboard != null,
              value: 'paste-widget',
            ),
            PopupMenuItem(
              child: Text('${project.editorVisible ? 'Hide' : 'Show'} Editor'),
              value: 'toggle-editor',
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
                CreatorWidget? _group = await WidgetGroup.create(context, page: project.pages.current, project: project);
                if (_group != null) project.pages.current.addWidget(_group);
                setState(() { });
                break;
              case 'toggle-multiselect':
                project.pages.current.toggleMultiselect();
                setState(() { });
                break;
              case 'duplicate-widget':
                copyToClipboard();
                pasteWidget();
                break;
              case 'copy-widget':
                copyToClipboard();
                break;
              case 'cut-widget':
                copyToClipboard();
                project.pages.current.delete(project.pages.current.selections.single);
                project.pages.current.select(project.pages.current.backround);
                setState(() { });
                break;
              case 'paste-widget':
                pasteWidget();
                break;
              case 'toggle-editor':
                project.editorVisible = !project.editorVisible;
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
      ],
    );
  }

  void copyToClipboard() {
    try {
      clipboard = project.pages.current.selections.single.duplicate();
      setState(() { });
    } on WidgetCreationException catch (e, stacktrace) {
      analytics.logError(e, cause: 'copyToClipboard failed', stacktrace: stacktrace);
      Alerts.snackbar(context, text: 'Failed to build widget');
    }
  }

  void pasteWidget() {
    if (clipboard == null) return;
    project.pages.current.addWidget(clipboard!);
    clipboard = null;
    setState(() { });
    Alerts.snackbar(context, text: 'Added Widget From Clipboard');
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