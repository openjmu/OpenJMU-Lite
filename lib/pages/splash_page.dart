import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/pages/login_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLogin = false;

  @override
  void initState() {
    super.initState();

    SpUtils.isLogin().then((isLogin) {
      if (isLogin) {
        DataUtils.recoverLoginInfo();
      } else {
        Instances.eventBus.fire(TicketFailedEvent());
      }
    });
    Instances.eventBus
      ..on<TicketGotEvent>().listen((event) async {
        trueDebugPrint("Ticket Got.");
        if (!event.isWizard) {}
        if (this.mounted) {
          isLogin = true;
          navigate();
        }
      })
      ..on<TicketFailedEvent>().listen((event) async {
        trueDebugPrint("Ticket Failed.");
        if (this.mounted) {
          isLogin = false;
          navigate();
        }
      });
  }

  void navigate() {
    try {
      if (isLogin) {
        pushToMain();
      } else {
        pushToLogin();
      }
    } catch (e) {
      trueDebugPrint("$e");
    }
  }

  void pushToMain() {
    navigatorState.pushReplacementNamed(Routes.openjmuLiteMainPage);
  }

  void pushToLogin() {
    Instances.navigatorKey.currentState.pushReplacement(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 1000),
      pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: LoginPage(),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: Themes.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: "logo-svg",
            child: SvgPicture.asset(
              "images/splash_page_logo.svg",
              color: Configs.appThemeColor,
              width: 120.0,
              height: 120.0,
            ),
          ),
        ),
      ),
    );
  }
}
