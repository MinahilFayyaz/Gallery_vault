import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingProvider with ChangeNotifier {
  OnBoardingProvider() {
    getOnboardInfo();
    checkOnBoardingStatus();
  }
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(value) {
    _currentIndex = value;
    notifyListeners();
  }

  bool _isBoardingCompleate = false;
  bool get isBoardingCompleate => _isBoardingCompleate;
  set isBoardingCompleate(bool value) {
    _isBoardingCompleate = value;
    storeOnboardInfo();
    notifyListeners();
  }


  Future<void> checkOnBoardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isBoardingCompleate = prefs.getBool('onBoard') ?? false;
    notifyListeners();
  }

  Future<void> setOnBoardingStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onBoard', status);
    _isBoardingCompleate = status;
    notifyListeners();
  }


  void getOnboardInfoo() async {
    await checkOnBoardingStatus();
  }

  void storeOnboardInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onBoard', _isBoardingCompleate);
    log(_isBoardingCompleate.toString(), name: 'setonBoard');
  }

  void getOnboardInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isBoardingCompleate = prefs.getBool('onBoard') ?? false;
    log(isBoardingCompleate.toString(), name: 'onBoard');
  }
}