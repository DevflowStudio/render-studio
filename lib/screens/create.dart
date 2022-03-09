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

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onPageUpdate);
    if (project.pages.pages.isEmpty) project.pages.add();
    project.pages.pages.forEach((page) {
      page.updateListeners();
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) => setState(() {}));
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
      onWillPop: () async {
        if (project.pages.pages.where((page) => page.history.length > 1).isEmpty) return true;
        bool? discard = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Project'),
            content: const Text('Do you want to discard this project? All the changes will be discarded. This cannot be reverted.'),
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
      },
      child: Scaffold(
        backgroundColor: App.getThemedObject(context, light: Colors.grey[50], dark: Palette.backgroundDarker),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: App.getThemedObject(context, light: Colors.grey[50], dark: Palette.backgroundDarker),
          elevation: 0,
          toolbarHeight: MediaQuery.of(context).size.height * 0.07, // Toolbar can cover a maximum of 5% of the screen area
          actions: [
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
                    await Spinner.fullscreen(
                      context,
                      task: () => handler.save(context, project: project)
                    );
                    AppRouter.removeAllAndPush(context, page: const Home());
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
            children: [
              spacer(1),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      spreadRadius: 0,
                    )
                  ]
                ),
                child: AnimatedContainer(
                  duration: Constants.animationDuration,
                  height: project.actualSize(context).height,
                  width: project.actualSize(context).width,
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
                        child: project.pages.pages[index].build(context),
                      ),
                      itemCount: project.pages.length,
                    )
                ),
              ),
              spacer(project.editorVisible ? 1 : 2),
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
        setState(() { });
      },
      child: Container(
        color: Colors.transparent
      )
    ),
  );

  void copyToClipboard() {
    CreatorWidget? widget = CreatorPage.createWidgetFromId(project.pages.current.currentSelection.id, page: project.pages.current, project: project);
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
    CreatorWidget? widget = CreatorPage.createWidgetFromId(clipboard!.id, page: project.pages.current, project: project);
    widget!.buildFromJSON(json);
    project.pages.current.addWidget(widget);
    clipboard = null;
    setState(() { });
    Alerts.snackbar(context, text: 'Added Widget From Clipboard');
  }

  void onPageUpdate() => setState(() { });

}