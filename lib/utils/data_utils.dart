import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/event.dart';
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
            Map<String, dynamic> user = (await UserAPI.getUserInfo(uid: data['uid'])).data;
            Map<String, dynamic> userInfo = {
                'sid': data['sid'],
                'uid': data['uid'],
                'username': user['username'],
                'signature': user['signature'],
                'ticket': data['ticket'],
                'blowfish': blowfish,
                'isTeacher': int.parse(user['type'].toString()) == 1,
                'workId': user['workid'],
                'gender': int.parse(user['gender'].toString()),
            };
            bool isWizard = true;
            if (!userInfo["isTeacher"]) isWizard = await checkWizard();
            try {
                setUserInfo(userInfo);
                await SpUtils.saveLoginInfo(userInfo);
                Constants.eventBus.fire(LoginEvent(context, isWizard));
                showShortToast("登录成功！");
            } catch (e) {
                Constants.eventBus.fire(LoginFailedEvent());
                debugPrint(e.toString());
                if (e.response != null) showLongToast(
                    "设置用户信息失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
                );
            }
        }).catchError((e) {
            Constants.eventBus.fire(LoginFailedEvent());
            debugPrint(e.toString());
            if (e.response != null) showLongToast(
                "登录失败！${jsonDecode(e.response.toString())['msg'] ?? e.toString()}",
            );
        });
    }

    static Future logout(context) async {
        await UserAPI.logout();
        await SpUtils.clearLoginInfo();
        Constants.eventBus.fire(LogoutEvent(context));
        showShortToast("退出登录成功");
    }

    static Future<bool> checkWizard() async {
        Map<String, dynamic> info = (await UserAPI.getStudentInfo()).data;
        if (info["wizard"].toString() == "1") {
            return true;
        } else {
            return false;
        }
    }

    static Future recoverLoginInfo() async {
        try {
            Map<String, dynamic> info = SpUtils.getTicket();
            UserAPI.currentUser.sid = info['ticket'];
            UserAPI.currentUser.blowfish = info['blowfish'];
            await getTicket();
        } catch (e) {
            debugPrint("Error in recover login info: $e");
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
            await getUserInfo();
            bool isWizard = true;
            if (!UserAPI.currentUser.isTeacher) isWizard = await checkWizard();
            Constants.eventBus.fire(TicketGotEvent(isWizard));
        } catch (e) {
            if (e.response != null) {
                debugPrint("Error response.");
                debugPrint(e);
                debugPrint(e.response.data);
                debugPrint(e.response.headers);
                debugPrint(e.response.request);
            }
            Constants.eventBus.fire(TicketFailedEvent());
        }
    }

    static Future getUserInfo([uid]) async {
        await NetUtils.getWithCookieSet(
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
                'workId': data['workid'],
                'gender': int.parse(data['gender'].toString()),
            };
            setUserInfo(userInfo);
        }).catchError((e) {
            debugPrint(e);
            debugPrint(e.toString());
            showShortToast(e.toString());
            return e;
        });
    }

    static void setUserInfo(data) {
        UserAPI.currentUser = UserAPI.createUserInfo(data);
    }

}