import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openjmu_lite/constants/configs.dart';


class NewLoginPage extends StatefulWidget {
    @override
    _NewLoginPageState createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
    bool _keyboardAppeared = false;
    double _indicatorValue = 0.5;

    void setAlignment(context) {
        if (MediaQuery.of(context).viewInsets.bottom != 0.0 && !_keyboardAppeared) {
            setState(() {
                _keyboardAppeared = true;
            });
        } else if (MediaQuery.of(context).viewInsets.bottom == 0.0 && _keyboardAppeared) {
            setState(() {
                _keyboardAppeared = false;
            });
        }
    }

    @override
    Widget build(BuildContext context) {
        setAlignment(context);
        return Scaffold(
            body: SafeArea(
                child: Center(
                    child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                            SizedBox(
                                width: 100.0,
                                height: 100.0,
                                child: Stack(
                                    children: <Widget>[
                                        Positioned(
                                            left: 0.0,
                                            top: 0.0,
                                            right: 0.0,
                                            bottom: 0.0,
                                            child: Center(
                                                child: Container(
                                                    constraints: BoxConstraints(
                                                        minWidth: 100.0,
                                                        minHeight: 100.0,
                                                    ),
                                                    child: CircularProgressIndicator(
                                                        value: _indicatorValue,
                                                        strokeWidth: 8,
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Center(
                                            child: Hero(
                                                tag: "logo-svg",
                                                child: SvgPicture.asset(
                                                    "images/splash_page_logo.svg",
                                                    color: Configs.appThemeColor,
                                                    width: 60.0,
                                                    height: 60.0,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
