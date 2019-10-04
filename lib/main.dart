import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/configs.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:openjmu_lite/localications/cupertino_zh.dart';
import 'package:openjmu_lite/pages/splash_page.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/utils/notification_utils.dart';
import 'package:openjmu_lite/utils/router_utils.dart';
import 'package:openjmu_lite/utils/shared_preference_utils.dart';
import 'package:openjmu_lite/utils/theme_utils.dart';


void main() async {
    await NotificationPermissions.getNotificationPermissionStatus();
    await SpUtils.initSharedPreferences();
    runApp(LiteApp());
}

class LiteApp extends StatefulWidget {
    @override
    _LiteAppState createState() => _LiteAppState();
}

class _LiteAppState extends State<LiteApp> {
    final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
    final Color currentThemeColor = Configs.appThemeColor;

    bool isDark = ThemeUtils.spGetBrightnessDark();

    @override
    void initState() {
        NetUtils.initConfig();
        NotificationUtils.initSettings();
        setBrightness();
        Constants.eventBus
            ..on<BrightnessChangedEvent>().listen((event) {
                isDark = event.isDark;
                if (mounted) setState(() {});
            })
            ..on<LogoutEvent>().listen((event) {
                isDark = false;
                if (mounted) setState(() {});
            })
        ;
        super.initState();
    }

    void setBrightness() {
        if (isDark == null) {
            Themes.isDark = isDark = false;
            if (mounted) setState(() {});
            ThemeUtils.spSetBrightnessDark(false);
        } else {
            Themes.isDark = isDark;
            if (mounted) setState(() {});
        }
    }


    @override
    Widget build(BuildContext context) {
        Constants.navigatorKey = _navigatorKey;
        return MaterialApp(
            navigatorKey: _navigatorKey,
            title: Configs.appTitle,
            routes: RouterUtils.routes,
            theme: isDark ? Themes.dark() : Themes.light(),
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
