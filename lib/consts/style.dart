// import 'package:flutter/material.dart';
//
// class Styles {
//   static ThemeData themeData(
//       {required bool isDarkTheme, required BuildContext context}) {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: isDarkTheme ? Brightness.dark : Brightness.light,
//       visualDensity: VisualDensity.adaptivePlatformDensity,
//       // colorScheme: ColorScheme.fromSeed(
//       //   seedColor: Color(0xfffff6e40),
//       //   brightness: isDarkTheme ? Brightness.dark : Brightness.light,
//       // ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import 'consts.dart';

class Styles {
  static ThemeData themeData(
      {required bool isDarkTheme, required BuildContext context}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Define color scheme for light and dark modes
      colorScheme: isDarkTheme
          ? ColorScheme.dark(
        primary: Consts.COLOR,
        secondary: Consts.COLOR,
        background: Consts.BG_COLOR,
        surface: Consts.FG_COLOR,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
      )
          : ColorScheme.light(
        primary: Consts.COLOR,
        secondary: Consts.COLOR,
        background: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Color(0xFF222222),
        onBackground: Color(0xFF222222),
        onSurface: Color(0xFF222222),
      ),
    );
  }
}
