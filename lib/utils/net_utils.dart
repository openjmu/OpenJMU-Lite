import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:openjmu_lite/apis/api.dart';

import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/constants.dart';


class NetUtils {
    static final Dio dio = Dio();

    static final DefaultCookieJar cookieJar = DefaultCookieJar();
    static final CookieManager cookieManager = CookieManager(cookieJar);

    static void initConfig() async {
        dio.interceptors.add(cookieManager);
        (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
//            client.findProxy = (uri) => "PROXY 192.168.0.101:8088";
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        };
        dio.interceptors.add(cookieManager);
        dio.interceptors.add(InterceptorsWrapper(
            onError: (DioError e) async {
                debugPrint("DioError: ${e.message}");
                return e;
            },
        ));
    }

    static void updateCookie(String url) {
        List<Cookie> cookies = cookieJar.loadForRequest(Uri.parse(url));
        cookieJar.saveFromResponse(Uri.parse(API.oa99Host), cookies);
        cookieJar.saveFromResponse(Uri.parse(API.oap99Host), cookies);
    }

    static void clearCookie() {
        cookieJar.deleteAll();
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

    static Future<Response> post(String url, {data}) async => await dio.post(
        url,
        data: data,
    );

    static Future<Response> postWithHeaderSet(String url, {cookies, headers, data}) async => await dio.post(
        url,
        data: data,
        options: Options(
            headers: headers ?? buildPostHeaders(UserAPI.currentUser.sid),
        ),
    );

    static Future<Response> deleteWithHeaderSet(String url, {data}) async => await dio.delete(
        url,
        data: data,
        options: Options(
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
