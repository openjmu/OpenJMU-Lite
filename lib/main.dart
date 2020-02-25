import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:notification_permissions/notification_permissions.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/pages/no_route_page.dart';
import 'package:openjmu_lite/pages/splash_page.dart';
import 'package:path_provider/path_provider.dart';

import 'openjmu_lite_route_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  await HiveBoxes.openBoxes();
  await NotificationPermissions.getNotificationPermissionStatus();

  await DeviceUtils.initDeviceInfo();
  NetUtils.initConfig();
  NotificationUtils.initSettings();
  await SpUtils.initSharedPreferences();
  await PackageUtils.initPackageInfo();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));

  runApp(LiteApp());
}

class LiteApp extends StatefulWidget {
  @override
  _LiteAppState createState() => _LiteAppState();
}

class _LiteAppState extends State<LiteApp> {
  final Color currentThemeColor = Configs.appThemeColor;

  bool isDark = ThemeUtils.spGetBrightnessDark();

  @override
  void initState() {
    super.initState();

    setBrightness();

    Instances.eventBus
      ..on<BrightnessChangedEvent>().listen((event) {
        isDark = event.isDark;
        if (mounted) setState(() {});
      })
      ..on<TicketGotEvent>().listen((event) {
        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            Provider.of<CoursesProvider>(currentContext, listen: false).initCourses();
            Provider.of<ScoresProvider>(currentContext, listen: false).initScore();
          }
        }
        Provider.of<WebAppsProvider>(currentContext, listen: false).initApps();
      })
      ..on<LogoutEvent>().listen((event) {
        isDark = false;
        if (mounted) setState(() {});

        if (!currentUser.isTeacher) {
          if (!currentUser.isPostgraduate) {
            Provider.of<CoursesProvider>(currentContext, listen: false).unloadCourses();
            Provider.of<ScoresProvider>(currentContext, listen: false).unloadScore();
          }
        }
        Provider.of<WebAppsProvider>(currentContext, listen: false).unloadApps();
      });
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
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        navigatorKey: Instances.navigatorKey,
        builder: (c, w) {
          ScreenUtil.init(c, allowFontScaling: true);
          return NoScaleTextWidget(child: w);
        },
        title: Configs.appTitle,
        theme: isDark ? Themes.dark() : Themes.light(),
        home: SplashPage(),
        navigatorObservers: [FFNavigatorObserver()],
        onGenerateRoute: (RouteSettings settings) => onGenerateRouteHelper(
          settings,
          notFoundFallback: NoRoutePage(route: settings.name),
        ),
        localizationsDelegates: Constants.localizationsDelegates,
        supportedLocales: Constants.supportedLocales,
      ),
    );
  }
}
