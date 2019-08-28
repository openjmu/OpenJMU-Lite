import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/cache_utils.dart';
import 'package:openjmu_lite/utils/net_utils.dart';


class UserAPI {
    static UserInfo currentUser = UserInfo();

    static List<Cookie> cookiesForJWGL;

    static Future login(Map<String, dynamic> params) async {
        return NetUtils.post(API.login, data: params);
    }

    static Future logout() async {
        return NetUtils.postWithCookieSet(API.logout);
    }

    static UserInfo createUserInfo(Map<String, dynamic> userData) {
        userData.forEach((k, v) {
            if (userData[k] == "") userData[k] = null;
        });
        return UserInfo(
            sid: userData['sid'] ?? null,
            uid: userData['uid'],
            name: userData['username'] ?? userData['uid'].toString(),
            signature: userData['signature'],
            ticket: userData['sid'] ?? null,
            blowfish: userData['blowfish'] ?? null,
            isTeacher: userData['isTeacher'] ?? int.parse(userData['type'].toString()) == 1,
            workId: (userData['workId'] ?? userData['workid'] ?? userData['uid']).toString(),
            gender: int.parse(userData['gender'].toString()),
            isFollowing: false,
        );
    }

    static User createUser(userData) => User(
        id: int.parse(userData['uid'].toString()),
        nickname: userData["nickname"] ?? userData["username"] ?? userData["name"] ?? userData["uid"].toString(),
        gender: userData["gender"] ?? 0,
        topics: userData["topics"] ?? 0,
        latestTid: userData["latest_tid"] ?? null,
        fans: userData["fans"] ?? 0,
        idols: userData["idols"] ?? 0,
        isFollowing: userData["is_following"] == 1,
    );

    static Widget getAvatarWidget({double size = 50.0, int uid}) {
        final double _s = Constants.size(size);
        return Hero(
            tag: "user_${uid ?? currentUser.uid}",
            child: SizedBox(
                width: _s,
                height: _s,
                child: CircleAvatar(
                    backgroundImage: getAvatarProvider(uid: uid),
                ),
            ),
        );
    }
    /// Update cache network image provider after avatar is updated.
    static int avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    static CachedNetworkImageProvider getAvatarProvider({int uid, int size, int t}) {
        return CachedNetworkImageProvider(
            "${API.userAvatar}"
                    "?uid=${uid ?? currentUser.uid}"
                    "&_t=${t ?? avatarLastModified}"
                    "&size=f${size ?? 152}"
            ,
            cacheManager: DefaultCacheManager(),
        );
    }
    static void updateAvatarProvider() {
        CacheUtils.remove("${API.userAvatar}?uid=${currentUser.uid}&size=f152&_t=$avatarLastModified");
        CacheUtils.remove("${API.userAvatar}?uid=${currentUser.uid}&size=f640&_t=$avatarLastModified");
        avatarLastModified = DateTime.now().millisecondsSinceEpoch;
    }

    static Future getUserInfo({int uid}) async {
        if (uid == null) {
            return currentUser;
        } else {
            return NetUtils.getWithCookieAndHeaderSet(API.userInfo, data: {'uid': uid});
        }
    }

    static Future getStudentInfo({int uid}) async {
        return NetUtils.getWithCookieSet(API.studentInfo(uid: uid ?? currentUser.uid));
    }

}
