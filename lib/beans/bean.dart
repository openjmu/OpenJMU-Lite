import 'dart:convert';

import 'package:flutter/widgets.dart';


///
/// 用户页用户实体
/// [id] 用户id, [nickname] 名称, [gender] 性别, [topics] 动态数, [latestTid] 最新动态id
/// [fans] 粉丝数, [idols] 关注数, [isFollowing] 是否已关注
///
class User {
    int id;
    String nickname;
    int gender;
    int topics;
    int latestTid;
    int fans, idols;
    bool isFollowing;

    User({
        this.id,
        this.nickname,
        this.gender,
        this.topics,
        this.latestTid,
        this.fans,
        this.idols,
        this.isFollowing,
    });

    @override
    bool operator == (Object other) => identical(this, other) || other is User && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;
}

///
/// 用户信息实体
/// [sid] 用户token, [ticket] 用户当前token, [blowfish] 用户设备uuid
/// [uid] 用户uid, [unitId] 组织/学校id, [workId] 工号/学号, [classId] 班级id,
/// [name] 名字, [signature] 签名, [gender] 性别, [isFollowing] 是否已关注
///
class UserInfo {
    /// For Login Process
    String sid;
    String ticket;
    String blowfish;
    bool isTeacher;
    bool isCY;

    /// Common Object
    int uid;
    int unitId;
    int classId;
    int gender;
    String name;
    String signature;
    String workId;
    bool isFollowing;

    UserInfo({
        this.sid,
        this.uid,
        this.name,
        this.signature,
        this.ticket,
        this.blowfish,
        this.isTeacher,
        this.isCY,
        this.unitId,
        this.workId,
        this.classId,
        this.gender,
        this.isFollowing,
    });

    @override
    bool operator == (Object other) => identical(this, other) || other is UserInfo && runtimeType == other.runtimeType && uid == other.uid;

    @override
    int get hashCode => uid.hashCode;

    @override
    String toString() {
        return "UserInfo ${JsonEncoder.withIndent("  ").convert({
            'sid': sid,
            'uid': uid,
            'name': name,
            'signature': signature,
            'ticket': ticket,
            'blowfish': blowfish,
            'isTeacher': isTeacher,
            'isCY': isCY,
            'unitId': unitId,
            'workId': workId,
//            'classId': classId,
            'gender': gender,
            'isFollowing': isFollowing,
        })}";
    }

    factory UserInfo.fromJson(Map<String, dynamic> json) {
        json.forEach((k, v) {
            if (json[k] == "") json[k] = null;
        });
        return UserInfo(
            sid: json['sid'],
            uid: json['uid'],
            name: json['username'] ?? json['uid'].toString(),
            signature: json['signature'],
            ticket: json['sid'],
            blowfish: json['blowfish'],
            isTeacher: json['isTeacher'] ?? int.parse(json['type'].toString()) == 1,
            isCY: json['isCY'],
            unitId: json['unitId'] ?? json['unitid'],
            workId: (json['workId'] ?? json['workid'] ?? json['uid']).toString(),
            classId: null,
            gender: int.parse(json['gender'].toString()),
            isFollowing: false,
        );
    }
}

///
/// 课程
/// [name] 课程名称, [time] 上课时间, [location] 上课地点, [className] 班级名称, [teacher] 教师名称,
/// [day] 上课日, [startWeek] 开始周, [endWeek] 结束周,
/// [classesName] 共同上课的班级,
/// [isEleven] 是否第十一节,
/// [oddEven] 是否为单双周, 0为普通, 1为单周, 2为双周
///
class Course {
    String name, time, location, className, teacher;
    int day, startWeek, endWeek, oddEven;
    List<String> classesName;
    bool isEleven;

    Course({
        this.name,
        this.time,
        this.location,
        this.className,
        this.teacher,
        this.day,
        this.startWeek,
        this.endWeek,
        this.classesName,
        this.isEleven,
        this.oddEven,
    });

    String get uniqueId => "$name\$$time\$$day\$$startWeek\$$endWeek";

    static int judgeOddEven(Map<String, dynamic> json) {
        int _oddEven = 0;
        List _split = json['allWeek'].split(' ');
        if (_split.length > 1) {
            if (_split[1] == "单周") {
                _oddEven = 1;
            } else if (_split[1] == "双周") {
                _oddEven = 2;
            }
        }
        return _oddEven;
    }

    factory Course.fromJson(Map<String, dynamic> json) {
        int _oddEven = judgeOddEven(json);
        List weeks = json['allWeek'].split(' ')[0].split('-');
        return Course(
            name: json['couName'],
            time: json['coudeTime'],
            location: json['couRoom'],
            className: json['className'],
            teacher: json['couTeaName'],
            day: json['couDayTime'],
            startWeek: int.parse(weeks[0]),
            endWeek: int.parse(weeks[1]),
            classesName: json['comboClassName'].split(','),
            isEleven: json['three'] != 'n',
            oddEven: _oddEven,
        );
    }

    @override
    String toString() {
        return "Course ${JsonEncoder.withIndent("  ").convert({
            'name': name,
            'time': time,
            'room': location,
            'className': className,
            'teacher': teacher,
            'day': day,
            'startWeek': startWeek,
            'endWeek': endWeek,
            'classesName': classesName,
            'isEleven': isEleven,
            'oddEven': oddEven,
        })}";
    }

}

///
/// 成绩类
/// [code] 课程代码, [courseName] 课程名称, [score] 成绩, [termId] 学年学期, [credit] 学分, [creditHour] 学时
///
class Score {
    String code, courseName, score, termId;
    double credit, creditHour;

    Score({this.code, this.courseName, this.score, this.termId, this.credit, this.creditHour});

    factory Score.fromJson(Map<String, dynamic> json) {
        return Score(
            code: json['code'],
            courseName: json['courseName'],
            score: json['score'],
            termId: json['termId'],
            credit: double.parse(json['credit']),
            creditHour: double.parse(json['creditHour']),
        );
    }

    @override
    String toString() {
        return "Score ${JsonEncoder.withIndent("  ").convert({
            'code': code,
            'courseName': courseName,
            'termId': termId,
            'score': score,
            'credit': credit,
            'creditHour': creditHour,
        })}";
    }
}

///
/// 应用中心应用
/// [id] 应用id, [sequence] 排序下标, [code] 代码, [name] 名称, [url] 地址, [menuType] 分类
///
class WebApp {
    int id;
    int sequence;
    String code;
    String name;
    String url;
    String menuType;

    WebApp({this.id, this.sequence, this.code, this.name, this.url, this.menuType});

    factory WebApp.fromJson(Map<String, dynamic> json) {
        return WebApp(
            id: json['appid'],
            sequence: json['sequence'],
            code: json['code'],
            name: json['name'],
            url: json['url'],
            menuType: json['menutype'],
        );
    }

    @override
    bool operator ==(Object other) => identical(this, other) || other is WebApp && runtimeType == other.runtimeType && id == other.id;

    @override
    int get hashCode => id.hashCode;

    static Map category = {
        "10": "个人事务",
        "A4": "我的服务",
        "A3": "我的系统",
        "A8": "流程服务",
        "A2": "我的媒体",
        "A1": "我的网站",
        "A5": "其他",
        "20": "行政办公",
        "30": "客户关系",
        "40": "知识管理",
        "50": "交流中心",
        "60": "人力资源",
        "70": "项目管理",
        "80": "档案管理",
        "90": "教育在线",
        "A0": "办公工具",
        "Z0": "系统设置",
    };
}

class NoGlowScrollBehavior extends ScrollBehavior {
    @override
    Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
        return child;
    }
}