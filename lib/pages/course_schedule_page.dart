import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/courses_api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/utils/notification_utils.dart';


class CourseSchedulePage extends StatefulWidget {
    @override
    _CourseSchedulePageState createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends State<CourseSchedulePage>
        with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
    bool loading = true, loaded = false;
    List<Course> courses;
    List<Course> coursesToday;
    List<Course> coursesWeek;
    Set<String> coursePushed = <String>{};
    TabController _tabController;
    Timer _courseRefreshTimer;

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        _tabController = TabController(length: CourseType.values.length, vsync: this);
        getCourses();
        _courseRefreshTimer = Timer.periodic(Duration(minutes: 1), (timer) async {
            getCourses();
        });
        super.initState();
    }

    @override
    void dispose() {
        _courseRefreshTimer?.cancel();
        super.dispose();
    }

    void getCourses() async {
        try {
            Map<String, dynamic> data = jsonDecode((await NetUtils.get(
                API.courseScheduleCourses,
                data: {"sid": UserAPI.currentUser.sid},
            )).data);
            List _courses = data['courses'];
            List<Course> _list = [], _listToday = [], _listWeek = [];
            _courses.forEach((course) {
                Course _c = Course.fromJson(course);
                _list.add(_c);
                if (CourseAPI.inCurrentDay(_c) && CourseAPI.inCurrentWeek(_c)) _listToday.add(_c);
                if (CourseAPI.inCurrentWeek(_c)) _listWeek.add(_c);
            });
            courses = _list;
            coursesToday = _listToday;
            coursesWeek = _listWeek;
            getCoursesPush();
            loading = false;
            if (mounted) setState(() {});
        } catch (e) {
            debugPrint("$e");
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
                List<TimeOfDay> times = CourseAPI.courseTime[_pushCourse.time];
                TimeOfDay start = times[0], end = times[1];
                if (_pushCourse.isEleven) end = CourseAPI.courseTime["11"][1];
                await NotificationUtils.show(
                    "上课提醒",
                    "${_pushCourse.name}　${start.format(context)} - ${end.format(context)}　${_pushCourse.location}"
                            "\n"
                            "千万不要迟到了噢~"
                    ,
                );
            } else if (CourseAPI.notifySecond(_pushCourse)) {
                coursePushed.add(_pushCourse.uniqueId);
                await NotificationUtils.show(
                    "上课提醒",
                    "${_pushCourse.name}还有5分钟就开始上课了~"
                            "\n"
                    "地点在${_pushCourse.location}，要加快脚步噢~"
                    ,
                );
            }
        }
    }

    Widget courseName(Course course, CourseType type) {
        return Text(
            course.name,
            style: TextStyle(
                color: CourseAPI.isActive(course)
                        ? Colors.white
                        : CourseAPI.isFinished(course) && type == CourseType.today
                        ? Colors.grey[400]
                        : Colors.black
                ,
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
                color: CourseAPI.isActive(course)
                        ? Colors.white
                        : CourseAPI.isFinished(course) && type == CourseType.today
                        ? Colors.grey[400]
                        : Colors.black
                ,
                fontSize: Constants.size(15.0),
            ),
        );
    }

    Widget courseLocation(Course course, CourseType type) {
        return Text(
            CourseAPI.getCourseLocation(context, course, type),
            style: TextStyle(
                color: CourseAPI.isActive(course)
                        ? Colors.white
                        : CourseAPI.isFinished(course) && type == CourseType.today
                        ? Colors.grey[400]
                        : Colors.black
                ,
                fontSize: Constants.size(15.0),
            ),
        );
    }

    Widget courseWidget(Course course, CourseType type) {
        return Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.size(24.0),
                    vertical: Constants.size(8.0),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Constants.size(16.0)),
                    color: CourseAPI.isActive(course)
                            ? Constants.appThemeColor
                            : Theme.of(context).canvasColor
                    ,
                ),
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
            ),
        );
    }

    Widget inProgressIndicator(Course course, CourseType type) {
        return Row(
            children: <Widget>[
                Container(
                    width: Constants.size(18.0),
                    height: Constants.size(18.0),
                    decoration: BoxDecoration(
                        border: !CourseAPI.isActive(course) ? Border.all(
                            color: CourseAPI.isFinished(course) && type == CourseType.today
                                    ? Constants.appThemeColor.withAlpha(80)
                                    : Constants.appThemeColor
                            ,
                            width: Constants.size(3.0),
                        ) : null,
                        color: CourseAPI.isActive(course) ? Constants.appThemeColor : null,
                        shape: BoxShape.circle,
                    ),
                    child: CourseAPI.isActive(course) ? Center(
                        child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: Constants.size(18.0),
                        ),
                    ) : null,
                ),
                Constants.emptyDivider(width: 16.0),
                if (CourseAPI.inReadyTime(course) && type == CourseType.today) Text(
                    "准备上课",
                    style: Theme.of(context).textTheme.body1.copyWith(
                        color: Constants.appThemeColor,
                        fontSize: Constants.size(18.0),
                        fontWeight: FontWeight.bold,
                    ),
                ),
                if (CourseAPI.isFinished(course) && type == CourseType.today) Text(
                    "已下课",
                    style: Theme.of(context).textTheme.body1.copyWith(
                        color: Constants.appThemeColor.withAlpha(80),
                        fontSize: Constants.size(18.0),
                        fontWeight: FontWeight.bold,
                    ),
                ),
                if (CourseAPI.isActive(course)) Text(
                    "正在上课",
                    style: Theme.of(context).textTheme.body1.copyWith(
                        color: Constants.appThemeColor,
                        fontSize: Constants.size(18.0),
                        fontWeight: FontWeight.bold,
                    ),
                ),
            ],
        );
    }

    Widget timelineIndicator(Course course) {
        return SizedBox(
            width: Constants.size(18.0),
            child: Center(
                child: Container(
                    width: Constants.size(4.0),
                    height: Constants.size(100.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.size(10.0)),
                        color: CourseAPI.isActive(course)
                                ? Constants.appThemeColor
                                : Constants.appThemeColor.withAlpha(80)
                        ,
                    ),
                ),
            ),
        );
    }

    Widget courseTabs(context) {
        return SizedBox(
            height: Constants.size(36.0),
            child: Row(
                children: <Widget>[
                    Flexible(
                        child: TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            labelColor: Theme.of(context).textTheme.title.color,
                            labelStyle: Theme.of(context).textTheme.title.copyWith(
                                fontSize: Constants.size(16.0),
                                fontWeight: FontWeight.bold,
                            ),
                            labelPadding: EdgeInsets.symmetric(horizontal: Constants.size(24.0)),
                            unselectedLabelStyle: Theme.of(context).textTheme.title.copyWith(
                                fontSize: Constants.size(16.0),
                                fontWeight: FontWeight.normal,
                            ),
                            indicatorWeight: Constants.size(3.0),
                            tabs: <Tab>[
                                Tab(text: "今日"),
                                Tab(text: "本周"),
                                Tab(text: "学期"),
                            ],
                        ),
                    ),
                ],
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
                ?
        showCourse ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
                Course course = _courses[index];
                return Container(
                    margin: EdgeInsets.only(
                        top: Constants.size(index == 0 ? 20.0 : 8.0),
                        bottom: Constants.size(index == _courses.length - 1 ? 20.0 : 8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: Constants.size(24.0),
                    ),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            inProgressIndicator(course, type),
                            Constants.emptyDivider(height: 8.0),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                    timelineIndicator(course),
                                    Constants.emptyDivider(width: 16.0),
                                    courseWidget(course, type),
                                ],
                            ),
                        ],
                    ),
                );
            },
        ) : Center(
            child: Text(
                emptyTips,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: Constants.size(18.0),
                ),
            ),
        )
                :
        DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Constants.size(30.0)),
                    topRight: Radius.circular(Constants.size(30.0)),
                ),
                color: Colors.white,
            ),
            child: Constants.progressIndicator(),
        );
    }

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        return Column(
            children: <Widget>[
                courseTabs(context),
                Expanded(
                    child: ExtendedTabBarView(
                        controller: _tabController,
                        children: <Widget>[
                            courseWrapper(context, CourseType.today),
                            courseWrapper(context, CourseType.week),
                            courseWrapper(context, CourseType.term),
                        ],
                    ),
                ),
            ],
        );
    }
}
