import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:openjmu_lite/utils/shared_preference_utils.dart';


class ThemeUtils {

    static void setDark(bool isDark) {
        Themes.isDark = isDark;
        spSetBrightnessDark(isDark);
        Constants.eventBus.fire(BrightnessChangedEvent(isDark));
        Constants.navigatorKey.currentState.setState(() {});
    }

    // 获取设置的夜间模式
    static bool spGetBrightnessDark() {
        return SpUtils.sp.getBool(SpUtils.spBrightness);
    }
    // 设置选择的夜间模式
    static Future spSetBrightnessDark(bool isDark) async {
        await SpUtils.sp.setBool(SpUtils.spBrightness, isDark);
    }

}