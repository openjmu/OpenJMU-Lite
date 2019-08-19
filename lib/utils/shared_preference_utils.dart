import 'package:shared_preferences/shared_preferences.dart';

import 'package:openjmu_lite/apis/user_api.dart';


class SpUtils {
    static final String spIsLogin           = "isLogin";
    static final String spIsTeacher         = "isTeacher";
    static final String spUserSid           = "sid";
    static final String spTicket            = "ticket";
    static final String spBlowfish          = "blowfish";
    static final String spUserUid           = "userUid";
    static final String spUserName          = "userName";
    static final String spUserWorkId        = "userWorkId";
    static final String spBrightness        = "themeBrightness";
    static final String spColorThemeIndex   = "themeColorThemeIndex";
    static final String spHomeSplashIndex   = "homeSplashIndex";
    static final String spHomeStartUpIndex  = "homeStartupIndex";

    static SharedPreferences sp;
    static Future initSharedPreferences() async {
        sp = await SharedPreferences.getInstance();
    }

    static Future<bool> isLogin() async {
        bool b = sp.getBool(spIsLogin);
        return b != null && b;
    }

    static Future<Null> saveLoginInfo(Map data) async {
        if (data != null) {
            await sp.setBool(spIsLogin, true);
            await sp.setBool(spIsTeacher, data['isTeacher']);
            await sp.setString(spUserSid, data['sid']);
            await sp.setString(spTicket, data['ticket']);
            await sp.setString(spBlowfish, data['blowfish']);
            await sp.setString(spUserName, data['name']);
            await sp.setInt(spUserUid, data['uid']);
            await sp.setInt(spUserWorkId, int.parse(data['workId']));
        }
    }
    static Future clearLoginInfo() async {
        await sp.remove(spIsLogin);
        await sp.remove(spIsTeacher);
        await sp.remove(spUserSid);
        await sp.remove(spTicket);
        await sp.remove(spBlowfish);
        await sp.remove(spUserName);
        await sp.remove(spUserUid);
        await sp.remove(spUserWorkId);
        await sp.remove(spBrightness);
        await sp.remove(spColorThemeIndex);
        await sp.remove(spHomeSplashIndex);
        await sp.remove(spHomeStartUpIndex);
    }

    static Map<String, dynamic> getTicket() => <String, dynamic>{
        'ticket': sp.getString(spTicket),
        'blowfish': sp.getString(spBlowfish),
    };

    static Future updateSid(response) async {
        await sp.setString(spUserSid, response['sid']);
        UserAPI.currentUser.sid = response['sid'];
        UserAPI.currentUser.uid = sp.getInt(spUserUid);
    }

}