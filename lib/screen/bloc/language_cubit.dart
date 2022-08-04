import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../../generated/l10n.dart';

String currentLanguage = "${LanguageCubit.baseLanguage.languageCode}_${LanguageCubit.baseLanguage.countryCode ?? ""}";
bool currentLanguageIsSystemLocal = false;

class LanguageCubit extends Cubit<Locale> {
  static Locale baseLanguage = const Locale("en", "");

  LanguageCubit() : super(baseLanguage);

  void changeStartLanguage({bool checkCountryCodeInSystemLocal = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isSystemLocal = prefs.getBool('isSystemLocal');
    if (isSystemLocal != null) {
      if (isSystemLocal) {
        List<dynamic> list = getSystemLocal(checkCountryCodeInSystemLocal: checkCountryCodeInSystemLocal);
        currentLanguageIsSystemLocal = true;
        currentLanguage = list[0] + "_" + list[1];
        emit(Locale(list[0], list[1]));
      } else {
        String? languageCode = prefs.getString('languageCode');
        String? countryCode = prefs.getString('countryCode');

        if (languageCode != null) {
          currentLanguageIsSystemLocal = false;
          currentLanguage = "${languageCode}_${countryCode ?? ""}";

          emit(Locale(languageCode, countryCode));
        }
      }
    }
  }

  List<dynamic> getSystemLocal({required bool checkCountryCodeInSystemLocal}) {
    bool isSystemLocal = false;
    String languageCode = "";
    String countryCode = "";

    Locale systemLocal = Locale(
        Platform.localeName.split('_')[0], checkCountryCodeInSystemLocal ? Platform.localeName.split('_')[1] : "");

    for (var element in S.delegate.supportedLocales) {
      if (element == systemLocal) {
        isSystemLocal = true;
        languageCode = systemLocal.languageCode;
        countryCode = systemLocal.countryCode ?? "";
        continue;
      }
    }

    if (languageCode == "") {
      languageCode = baseLanguage.languageCode;
      countryCode = baseLanguage.countryCode ?? "";
    }

    return [languageCode, countryCode, isSystemLocal];
  }

  void changeLanguage(context,
      {required String languageCode, String countryCode = "", bool checkCountryCodeInSystemLocal = false}) async {
    bool isSystemLocal = false;
    if (languageCode == "") {
      List<dynamic> list = getSystemLocal(checkCountryCodeInSystemLocal: checkCountryCodeInSystemLocal);
      languageCode = list[0];
      countryCode = list[1];
      isSystemLocal = list[2];
    }

    emit(Locale(languageCode, countryCode));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    currentLanguageIsSystemLocal = isSystemLocal;
    currentLanguage = "${languageCode}_$countryCode";

    await prefs.setString('languageCode', languageCode);
    await prefs.setString('countryCode', countryCode);
    await prefs.setBool('isSystemLocal', isSystemLocal);
  }
}
