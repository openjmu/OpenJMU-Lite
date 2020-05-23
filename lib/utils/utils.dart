///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-02-24 17:39
///
import 'dart:developer';

import 'package:flutter/foundation.dart';

import 'package:openjmu_lite/constants/constants.dart';

export 'channel_utils.dart';
export 'cache_utils.dart';
export 'data_utils.dart';
export 'device_utils.dart';
export 'hive_field_utils.dart';
export 'net_utils.dart';
export 'notification_utils.dart';
export 'package_utils.dart';
export 'router_utils.dart';
export 'shared_preference_utils.dart';
export 'socket_utils.dart';
export 'theme_utils.dart';
export 'toast_utils.dart';

/// Log only in debug mode.
/// 只在调试模式打印
void trueDebugPrint(dynamic message) {
  if (!kDebugMode) {
    log('$message');
  }
}

/// Check permissions and only return whether they succeed or not.
Future<bool> checkPermissions(List<Permission> permissions) async {
  try {
    final Map<Permission, PermissionStatus> status =
        await permissions.request();
    return !status.values.any(
      (PermissionStatus p) => p != PermissionStatus.granted,
    );
  } catch (e) {
    trueDebugPrint('Error when requesting permission: $e');
    return false;
  }
}
