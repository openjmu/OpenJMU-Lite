import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/constants.dart';


class NetUtils {
    static Dio dio = Dio();
    static CookieJar cookieJar = CookieJar();
    static CookieManager cookieManager = CookieManager(cookieJar);

    static void initConfig() async {
        dio.interceptors.add(cookieManager);
    }

    static Future<Response> get(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
    );

    static Future<Response> getBytes(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            responseType: ResponseType.bytes,
        ),
    );

    static Future<Response> getWithHeaderSet(String url, {data, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            headers: headers ?? buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieSet(String url, {data, cookies}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? buildPHPSESSIDCookies(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> getWithCookieAndHeaderSet(String url, {data, cookies, headers}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
            cookies: cookies ?? buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: headers ?? buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> post(String url, {data}) async => await dio.post(
        url,
        data: data,
    );

    static Future<Response> postWithCookieSet(String url, {data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: buildPHPSESSIDCookies(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> postWithCookieAndHeaderSet(String url, {cookies, headers, data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            cookies: cookies ?? buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: headers ?? buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> deleteWithCookieAndHeaderSet(String url, {data}) async => await dio.delete(
        url,
        data: data,
        options: Options(
            cookies: buildPHPSESSIDCookies(UserAPI.currentUser.sid),
            headers: buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Map<String, dynamic> buildPostHeaders(sid) {
        Map<String, String> headers = {
            "CLOUDID": "jmu",
            "CLOUD-ID": "jmu",
            "UAP-SID": sid,
        };
        if (Platform.isIOS) {
            headers["WEIBO-API-KEY"] = Constants.postApiKeyIOS;
            headers["WEIBO-API-SECRET"] = Constants.postApiSecretIOS;
        } else if (Platform.isAndroid) {
            headers["WEIBO-API-KEY"] = Constants.postApiKeyAndroid;
            headers["WEIBO-API-SECRET"] = Constants.postApiSecretAndroid;
        }
        return headers;
    }
    static List<Cookie> buildPHPSESSIDCookies(sid) => [Cookie("PHPSESSID", sid)];
}
