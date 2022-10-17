import 'package:flutter/material.dart';

import '../rehmat.dart';

class AppState extends ChangeNotifier {

  ThemeData _theme = AppTheme.build(brightness: Brightness.light);

  int toggle = 0;

  ThemeData get theme => _theme;
  
  void toggleTheme() {
    if (toggle == 0) {
      _theme = AppTheme.build(brightness: Brightness.dark);
      toggle += 1;
    } else if (toggle == 1) {
      _theme = AppTheme.build(brightness: Brightness.light, seed: Colors.red);
      toggle += 1;
    } else if (toggle == 2) {
      _theme = AppTheme.build(brightness: Brightness.dark, seed: Colors.red);
      toggle += 1;
    } else if (toggle == 3) {
      _theme = AppTheme.build(brightness: Brightness.light, seed: Colors.blue);
      toggle += 1;
    } else if (toggle == 4) {
      _theme = AppTheme.build(brightness: Brightness.dark, seed: Colors.blue);
      toggle += 1;
    } else {
      _theme = AppTheme.build(brightness: Brightness.light);
      toggle = 0;
    }
    notifyListeners();
  }

}