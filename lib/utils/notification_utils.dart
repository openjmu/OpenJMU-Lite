import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:openjmu_lite/constants/configs.dart';

import 'package:openjmu_lite/constants/constants.dart';

class NotificationUtils {
  static FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static void initSettings() {
    AndroidInitializationSettings _settingsAndroid =
        AndroidInitializationSettings('notification');
    IOSInitializationSettings _settingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: _onReceive,
    );
    InitializationSettings _settings = InitializationSettings(
      _settingsAndroid,
      _settingsIOS,
    );
    NotificationUtils.plugin
        .initialize(_settings, onSelectNotification: _onSelect);
  }

  static Future show(String title, String body) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'openjmu_channel',
      'openjmu_course',
      'Channel for course notification.',
      importance: Importance.Max,
      priority: Priority.High,
      color: Configs.appThemeColor,
      ticker: 'ticker',
    );
    IOSNotificationDetails iOSDetails = IOSNotificationDetails();
    NotificationDetails _details = NotificationDetails(
      androidDetails,
      iOSDetails,
    );
    await NotificationUtils.plugin.show(0, title, body, _details);
  }

  static Future cancelAll() async {
    await NotificationUtils.plugin.cancelAll();
  }

  static Future _onReceive(
    int id,
    String title,
    String body,
    String payload,
  ) async {}

  static Future _onSelect(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }
}
