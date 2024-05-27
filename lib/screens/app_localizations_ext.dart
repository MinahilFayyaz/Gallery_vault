import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsExtension on AppLocalizations {
  String getValue(String key) {
    switch (key) {
      case 'value1':
        return value1;
      case 'value2':
        return value2;
      case 'value3':
        return value3;
      case 'value4':
        return value4;
      case 'value5':
        return value5;
      case 'value6':
        return value6;
      case 'value7':
        return value7;
      case 'value8':
        return value8;
      case 'value9':
        return value9;
      case 'value0':
        return value0;
      default:
        return 'Translation not found';
    }
  }
}
