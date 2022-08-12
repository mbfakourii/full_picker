import 'package:flutter/material.dart';
import '../model/country.dart';

class UpdateCountryCode extends ChangeNotifier {
  int _skip = 0;

  int get skip => _skip;

  set skip(int value) {
    _skip = value;
    notifyListeners();
  }

  dynamic _backState;

  dynamic get backState => _backState;

  set backState(dynamic value) {
    _backState = value;
    notifyListeners();
  }

  void updateListview(List<Country> country, context, int pageKey, pagingController) {
    try {
      final isLastPage = country.length < 20;
      if (isLastPage) {
        pagingController.appendLastPage(country);
      } else {
        final nextPageKey = pageKey + 1;
        skip = nextPageKey;
        pagingController.appendPage(country, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }

    notifyListeners();
  }
}
