///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2019-11-08 10:53
///
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:openjmu_lite/constants/constants.dart';

export 'package:provider/provider.dart';
export 'package:openjmu_lite/providers/courses_provider.dart';
export 'package:openjmu_lite/providers/date_provider.dart';
export 'package:openjmu_lite/providers/scores_provider.dart';
export 'package:openjmu_lite/providers/settings_provider.dart';
export 'package:openjmu_lite/providers/themes_provider.dart';
export 'package:openjmu_lite/providers/webapps_provider.dart';

ChangeNotifierProvider<T> buildProvider<T extends ChangeNotifier>(T value) {
  return ChangeNotifierProvider<T>.value(value: value);
}

List<SingleChildWidget> get providers => _providers;

final _providers = [
  buildProvider<CoursesProvider>(CoursesProvider()),
  buildProvider<DateProvider>(DateProvider()..initCurrentWeek()),
  buildProvider<ScoresProvider>(ScoresProvider()),
  buildProvider<SettingsProvider>(SettingsProvider()..init()),
  buildProvider<ThemesProvider>(ThemesProvider()..initTheme()),
  buildProvider<WebAppsProvider>(WebAppsProvider()),
];
