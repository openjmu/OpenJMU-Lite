import 'package:flutter/material.dart' show BuildContext;

import 'package:openjmu_lite/beans/beans.dart';

/// Event for testing.
class TestEvent {
  var content;
  TestEvent({content}) {
    this.content = content;
  }
}

class LoginEvent {
  BuildContext context;
  bool isWizard; // 账号是否已通过新人引导
  LoginEvent(BuildContext context, bool isWizard) {
    this.context = context;
    this.isWizard = isWizard;
  }
}

class LogoutEvent {
  BuildContext context;
  LogoutEvent(BuildContext context) {
    this.context = context;
  }
}

class LoginFailedEvent {}

class TicketGotEvent {
  bool isWizard; // 账号是否已通过新人引导
  TicketGotEvent(bool isWizard) {
    this.isWizard = isWizard;
  }
}

class TicketFailedEvent {}

class UserInfoGotEvent {
  UserInfo currentUser;
  UserInfoGotEvent(UserInfo userInfo) {
    this.currentUser = userInfo;
  }
}

class BlacklistUpdateEvent {}

class AppCenterRefreshEvent {
  int currentIndex;

  AppCenterRefreshEvent(int currentIndex) {
    this.currentIndex = currentIndex;
  }
}

class ScoreRefreshEvent {}

class CourseScheduleRefreshEvent {}

class CurrentWeekUpdatedEvent {}

class BrightnessChangedEvent {
  bool isDark;
  BrightnessChangedEvent(bool isDark) {
    this.isDark = isDark;
  }
}
