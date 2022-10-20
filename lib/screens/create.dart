import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../rehmat.dart';

class Create extends StatefulWidget {

  Create({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends State<Create> {

  late Project project;

  CreatorWidget? clipboard;

  bool isLoading = false;
  DateTime? _lastSaved;

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onPageUpdate);
    if (project.pages.pages.isEmpty) project.pages.add();
    project.pages.pages.forEach((page) {
      page.updateListeners();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onPageUpdate);
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
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              if (await canPagePop()) Navigator.of(context).pop();
            },
            icon: Icon(CupertinoIcons.arrow_turn_up_left),
            iconSize: 20,
          ),
          centerTitle: true,
          elevation: 0,
          toolbarHeight: MediaQuery.of(context).size.height * 0.07, // Toolbar can cover a maximum of 5% of the screen area
          title: isLoading ? TitleSpinnerWidget() : null,
          actions: [
            // IconButton(
            //   onPressed: () {
            //     // print(project.pages.current.widgets.last.uid);
            //   },
            //   icon: Icon(Icons.science_rounded),
            //   tooltip: 'Experiment',
            // ),
            IconButton(
              onPressed: project.pages.current.undoFuntion,
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
            ),
            IconButton(
              onPressed: project.pages.current.redoFuntion,
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
            ),
            IconButton(
              onPressed: () => AppRouter.push(context, page: Information(project: project)),
              icon: const Icon(Icons.info),
              tooltip: 'Info',
            ),
            PopupMenuButton(
              tooltip: 'More',
              itemBuilder: (context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  child: Text('Add Page'),
                  value: 'page-add',
                ),
                if (project.pages.current.currentSelection.allowClipboard) ... [
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
                  case 'page-add':
                    project.pages.add();
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
                    project.pages.current.delete(project.pages.current.currentSelection);
                    project.pages.current.changeSelection(project.pages.current.page);
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
                    setState(() {
                      isLoading = true;
                    });
                    await handler.save(context, project: project);
                    _lastSaved = DateTime.now();
                    if (mounted) setState(() {
                      isLoading = false;
                    });
                    Alerts.snackbar(context, text: 'Project saved');
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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // spacer(1),
              Expanded(
                // duration: Constants.animationDuration,
                // height: project.canvasSize(context).height,
                // width: project.canvasSize(context).width,
                child: project.pages.pages.isEmpty
                  ? const Center(
                    child: Spinner(),
                  )
                  : PageView.builder(
                    controller: project.pages.controller,
                    physics: (project.pages.current.currentSelection is CreatorPageProperties) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) {
                      project.pages.changePage(value);
                    },
                    itemBuilder: (context, index) => Center(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 3,
                              offset: const Offset(0, 0), // changes position of shadow
                            ),
                          ]
                        ),
                        child: SizedBox.fromSize(
                          size: project.canvasSize(context),
                          child: project.pages.pages[index].build(context)
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
        bottomNavigationBar: project.editorVisible ? project.pages.current.currentSelection.editor.build : null,
      ),
    );
  }

  Widget spacer([int? flex]) => Expanded(
    flex: flex ?? 1,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        project.pages.current.changeSelection(project.pages.current.page);
      },
      child: Container(
        color: Colors.transparent
      )
    ),
  );

  void copyToClipboard() {
    CreatorWidget? widget = CreatorPage.createWidgetFromId(project.pages.current.currentSelection.id, page: project.pages.current, project: project, uid: project.pages.current.currentSelection.uid!);
    if (widget == null) {
      Alerts.snackbar(context, text: 'Failed to build widget');
      return;
    }
    if (!widget.buildFromJSON(project.pages.current.currentSelection.toJSON())) Alerts.snackbar(context, text: 'Failed to build widget');
    widget.position = Offset(widget.position.dx + 10, widget.position.dy + 10);
    clipboard = widget;
    setState(() { });
    Alerts.snackbar(context, text: 'Copied Widget to Clipboard');
  }

  void pasteWidget() {
    Map<String, dynamic> json = clipboard!.toJSON();
    json['uid'] = Constants.generateID();
    CreatorWidget? widget = CreatorPage.createWidgetFromId(clipboard!.id, page: project.pages.current, project: project, uid: clipboard!.uid!);
    widget!.buildFromJSON(json);
    project.pages.current.addWidget(widget);
    clipboard = null;
    setState(() { });
    Alerts.snackbar(context, text: 'Added Widget From Clipboard');
  }

  void onPageUpdate() => setState(() { });

  Future<bool> canPagePop() async {
    bool _hasHistory = project.pages.pages.where((page) => page.history.length > 1).isNotEmpty;
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

}