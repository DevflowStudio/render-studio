import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:render_studio/creator/helpers/editor_manager.dart';
import 'package:render_studio/screens/creator/widgets/debug_banner.dart';
import 'package:render_studio/screens/creator/widgets/page_indicator.dart';
import 'package:render_studio/screens/creator/widgets/project_app_bar.dart';
import 'package:sprung/sprung.dart';
import '../../../rehmat.dart';

class Studio extends StatefulWidget {

  Studio({Key? key, required this.project}) : super(key: key);

  final Project project;

  @override
  _StudioState createState() => _StudioState();
}

class _StudioState extends State<Studio> with TickerProviderStateMixin {

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
        backgroundColor: context.isDarkMode ? Palette.of(context).surface : Palette.of(context).surfaceContainerLow,
        resizeToAvoidBottomInset: false,
        appBar: ProjectAppBar(
          project: project,
          isLoading: isLoading,
          onLeadingPressed: () async {
            if (await canPagePop()) Navigator.of(context).pop();
          },
          save: save,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (preferences.debugMode) Align(
                alignment: Alignment.topLeft,
                child: ProjectDebugBanner(project: project),
              ),
              Expanded(
                child: IgnorePointer(
                  ignoring: isLoading,
                  child: creator
                ),
              ),
              PageIndicator(project: project),
              // spacer(project.editorVisible ? 1 : 2),
            ],
          ),
        ),
        bottomNavigationBar: AnimatedSize(
          duration: kAnimationDuration * 2,
          curve: Sprung(),
          child: _BottomNavBuilder(project: project, isLoading: isLoading)
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
      title: 'Save Project?',
      message: 'You have unsaved changes. Do you want to discard them? This action cannot be undone.',
      cancelButtonText: 'Back',
      confirmButtonText: 'Discard',
      isDestructive: true
    );
    
    return discard;
  }

  Future<bool> save({
    ExportQuality quality = ExportQuality.onex,
    bool showSuccess = true
  }) async {
    try {
      setState(() => isLoading = true);
      project.pages.current.widgets.select();
      await project.save(context, quality: quality);
      _lastSaved = DateTime.now();
      setState(() => isLoading = false);
      if (showSuccess) Alerts.showSuccess(context, message: 'Saved', asset: 'assets/animations/success-2.json');
      return true;
    } catch (e) {
      setState(() => isLoading = false);
      return false;
    }
  }

}

class _BottomNavBuilder extends StatefulWidget {

  _BottomNavBuilder({
    Key? key,
    required this.project,
    this.isLoading = false
  }) : super(key: key);

  final Project project;
  final bool isLoading;

  @override
  State<_BottomNavBuilder> createState() => __BottomNavBuilderState();
}

class __BottomNavBuilderState extends State<_BottomNavBuilder> {

  late Project project;

  late CreatorPage current;

  void onUpdate() {
    if (current != project.pages.current) {
      setState(() => current = project.pages.current);
    }
  }

  late Editor editor;

  @override
  void initState() {
    project = widget.project;
    project.pages.addListener(onUpdate);
    current = project.pages.current;
    super.initState();
  }

  @override
  void dispose() {
    project.pages.removeListener(onUpdate);
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
    return AnimatedSwitcher(
      duration: kAnimationDuration,
      child: widget.isLoading ? Padding(
        padding: EdgeInsets.only(
          bottom: Constants.of(context).bottomPadding
        ),
        child: IntrinsicHeight(
          child: SpinKitThreeInOut(
            color: context.isDarkMode ? Colors.grey[200] : Colors.grey[800],
            size: 20,
          ),
        ),
      ) : FadeInUp(
        duration: kAnimationDuration,
        child: PageEditorView(manager: current.editorManager)
      )
    );
  }

}