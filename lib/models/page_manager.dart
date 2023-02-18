import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:sprung/sprung.dart';

import '../rehmat.dart';

class PageManager extends PropertyChangeNotifier {
  
  PageManager(this.project) {
    controller.addListener(onPageChange);
  }
  final Project project;

  List<CreatorPage> pages = [];

  PageController controller = PageController();

  int currentPage = 0;

  int get length => pages.length;

  static int maxPages = 10;

  void add({
    bool silent = false
  }) {
    if (pages.length >= maxPages) return;
    pages.add(CreatorPage(project: project, isFirstPage: pages.isEmpty));
    if (pages.length > 1) controller.animateToPage(pages.length - 1, duration: Constants.animationDuration, curve: Sprung.overDamped);
    updateListeners();
    if (!silent) notifyListeners(PageViewChange.page);
  }

  void delete([List<int>? indices]) {
    if (indices == null) indices = [currentPage];
    pages.removeWhere((element) => indices!.contains(pages.indexOf(element)));
    if (pages.isEmpty) add();
    currentPage = 0;
    controller.animateToPage(currentPage, duration: Constants.animationDuration, curve: Sprung.overDamped);
    updateListeners();
    notifyListeners(PageViewChange.page);
  }

  Future<void> duplicate([int? index]) async {
    index ??= currentPage;
    if (pages.length >= maxPages) return;
    Map<String, dynamic> data = pages[index].toJSON();
    CreatorPage? duplicate = await CreatorPage.fromJSON(data, project: project);
    if (duplicate == null) return;
    pages.insert(index + 1, duplicate);
    updateListeners();
    notifyListeners(PageViewChange.page);
  }

  CreatorPage get current => pages[currentPage];

  void changePage(int value) {
    currentPage = value;
  }

  void onPageUpdate() {
    notifyListeners(PageViewChange.update);
  }

  void onPageChange() {
    currentPage = controller.page!.round();
    notifyListeners(PageViewChange.page);
  }

  void _addListeners() {
    for (var page in pages) {
      page.addListener(onPageUpdate, [PageChange.update, PageChange.misc, PageChange.selection]);
    }
  }

  void _removeListeners() {
    for (var page in pages) {
      page.widgets.removeListeners();
    }
  }

  void updateListeners() {
    _removeListeners();
    _addListeners();
  }

}

enum PageViewChange {
  page,
  update
}