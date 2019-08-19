import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/utils/net_utils.dart';

class DateAPI {
    static DateTime startDate;
    static int currentWeek;
    static int difference;

    static Future getCurrentWeek () async => NetUtils.get(API.firstDayOfTerm);
}
