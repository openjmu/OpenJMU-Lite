import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:openjmu_lite/constants/constants.dart';

final math.Random _random = math.Random();

int next(int min, int max) => min + _random.nextInt(max - min);

enum CourseType {
  ///
  /// [Course] for current day.
  /// This type of course will only display courses
  /// belong to the current ***day***.
  ///
  today,

  ///
  /// [Course] for current week.
  /// This type of course will only display courses
  /// belong to the current ***week***.
  ///
  week,

  ///
  /// [Course] for current term.
  /// This type of course will only display courses
  /// belong to the current ***term***.
  ///
  term
}

class CourseAPI {
  static TimeOfDay _time(int hour, int minute) =>
      TimeOfDay(hour: hour, minute: minute);
  static double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

  static Set<CourseColor> coursesUniqueColor = {};

  static Future<Response<String>> getCourse() async => NetUtils.get(
        API.courseScheduleCourses,
        data: <String, dynamic>{'sid': currentUser.sid},
      );

  static Future<Response<String>> getRemark() async => NetUtils.get(
        API.courseScheduleClassRemark,
        data: <String, dynamic>{'sid': currentUser.sid},
      );

  static bool inReadyTime(Course course) {
    double timeNow = _timeToDouble(TimeOfDay.now());
    List<TimeOfDay> times = courseTime[course.time.toInt()];
    double start = _timeToDouble(times[0]);
    return start - timeNow <= 0.5 && start - timeNow > 0;
  }

  static bool inCurrentTime(Course course) {
    final double timeNow = _timeToDouble(TimeOfDay.now()) - (1 / 60);
    List<TimeOfDay> times = courseTime[course.time.toInt()];
    final double start = _timeToDouble(times[0]);
    double end = _timeToDouble(times[1]) - (1 / 60);
    if (course.isEleven) end = _timeToDouble(courseTime[11][1]);
    return start <= timeNow && end >= timeNow;
  }

  static bool inCurrentDay(Course course) {
    DateTime now = DateTime.now();
    return course.day == now.weekday;
  }

  static bool inCurrentWeek(Course course, {int currentWeek}) {
    final provider = Provider.of<DateProvider>(currentContext, listen: false);
    final int week = currentWeek ?? provider.currentWeek ?? 0;
    bool result;
    bool inRange = week >= course.startWeek && week <= course.endWeek;
    bool isOddEven = course.oddEven != 0;
    if (isOddEven) {
      if (course.oddEven == 1) {
        result = inRange && week.isOdd;
      } else if (course.oddEven == 2) {
        result = inRange && week.isEven;
      }
    } else {
      result = inRange;
    }
    return result;
  }

  static bool isFinished(Course course) {
    double timeNow = _timeToDouble(TimeOfDay.now());
    List<TimeOfDay> times = courseTime[course.time.toInt()];
    double end = _timeToDouble(times[1]);
    return end < timeNow;
  }

  static bool isActive(Course course) {
    return inCurrentTime(course) &&
        inCurrentDay(course) &&
        inCurrentWeek(course);
  }

  static bool notifyFirst(Course course) {
    double timeToNotify = _timeToDouble(
        TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 30))));
    double start = _timeToDouble(courseTime[course.time.toInt()][0]);
    return timeToNotify == start;
  }

  static bool notifySecond(Course course) {
    double timeToNotify = _timeToDouble(
        TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 5))));
    double start = _timeToDouble(courseTime[course.time.toInt()][0]);
    return timeToNotify == start;
  }

  static Map<int, List<TimeOfDay>> courseTime = {
    1: [_time(08, 00), _time(08, 45)],
    2: [_time(08, 50), _time(09, 35)],
    3: [_time(10, 05), _time(10, 50)],
    4: [_time(10, 55), _time(11, 40)],
    5: [_time(14, 00), _time(14, 45)],
    6: [_time(14, 50), _time(15, 35)],
    7: [_time(15, 55), _time(16, 40)],
    8: [_time(16, 45), _time(17, 30)],
    9: [_time(19, 00), _time(19, 45)],
    10: [_time(19, 50), _time(20, 35)],
    11: [_time(20, 40), _time(21, 25)],
    12: [_time(21, 30), _time(22, 15)],
  };

  static Map<String, String> courseTimeChinese = {
    '1': '一二节',
    '12': '一二节',
    '3': '三四节',
    '34': '三四节',
    '5': '五六节',
    '56': '五六节',
    '7': '七八节',
    '78': '七八节',
    '9': '九十节',
    '90': '九十节',
    '11': '十一节',
    '911': '九十十一节',
  };

  static Map<int, String> courseDayTime = {
    1: "一",
    2: "二",
    3: "三",
    4: "四",
    5: "五",
    6: "六",
    7: "日",
  };

  static String getCourseTime(
      BuildContext context, Course course, CourseType type) {
    List<TimeOfDay> times = courseTime[course.time.toInt()];
    TimeOfDay start = times[0], end = times[1];
    if (course.isEleven) end = courseTime[11][1];
    String result;
    switch (type) {
      case CourseType.today:
        String _time = courseTimeChinese[course.time];
        if (course.isEleven)
          _time = "${_time.substring(0, 1)}至${courseTimeChinese["11"]}";
        result = "${start.format(context)} - ${end.format(context)}　$_time";
        break;
      case CourseType.week:
        result =
            "${start.format(context)} - ${end.format(context)}　星期${courseDayTime[course.day]}";
        break;
      case CourseType.term:
        result = "${start.format(context)} - ${end.format(context)}"
            "　"
            "周${courseDayTime[course.day]}"
            "　"
            "${course.startWeek}-${course.endWeek}"
            "${course.oddEven != 0 ? course.oddEven == 1 ? "单" : "双" : ""}周";
        break;
    }
    return result;
  }

  static String getCourseLocation(
      BuildContext context, Course course, CourseType type) {
    String location = course.location;
    String result;
    switch (type) {
      case CourseType.term:
        result = "${courseTimeChinese[course.time]}　${course.location}";
        break;
      default:
        result = "$location";
    }
    return result;
  }

  static final List<Color> courseColorsList = [
    Color(0xffEF9A9A),
    Color(0xffF48FB1),
    Color(0xffCE93D8),
    Color(0xffB39DDB),
    Color(0xff9FA8DA),
    Color(0xff90CAF9),
    Color(0xff81D4FA),
    Color(0xff80DEEA),
    Color(0xff80CBC4),
    Color(0xffA5D6A7),
    Color(0xffC5E1A5),
    Color(0xffE6EE9C),
    Color(0xffFFF59D),
    Color(0xffFFE082),
    Color(0xffFFCC80),
    Color(0xffFFAB91),
    Color(0xffBCAAA4),
    Color(0xffd8b5df),
    Color(0xff68c0ca),
    Color(0xff05bac3),
    Color(0xffe98b81),
    Color(0xffd86f5c),
    Color(0xfffed68e),
    Color(0xfff8b475),
    Color(0xffc16594),
    Color(0xffaccbd0),
    Color(0xffe6e5d1),
    Color(0xffe5f3a6),
    Color(0xfff6af9f),
    Color(0xfffb5320),
    Color(0xff20b1fb),
    Color(0xff3275a9),
  ];

  static Color randomCourseColor() =>
      courseColorsList[next(0, courseColorsList.length)];
}
