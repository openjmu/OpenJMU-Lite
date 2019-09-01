import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/localications/cupertino_zh.dart';
import 'package:openjmu_lite/pages/splash_page.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/utils/notification_utils.dart';
import 'package:openjmu_lite/utils/router_utils.dart';
import 'package:openjmu_lite/utils/shared_preference_utils.dart';


void main() async {
    await SpUtils.initSharedPreferences();
    runApp(LiteApp());
}

class LiteApp extends StatefulWidget {
    @override
    _LiteAppState createState() => _LiteAppState();
}

class _LiteAppState extends State<LiteApp> {
    @override
    void initState() {
        NetUtils.initConfig();
        NotificationUtils.initSettings();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: Constants.appTitle,
            routes: RouterUtils.routes,
            theme: ThemeData(
                primarySwatch: Colors.red,
                appBarTheme: AppBarTheme(
                    color: Constants.appThemeColor,
                ),
                pageTransitionsTheme: PageTransitionsTheme(
                    builders: {
                        TargetPlatform.iOS: FadePageTransitionsBuilder(),
                        TargetPlatform.android: FadePageTransitionsBuilder(),
                    },
                ),
            ),
            home: SplashPage(),
            localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                ChineseCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
                const Locale('zh'),
                const Locale('en'),
            ],
        );
    }
}
