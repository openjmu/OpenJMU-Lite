import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:crypto/crypto.dart';
import 'package:event_bus/event_bus.dart';

class Constants {
    static final appTitle = 'OpenJMU Lite';
    static final appThemeColor = Color.fromARGB(0xff, 212, 46, 48);
    static double fontScale = 1.0;
    static double size(double size) => size * fontScale;

    static final EventBus eventBus = EventBus();

    // Fow news list.
    static final int appId = Platform.isIOS ? 274 : 273;
    static final String apiKey = "c2bd7a89a377595c1da3d49a0ca825d5";
    static final String deviceType = Platform.isIOS ? "iPhone" : "android";
    // For posts. Different type of devices (iOS/Android) use different pair of key and secret.
    static final String postApiKeyAndroid = "1FD8506EF9FF0FAB7CAFEBB610F536A1";
    static final String postApiSecretAndroid = "E3277DE3AED6E2E5711A12F707FA2365";
    static final String postApiKeyIOS = "3E63F9003DF7BE296A865910D8DEE630";
    static final String postApiSecretIOS = "773958E5CFE0FF8252808C417A8ECCAB";

    static Map<String, dynamic> loginClientInfo = {
        "appid": Platform.isIOS ? 274 : 273,
        if (Platform.isIOS) "packetid": "",
        "platform": Platform.isIOS ? 40 : 30,
        "platformver": Platform.isIOS ? "2.3.2" : "2.3.1",
        "deviceid": "",
        "devicetype": deviceType,
        "systype": Platform.isIOS ? "iPhone OS" : "Android OS",
        "sysver": Platform.isIOS ? "12.2" : "9.0",
    };

    static Map<String, dynamic> loginParams({
        String blowfish,
        String username,
        String password,
        String ticket,
    }) => {
        "appid": Platform.isIOS ? 274 : 273,
        "blowfish": "$blowfish",
        if (ticket != null) "ticket": "$ticket",
        if (username != null) "account": "$username",
        if (password != null) "password": "${sha1.convert(utf8.encode(password))}",
        if (password != null) "encrypt": 1,
        if (username != null) "unitid": 55,
        if (username != null) "unitcode": "jmu",
        "clientinfo": jsonEncode(loginClientInfo),
    };

    static Widget emptyDivider({double width = 8.0, double height = 8.0}) {
        return SizedBox(
            width: size(width),
            height: size(height),
        );
    }
    /// Progress Indicator. Used in loading data.
    static Widget progressIndicator({
        double strokeWidth = 4.0,
        Color color,
        double value,
    }) => Center(child: Platform.isIOS
            ? CupertinoActivityIndicator()
            : CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
        value: value,
    ));
}