import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu_lite/apis/date_api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/pages/course_schedule_page.dart';


class MainPage extends StatefulWidget {
    @override
    _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    Color themeColor = Constants.appThemeColor;
//    int _index = 0;

    int currentWeek;
    DateTime now;
    String hello = "你好";
    Timer updateHelloTimer;

    @override
    void initState() {
        updateHello();
        getCurrentWeek();
        if (mounted && updateHelloTimer != null) {
            updateHelloTimer = Timer.periodic(Duration(minutes: 1), (timer) {
                updateHello();
                getCurrentWeek();
            });
        }

        Constants.eventBus.on<LogoutEvent>().listen((event) {
            Navigator.of(event.context).pushReplacementNamed("/login");
        });

        super.initState();
    }

    Widget avatar(context) {
        return GestureDetector(
            child: UserAPI.getAvatarWidget(),
            onTap: () {
                Navigator.of(context).pushNamed("/user");
            },
        );
    }

    Widget scan(context) {
        final double size = Constants.size(50.0);
        return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: Colors.grey.withAlpha(125),
                shape: BoxShape.circle,
            ),
            child: IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                    "assets/icons/scan.svg",
                    color: Colors.white,
                    width: size / 1.5,
                    height: size / 1.5,
                ),
                onPressed: () async {
                    Map<PermissionGroup, PermissionStatus>permissions = await PermissionHandler().requestPermissions([
                        PermissionGroup.camera,
                    ]);
                    if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
                        Navigator.of(context).pushNamed("/scanqrcode");
                    }
                },
            ),
        );
    }

    Widget currentDay(DateTime now) {
        final double size = Constants.size(24.0);
        return RichText(
            text: TextSpan(
                children: <TextSpan>[
                    TextSpan(
                        text: "${UserAPI.currentUser.name}",
                        style: TextStyle(
                            fontSize: size,
                            fontWeight: FontWeight.bold,
                        ),
                    ),
                    TextSpan(
                        text: "，$hello~\n",
                        style: TextStyle(fontSize: size),
                    ),
                    TextSpan(text: "今天是"),
                    TextSpan(text: "${DateFormat("MMMdd日，", "zh_CN").format(now)}"),
                    TextSpan(text: "${DateFormat("EEEE，", "zh_CN").format(now)}"),
                    if (currentWeek != null)
                        if (currentWeek >= 1 && currentWeek <= 20) TextSpan(text: "第$currentWeek周")
                        else if (currentWeek == 0) TextSpan(text: "下周开学")
                        else if (currentWeek < 0) TextSpan(text: "距离开学还有$currentWeek周")
                    ,
                    TextSpan(text: "。"),
                ],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: size / 1.75,
                ),
            ),
        );
    }

    void getCurrentWeek() async {
        String _day = jsonDecode((await DateAPI.getCurrentWeek()).data)['start'];
//        String _day = "2019-07-22";
        DateAPI.startDate = DateTime.parse(_day);
        DateTime currentDate = DateTime.now();
        DateAPI.difference = DateAPI.startDate.difference(currentDate).inDays - 1;
        DateAPI.currentWeek = - (DateAPI.difference / 7).floor();
        if (DateAPI.currentWeek <= 20) {
            currentWeek = DateAPI.currentWeek;
        } else {
            currentWeek = null;
        }
        if (mounted) setState(() {});
    }

    void updateHello() {
        int hour = DateTime.now().hour;
        setState(() {
            now = DateTime.now();

            if (hour >= 0 && hour < 6) {
                hello = "深夜了，注意休息";
            } else if (hour >= 6 && hour < 8) {
                hello = "早上好";
            } else if (hour >= 8 && hour < 11) {
                hello = "上午好";
            } else if (hour >= 11 && hour < 14) {
                hello = "中午好";
            } else if (hour >= 14 && hour < 18) {
                hello = "下午好";
            } else if (hour >= 18 && hour < 20) {
                hello = "傍晚好";
            } else if (hour >= 20 && hour <= 24) {
                hello = "晚上好";
            }
        });
    }

//    void selectItem(index) {
//        setState(() {
//            _index = index;
//        });
//    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Constants.appThemeColor,
            body: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Constants.size(16.0),
                                vertical: Constants.size(8.0),
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                    avatar(context),
                                    Expanded(child: SizedBox()),
                                    scan(context),
                                ],
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: Constants.size(16.0),
                                right: Constants.size(16.0),
                                bottom: Constants.size(10.0),
                            ),
                            child: Row(
                                children: <Widget>[
                                    currentDay(now),
                                ],
                            ),
                        ),
                        Expanded(
                            child: DecoratedBox(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(Constants.size(30.0)),
                                        topRight: Radius.circular(Constants.size(30.0)),
                                    ),
                                    color: Colors.white,
                                ),
                                child: CourseSchedulePage(),
                            ),
                        ),
                    ],
                ),
            ),
//            bottomNavigationBar: BottomNavigationBar(
//                type: BottomNavigationBarType.shifting,
//                currentIndex: _index,
//                selectedItemColor: themeColor,
//                unselectedItemColor: Colors.grey,
//                onTap: selectItem,
//                items: <BottomNavigationBarItem>[
//                    BottomNavigationBarItem(
//                            icon: Icon(Icons.calendar_today),
//                            title: Text("首页")
//                    ),
//                    BottomNavigationBarItem(
//                            icon: Icon(Icons.person),
//                            title: Text("我的")
//                    ),
//                ],
//            ),
        );
    }
}
