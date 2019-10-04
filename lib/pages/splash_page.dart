import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openjmu_lite/constants/configs.dart';


import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:openjmu_lite/pages/login_page.dart';
import 'package:openjmu_lite/pages/main_page.dart';
import 'package:openjmu_lite/pages/new_login_page.dart';
import 'package:openjmu_lite/utils/data_utils.dart';
import 'package:openjmu_lite/utils/shared_preference_utils.dart';


class SplashPage extends StatefulWidget {
    @override
    _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
    bool isLogin = false;

    @override
    void initState() {
        SpUtils.isLogin().then((isLogin) {
            if (isLogin) {
                DataUtils.recoverLoginInfo();
            } else {
                Constants.eventBus.fire(TicketFailedEvent());
            }
        });
        Constants.eventBus
            ..on<TicketGotEvent>().listen((event) async {
                debugPrint("Ticket Got.");
                if (!event.isWizard) {}
                if (this.mounted) {
                    isLogin = true;
                    navigate();
                }
            })
            ..on<TicketFailedEvent>().listen((event) async {
                debugPrint("Ticket Failed.");
                if (this.mounted) {
                    isLogin = false;
                    navigate();
                }
            });
        super.initState();
    }

    void navigate() {
        Future.delayed(const Duration(seconds: 3), () {
            try {
                if (isLogin) {
                    pushToMain();
                } else {
                    pushToLogin();
                }
            } catch (e) {
                debugPrint("$e");
            }
        });
    }

    void pushToMain() {
        Constants.navigatorKey.currentState.pushReplacementNamed("/main");
    }

    void pushToLogin() {
        Constants.navigatorKey.currentState.pushReplacement(PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 1000),
            pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                return FadeTransition(
                    opacity: animation,
                    child: NewLoginPage(),
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
