import 'dart:async';
import 'package:package_info/package_info.dart';

import 'package:openjmu_lite/constants/constants.dart';

class PackageUtils {
  const PackageUtils._();

  static PackageInfo _packageInfo;
  static PackageInfo get packageInfo => _packageInfo;
  static String get version => _packageInfo.version;
  static int get buildNumber => _packageInfo.buildNumber.toIntOrNull();
  static String get appName => _packageInfo.appName;
  static String get packageName => _packageInfo.packageName;

  static String remoteVersion = version;
  static int remoteBuildNumber = buildNumber;

  static Future<void> initPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
}
