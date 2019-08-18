import 'dart:async';

import 'package:flutter/material.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/pages/login_page.dart';
import 'package:openjmu_lite/pages/main_page.dart';
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
                Navigator.of(context).pushAndRemoveUntil(PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 1000),
                    pageBuilder: (
                            BuildContext context,
                            Animation animation,
                            Animation secondaryAnimation
                            ) => FadeTransition(
                        opacity: animation,
                        child: isLogin ? MainPage() : LoginPage(),
                    ),
                ), (Route<dynamic> route) => false);
            } catch (e) {
                debugPrint("$e");
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Constants.appThemeColor,
            child: Center(
                child: Image.asset(
                    "images/jmu_logo_circle.png",
                    width: 120.0,
                    height: 120.0,
                ),
            ),
        );
    }
}
