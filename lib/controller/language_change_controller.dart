import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeController with ChangeNotifier {
  Locale? _appLocale;
  Locale? get appLocale => _appLocale;
  LanguageChangeController() {
    fetchLocale();
  }

  Future<void> changeLanguage(Locale type) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    String languageCode = type.languageCode;
    String? countryCode = type.countryCode;

    if (type == Locale('en')) {
      await sp.setString('language_code', 'en');
    } else if (type == Locale('ar')) {
      await sp.setString('language_code', 'ar');
    } else if (type == Locale('bn')) {
      await sp.setString('language_code', 'bn');
    } else if (type == Locale('de')) {
      await sp.setString('language_code', 'de');
    } else if (type == Locale('fa')) {
      await sp.setString('language_code', 'fa');
    } else if (type == Locale('fr')) {
      await sp.setString('language_code', 'fr');
    } else if (type == Locale('ga')) {
      await sp.setString('language_code', 'ga');
    } else if (type == Locale('hi')) {
      await sp.setString('language_code', 'hi');
    } else if (type == Locale('id')) {
      await sp.setString('language_code', 'id');
    } else if (type == Locale('it')) {
      await sp.setString('language_code', 'it');
    } else if (type == Locale('ja')) {
      await sp.setString('language_code', 'ja');
    } else if (type == Locale('ko')) {
      await sp.setString('language_code', 'ko');
    } else if (type == Locale('ms')) {
      await sp.setString('language_code', 'ms');
    } else if (type == Locale('nl')) {
      await sp.setString('language_code', 'nl');
    } else if (type == Locale('pl')) {
      await sp.setString('language_code', 'pl');
    } else if (type == Locale('pt')) {
      await sp.setString('language_code', 'pt');
    } else if (type == Locale('ro')) {
      await sp.setString('language_code', 'ro');
    } else if (type == Locale('ru')) {
      await sp.setString('language_code', 'ru');
    } else if (type == Locale('th')) {
      await sp.setString('language_code', 'th');
    } else if (type == Locale('tr')) {
      await sp.setString('language_code', 'tr');
    } else if (type == Locale('ur')) {
      await sp.setString('language_code', 'ur');
    } else {
      await sp.setString('language_code', 'zh');
    }

    //String languageCode = languageCodeMap[type.languageCode] ?? 'en';
    await sp.setString('language_code', languageCode);
    print('Stored Language Code: $languageCode');
    _appLocale = type;
    fetchLocale();
    notifyListeners();
  }


  fetchLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    _appLocale = languageCode != null ? Locale(languageCode) : Locale('en');
    notifyListeners();
    print('Language code in fetch locale: $languageCode');
    print('Fetching locale...');
  }
}
