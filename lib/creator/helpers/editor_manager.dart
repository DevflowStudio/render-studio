import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../rehmat.dart';

class EditorManager extends ChangeNotifier {

  final CreatorPage page;

  EditorManager._({required this.page}) {
    page.addListener(updateEditor, [PageChange.selection]);
  }

  static EditorManager create(CreatorPage page) {
    return EditorManager._(page: page);
  }

  static Size standardSize(BuildContext context) {
    double verticalPadding = Constants.of(context).bottomPadding;
    double height = standardOptionHeight(context);
    return Size(double.infinity, height + verticalPadding);
  }

  static double standardOptionHeight(BuildContext context) {
    return (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.2 * 2) + 6 + 70; // Height of a standard option icon button + padding
  }

  Editor? _editor;
  List<_EditorModal> modals = [];

  Editor? get editor => _editor;

  void updateEditor() {
    if (page.widgets.nSelections == 0) {
      _editor = null;
      closeAllModals();
    } else if (page.widgets.nSelections == 1) {
      _editor = page.widgets.selections.single.editor;
      closeAllModals();
    } else {
      _editor = page.widgets.background.editor;
    }
    notifyListeners();
  }

  void openModal({
    required EditorTab Function(BuildContext context, void Function(void Function()) setState) tab,
    EdgeInsets? padding,
    List<Widget> Function(void Function() dismiss)? actions,
    void Function()? onDismiss,
  }) {
    modals.add(_EditorModal(tab: tab, actions: actions, padding: padding, onDismiss: onDismiss));
    notifyListeners();
  }

  void closeModal({
    _EditorModal? modal,
    bool callOnDismiss = true,
  }) {
    if (modal != null) {
      if (callOnDismiss) modal.onDismiss?.call();
      modals.remove(modal);
    } else {
      if (modals.isEmpty) return;
      if (callOnDismiss) modals.last.onDismiss?.call();
      modals.removeLast();
    }
    notifyListeners();
  }

  void closeAllModals() {
    for (var modal in modals) {
      modal.onDismiss?.call();
    }
    modals.clear();
    notifyListeners();
  }

  static Widget _modalWidget(BuildContext context, {
    required _EditorModal editor,
    required void Function() onDismiss,
    required void Function() dismiss,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        EditorTab _tab = editor.tab(context, setState);
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Palette.of(context).surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                spreadRadius: 0,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 3
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onDismiss,
                          icon: Icon(RenderIcons.arrow_down)
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            _tab.tab,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    if (editor.actions != null) Row(
                      mainAxisSize: MainAxisSize.min,
                      children: editor.actions!(dismiss),
                    )
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: Editor.calculateSize(context).height,
                  maxHeight: MediaQuery.of(context).size.height/2.7,
                ),
                child: Padding(
                  padding: editor.padding ?? EdgeInsets.only(
                    left: 5,
                    right: 5,
                    // top: 20,
                    bottom: Constants.of(context).bottomPadding
                  ),
                  child: _tab.build(context),
                ),
              ),
            ],
          )
        );
      }
    );
  }

  @override
  void dispose() {
    page.removeListener(updateEditor);
    super.dispose();
  }

}

class _EditorModal {

  final EditorTab Function(BuildContext context, void Function(void Function()) setState) tab;
  final EdgeInsets? padding;
  final List<Widget> Function(void Function() dismiss)? actions;
  final void Function()? onDismiss;

  _EditorModal({required this.tab, this.actions, this.padding, this.onDismiss});

}

class PageEditorView extends StatefulWidget {

  const PageEditorView({super.key, required this.manager});

  final EditorManager manager;

  @override
  State<PageEditorView> createState() => PageEditorViewState();
}

class PageEditorViewState extends State<PageEditorView> {

  @override
  void initState() {
    super.initState();
    widget.manager.addListener(onUpdate);
  }

  @override
  void dispose() {
    widget.manager.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CreativeWidgetsShowcase(
          page: widget.manager.page,
        ),
        if (widget.manager.editor != null) FadeInUp(
          duration: kAnimationDuration,
          child: widget.manager.editor!
        ),
        for (var modal in widget.manager.modals) EditorManager._modalWidget(
          context,
          editor: modal,
          onDismiss: widget.manager.closeModal,
          dismiss: () {
            widget.manager.closeModal(modal: modal, callOnDismiss: false);
          },
        )
      ],
    );
  }

  void onUpdate() => setState(() { });

}