import 'package:intl/intl.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/utils/net_utils.dart';


class SignAPI {
    static Future requestSign() async => NetUtils.postWithCookieAndHeaderSet(API.sign);
    static Future getSignList() async => NetUtils.postWithCookieAndHeaderSet(
        API.signList,
        data: {"signmonth": "${DateFormat("yyyy-MM").format(DateTime.now())}"},
    );
    static Future getTodayStatus() async => NetUtils.postWithCookieAndHeaderSet(API.signStatus);
    static Future getSignSummary() async => NetUtils.postWithCookieAndHeaderSet(API.signSummary);
}
