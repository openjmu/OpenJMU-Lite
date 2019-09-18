import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
                Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: isLogin ? 300 : 1000),
                        pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
                            return FadeTransition(
                                opacity: animation,
                                child: isLogin ? MainPage() : LoginPage(),
                            );
                        },
                    ), (Route<dynamic> route) => false,
                );
            } catch (e) {
                debugPrint("$e");
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Container(
            color: Colors.white,
            child: Center(
                child: SvgPicture.asset(
                    "images/splash_page_logo.svg",
                    color: Constants.appThemeColor,
                    width: 120.0,
                    height: 120.0,
                ),
            ),
        );
    }
}
