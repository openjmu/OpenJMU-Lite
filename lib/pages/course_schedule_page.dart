import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:intl/intl.dart';

import 'package:openjmu_lite/constants/constants.dart';

class CourseSchedulePage extends StatefulWidget {
  @override
  _CourseSchedulePageState createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends State<CourseSchedulePage>
    with TickerProviderStateMixin {
  bool loading = true, loaded = false;
  List<Course> courses;
  List<Course> coursesToday;
  List<Course> coursesWeek;
  Set<String> coursePushed = <String>{};
  TabController _tabController;
  Timer _courseRefreshTimer;

  String hello = "你好";
  Timer updateHelloTimer;

  @override
  void initState() {
    _tabController =
        TabController(length: CourseType.values.length, vsync: this);
    getCourses();
    _courseRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
      getCourses();
    });

    super.initState();
  }

  @override
  void dispose() {
    _courseRefreshTimer?.cancel();
    updateHelloTimer?.cancel();
    super.dispose();
  }

  Widget currentDay() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<DateProvider>(
        builder: (_, DateProvider provider, __) {
          return RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: "今天是"),
                TextSpan(
                    text:
                        "${DateFormat("MMMdd日，", "zh_CN").format(provider.now)}"),
                TextSpan(
                    text:
                        "${DateFormat("EEEE，", "zh_CN").format(provider.now)}"),
                if (provider.currentWeek != null)
                  if (provider.currentWeek >= 1 && provider.currentWeek <= 20)
                    TextSpan(text: "第${provider.currentWeek}周")
                  else if (provider.currentWeek == 0)
                    TextSpan(text: "下周开学")
                  else if (provider.currentWeek < 0)
                    TextSpan(text: "距离开学还有${provider.currentWeek}周"),
                TextSpan(text: "。"),
              ],
              style: TextStyle(
                color: Colors.grey[350],
                fontSize: 16.0,
              ),
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  void getCourses() async {
    try {
      Map<String, dynamic> data = jsonDecode((await NetUtils.get(
        API.courseScheduleCourses,
        data: {"sid": UserAPI.currentUser.sid},
      ))
          .data);
      List _courses = data['courses'];
      List<Course> _list = [], _listToday = [], _listWeek = [];
      _courses.forEach((course) {
        Course _c = Course.fromJson(course);
        _list.add(_c);
        if (CourseAPI.inCurrentDay(_c) && CourseAPI.inCurrentWeek(_c))
          _listToday.add(_c);
        if (CourseAPI.inCurrentWeek(_c)) _listWeek.add(_c);
      });
      courses = _list;
      coursesToday = _listToday;
      coursesWeek = _listWeek;
      getCoursesPush();
      loading = false;
      if (mounted) setState(() {});
    } catch (e) {
      trueDebugPrint("$e");
    }
  }

  void getCoursesPush() async {
    Course _pushCourse;
    for (int i = 0; i < coursesToday.length; i++) {
      Course _c = coursesToday[i];
      if (!CourseAPI.isFinished(_c) && !CourseAPI.isActive(_c)) {
        if (!coursePushed.contains(_c.uniqueId)) {
          _pushCourse = _c;
          break;
        }
      }
    }
    if (_pushCourse != null) {
      if (CourseAPI.notifyFirst(_pushCourse)) {
        List<TimeOfDay> times = CourseAPI.courseTime[_pushCourse.time.toInt()];
        TimeOfDay start = times[0], end = times[1];
        if (_pushCourse.isEleven) end = CourseAPI.courseTime[11][1];
        await NotificationUtils.show(
          "上课提醒",
          "${_pushCourse.name}"
              "　"
              "${start.format(context)} - ${end.format(context)}"
              "　"
              "${_pushCourse.location}"
              "\n"
              "千万不要迟到了噢~",
        );
      } else if (CourseAPI.notifySecond(_pushCourse)) {
        coursePushed.add(_pushCourse.uniqueId);
        await NotificationUtils.show(
          "上课提醒",
          "${_pushCourse.name}还有5分钟就开始上课了~"
              "\n"
              "地点在${_pushCourse.location}，要加快脚步噢~",
        );
      }
    }
  }

  Widget courseName(Course course, CourseType type) {
    return Text(
      course.name,
      style: TextStyle(
        color: CourseAPI.isFinished(course) && type == CourseType.today
            ? Colors.grey[500]
            : null,
        fontSize: Constants.size(20.0),
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget courseTime(Course course, CourseType type) {
    return Text(
      CourseAPI.getCourseTime(context, course, type),
      style: TextStyle(
        color: CourseAPI.isFinished(course) && type == CourseType.today
            ? Colors.grey[400]
            : null,
        fontSize: Constants.size(15.0),
      ),
    );
  }

  Widget courseLocation(Course course, CourseType type) {
    return Text(
      CourseAPI.getCourseLocation(context, course, type),
      style: TextStyle(
        color: CourseAPI.isFinished(course) && type == CourseType.today
            ? Colors.grey[400]
            : null,
        fontSize: Constants.size(15.0),
      ),
    );
  }

  Widget courseWidget(Course course, CourseType type) {
    return Expanded(
      child: SizedBox(
        height: Constants.size(84.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            courseName(course, type),
            courseTime(course, type),
            if (course.location != "") courseLocation(course, type),
          ],
        ),
      ),
    );
  }

  Widget timelineIndicator(Course course, CourseType type) {
    Color color;
    if (CourseAPI.isFinished(course)) {
      color = Colors.grey[400];
    } else if (CourseAPI.isActive(course)) {
      color = Colors.redAccent;
    }
    if (type == CourseType.today) {
      return Container(
        width: Constants.size(8.0),
        height: Constants.size(84.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomRight: Radius.circular(5.0),
          ),
          color: color,
        ),
      );
    } else {
      return SizedBox(
        width: Constants.size(8.0),
        height: Constants.size(84.0),
      );
    }
  }

  Widget courseTabs(context) {
    return Flexible(
      child: SizedBox(
        height: suSetHeight(kAppBarHeight),
        child: TabBar(
          isScrollable: true,
          controller: _tabController,
          labelColor: Theme.of(context).textTheme.headline6.color,
          labelStyle: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: 19.0,
                fontWeight: FontWeight.bold,
              ),
          labelPadding: EdgeInsets.symmetric(horizontal: Constants.size(20.0)),
          unselectedLabelStyle: Theme.of(context).textTheme.headline6.copyWith(
                fontSize: 19.0,
                fontWeight: FontWeight.normal,
              ),
          indicator: RoundedTabIndicator(),
          tabs: <Tab>[
            Tab(text: "今日"),
            Tab(text: "本周"),
            Tab(text: "学期"),
          ],
        ),
      ),
    );
  }

  Widget courseWrapper(context, CourseType type) {
    bool showCourse = false;
    List _courses = courses;
    String emptyTips;
    switch (type) {
      case CourseType.today:
        showCourse = coursesToday != null && coursesToday.length > 0;
        _courses = coursesToday;
        emptyTips = "今天没有课程\n课余时间要适度放松自己😴";
        break;
      case CourseType.week:
        showCourse = coursesWeek != null && coursesWeek.length > 0;
        _courses = coursesWeek;
        emptyTips = "本周没有课程\n不要让自己轻易成为咸鱼🐡";
        break;
      case CourseType.term:
        showCourse = courses != null && courses.length > 0;
        _courses = courses;
        emptyTips = "本学期没有课程\n对自己的规划是成长的阶梯🏃";
        break;
    }
    return !loading && !loaded
        ? showCourse
            ? ListView.separated(
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (_, __) {
                  return separator(
                    context,
                    height: 1.0,
                    color: Theme.of(context).dividerColor,
                  );
                },
                itemCount: _courses.length + 1,
                itemBuilder: (context, index) {
                  if (index == _courses.length) {
                    return currentDay();
                  } else {
                    Course course = _courses[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              timelineIndicator(course, type),
                              emptyDivider(width: 16.0),
                              courseWidget(course, type),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                },
              )
            : Center(
                child: Text(
                  emptyTips,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Constants.size(18.0),
                  ),
                ),
              )
        : Center(child: SpinKitWidget());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: suSetHeight(kAppBarHeight),
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: ExtendedTabBarView(
              controller: _tabController,
              children: <Widget>[
                courseWrapper(context, CourseType.today),
                courseWrapper(context, CourseType.week),
                courseWrapper(context, CourseType.term),
              ],
            ),
          ),
          Positioned(
            top: 0.0,
            left: 56.0,
            right: 56.0,
            child: FixedAppBar(
              elevation: 0.0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[courseTabs(context)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
