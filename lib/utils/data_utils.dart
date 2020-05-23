import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:openjmu_lite/beans/beans.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:uuid/uuid.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/events.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/utils/toast_utils.dart';
import 'package:openjmu_lite/utils/shared_preference_utils.dart';

class DataUtils {
  static Future login(context, String username, String password) async {
    final String blowfish = Uuid().v4();
    Map<String, dynamic> params = Constants.loginParams(
      blowfish: blowfish,
      username: "$username",
      password: password,
    );
    UserAPI.login(params).then((response) async {
      Map<String, dynamic> data = response.data;
      UserAPI.currentUser.sid = data['sid'];
      UserAPI.currentUser.ticket = data['ticket'];
      UserAPI.currentUser.blowfish = blowfish;
      NetUtils.updateCookie();
      Map<String, dynamic> user = (await UserAPI.getUserInfo(uid: data['uid'])).data;
      Map<String, dynamic> userInfo = {
        'sid': data['sid'],
        'uid': data['uid'],
        'username': user['username'],
        'signature': user['signature'],
        'ticket': data['ticket'],
        'blowfish': blowfish,
        'isTeacher': int.parse(user['type'].toString()) == 1,
        'isCY': checkCY(user['workid']),
        'workId': user['workid'],
        'gender': int.parse(user['gender'].toString()),
      };
      bool isWizard = true;
      if (!userInfo["isTeacher"]) isWizard = await checkWizard();
      try {
        setUserInfo(userInfo);
        await SpUtils.saveLoginInfo(userInfo);
        Instances.eventBus.fire(LoginEvent(context, isWizard));
        showToast("登录成功！");
      } catch (e) {
        Instances.eventBus.fire(LoginFailedEvent());
        trueDebugPrint(e.toString());
        if (e.response != null)
          showToast(
            "设置用户信息失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
          );
      }
    }).catchError((e) {
      Instances.eventBus.fire(LoginFailedEvent());
      trueDebugPrint(e.toString());
      if (e.response != null)
        showToast(
          "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
        );
    });
  }

  static Future logout(context) async {
    await UserAPI.logout();
    await SpUtils.clearLoginInfo();
    NetUtils.clearCookie();
    Instances.eventBus.fire(LogoutEvent(context));
    showToast("退出登录成功");
  }

  static Future<bool> checkWizard() async {
    Map<String, dynamic> info = (await UserAPI.getStudentInfo()).data;
    if (info["wizard"].toString() == "1") {
      return true;
    } else {
      return false;
    }
  }

  static bool checkCY(String workId) {
    if (workId.length != 12) {
      return false;
    } else {
      final int code = int.tryParse(workId.substring(4, 6));
      if (code >= 41 && code <= 45) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future recoverLoginInfo() async {
    try {
      Map<String, dynamic> info = SpUtils.getTicket();
      UserAPI.currentUser.sid = info['ticket'];
      UserAPI.currentUser.blowfish = info['blowfish'];
      await getTicket();
      Themes.isDark = SpUtils.sp.getBool(SpUtils.spBrightness);
    } catch (e) {
      trueDebugPrint("Error in recover login info: $e");
    }
  }

  static Future getTicket() async {
    try {
      Map<String, dynamic> params = Constants.loginParams(
        ticket: UserAPI.currentUser.sid,
        blowfish: UserAPI.currentUser.blowfish,
      );
      Map<String, dynamic> response = (await NetUtils.post(API.loginTicket, data: params)).data;
      await SpUtils.updateSid(response);
      NetUtils.updateCookie();
      await getUserInfo();
      bool isWizard = true;
      if (!UserAPI.currentUser.isTeacher) isWizard = await checkWizard();
      Instances.eventBus.fire(TicketGotEvent(isWizard));
    } catch (e) {
      if (e.response != null) {
        trueDebugPrint("Error response.");
        trueDebugPrint(e);
        trueDebugPrint(e.response.data);
        trueDebugPrint(e.response.headers);
        trueDebugPrint(e.response.request);
      }
      Instances.eventBus.fire(TicketFailedEvent());
    }
  }

  static Future getUserInfo([uid]) async {
    await NetUtils.get(
      "${API.userInfo}?uid=${uid ?? UserAPI.currentUser.uid}",
    ).then((response) {
      Map<String, dynamic> data = response.data;
      Map<String, dynamic> userInfo = {
        'sid': UserAPI.currentUser.sid,
        'uid': UserAPI.currentUser.uid,
        'username': data['username'],
        'signature': data['signature'],
        'ticket': UserAPI.currentUser.sid,
        'blowfish': UserAPI.currentUser.blowfish,
        'isTeacher': int.parse(data['type'].toString()) == 1,
        'isCY': checkCY(data['workid']),
        'workId': data['workid'],
        'gender': int.parse(data['gender'].toString()),
      };
      setUserInfo(userInfo);
    }).catchError((e) {
      trueDebugPrint(e);
      trueDebugPrint(e.toString());
      showToast(e.toString());
      return e;
    });
  }

  static void setUserInfo(data) {
    UserAPI.currentUser = UserInfo.fromJson(data);
  }
}
