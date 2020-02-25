///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/2/25 10:50
///
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:event_bus/event_bus.dart';

NavigatorState get navigatorState => Instances.navigatorKey.currentState;
BuildContext get currentContext => navigatorState.context;
ThemeData get currentTheme => Theme.of(currentContext);
Brightness get currentBrightness => Theme.of(currentContext).brightness;
Color get currentThemeColor => Theme.of(currentContext).accentColor;
bool get currentIsDark => currentBrightness == Brightness.dark;
int moreThanZero(num value) => math.max(0, value);
int moreThanOne(num value) => math.max(1, value);

class Instances {
  const Instances._();

  static final EventBus eventBus = EventBus();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;
  static ConnectivityResult connectivityResult;
}
