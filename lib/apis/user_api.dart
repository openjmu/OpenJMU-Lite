import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/beans/beans.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/net_utils.dart';

UserInfo get currentUser => UserAPI.currentUser;

class UserAPI {
  const UserAPI._();

  static UserInfo currentUser = UserInfo();

  static List<Cookie> cookiesForJWGL;

  static Future login(Map<String, dynamic> params) async {
    return NetUtils.post(API.login, data: params);
  }

  static Future logout() async {
    return NetUtils.post(API.logout);
  }

  static Widget getAvatarWidget({double size = 50.0, int uid}) {
    final double _s = Constants.size(size);
    return Hero(
      tag: "user_${uid ?? currentUser.uid}",
      child: SizedBox(
        width: _s,
        height: _s,
        child: CircleAvatar(backgroundImage: getAvatarProvider(uid: uid)),
      ),
    );
  }

  static CachedNetworkImageProvider getAvatarProvider({int uid, int size, int t}) {
    return CachedNetworkImageProvider(
      "${API.userAvatar}"
      "?uid=${uid ?? currentUser.uid}"
      "&size=f${size ?? 152}",
      cacheManager: DefaultCacheManager(),
    );
  }

  static Future getUserInfo({int uid}) async {
    if (uid == null) {
      return currentUser;
    } else {
      return NetUtils.getWithHeaderSet(API.userInfo, data: {'uid': uid});
    }
  }

  static Future getStudentInfo({int uid}) async {
    return NetUtils.get(API.studentInfo(uid: uid ?? currentUser.uid));
  }
}
