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

  Editor? editor;

  void updateEditor() {
    if (page.widgets.nSelections == 0) {
      editor = null;
    } else if (page.widgets.nSelections == 1) {
      editor = page.widgets.selections.single.editor;
    } else {
      editor = page.widgets.background.editor;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    page.removeListener(updateEditor);
    super.dispose();
  }

}