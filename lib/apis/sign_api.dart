import 'package:intl/intl.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/utils/net_utils.dart';


class SignAPI {
    static Future requestSign() async => NetUtils.postWithHeaderSet(API.sign);
    static Future getSignList() async => NetUtils.postWithHeaderSet(
        API.signList,
        data: {"signmonth": "${DateFormat("yyyy-MM").format(DateTime.now())}"},
    );
    static Future getTodayStatus() async => NetUtils.postWithHeaderSet(API.signStatus);
    static Future getSignSummary() async => NetUtils.postWithHeaderSet(API.signSummary);
}
