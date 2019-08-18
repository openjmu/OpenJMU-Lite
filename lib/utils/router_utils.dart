import 'package:flutter/material.dart';

// Routes Pages
import 'package:openjmu_lite/pages/login_page.dart';
import 'package:openjmu_lite/pages/main_page.dart';
import 'package:openjmu_lite/pages/splash_page.dart';

class RouterUtils {
    static final String pathDivider = "/";

    static Map<String, WidgetBuilder> routes = {
        "${pathDivider}splash": (BuildContext context) => SplashPage(),
        "${pathDivider}login": (BuildContext context) => LoginPage(),
        "${pathDivider}main": (BuildContext context) => MainPage(),
    };
}
