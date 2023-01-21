import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:render_studio/screens/creator/widgets/debug_banner.dart';
import 'package:render_studio/screens/creator/widgets/page_indicator.dart';
import 'package:render_studio/screens/creator/widgets/project_app_bar.dart';
import '../../../rehmat.dart';

class Studio extends StatefulWidget {

  Studio({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  _StudioState createState() => _StudioState();
}

class _StudioState extends State<Studio> {

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
    return WillPopScope(
      onWillPop: canPagePop,
      child: Scaffold(
        backgroundColor: context.isDarkMode ? Palette.of(context).background : Palette.of(context).surfaceVariant,
        appBar: ProjectAppBar(
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
                  child: ProjectDebugBanner(project: project),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      // if (project.thumbnail != null) Center(
                      //   child: Opacity(
                      //     opacity: 0,
                      //     child: Hero(
                      //       tag: 'project-${project.id}',
                      //       child: OctoImage(
                      //         image: FileImage(File(pathProvider.generateRelativePath(project.thumbnail!)))
                      //       )
                      //     ),
                      //   ),
                      // ),
                      Hero(
                        tag: 'project-${project.id}',
                        child: creator
                      ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: PageIndicator(project: project),
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
      isDestructive: true
    );
    return discard;
  }

  Future<void> save({
    bool export = false
  }) async {
    await Spinner.fullscreen(
      context,
      task: () async {
        await manager.save(context, project: project, saveToGallery: true);
      },
    );
    _lastSaved = DateTime.now();
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