import 'dart:async';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:openjmu_lite/apis/api.dart';

import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  static void updateCookie() {
    List<Cookie> cookies = [
      Cookie("PHPSESSID", currentUser.sid),
      Cookie("OAPSID", currentUser.sid),
    ];
    cookieJar.saveFromResponse(Uri.parse(API.oap99Host), cookies);
  }

  static void clearCookie() {
    cookieJar.deleteAll();
  }

  static Future<Response<T>> get<T>(String url, {Map<String, dynamic> data}) async =>
      await dio.get<T>(url, queryParameters: data);

  static Future<Response> getBytes(String url, {data}) async => await dio.get(
        url,
        queryParameters: data,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

  static Future<Response<T>> getWithHeaderSet<T>(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async =>
      await dio.get<T>(
        url,
        queryParameters: data,
        options: Options(
          headers: headers ?? buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> post(String url, {data}) async => await dio.post(
        url,
        data: data,
      );

  static Future<Response> postWithHeaderSet(String url, {cookies, headers, data}) async =>
      await dio.post(
        url,
        data: data,
        options: Options(
          headers: headers ?? buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response> deleteWithHeaderSet(String url, {data}) async => await dio.delete(
        url,
        data: data,
        options: Options(
          headers: buildPostHeaders(currentUser.sid),
        ),
      );

  static Future<Response<dynamic>> download(
    String url, {
    Map<String, dynamic> data,
    Map<String, dynamic> headers,
  }) async {
    Response<dynamic> response;
    String path;
    final bool isAllGranted = await checkPermissions(<Permission>[
      Permission.storage,
    ]);
    if (isAllGranted) {
      showToast('开始下载...');
      debugPrint('File start download: $url');
      path = (await getExternalStorageDirectory()).path;
      path += '/' + url.split('/').last.split('?').first;
      try {
        response = await dio.download(
          url,
          path,
          data: data,
          options: Options(
            headers: headers ?? buildPostHeaders(currentUser.sid),
          ),
        );
        debugPrint('File downloaded: $path');
        showToast('下载完成 $path');
        final OpenResult openFileResult = await OpenFile.open(path);
        debugPrint('File open result: ${openFileResult.type}');
        return response;
      } catch (e) {
        debugPrint('File download failed: $e');
        return null;
      }
    } else {
      debugPrint('No permission to download file: $url');
      showToast('未获得存储权限');
      return null;
    }
  }

  static Map<String, dynamic> buildPostHeaders(sid) {
    Map<String, String> headers = {
      "CLOUDID": "jmu",
      "CLOUD-ID": "jmu",
      "UAP-SID": sid,
      "WEIBO-API-KEY": Platform.isIOS ? Constants.postApiKeyIOS : Constants.postApiKeyAndroid,
      "WEIBO-API-SECRET":
          Platform.isIOS ? Constants.postApiSecretIOS : Constants.postApiSecretAndroid,
    };
    return headers;
  }

  static List<Cookie> buildPHPSESSIDCookies(sid) => [Cookie("PHPSESSID", sid)];
}
