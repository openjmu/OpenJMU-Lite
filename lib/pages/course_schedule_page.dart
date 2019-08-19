import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:extended_tabs/extended_tabs.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/courses_api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/net_utils.dart';


class CourseSchedulePage extends StatefulWidget {
    @override
    _CourseSchedulePageState createState() => _CourseSchedulePageState();
}

class _CourseSchedulePageState extends State<CourseSchedulePage> with TickerProviderStateMixin{
    bool loading = true;
    List<Course> courses;
    List<Course> coursesToday;
    List<Course> coursesWeek;
    TabController _tabController;

    @override
    void initState() {
        _tabController = TabController(length: CourseType.values.length, vsync: this);
        getCourses();
        super.initState();
    }

    void getCourses({CourseType type = CourseType.today}) async {
        if (!loading) setState(() {
            loading = true;
        });
        try {
            Map<String, dynamic> data = jsonDecode((await NetUtils.get(
                API.courseScheduleCourses,
                data: {"sid": UserAPI.currentUser.sid},
            )).data);
            List _courses = data['courses'];
            List<Course> _list = [], _listToday = [], _listWeek = [];
            _courses.forEach((course) {
                Course _c = Course.fromJson(course);
                bool inToday = CourseAPI.inCurrentDay(_c) && CourseAPI.inCurrentWeek(_c);
                bool inWeek = CourseAPI.inCurrentDay(_c) && CourseAPI.inCurrentWeek(_c);

                _list.add(Course.fromJson(course));
                if (inToday) _listToday.add(Course.fromJson(course));
                if (inWeek) _listToday.add(Course.fromJson(course));
            });
            courses = _list;
            coursesToday = _listToday;
            coursesWeek = _listWeek;
            loading = false;
            if (mounted) setState(() {});
        } catch (e) {
            debugPrint("$e");
        }
    }

    Widget courseName(Course course) {
        return Text(
            course.name,
            style: TextStyle(
                color: CourseAPI.isActive(course) ? Colors.white : Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
        );
    }

    Widget courseTime(Course course, CourseType type) {
        return Text(
            CourseAPI.getCourseTime(context, course, type),
            style: TextStyle(
                color: CourseAPI.isActive(course) ? Colors.white : Colors.black,
                fontSize: 17.0,
            ),
        );
    }

    Widget courseLocation(Course course) {
        return Text(
            course.location,
            style: TextStyle(
                color: CourseAPI.isActive(course) ? Colors.white : Colors.black,
                fontSize: 20.0,
            ),
        );
    }

    Widget courseWidget(Course course, CourseType type) {
        return Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: CourseAPI.isActive(course)
                            ? Constants.appThemeColor
                            : Theme.of(context).canvasColor
                    ,
                ),
                child: SizedBox(
                    height: 100.0,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            courseName(course),
                            courseTime(course, type),
                            if (course.location != "") courseLocation(course),
                        ],
                    ),
                ),
            ),
        );
    }

    Widget timelineIndicator(Course course) {
        return Column(
            children: <Widget>[
                Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                        border: !CourseAPI.isActive(course) ? Border.all(
                            color: Constants.appThemeColor,
                            width: 4.0,
                        ) : null,
                        color: CourseAPI.isActive(course) ? Constants.appThemeColor : null,
                        shape: BoxShape.circle,
                    ),
                    child: CourseAPI.isActive(course) ? Stack(
                        children: <Widget>[
                            Icon(
                                Icons.check,
                                color: Colors.white,
                            ),
                        ],
                    ) : null,
                ),
                SizedBox(height: 8.0),
                Container(
                    width: 6.0,
                    height: 124.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: CourseAPI.isActive(course)
                                ? Constants.appThemeColor
                                : Constants.appThemeColor.withAlpha(80)
                        ,
                    ),
                ),
            ],
        );
    }

    Widget courseTabs(context) {
        return Row(
            children: <Widget>[
                Flexible(
                    child: TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        labelColor: Theme.of(context).textTheme.title.color,
                        labelStyle: Theme.of(context).textTheme.title.copyWith(
                            fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: Theme.of(context).textTheme.title,
                        tabs: <Tab>[
                            Tab(text: "今日",),
                            Tab(text: "本周",),
                            Tab(text: "学期",),
                        ],
                    ),
                ),
            ],
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
        return !loading
                ?
        showCourse ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
                Course course = courses[index];
                return Container(
                    margin: EdgeInsets.only(
                        top: index == 0 ? 20.0 : 8.0,
                        bottom: index == _courses.length - 1 ? 20.0 : 8.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                            timelineIndicator(course),
                            SizedBox(width: 20.0),
                            courseWidget(course, type),
                        ],
                    ),
                );
            },
        ) : Center(
            child: Text(
                emptyTips,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24.0,
                ),
            ),
        )
                :
        DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
            ),
            child: Constants.progressIndicator(),
        );
    }

    @override
    Widget build(BuildContext context) {
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
