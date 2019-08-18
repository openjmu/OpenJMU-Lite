import 'package:openjmu_lite/beans/bean.dart';

/// Event for testing.
class TestEvent {
    var content;
    TestEvent({content}) {
        this.content = content;
    }
}

class LoginEvent {
    bool isWizard;  // 账号是否已通过新人引导
    LoginEvent(bool isWizard) {
        this.isWizard = isWizard;
    }
}
class LogoutEvent {}
class LoginFailedEvent {}
class TicketGotEvent {
    bool isWizard;  // 账号是否已通过新人引导
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