import 'package:flutter/material.dart';

class Language {
  String code;
  String name;
  bool isSelected;

  Language({
    required this.code,
    required this.name,
    this.isSelected = false,
  });

  // Convert Language to Locale
  Locale get locale => Locale(code);
}
