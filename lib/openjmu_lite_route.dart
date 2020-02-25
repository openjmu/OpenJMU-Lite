// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************

import 'package:flutter/widgets.dart';

import 'pages/main_page.dart';
import 'pages/login_page.dart';
import 'pages/settings_page.dart';
import 'pages/about_page.dart';
import 'pages/scan_qrcode_page.dart';
import 'widgets/in_app_webview.dart';

RouteResult getRouteResult({String name, Map<String, dynamic> arguments}) {
  switch (name) {
    case "openjmu-lite://about":
      return RouteResult(
        widget: AboutPage(),
        routeName: "关于页",
      );
    case "openjmu-lite://inappbrowser":
      return RouteResult(
        widget: InAppBrowserPage(
          url: arguments['url'],
          title: arguments['title'],
          app: arguments['app'],
          withCookie: arguments['withCookie'],
          withAppBar: arguments['withAppBar'],
          withAction: arguments['withAction'],
          withScaffold: arguments['withScaffold'],
          keepAlive: arguments['keepAlive'],
        ),
        routeName: "网页浏览",
      );
    case "openjmu-lite://login-page":
      return RouteResult(
        widget: LoginPage(),
        routeName: "登录页",
      );
    case "openjmu-lite://main-page":
      return RouteResult(
        widget: MainPage(),
        routeName: "首页",
      );
    case "openjmu-lite://scan-qrcode":
      return RouteResult(
        widget: ScanQrCodePage(),
        routeName: "扫描二维码",
      );
    case "openjmu-lite://settings-page":
      return RouteResult(
        widget: SettingsPage(),
        routeName: "设置页",
      );
    default:
      return RouteResult();
  }
}

class RouteResult {
  /// The Widget return base on route
  final Widget widget;

  /// Whether show this route with status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  const RouteResult({
    this.widget,
    this.showStatusBar = true,
    this.routeName = '',
    this.pageRouteType,
    this.description = '',
  });
}

enum PageRouteType { material, cupertino, transparent }

List<String> routeNames = [
  "openjmu-lite://about",
  "openjmu-lite://inappbrowser",
  "openjmu-lite://login-page",
  "openjmu-lite://main-page",
  "openjmu-lite://scan-qrcode",
  "openjmu-lite://settings-page"
];

class Routes {
  const Routes._();

  /// 关于页
  ///
  /// [name] : openjmu-lite://about
  /// [routeName] : 关于页
  static const String OPENJMU_LITE_ABOUT = "openjmu-lite://about";

  /// 网页浏览
  ///
  /// [name] : openjmu-lite://inappbrowser
  /// [routeName] : 网页浏览
  /// [arguments] : [url, title, app, withCookie, withAppBar, withAction, withScaffold, keepAlive]
  static const String OPENJMU_LITE_INAPPBROWSER = "openjmu-lite://inappbrowser";

  /// 登录页
  ///
  /// [name] : openjmu-lite://login-page
  /// [routeName] : 登录页
  static const String OPENJMU_LITE_LOGIN_PAGE = "openjmu-lite://login-page";

  /// 首页
  ///
  /// [name] : openjmu-lite://main-page
  /// [routeName] : 首页
  static const String OPENJMU_LITE_MAIN_PAGE = "openjmu-lite://main-page";

  /// 扫描二维码
  ///
  /// [name] : openjmu-lite://scan-qrcode
  /// [routeName] : 扫描二维码
  static const String OPENJMU_LITE_SCAN_QRCODE = "openjmu-lite://scan-qrcode";

  /// 设置页
  ///
  /// [name] : openjmu-lite://settings-page
  /// [routeName] : 设置页
  static const String OPENJMU_LITE_SETTINGS_PAGE = "openjmu-lite://settings-page";
}
