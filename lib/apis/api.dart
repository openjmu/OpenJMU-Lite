import 'dart:core';

import 'package:openjmu_lite/utils/socket_utils.dart';


class API {
    static final String homePage = "https://openjmu.xyz";

    /// custom channel.
    static final String firstDayOfTerm = "https://project.alexv525.com/openjmu/first-day-of-term";
    static final String checkUpdate = "https://project.alexv525.com/openjmu/latest-version";
    static final String latestAndroid = "https://project.alexv525.com/openjmu/openjmu-latest.apk";
    static final String announcement = "https://project.alexv525.com/openjmu/announcement";

    /// Hosts.
    static final String openjmuHost = "openjmu.jmu.edu.cn";
    static final String oa99Host = "https://oa99.jmu.edu.cn";
    static final String oap99Host = "https://oap99.jmu.edu.cn";
    static final String labsHost = "http://labs.jmu.edu.cn";

    /// 认证相关
    static final String login = "$oa99Host/v2/passport/api/user/login1";
    static final String logout = "$oap99Host/passport/logout";
    static final String loginTicket = "$oa99Host/v2/passport/api/user/loginticket1";

    /// 用户相关
    static final String userInfo = "$oap99Host/user/info";
    static String studentInfo({int uid = 0}) => "$oa99Host/v2/api/class/studentinfo?uid=$uid";
    static final String userAvatar = "$oap99Host/face";

    /// 应用中心
    static final String webAppLists = "$oap99Host/app/unitmenu?cfg=1";
    static final String webAppIcons = "$oap99Host/app/menuicon?size=f128&unitid=55&";

    /// 成绩相关
    static final SocketConfig scoreSocket = SocketConfig("$openjmuHost", 4000);

    /// 签到相关
    static final String sign = "$oa99Host/ajax/sign/usersign";
    static final String signList = "$oa99Host/ajax/sign/getsignlist";
    static final String signStatus = "$oa99Host/ajax/sign/gettodaystatus";
    static final String signSummary = "$oa99Host/ajax/sign/usersign";

    static final String task = "$oa99Host/ajax/tasks";

    /// 课程表相关
    static final String courseSchedule = "$labsHost/courseSchedule/course.html";
    static final String courseScheduleTeacher = "$labsHost/courseSchedule/Tcourse.html";

    static final String courseScheduleCourses = "$labsHost/courseSchedule/StudentCourseSchedule";
    static final String courseScheduleClassRemark = "$labsHost/courseSchedule/StudentClassRemark";
    static final String courseScheduleTermLists = "$labsHost/courseSchedule/GetSemesters";

    /// 静态scheme正则
    static final RegExp urlReg = RegExp(r"(https?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
    static final RegExp schemeUserPage = RegExp(r"^openjmu://user/*");
}
