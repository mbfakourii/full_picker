import 'package:flutter/material.dart';

class UpdateNavigation extends ChangeNotifier {
  var _currentPageIndex = 0;

  int get getPageIndex {
    return _currentPageIndex;
  }

  void updatePageIndex(value) {
    _currentPageIndex = value;
    notifyListeners();
  }
}
