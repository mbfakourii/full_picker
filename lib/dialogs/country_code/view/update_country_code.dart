import 'package:flutter/material.dart';
import '../model/country.dart';

// ignore_for_file: prefer_final_fields
class UpdateCountryCode extends ChangeNotifier {
  List<Country> _listCountries = [];
  bool _canLoadMore = false;
  bool _isLoading = true;
  int _skip = 0;
  bool _nowSearch = false;
  String _lastTextSearch = "";

  String get lastTextSearch => _lastTextSearch;

  bool get nowSearch => _nowSearch;

  int get skip => _skip;

  bool get canLoadMore => _canLoadMore;

  List<Country> get getCountries => _listCountries;


  bool get isLoading => _isLoading;

  dynamic _backState;


  dynamic get backState => _backState;

  set backState(dynamic value) {
    _backState = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set lastTextSearch(String value) {
    _lastTextSearch = value;
    notifyListeners();
  }

  set nowSearch(bool value) {
    _nowSearch = value;
    notifyListeners();
  }

  set skip(int value) {
    _skip = value;
    notifyListeners();
  }

  set canLoadMore(value) {
    _canLoadMore = value;
    notifyListeners();
  }

  void updateListview(List<Country> country, context) {
    // print(country.first.name);
    _listCountries += country;
    // print(_listCountries.length);
    try {
      if (country.length < 20) {
        isLoading = true;
      }else{
        isLoading = false;
      }
    } catch (e) {
      isLoading = false;
    }

    notifyListeners();
  }

  void clearData() {
    _listCountries.clear();
    _isLoading = true;

    notifyListeners();
  }
}
