import 'package:flutter/material.dart';

import 'GeneralData.dart';

class ThemeInfo {
  static List<ThemeData> themesData = [
    ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.amber,
      accentColor: Colors.amber[900],
      toggleableActiveColor: colorIconActive,
    ),
    ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.amber,
      accentColor: Colors.amber[900],
      toggleableActiveColor: colorIconActive,
    ),
  ];

  static const TextStyle textNameButtonActive = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 1),
    fontSize: 16,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    fontFamily: "Roboto",
  );

  static TextStyle get textNameButtonInActive {
    if (gd.currentTheme.brightness == Brightness.light) {
      return textNameButtonActive.copyWith(color: Color.fromRGBO(0, 0, 0, 0.5));
    } else {
      return textNameButtonActive.copyWith(
          color: Color.fromRGBO(255, 255, 255, 0.5));
    }
  }

  static const TextStyle textStatusButtonActive = TextStyle(
    color: Color.fromRGBO(0, 0, 0, 0.5),
    fontSize: 16,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontFamily: "Roboto",
  );

  static TextStyle get textStatusButtonInActive {
    if (gd.currentTheme.brightness == Brightness.light) {
      return textStatusButtonActive.copyWith(
          color: Color.fromRGBO(0, 0, 0, 0.5));
    } else {
      return textStatusButtonActive.copyWith(
          color: Color.fromRGBO(255, 255, 255, 0.5));
    }
  }

  static TextStyle get pickerActivateStyle {
    return textStatusButtonActive.copyWith(color: Colors.amberAccent);
  }

  static const Color colorBackgroundActive =
      Color.fromRGBO(255, 255, 255, 0.75);

  static Color get colorEntityBackground {
    if (gd.currentTheme.brightness == Brightness.light) {
      return Color.fromRGBO(255, 255, 255, 0.5);
    } else {
      return Color.fromRGBO(0, 0, 0, 0.5);
    }
  }

  static Color get colorBottomSheet {
    if (gd.currentTheme.brightness == Brightness.light) {
      return Color.fromRGBO(255, 255, 255, 1);
    } else {
      return Color.fromRGBO(28, 28, 28, 1);
    }
  }

  static Color get colorBottomSheetReverse {
    if (gd.currentTheme.brightness == Brightness.dark) {
      return Color.fromRGBO(255, 255, 255, 1);
    } else {
      return Color.fromRGBO(28, 28, 28, 1);
    }
  }

//  static const Color colorIconActive = Color.fromRGBO(255, 204, 51, 1);
  static const Color colorIconActive = Color(0xffFFB300);
  static const Color colorIconInActive = Color.fromRGBO(153, 153, 153, 1);
//  static const Color colorIconInActive = Color(0xffFFF8E1);

//  static const Color colorTemp01 = Color.fromRGBO(100, 181, 246, 1);
  static const Color colorTemp01 = Color(0xff42A5F5);
//  static const Color colorTemp02 = Color.fromRGBO(77, 182, 172, 1);
  static const Color colorTemp02 = Color(0xff26C6DA);
//  static const Color colorTemp03 = Color.fromRGBO(129, 199, 132, 1);
  static const Color colorTemp03 = Color(0xff66BB6A);
//  static const Color colorTemp04 = Color.fromRGBO(255, 241, 118, 1);
  static const Color colorTemp04 = Color(0xffFFEE58);
//  static const Color colorTemp05 = Color.fromRGBO(229, 115, 115, 1);
  static const Color colorTemp05 = Color(0xffEF5350);
}
