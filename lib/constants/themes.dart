import 'package:flutter/material.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/utils/router_utils.dart';

class Themes {
  static bool isDark = false;

  static Map<bool, Color> scorePassed = {
    true: Color(0xff4cb6ac),
    false: Color(0xfff54337),
  };

  static ThemeData light() => ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        primaryColorBrightness: Brightness.light,
        primaryColorLight: Colors.white,
        primaryColorDark: Colors.white,
        accentColor: Configs.appThemeColor,
        accentColorBrightness: Brightness.light,
        canvasColor: Colors.grey[200],
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarColor: Colors.white,
        cardColor: Colors.white,
        toggleableActiveColor: Configs.appThemeColor,
        textSelectionColor: Configs.appThemeColor,
        cursorColor: Configs.appThemeColor,
        textSelectionHandleColor: Configs.appThemeColor,
        indicatorColor: Configs.appThemeColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          elevation: 1.0,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        primaryIconTheme: IconThemeData(
          color: Colors.black,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: const FadePageTransitionsBuilder(),
            TargetPlatform.android: const FadePageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData dark() => ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        primaryColorBrightness: Brightness.dark,
        primaryColorLight: Colors.grey[900],
        primaryColorDark: Colors.grey[900],
        accentColor: Configs.appThemeColor,
        accentColorBrightness: Brightness.dark,
        canvasColor: Colors.grey[900],
        scaffoldBackgroundColor: Colors.grey[900],
        bottomAppBarColor: Colors.grey[900],
        cardColor: Colors.grey[900],
        toggleableActiveColor: Configs.appThemeColor,
        textSelectionColor: Configs.appThemeColor,
        cursorColor: Configs.appThemeColor,
        textSelectionHandleColor: Configs.appThemeColor,
        indicatorColor: Configs.appThemeColor,
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          elevation: 1.0,
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[300],
        ),
        primaryIconTheme: IconThemeData(
          color: Colors.grey[300],
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.grey[300],
          unselectedLabelColor: Colors.grey[300],
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: const FadePageTransitionsBuilder(),
            TargetPlatform.android: const FadePageTransitionsBuilder(),
          },
        ),
      );
}
