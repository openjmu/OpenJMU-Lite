///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-12-01 19:34
///
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'package:openjmu_lite/constants/constants.dart';

const String hiveBoxPrefix = 'openjmu_lite';

class HiveBoxes {
  const HiveBoxes._();

  static Box<Map<dynamic, dynamic>> coursesBox;
  static Box<String> courseRemarkBox;
  static Box<DateTime> startWeekBox;
  static Box<Map<dynamic, dynamic>> scoresBox;
  static Box<List<dynamic>> webAppsBox;

  static Box<dynamic> settingsBox;

  static Future<void> openBoxes() async {
    Hive
      ..registerAdapter(CourseAdapter())
      ..registerAdapter(ScoreAdapter())
      ..registerAdapter(WebAppAdapter());

    coursesBox = await Hive.openBox<Map<dynamic, dynamic>>('${hiveBoxPrefix}_user_courses');
    courseRemarkBox = await Hive.openBox<String>('${hiveBoxPrefix}_user_course_remark');
    startWeekBox = await Hive.openBox<DateTime>('${hiveBoxPrefix}_start_week');
    scoresBox = await Hive.openBox<Map<dynamic, dynamic>>('${hiveBoxPrefix}_user_scores');
    webAppsBox = await Hive.openBox<List<dynamic>>('${hiveBoxPrefix}_webapps');

    settingsBox = await Hive.openBox<dynamic>('${hiveBoxPrefix}_app_settings');
  }

  static Future<void> clearBoxes({BuildContext context}) async {
    bool confirm = true;
    if (context != null) {
      confirm = await ConfirmationBottomSheet.show(
        context,
        title: '清除应用数据',
        showConfirm: true,
        content: '清除数据会将您的所有应用内容（包括设置、应用消息）清除。\n确定继续吗？',
      );
    }
    if (confirm) {
      debugPrint('Clearing Hive Boxes...');
      await coursesBox?.clear();
      await courseRemarkBox?.clear();
      await scoresBox?.clear();
      await webAppsBox?.clear();
      await settingsBox?.clear();
      await startWeekBox?.clear();
      debugPrint('Boxes cleared');
      if (kReleaseMode) {
        unawaited(SystemNavigator.pop());
      }
    }
  }
}

class HiveAdapterTypeIds {
  const HiveAdapterTypeIds._();

  static const int appMessage = 0;
  static const int message = 1;
  static const int course = 2;
  static const int score = 3;
  static const int webapp = 4;
  static const int changelog = 5;
}
