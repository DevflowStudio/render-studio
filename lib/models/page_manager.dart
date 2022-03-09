import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';

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

  void add() {
    pages.add(CreatorPage(project: project));
    if (pages.length > 1) controller.animateToPage(pages.length - 1, duration: Constants.animationDuration, curve: Curves.easeInOut);
    updateListeners();
  }

  void delete() {
    pages.removeAt(currentPage);
    if (currentPage >= pages.length) currentPage -= 1;
    controller.animateToPage(currentPage, duration: Constants.animationDuration, curve: Curves.easeInOut);
    updateListeners();
    notifyListeners();
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
      page.addListener(onPageUpdate, [PageChange.update]);
      page.addListener(onPageUpdate, [PageChange.selection]);
    }
  }

  void _removeListeners() {
    for (var page in pages) {
      page.removeListeners();
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