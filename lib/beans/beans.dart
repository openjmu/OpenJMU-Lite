import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';

import 'package:openjmu_lite/constants/constants.dart';

part 'beans.g.dart';

part 'changelog.dart';
part 'course.dart';
part 'score.dart';
part 'user.dart';
part 'user_info.dart';
part 'web_app.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
