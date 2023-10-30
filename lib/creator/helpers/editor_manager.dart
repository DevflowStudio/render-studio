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
    double height = (Theme.of(context).textTheme.bodySmall!.fontSize! * 1.2 * 2) + 6 + 70; // Height of a standard option icon button + padding
    return Size(double.infinity, height + verticalPadding);
  }

  Editor? _editor;
  Editor? _modalEditor;

  Editor get editor => _modalEditor ?? _editor ?? page.widgets.background.editor;

  void updateEditor() {
    if (page.widgets.nSelections == 0) {
      _editor = null;
    } else if (page.widgets.nSelections == 1) {
      _editor = page.widgets.selections.single.editor;
    } else {
      _editor = page.widgets.background.editor;
    }
    notifyListeners();
  }

  void openModal(Editor editor) {
    _modalEditor = editor;
    notifyListeners();
  }

  void closeModal() {
    _modalEditor = null;
    notifyListeners();
  }

  @override
  void dispose() {
    page.removeListener(updateEditor);
    super.dispose();
  }

}